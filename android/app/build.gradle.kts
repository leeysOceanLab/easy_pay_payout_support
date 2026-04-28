plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 保持你的 namespace
    namespace = "com.example.easy_pay_bank_infomrm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    flavorDimensions += "app"

    productFlavors {
         create("staging") {
            dimension = "app"
            applicationId = "com.easypay.bankinfomrm.staging"
            resValue("string", "app_name", "EZ Pay Staging")
        }
        
        create("easyPay") {
            dimension = "app"
            applicationId = "com.easypay.bankinfomrm"
            resValue("string", "app_name", "EZ Pay 辅助系统")
        }

        create("threeSixty") {
            dimension = "app"
            applicationId = "com.easypay.bankinfomrm.threesixty"
            resValue("string", "app_name", "360 辅助系统")
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // 修复警告：使用最新的 compilerOptions 写法
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // 修复报错：将 targetSdk 改为 targetSdkVersion
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 核心脱糖库
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Android Bubbles / Shortcut API
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.core:core-ktx:1.13.1")
}
