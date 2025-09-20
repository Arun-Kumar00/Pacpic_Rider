import java.util.Properties
        import java.io.FileInputStream

        plugins {
            id("com.android.application")
            // START: FlutterFire Configuration
            id("com.google.gms.google-services")
            // END: FlutterFire Configuration
            id("kotlin-android")
            // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
            id("dev.flutter.flutter-gradle-plugin")
        }

// Kotlin way to read properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties") // Use double quotes for strings in Kotlin
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.arunnitd.pacpic_rider"
    compileSdk = flutter.compileSdkVersion // Assuming flutter object is correctly providing this
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") { // Use create for named configurations
            if (keystorePropertiesFile.exists()) {
                // Use .getProperty("keyName") and ensure keys exist in your properties file
                // Also, make sure the values from properties file are correctly typed
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.arunnitd.pacpic_rider"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion // Assuming flutter object is correctly providing this
        versionCode = flutter.versionCode    // Assuming flutter object is correctly providing this
        versionName = flutter.versionName    // Assuming flutter object is correctly providing this
    }

    buildTypes {
        getByName("release") { // Use getByName to configure existing build types
            signingConfig = signingConfigs.getByName("release")
            // You might also want to add other release configurations here, e.g.:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}