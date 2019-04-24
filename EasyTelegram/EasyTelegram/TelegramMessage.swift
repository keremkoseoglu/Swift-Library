//
//  TelegramMessage.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public struct TelegramMessage {
	public var update_id: Int
	public var text: String
	public var date: Int
	
	public init(pUpdateId:Int, pText: String, pDate: Int) {
		update_id = pUpdateId
		text = pText
		date = pDate
	}
}
