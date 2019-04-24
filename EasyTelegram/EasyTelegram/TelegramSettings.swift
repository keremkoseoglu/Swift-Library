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
	public var roomID : String
	
	public init() {
		botName = ""
		botToken = ""
		roomID = ""
	}
}

public class Settings {
	
	private static let KEY_BOT_NAME = "BotName"
	private static let KEY_BOT_TOKEN = "BotToken"
	private static let KEY_ROOM_ID = "RoomID"
	
	public init() {}
	
	public static func getTelegramSettings() -> TelegramSettings {
		var output = TelegramSettings()
		let defaults = UserDefaults.standard
		output.roomID = defaults.string(forKey: Settings.KEY_ROOM_ID) ?? ""
		output.botName = defaults.string(forKey: Settings.KEY_BOT_NAME) ?? ""
		output.botToken = defaults.string(forKey: Settings.KEY_BOT_TOKEN) ?? ""
		return output
	}
	
	public static func setTelegramSettings(_ settings:TelegramSettings) {
		let defaults = UserDefaults.standard
		defaults.set(settings.roomID, forKey:Settings.KEY_ROOM_ID)
		defaults.set(settings.botName, forKey:Settings.KEY_BOT_NAME)
		defaults.set(settings.botToken, forKey:Settings.KEY_BOT_TOKEN)
	}
	
}
