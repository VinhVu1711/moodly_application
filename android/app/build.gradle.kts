plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.moodlyy_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Giữ Java 11 như hiện tại
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // BẬT desugaring cho thư viện core (bắt buộc cho flutter_local_notifications/timezone)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.moodlyy_application"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Ký tạm bằng debug để chạy nhanh (như hiện tại)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ THÊM KHỐI NÀY
dependencies {
    // Cần cho core library desugaring (Java 8 APIs trên Android cũ)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // (Không bắt buộc) Nếu muốn, có thể thêm jdk8 stdlib:
    // implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
