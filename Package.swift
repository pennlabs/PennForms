// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PennForms",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PennForms",
            targets: ["PennForms"]),
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect.git", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PennForms",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "PennFormsTests",
            dependencies: ["PennForms"]),
    ]
)
