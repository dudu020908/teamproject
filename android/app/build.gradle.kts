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

    // 🔹 keystore / key.properties 읽기 (있으면만)
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()

    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { fis ->
            keystoreProperties.load(fis)
        }
    }

    signingConfigs {
        // 기본 debug 서명은 안 건드림

        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = rootProject.file(
                    keystoreProperties["storeFile"] as String
                )
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.teamproject"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // key.properties가 있으면 release 키로, 없으면 debug 서명 사용
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // 필요하면 여기서 minifyEnabled 같은 거 추가
            // isMinifyEnabled = false
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
