//
//  TelegramAnnouncement.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public class TelegramAnnouncement : TelegramTaskWorker, TelegramWorkClient {
	
	private var currentWorkClient: TelegramWorkClient?
	private var message: String
	
	public init(pMessage:String) {message=pMessage}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		currentWorkClient = workClient
		TelegramSendMessage(message).work(taskID: taskID, workClient: self)
	}
	
	////////////////////////////////////////////////////////////
	// Work client
	////////////////////////////////////////////////////////////
	
	public func workCompleted(result: WorkResult) {
		currentWorkClient?.workCompleted(result: result)
	}
	
}
