import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.ahra.partner"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {

        create("release") {

            keyAlias =
                keystoreProperties["keyAlias"] as String

            keyPassword =
                keystoreProperties["keyPassword"] as String

            storeFile = file("key.jks")

            storePassword =
                keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {

        applicationId = "com.ahra.partner"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName

        // 🔥 ADDED
        multiDexEnabled = true
    }

    buildTypes {

        getByName("release") {

            signingConfig =
                signingConfigs.getByName("release")

            isMinifyEnabled = false

            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
apply(plugin = "com.google.gms.google-services")
// 🔥 ADDED
dependencies {

    implementation(
        "com.google.android.gms:play-services-auth:21.2.0"
    )

    implementation(
        "com.google.android.gms:play-services-safetynet:18.1.0"
    )
}