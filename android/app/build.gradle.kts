plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.instant_weather" // Your package name might be different
    compileSdk = 35// Or whatever your compileSdk is

    ndkVersion = "27.0.12077973"

    compileOptions {
        // Use the fully qualified name and toVersion() method for robustness
        sourceCompatibility = org.gradle.api.JavaVersion.toVersion("11")
        targetCompatibility = org.gradle.api.JavaVersion.toVersion("11")
    }

    kotlinOptions {
        jvmTarget = "11" // Ensure this matches the Java version
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.instant_weather"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
