// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [.iOS(.v17), .watchOS(.v10), .macOS(.v14), .visionOS(.v1)],
    products: [
        .library(
            name: "Package",
            targets: [
                "App",
                "AccountFeature",
                "ItemListFeature",
                "SavedItemListFeature",
                "ItemDetailFeature"
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.0.0"),
    ],
    targets: [
        // Entry module
        .target(
            name: "App",
            dependencies: [
                "AccountFeature",
                "ItemListFeature",
                "SavedItemListFeature",
                "ItemDetailFeature"
            ]
        ),

        // Feature modules
        .target(
            name: "AccountFeature",
            dependencies: ["Core"]
        ),
        .target(
            name: "ItemListFeature",
            dependencies: [
                "ItemDetailFeature",
                "ViewComponents",
                "Core"
            ]
        ),
        .target(
            name: "SavedItemListFeature",
            dependencies: [
                "ItemDetailFeature",
                "ViewComponents",
                "Core",
            ]
        ),
        .target(
            name: "ItemDetailFeature",
            dependencies: [
                "Core",
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ]
        ),

        .target(
            name: "ViewComponents",
            dependencies: ["Core"]
        ),

        // Core modules
        .target(
            name: "Core",
            dependencies: [
                "APIClient",
                "Database",
                "KeychainAccess",
            ]
        ),
        .target(name: "APIClient"),
        .target(name: "Database"),
    ]
)
