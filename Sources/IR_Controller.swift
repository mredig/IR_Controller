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

	private static let data: [UInt8] = [
		180, 80, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 30, 10, 30, 10, 30, 10, 30,
		10, 30, 10, 30, 10, 30, 10, 30, 10, 30, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
		10, 30, 10, 30, 10, 30, 10, 30, 10, 30, 10, 30, 10, 30, 10
	]

	private static let timer = PrecisionTimer()

	mutating func run() async throws {
//		guard
//			let pwm = pwms?[1]?[.P13]
//		else { throw IRError.noPWM }

//		pwm.initPWM()

		guard
			let pin = gpios[.P13]
		else { throw IRError.noGPIO }
		pin.direction = .OUT

		while true {
			print("Start")
			nonsignal(pin: pin)
			print("Stop")
			sleep(2)
		}

//		while true {
//			print("sending")
//			pwm.initPWMPattern(bytes: Self.data.count, at: 38000, with: 6000, dutyzero: 66, dutyone: 33)
//
//			pwm.sendDataWithPattern(values: Self.data)
//			pwm.waitOnSendData()
//			pwm.cleanupPattern()
////			signal(pwm: pwm)
//			print("sent")
//			sleep(1)
//		}

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

	func nonsignal(pin: GPIO) {
		let timer = Self.timer

		pin.value = 0
		var passage: [(Int, Bool)] = .init(unsafeUninitializedCapacity: 100) { buffer, initializedCount in
			initializedCount = 0
		}
		passage.append((timer.getTime(), false))

		let nsData = Self.data.map { Int($0) * 1000 }

		var shouldPulse = true
		for datum in nsData {
			let dataStart = timer.getTime()
			let timerEnd = dataStart + datum
			defer { shouldPulse.toggle() }
			
			var isOn = false
			var currentTime = timer.getTime()
			var lastPulse = currentTime
			while currentTime < timerEnd {
				defer { currentTime = timer.getTime() }
				passage.append((currentTime, isOn))
				guard shouldPulse else { continue }
				guard currentTime > lastPulse + 13158 else { continue }
				pin.value = isOn ? 0 : 1
				isOn.toggle()
				lastPulse = currentTime
			}
			pin.value = 0
		}






//		for i in 0..<50 {
//			pin.value = 1
//			passage.append((Self.timer.getTime(), true))
//			pin.value = 0
//			passage.append((Self.timer.getTime(), false))
//		}

		var previousTime = passage[0].0
		for (time, isOn) in passage[1...] {
			let elapsed = time - previousTime
//			print("\(elapsed) nanoseconds, \(isOn)")
			print("\(elapsed / 1000) microseconds, \(isOn)")
			previousTime = time
		}
		print("\((passage.last!.0 - passage.first!.0) / 1000) total")
	}

//	private func lut(_ time: Int, table: Table) {
//
//	}

//	class Table {
//		let timer: PrecisionTimer
//
//		let startTime: Int
//		let microsecondData: [UInt8]
//		let firstPulseIsOn: Bool
//		let hertz: Int
//
//		let lut: [(Int, Bool)]
//
//		init(timer: PrecisionTimer, microsecondData: [UInt8], firstPulseIsOn: Bool, hertz: Int) {
//			self.timer = timer
//			self.microsecondData = microsecondData
//			self.firstPulseIsOn = firstPulseIsOn
//			self.hertz = hertz
//
//			let nsPeriod = (1.0 * 1_000_000_000) / Double(hertz)
//			let halfPeriod = nsPeriod / 2
//
//			let timeNow = timer.getTime()
//			self.startTime = timeNow
//
//			let delay = 2000
//
//			var currentPulse = firstPulseIsOn
//			var values: [(Int, Bool)] = []
//			var timeTracker = timeNow + delay
//			for datum in microsecondData {
//				let pulse = (Int(datum) * 1000) / hertz
//				for i in 0..<hertz {
//					values.append((timeTracker, currentPulse))
//
//					timeTracker += nsPrecision
//				}
//
//			}
//		}
//	}

//	func signal(pwm: PWMOutput) {
//		let data = Self.data.map { $0 * 1000 }
//
//		var ts = timespec()
//
//		var isOn = false
//
//		var passage: [Int] = .init(unsafeUninitializedCapacity: 100) { buffer, initializedCount in
//			initializedCount = 0
//		}
//		clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
//		passage.append(ts.tv_nsec)
//
//		for period in data {
//			defer {
//				clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
//				passage.append(ts.tv_nsec)
//			}
//
//			if isOn {
//				isOn = false
//				pwm.stopPWM()
//				delay(period)
//			} else {
//				isOn = true
//				pwm.startPWM(period: 26316, duty: 50)
//				delay(period)
//			}
//		}
//		pwm.stopPWM()
////		print("Starting")
////		pwm.startPWM(period: 26316, duty: 50)
////		sleep(2)
////		print("Stopping")
////		pwm.stopPWM()
////		sleep(2)
////		pwm.waitOnSendData()
//		var previousTime = 0
//		for time in passage {
//			let elapsed = time - previousTime
////			print("\(elapsed) ns")
//			print("\(elapsed / 1000) microseconds")
//			previousTime = time
//		}
//		let expected = data.reduce(0, +)
//		print("\((passage.last! - passage.first!) / 1000) total, \(expected / 1000) expected")
//	}

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
		case noGPIO
	}

	class PrecisionTimer {
		private var ts = timespec()

		func getTime() -> Int {
			clock_gettime(CLOCK_MONOTONIC_RAW, &ts)
			return ts.tv_nsec
		}
	}
}
