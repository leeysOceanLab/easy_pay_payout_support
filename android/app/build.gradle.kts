plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
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
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
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

flutter {
    source = "../.."
}