import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.teamproject"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

signingConfigs {
    create("release") {
        val keystoreFile = rootProject.file("key.properties")

        val keystoreProperties = Properties().apply {
            load(FileInputStream(keystoreFile))
        }

        storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
    }
}

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.teamproject"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   buildTypes {
        getByName("release") {
            // keystore가 제대로 읽히면 release 키로, 아니면 그냥 디폴트(=debug 키)로 서명
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
flutter {
    source = "../.."
}
dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("com.google.android.material:material:1.12.0")
}