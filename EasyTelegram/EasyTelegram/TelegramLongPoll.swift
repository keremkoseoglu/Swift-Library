//
//  TelegramLongPoll.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyHTTP

public class TelegramLongPoll: TelegramTaskWorker, HttpClient {
	
	private static var singleton: TelegramLongPoll!
	private static var maxHistoryCount = 1000
	
	private var workResult: WorkResult!
	private var currentWorkClient: TelegramWorkClient?
	private var channelMessages: [TelegramMessage]
	private var offset: Int
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	private init() {
		channelMessages = [TelegramMessage]()
		offset = 0
	}
	
	public static func getInstance() -> TelegramLongPoll {
		if singleton == nil { singleton = TelegramLongPoll() }
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		workResult = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		TelegramHttp.getGroupMessages(offset: offset, httpClient: self)
	}
	
	////////////////////////////////////////////////////////////
	// HTTP
	////////////////////////////////////////////////////////////
	
	public func handle_http_error(error: Error) {
		workResult.error = error.localizedDescription
		currentWorkClient?.workCompleted(result: workResult)
	}
	
	public func handle_http_response(json: [String : Any]) {
		parseGetUpdatesResult(json)
		shrinkChannelMessages()
		workResult.success = json["ok"] as? Bool ?? false
		workResult.error = json["description"] as? String ?? ""
		currentWorkClient?.workCompleted(result: workResult)
	}
	
	private func parseGetUpdatesResult(_ json: [String : Any]) {
		let ok = json["ok"] as? Bool ?? false
		if !ok { return }
		
		guard let resultArray = json["result"] as? [[String: Any]] else { return }
		for result in resultArray {
			guard let channel_post = result["channel_post"] as? [String: Any] else { continue }
			let update_id = result["update_id"] as? Int ?? 0
			let text = channel_post["text"] as? String ?? ""
			let date = channel_post["date"] as? Int ?? 0
			let tm = TelegramMessage(
				pUpdateId: update_id,
				pText: text,
				pDate: date
			)
			channelMessages.append(tm)
			if update_id > offset { offset = update_id }
		}
		
	}
	
	////////////////////////////////////////////////////////////
	// Selfie
	////////////////////////////////////////////////////////////
	
	public func getLatestDate() -> Int {
		if channelMessages.count <= 0 {return 0}
		return channelMessages[channelMessages.count-1].date
	}
	
	public func getMessages() -> [TelegramMessage] {return channelMessages}
	
	private func shrinkChannelMessages() {
		while channelMessages.count > TelegramLongPoll.maxHistoryCount { channelMessages.remove(at: 0) }
	}
	
}
