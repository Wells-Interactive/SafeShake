plugins {
    id("com.android.application")

    // Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")

    // Flutter
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wellsint.brainyte.safeshake"

    // Required by flutter_local_notifications 23.0.0
    compileSdk = 37

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.wellsint.brainyte.safeshake"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug signing retained for testing.
            // Replace with your Brainyte release signing configuration
            // before publishing to production.
            signingConfig = signingConfigs.getByName("debug")

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
    // Required by flutter_local_notifications 23.0.0
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}
