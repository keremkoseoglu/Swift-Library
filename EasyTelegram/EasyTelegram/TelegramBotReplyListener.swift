//
//  TelegramBotReplyListener.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public struct TelegramBotReplyValue {
	let key: String
	let val: String
	
	public init(pKey:String, pVal:String) {
		key = pKey
		val = pVal
	}
}

public class TelegramBotReply {
	var command: String
	var repliedValues: [TelegramBotReplyValue]
	
	public init() {
		command = ""
		repliedValues = [TelegramBotReplyValue]()
	}
	
	public func getValue(_ key: String) -> String {
		for rv in repliedValues { if rv.key == key {return rv.val} }
		return ""
	}
}

public protocol TelegramBotReplyListenerClient {
	func botReply(botID: String, success:Bool, reply:TelegramBotReply, error:String)
}

public class TelegramBotReplyListener {
	
	private static var TIME_INTERVAL: Double = 3
	private static var MAX_TICK = 10
	
	private var longPoll: TelegramLongPoll
	private var latestDateBeforeParse: Int
	private var expectedBotReply: String
	private var expectedBotID: String
	private var client: TelegramBotReplyListenerClient
	private var taskTimer: Timer!
	private var checkingLongPoll: Bool!
	private var longPollCheckCount: Int!
	private var botReply: TelegramBotReply!
	
	////////////////////////////////////////////////////////////
	// Public interface
	////////////////////////////////////////////////////////////
	
	public init(botReply:String, botID:String, pClient: TelegramBotReplyListenerClient) {
		longPoll = TelegramLongPoll.getInstance()
		latestDateBeforeParse = longPoll.getLatestDate()
		expectedBotReply = botReply
		expectedBotID = botID
		client = pClient
	}
	
	public func listen() {
		if (taskTimer != nil && taskTimer.isValid) {return}
		
		checkingLongPoll = false
		longPollCheckCount = 0
		botReply = TelegramBotReply()
		
		DispatchQueue.main.async {
			self.taskTimer = Timer.scheduledTimer(
				withTimeInterval: TelegramBotReplyListener.TIME_INTERVAL,
				repeats: true,
				block: { taskTimer in self.timerTick() }
			)
		}
	}
	
	////////////////////////////////////////////////////////////
	// Timer stuff
	////////////////////////////////////////////////////////////
	
	private func timerTick() {
		
		// Prevent duplicates
		if (checkingLongPoll) {return}
		checkingLongPoll = true
		
		// Prevent timeout
		longPollCheckCount += 1
		if longPollCheckCount > TelegramBotReplyListener.MAX_TICK {
			stopListening()
			client.botReply(botID: expectedBotID, success: false, reply: botReply, error: "Timeout")
			return
		}
		
		// Work
		readPoll()
		
		// Enable method again
		checkingLongPoll = false
	}
	
	private func stopListening() {
		taskTimer.invalidate()
		checkingLongPoll = false
	}
	
	////////////////////////////////////////////////////////////
	// Poll stuff
	////////////////////////////////////////////////////////////
	
	private func parseBotReplyText(_ text:String) -> TelegramBotReply {
		let output = TelegramBotReply()
		
		let splitText = text.split(separator: " ")
		if splitText.count <= 0 {return output}
		
		var first = true
		
		for word in splitText {
			if first {
				if word.prefix(1) == "/" {output.command = String(word)}
			}
			else {
				let keyVal = word.split(separator: ":")
				if keyVal.count == 2 {
					output.repliedValues.append(
						TelegramBotReplyValue(
							pKey: String(keyVal[0]),
							pVal: String(keyVal[1])
						)
					)
				}
			}
			
			first = false
		}
		
		return output
	}
	
	private func readPoll() {
		
		let messages = longPoll.getMessages()
		var msgPos = messages.count - 1
		
		while msgPos >= 0 {
			let message = messages[msgPos]
			if message.date <= latestDateBeforeParse {return}
			botReply = parseBotReplyText(message.text)
			
			if  botReply.command == expectedBotReply &&
				botReply.getValue("drone") == expectedBotID {
				
				stopListening()
				client.botReply(botID: expectedBotID, success: true, reply: botReply, error: "")
				return
			}
			
			msgPos = msgPos - 1
		}
	}
	
}
