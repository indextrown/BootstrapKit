// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BootstrapKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "BootstrapKit",
            targets: ["BootstrapKit"]),
        .library(
            name: "BootstrapFirebase",
            targets: ["BootstrapFirebase"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.11.0"
        ),
        .package(
            url: "https://github.com/kakao/kakao-ios-sdk.git",
            from: "2.27.2"
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            from: "9.1.0"
        )
    ],
    targets: [
        // BootstrapKit
        .target(
            name: "BootstrapKit"
        ),
        
        // BootstrapFirebase
        .target(
            name: "BootstrapFirebase",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                
                .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
                
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        ),
        
        // test
        .testTarget(
            name: "BootstrapKitTests",
            dependencies: ["BootstrapKit"]
        ),
    ]
)
