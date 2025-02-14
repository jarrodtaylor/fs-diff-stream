// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "FSDiffStream",
  platforms: [.macOS(.v13)],
  products: [.library(name: "FSDiffStream", targets: ["FSDiffStream"])],
  targets: [.target(name: "FSDiffStream")]
)