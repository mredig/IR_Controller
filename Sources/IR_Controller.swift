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
			print("sending")
			signal(pwm: pwm)
			print("sent")
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
		let data: [UInt32] = [
			180,  80,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10,  30,  10
		].map { $0 * 1000 }

		var ts = timespec()

		var isOn = false

		var passage: [Int] = []
		for period in data {
			defer {
				clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
				passage.append(ts.tv_nsec)
			}

			if isOn {
				isOn = false
				pwm.stopPWM()
				delay(period)
			} else {
				isOn = true
				pwm.startPWM(period: 26316, duty: 50)
				delay(period)
			}
		}
		pwm.stopPWM()
//		print("Starting")
//		pwm.startPWM(period: 26316, duty: 50)
//		sleep(2)
//		print("Stopping")
//		pwm.stopPWM()
//		sleep(2)
//		pwm.waitOnSendData()
		var previousTime = 0
		for time in passage {
			let elapsed = time - previousTime
//			print("\(elapsed) ns")
			print("\(elapsed / 1000) microseconds")
			previousTime = time
		}
		let expected = data.reduce(0, +)
		print("\((passage.last! - passage.first!) / 1000) total, \(expected / 1000) expected")
	}

	@inline(__always)
	private func delay(_ nanoseconds: UInt32) {
		var ts = timespec()
		
		clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
		let startTime = ts.tv_nsec

		var passedTime = 0

		while passedTime < nanoseconds {
			clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
			passedTime = ts.tv_nsec - startTime
		}
	}

	enum IRError: Error {
		case noPWM
	}
}
