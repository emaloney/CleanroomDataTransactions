// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CleanroomDataTransactions",
    products: [
        .library(
            name: "CleanroomDataTransactions",
            targets: ["CleanroomDataTransactions"]
        )
    ],
    targets: [
        .target(
            name: "CleanroomDataTransactions",
            path: "Sources"
        )
    ]
)
