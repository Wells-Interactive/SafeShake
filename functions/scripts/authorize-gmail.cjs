const { randomBytes } = require("node:crypto");
const { createServer } = require("node:http");
const { readFile } = require("node:fs/promises");
const { OAuth2Client } = require("google-auth-library");

const redirectUri = "http://localhost:3000/oauth2callback";
const scope = "https://www.googleapis.com/auth/gmail.send";

async function main() {
  const credentialsPath = process.argv[2];
  if (!credentialsPath) {
    throw new Error(
      "Usage: node scripts/authorize-gmail.cjs /path/to/client_secret.json",
    );
  }

  const credentialsFile = JSON.parse(await readFile(credentialsPath, "utf8"));
  const isWebClient = Boolean(credentialsFile.web);
  const credentials = credentialsFile.web ?? credentialsFile.installed;
  if (!credentials?.client_id || !credentials?.client_secret) {
    throw new Error(
      "The JSON must contain a web or installed OAuth client with a client_id and client_secret.",
    );
  }
  if (isWebClient && !credentials.redirect_uris?.includes(redirectUri)) {
    throw new Error(
      `Add ${redirectUri} to this web OAuth client's authorized redirect URIs, then retry.`,
    );
  }

  const oauth = new OAuth2Client(
    credentials.client_id,
    credentials.client_secret,
    redirectUri,
  );
  const state = randomBytes(24).toString("hex");

  const server = createServer(async (request, response) => {
    const callback = new URL(request.url ?? "/", redirectUri);
    if (callback.pathname !== "/oauth2callback") {
      response.writeHead(404).end("Not found");
      return;
    }
    if (callback.searchParams.get("state") !== state) {
      response.writeHead(400).end("OAuth state did not match.");
      return;
    }

    const code = callback.searchParams.get("code");
    if (!code) {
      response.writeHead(400).end("Google did not return an authorization code.");
      return;
    }

    response.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    response.end("Gmail authorization complete. Return to the terminal.");
    server.close();

    try {
      const { tokens } = await oauth.getToken(code);
      if (!tokens.refresh_token) {
        throw new Error(
          "Google did not return a refresh token. Revoke this app's access in your Google Account, then rerun the script.",
        );
      }
      process.stdout.write(
        `\nGMAIL_REFRESH_TOKEN (keep secret):\n${tokens.refresh_token}\n`,
      );
      process.stdout.write(
        "Copy this value directly into Firebase Secret Manager. Do not commit or share it.\n",
      );
    } catch (error) {
      process.exitCode = 1;
      console.error("Could not complete Gmail OAuth:", error.message);
    }
  });

  server.listen(3000, "127.0.0.1", () => {
    const url = oauth.generateAuthUrl({
      access_type: "offline",
      prompt: "consent",
      scope: [scope],
      state,
    });
    console.log("Open this URL in a browser signed in as the Gmail sender:\n");
    console.log(url);
    console.log("\nWaiting for Google's redirect on localhost:3000...");
  });

  server.setTimeout(5 * 60 * 1000, () => {
    server.close();
    console.error("Authorization timed out after five minutes.");
    process.exitCode = 1;
  });
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
