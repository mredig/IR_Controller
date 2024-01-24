import ArgumentParser
import Foundation
import Hummingbird
import ServerLibrary
#if os(Linux)
import Glibc
#else
import Darwin
#endif

@main
struct IR_Controller: ParsableCommand {

	@Argument(help: "Path to serial port. For example, \"/dev/cu.usbmodem*\".")
	var path: String

	@Option(name: .shortAndLong)
	var hostname = "127.0.0.1"

	@Option(name: .shortAndLong)
	var port = 8080

	mutating func run() throws {
		let configuration = HBApplication.Configuration(address: .hostname(hostname, port: port), serverName: "IR_Controller")
		let app = HBApplication(configuration: configuration)

		try app.configure(serialPortPath: path, baudRate: .baud115200)
		try app.start()

		app.wait()
	}
}
