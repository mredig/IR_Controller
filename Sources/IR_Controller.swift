import ArgumentParser
import SwiftyGPIO
#if os(Linux)
import Glibc
#else
import Darwin
#endif

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi4)

@main
struct IR_Controller: AsyncParsableCommand {

	mutating func run() async throws {
		gpios[.P4]?.direction = .OUT
		print("Hello, world!")

		while true {
			gpios[.P4]?.value = 1
			sleep(1)
			gpios[.P4]?.value = 0
			sleep(1)
		}
	}
}
