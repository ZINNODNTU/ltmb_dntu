plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.my_note"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.my_note"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    // **QUAN TRỌNG: Sử dụng Firebase BoM (Bill of Materials) để quản lý phiên bản**
    // Hãy kiểm tra phiên bản mới nhất trên trang tài liệu Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))

    implementation("com.google.firebase:firebase-analytics-ktx") // Cho Google Analytics
    implementation("com.google.firebase:firebase-auth-ktx")      // Cho Firebase Authentication

}
// --->>> KẾT THÚC KHỐI DEPENDENCIES <<<---

flutter {
    source = "../.."
}

