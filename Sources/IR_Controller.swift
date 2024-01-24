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
		guard
			let pwm = pwms?[1]?[.P13]
		else { throw IRError.noPWM }

		pwm.initPWM()

		while true {
//			pwm?.initPWMPattern(bytes: data.count, at: 38000, with: 6000, dutyzero: 33, dutyone: 66)
//
//			pwm?.sendDataWithPattern(values: data)
//			pwm?.waitOnSendData()
//			pwm?.cleanupPattern()
			signal(pwm: pwm)
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

	func signal(pwm: PWMOutput) {
//		let data: [UInt32] = [
//			180,  80,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10
//		].map { $0 * 1000 }
//		var isOn = false
//
//		for period in data {
//			if isOn {
//				isOn = false
//				pwm.stopPWM()
//				usleep(period)
//			} else {
//				isOn = true
//				pwm.startPWM(period: 26316, duty: 50)
//				usleep(period)
//			}
//		}
		print("Starting")
		pwm.startPWM(period: 26316, duty: 50)
		sleep(2)
		print("Stopping")
		pwm.stopPWM()
		sleep(2)
		pwm.waitOnSendData()
	}

	enum IRError: Error {
		case noPWM
	}
}
