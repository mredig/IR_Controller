// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "IR_Controller",
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		.package(url: "https://github.com/uraimo/SwiftyGPIO.git", .upToNextMinor(from: "1.4.0"))
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.executableTarget(
			name: "IR_Controller",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"SwiftyGPIO",
			]
		),
	]
)
