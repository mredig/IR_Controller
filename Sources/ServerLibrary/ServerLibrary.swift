import Hummingbird
import HummingbirdFoundation
import SwiftSerial

public extension HBApplication {

	func configure(serialPortPath: String, baudRate: BaudRate = .baud115200) throws {

		let taskTracker = TaskTracker()

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
				<ul>
				<li><a href="/control/on">Turn light on</a></li>
				<li><a href="/control/off">Turn light off</a></li>

				<li><a href="/control/timer/1">Turn light on for 1 minute</a></li>
				<li><a href="/control/timer/5">Turn light on for 5 minutes</a></li>
				</ul>
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

			return HBResponse(
				status: .temporaryRedirect,
				headers: ["Location": "/"],
				body: .empty)
		}

		group.get("off") { _ in
			_ = try serialPort.writeString("off")

			return HBResponse(
				status: .temporaryRedirect,
				headers: ["Location": "/"],
				body: .empty)
		}

		let timerGroup = group.group("timer")

		timerGroup.get(":time") { request in
			guard
				let time = request.parameters.get("time", as: Int.self)
			else { throw HBHTTPError(.badRequest, message: "Invalid time format") }
			_ = try serialPort.writeString("on")

			print("setting timer for \(time) minutes.")

			let newTask = Task {
				try await Task.sleep(for: .seconds(time * 60))

				guard Task.isCancelled == false else {
					return
				}

				_ = try serialPort.writeString("off")
				taskTracker.clearTask()
			}
			taskTracker.setNewTask(newTask)

			return HBResponse(
				status: .temporaryRedirect,
				headers: ["Location": "/"],
				body: .empty)
		}
	}
}
