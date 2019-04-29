//
//  TelegramSettings.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public struct TelegramSettings {
	public var botName: String
	public var botToken: String
	public var roomID: String
	
	public var taskManagerFrequency: Int
	public var pollFrequency: Int
	public var telegramTimeout: Int
	
	public init() {
		botName = ""
		botToken = ""
		roomID = ""
		taskManagerFrequency = 0
		pollFrequency = 0
		telegramTimeout = 0
	}
}

public class Settings {
	
	private enum Key: String {
		case botName = "BotName"
		case botToken = "BotToken"
		case roomID = "RoomID"
		case taskManagerFrequency = "TaskManagerFrequency"
		case pollFrequency = "PollFrequency"
		case telegramTimeout = "TelegramTimeout"
		case locationExpire = "LocationExpire"
	}
	
	public init() {}
	
	public static func getTelegramSettings() -> TelegramSettings {
		var output = TelegramSettings()
		let defaults = UserDefaults.standard
		output.roomID = defaults.string(forKey: Settings.Key.roomID.rawValue) ?? ""
		output.botName = defaults.string(forKey: Settings.Key.botName.rawValue) ?? ""
		output.botToken = defaults.string(forKey: Settings.Key.botToken.rawValue) ?? ""
		output.taskManagerFrequency = defaults.integer(forKey: Settings.Key.taskManagerFrequency.rawValue)
		output.pollFrequency = defaults.integer(forKey: Settings.Key.pollFrequency.rawValue)
		output.telegramTimeout = defaults.integer(forKey: Settings.Key.telegramTimeout.rawValue)
		return output
	}
	
	public static func setTelegramSettings(_ settings:TelegramSettings) {
		let defaults = UserDefaults.standard
		defaults.set(settings.roomID, forKey:Settings.Key.roomID.rawValue)
		defaults.set(settings.botName, forKey:Settings.Key.botName.rawValue)
		defaults.set(settings.botToken, forKey:Settings.Key.botToken.rawValue)
		defaults.set(settings.taskManagerFrequency, forKey:Settings.Key.taskManagerFrequency.rawValue)
		defaults.set(settings.pollFrequency, forKey:Settings.Key.pollFrequency.rawValue)
		defaults.set(settings.telegramTimeout, forKey:Settings.Key.telegramTimeout.rawValue)
	}
	
}
