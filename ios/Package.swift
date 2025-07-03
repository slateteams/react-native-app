// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlateReactNative",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SlateReactNative",
            targets: ["SlateReactNative"]
        ),
    ],
    dependencies: [
        // Firebase Suite (Already available via SPM)
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        
        // Third-party libraries (SPM Available)
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.12.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD", from: "1.2.0"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.6.2"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.8.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        
        // Facebook SDK (SPM Available)
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "16.0.0"),
        
        // TODO: Slate dependencies when available via SPM
        // .package(url: "https://github.com/slateteams/ios-fm-lib-spm", from: "1.1.32"),
        // .package(url: "https://github.com/slateteams/ios-fm-rendering-spm", from: "1.2.5"),
        // .package(url: "https://github.com/slateteams/ios-fm-sharing-spm", from: "1.1.10"),
    ],
    targets: [
        .target(
            name: "SlateReactNative",
            dependencies: [
                // Firebase Suite
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                
                // Third-party libraries
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                
                // Facebook SDK
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookShare", package: "facebook-ios-sdk"),
                
                // TODO: Add Slate dependencies when available
                // "FMCore",
                // "FMRendering", 
                // "FMSharing",
                // "FMTextView",
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
    ]
) 