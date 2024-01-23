import ArgumentParser

@main
struct IR_Controller: AsyncParsableCommand {
	mutating func run() async throws {
		print("Hello, world!")
	}
}
