//
//  TelegramHttp.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyHTTP

public class TelegramHttp {
	
	public static func getFile(fileID: String, httpClient:HttpClient) {
		let ts = Settings.getTelegramSettings()
		let url = "https://api.telegram.org/bot" + ts.botToken + "/getFile"
		
		Http().get(
			client: httpClient,
			parameters: ["file_id": fileID],
			url: url
		)
	}
	
	public static func getFileUrl(_ filePath: String) -> String {
		let ts = Settings.getTelegramSettings()
		return "https://api.telegram.org/file/bot" + ts.botToken + "/" + filePath
	}
	
	public static func getGroupAdminList(httpClient:HttpClient) {
		let ts = Settings.getTelegramSettings()
		let url = "https://api.telegram.org/bot" + ts.botToken + "/getChatAdministrators"
		
		Http().get(
			client: httpClient,
			parameters: ["chat_id": "-" + ts.roomID],
			url: url
		)
	}
	
	public static func getGroupMessages(offset:Int=0, httpClient:HttpClient) {
		let ts = Settings.getTelegramSettings()
		let url = "https://api.telegram.org/bot" + ts.botToken + "/getUpdates"
		var parameters = [String:String]()
		if offset != 0 {
			let readOffset = offset + 1
			parameters = ["offset":String(readOffset)]
		}
		
		Http().get(
			client: httpClient,
			parameters: parameters,
			url: url
		)
	}
	
	public static func sendMessageToRoom(_ message:String, httpClient:HttpClient, specialRecipient:String="") {
		let ts = Settings.getTelegramSettings()
		let url = "https://api.telegram.org/bot" + ts.botToken + "/sendMessage"
		
		var chat_id = ""
		if specialRecipient == "" {chat_id = "-" + ts.roomID} else {chat_id = specialRecipient}
		
		Http().get(
			client: httpClient,
			parameters: [
				"chat_id": chat_id,
				"text": message
			],
			url: url
		)
	}
	
}
