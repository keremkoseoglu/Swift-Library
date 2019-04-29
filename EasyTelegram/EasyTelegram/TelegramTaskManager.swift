//
//  TelegramTaskManager.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public struct WorkResult {
	
	public var taskID: String
	public var success: Bool
	public var error: String
	
	public init(pTaskID: String, pSuccess: Bool, pError: String) {
		taskID = pTaskID
		success = pSuccess
		error = pError
	}
	
}

public protocol TelegramTaskClient {
	func taskCompleted(result: WorkResult)
}

public protocol TelegramWorkClient {
	func workCompleted(result: WorkResult)
}

public protocol TelegramTaskWorker {
	func work(taskID: String, workClient: TelegramWorkClient?)
}

public struct TelegramTask {
	
	public var id: String
	public var client: TelegramTaskClient?
	public var worker: TelegramTaskWorker
	
	public init(pTaskID: String="", pClient:TelegramTaskClient?, pWorker: TelegramTaskWorker) {
		var tid = pTaskID
		if tid == "" { tid = UUID().uuidString }
		
		id = tid
		client = pClient
		worker = pWorker
	}
	
}

public class TelegramTaskManager: TelegramWorkClient {
	
	private static var DEFAULT_TIME_INTERVAL: Double = 1
	
	private var tasks: [TelegramTask]
	private var processingTasks: Bool
	private var taskTimer: Timer!
	private var timerActive: Bool
	private var currentTask: TelegramTask!
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	public init() {
		tasks = [TelegramTask]()
		processingTasks = false
		timerActive = false
		resume()
	}
	
	////////////////////////////////////////////////////////////
	// Main public functionality
	////////////////////////////////////////////////////////////
	
	public func addTask(_ task:TelegramTask) {
		tasks.append(task)
		resume()
	}
	
	public func pause() {
		if (!timerActive) { return }
		taskTimer.invalidate()
		timerActive = false
	}
	
	public func resume() {
		if (timerActive) { return }
		
		var actualInterval = Double(Settings.getTelegramSettings().taskManagerFrequency)
		if actualInterval <= 0 {actualInterval = TelegramTaskManager.DEFAULT_TIME_INTERVAL}
		
		taskTimer = Timer.scheduledTimer(
			withTimeInterval: actualInterval,
			repeats: true,
			block: { taskTimer in self.processNextTask() }
		)
		
		timerActive = true
		
		processNextTask() // Let's not wait for 1 second on first command
	}
	
	////////////////////////////////////////////////////////////
	// Internal stuff
	////////////////////////////////////////////////////////////
	
	private func processNextTask() {
		
		if processingTasks { return }
		if tasks.count <= 0 { return }
		
		processingTasks = true
		currentTask = tasks[0]
		currentTask.worker.work(taskID:currentTask.id, workClient:self)
	}
	
	////////////////////////////////////////////////////////////
	// Work completed
	////////////////////////////////////////////////////////////
	
	public func workCompleted(result: WorkResult) {
		
		
		currentTask.client?.taskCompleted(result: result)
		tasks.remove(at: 0)
		processingTasks = false
		processNextTask()
	}
	
}
