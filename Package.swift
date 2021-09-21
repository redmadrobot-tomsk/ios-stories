// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

 import PackageDescription

 let package = Package(
   name: "KODEiOSStories",
   defaultLocalization: "en",
   platforms: [
     .iOS(.v11)
   ],
   products: [
     .library(
       name: "KODEiOSStories",
       targets: ["KODEiOSStories"])
   ],
   dependencies: [
     .package(url: "https://github.com/onevcat/Kingfisher", from: "6.0.0"),
     .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.0")
   ],
   targets: [
     .target(
       name: "KODEiOSStories",
       dependencies: ["Kingfisher", "SnapKit"],
       path: "Sources")
   ]
 )
