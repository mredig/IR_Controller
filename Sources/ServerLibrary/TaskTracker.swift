import Foundation

class TaskTracker {
	private var currentTask: Task<Void, Error>?

	func setNewTask(_ task: Task<Void, Error>) {
		if let currentTask {
			currentTask.cancel()
			self.currentTask = nil
		}

		currentTask = task
	}

	func clearTask() {
		currentTask = nil
	}
}
