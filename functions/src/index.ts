import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { google } from "googleapis";

initializeApp();

const gmailClientId = defineSecret("GMAIL_CLIENT_ID");
const gmailClientSecret = defineSecret("GMAIL_CLIENT_SECRET");
const gmailRefreshToken = defineSecret("GMAIL_REFRESH_TOKEN");
const gmailSendScope = "https://www.googleapis.com/auth/gmail.send";
const emailPattern = /^[^\s@,<>]+@[^\s@,<>]+\.[^\s@,<>]+$/;
const maxMessageLength = 5000;

export const sendEmergencyAlert = onCall(
  {
    region: "europe-west1",
    secrets: [gmailClientId, gmailClientSecret, gmailRefreshToken],
    timeoutSeconds: 60,
    maxInstances: 2,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in before sending an alert.");
    }

    const message = request.data?.message;
    if (
      typeof message !== "string" ||
      message.trim().length === 0 ||
      message.length > maxMessageLength
    ) {
      throw new HttpsError("invalid-argument", "The emergency message is invalid.");
    }

    const contacts = await getFirestore()
      .collection("users")
      .doc(uid)
      .collection("contacts")
      .get();
    const recipients = [
      ...new Set(
        contacts.docs
          .filter((contact) => contact.get("enabled") === true)
          .map((contact) => contact.get("email"))
          .filter(
            (email): email is string =>
              typeof email === "string" && emailPattern.test(email.trim()),
          )
          .map((email) => email.trim()),
      ),
    ];

    if (recipients.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Add an email address to an enabled emergency contact before using email alerts.",
      );
    }

    const auth = new google.auth.OAuth2(
      gmailClientId.value(),
      gmailClientSecret.value(),
    );
    auth.setCredentials({ refresh_token: gmailRefreshToken.value() });
    const gmail = google.gmail({ version: "v1", auth });
    let sentCount = 0;

    for (const recipient of recipients) {
      try {
        const encodedBody = Buffer.from(message, "utf8")
          .toString("base64")
          .match(/.{1,76}/g)
          ?.join("\r\n") ?? "";
        const mimeMessage = [
          `To: ${recipient}`,
          "Subject: SafeShake emergency alert",
          "MIME-Version: 1.0",
          "Content-Type: text/plain; charset=UTF-8",
          "Content-Transfer-Encoding: base64",
          "",
          encodedBody,
        ].join("\r\n");
        const raw = Buffer.from(mimeMessage, "utf8").toString("base64url");

        await gmail.users.messages.send({
          userId: "me",
          requestBody: { raw },
        });
        sentCount++;
      } catch (error) {
        const code =
          typeof error === "object" && error !== null && "code" in error
            ? String(error.code)
            : "unknown";
        logger.error("Gmail API failed to send an emergency alert.", {
          uid,
          code,
        });
      }
    }

    if (sentCount !== recipients.length) {
      throw new HttpsError(
        "internal",
        `Gmail sent ${sentCount} of ${recipients.length} emergency emails.`,
      );
    }

    return { sentCount };
  },
);
