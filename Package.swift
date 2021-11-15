// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

 import PackageDescription

 let package = Package(
   name: "Stories",
   defaultLocalization: "en",
   platforms: [
     .iOS(.v13)
   ],
   products: [
     .library(
       name: "Stories",
       targets: ["Stories"])
   ],
   dependencies: [
     .package(url: "https://github.com/onevcat/Kingfisher", from: "6.0.0"),
     .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.0")
   ],
   targets: [
     .target(
       name: "Stories",
       dependencies: ["Kingfisher", "SnapKit"],
       path: "Sources")
   ]
 )
