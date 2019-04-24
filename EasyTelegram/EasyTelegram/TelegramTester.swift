//
//  TelegramTester.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public class TelegramTester : TelegramTaskWorker, TelegramWorkClient {
	
	private var currentWorkClient: TelegramWorkClient?
	
	public init() {}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		currentWorkClient = workClient
		TelegramSendMessage("/test").work(taskID: taskID, workClient: self)
	}
	
	////////////////////////////////////////////////////////////
	// Work client
	////////////////////////////////////////////////////////////
	
	public func workCompleted(result: WorkResult) {
		currentWorkClient?.workCompleted(result: result)
	}
	
}
