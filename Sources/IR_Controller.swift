import ArgumentParser
import SwiftSerial
import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

@main
struct IR_Controller: ParsableCommand {

	@Argument(help: "Path to serial port. For example, \"/dev/cu.usbmodem*\".")
	var path: String

	mutating func run() throws {
		let serialPort: SerialPort = SerialPort(path: path)
		try serialPort.openPort(toReceive: true, andTransmit: true)

		serialPort.setSettings(receiveRate: .baud115200, transmitRate: .baud115200, minimumBytesToRead: 1)

		Task {
			let readStream = try serialPort.asyncLines()

			for await line in readStream {
				print(line, terminator: "")
			}
		}

		for _ in 0..<20 {
			_ = try serialPort.writeString("on")
			sleep(2)
			_ = try serialPort.writeString("off")
			sleep(2)
		}


		serialPort.closePort()
	}
}
