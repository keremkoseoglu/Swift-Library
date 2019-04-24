//
//  TelegramBotAdminList.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyHTTP

public class TelegramBotAdminList : TelegramTaskWorker, HttpClient {
	
	private var result: WorkResult!
	private var currentWorkClient: TelegramWorkClient?
	public var botAdminList: [String]!
	
	public init() {
	}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		result = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		botAdminList = [String]()
		TelegramHttp.getGroupAdminList(httpClient: self)
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
		if !result.success {
			currentWorkClient?.workCompleted(result: result)
			return
		}
		
		guard let resultArray = json["result"] as? [[String: Any]] else { return }
		for result in resultArray {
			guard let user = result["user"] as? [String: Any] else { continue }
			guard let isBot = user["is_bot"] as? Bool else {continue}
			if !isBot {continue}
			guard let botName = user["username"] as? String else {continue}
			botAdminList.append(botName)
		}
		
		currentWorkClient?.workCompleted(result: result)
	}
	
}
