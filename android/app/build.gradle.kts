import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")

    // Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")

    // Flutter
    id("dev.flutter.flutter-gradle-plugin")
}

// Load Brainyte release signing credentials
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.wellsint.brainyte.safeshake"

    compileSdk = 37

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.wellsint.brainyte.safeshake"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Brainyte release signing configuration
    signingConfigs {
        create("release") {
            val alias = keystoreProperties["keyAlias"] as String?
            val password = keystoreProperties["keyPassword"] as String?
            val storePasswordValue = keystoreProperties["storePassword"] as String?
            val storeFileValue = keystoreProperties["storeFile"] as String?

            if (
                alias.isNullOrBlank() ||
                password.isNullOrBlank() ||
                storePasswordValue.isNullOrBlank() ||
                storeFileValue.isNullOrBlank()
            ) {
                throw GradleException(
                    "Brainyte release signing credentials are missing. " +
                    "Check android/key.properties."
                )
            }

            keyAlias = alias
            keyPassword = password
            this.storePassword = storePasswordValue
            storeFile = file(storeFileValue)
        }
    }

    buildTypes {
        release {
            // IMPORTANT: Use the Brainyte release keystore.
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}
