//
//  TelegramSendMessage.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyHTTP

public class TelegramSendMessage : TelegramTaskWorker, HttpClient {
	
	private var result: WorkResult!
	private var currentWorkClient: TelegramWorkClient?
	private var message: String
	private var specialRecipient: String
	
	public init(_ msg: String, adHocRecipient:String="") {
		message = msg
		specialRecipient = adHocRecipient
	}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		result = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		TelegramHttp.sendMessageToRoom(message, httpClient: self, specialRecipient:specialRecipient)
		
	}
	
	////////////////////////////////////////////////////////////
	// HTTP
	////////////////////////////////////////////////////////////
	
	public func handle_http_error(error: Error) {
		result.error = error.localizedDescription
		currentWorkClient?.workCompleted(result: result)
	}
	
	public func handle_http_response(json: [String : Any]) {
		result.success = json["ok"] as? Bool ?? false
		result.error = json["description"] as? String ?? ""
		currentWorkClient?.workCompleted(result: result)
	}
}
