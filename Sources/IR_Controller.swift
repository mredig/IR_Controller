import ArgumentParser
import SwiftyGPIO
#if os(Linux)
import Glibc
#else
import Darwin
#endif

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi4)
let pwms = SwiftyGPIO.hardwarePWMs(for: .RaspberryPi4)

@main
struct IR_Controller: AsyncParsableCommand {
	mutating func run() async throws {
		let pwm = pwms?[1]?[.P13]

		let data: [UInt8] = [
			180,  80,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10
		]

		while true {
			pwm?.initPWMPattern(bytes: data.count, at: 38000, with: 6000, dutyzero: 33, dutyone: 66)

			pwm?.sendDataWithPattern(values: data)
			pwm?.waitOnSendData()
			pwm?.cleanupPattern()
			sleep(1)
		}

//		gpios[.P4]?.direction = .OUT
//		print("Hello, world!")
//
//		while true {
//			gpios[.P4]?.value = 1
//			sleep(1)
//			gpios[.P4]?.value = 0
//			sleep(1)
//		}
	}
}
