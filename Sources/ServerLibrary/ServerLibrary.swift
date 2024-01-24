import Hummingbird
import HummingbirdFoundation
import SwiftSerial

public extension HBApplication {

	func configure(serialPortPath: String, baudRate: BaudRate = .baud115200) throws {

		let serialPort = SerialPort(path: serialPortPath)
		try serialPort.openPort()

		serialPort.setSettings(
			receiveRate: baudRate,
			transmitRate: baudRate,
			minimumBytesToRead: 1)

		Task {
			let readStream = try serialPort.asyncLines()

			for await line in readStream {
				print(line, terminator: "")
			}
		}

		router.get("/") { _ -> HBResponse in
			let value = """
				<!DOCTYPE html>
				<html lang="en">
				<title>LED Control</title>
				<body>
				<a href="/control/on">Turn light on</a>
				<br>
				<a href="/control/off">Turn light off</a>
				</body>
				</html>
				"""

			return .init(
				status: .ok,
				headers: ["Content-Type": "text/html; charset-utf-8"],
				body: .byteBuffer(.init(string: value)))
		}

		let group = router.group("control")

		group.get("on") { _ in
			_ = try serialPort.writeString("on")

			return ""
		}

		group.get("off") { _ in
			_ = try serialPort.writeString("off")

			return ""
		}
	}
}
