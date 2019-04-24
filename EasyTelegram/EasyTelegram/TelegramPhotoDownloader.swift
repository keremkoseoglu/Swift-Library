//
//  TelegramPhotoDownloader.swift
//  EasyTelegram
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import EasyHTTP

public protocol TelegramPhotoDownloaderClient {
	func downloadComplete(image: UIImage, success:Bool, error:String)
}

public class TelegramPhotoDownloader : HttpClient {
	
	private struct GetFileResult {
		var success: Bool
		var error: String
		var file_path: String
		
		init() {
			success = false
			error = ""
			file_path = ""
		}
	}
	
	private var client: TelegramPhotoDownloaderClient!
	private var fileID: String!
	private var image: UIImage!
	
	public init() {}
	
	public func downloadImage(pFileID: String, pClient: TelegramPhotoDownloaderClient) {
		fileID = pFileID
		client = pClient
		image = UIImage(ciImage: CIImage(color: CIColor.black))
		
		TelegramHttp.getFile(fileID: fileID, httpClient: self)
	}
	
	////////////////////////////////////////////////////////////
	// HTTP Client
	////////////////////////////////////////////////////////////
	
	public func handle_http_error(error: Error) {
		client.downloadComplete(image: image, success: false, error: error.localizedDescription)
	}
	
	public func handle_http_response(json: [String : Any]) {
		
		let getFileResult = parseGetFileResult(json)
		if getFileResult.success {
			do {
				let fileUrl = TelegramHttp.getFileUrl(getFileResult.file_path)
				image = try Http().downloadImage(fileUrl)
				client.downloadComplete(image: image, success: true, error: "")
			}
			catch {
				client.downloadComplete(image: image, success: false, error: error.localizedDescription)
				return
			}
		}
		else {
			client.downloadComplete(image: image, success: false, error: getFileResult.error)
			return
		}
		
	}
	
	////////////////////////////////////////////////////////////
	// Internal stuff
	////////////////////////////////////////////////////////////
	
	private func parseGetFileResult(_ json: [String : Any]) -> GetFileResult {
		
		// {"ok":true,"result":{"file_id":"AgADBAADNbExG7y4cFFunYKwAtmdmT4EIhsABHHbrosp10scoUkEAAEC","file_size":4144,"file_path":"photos/file_0.jpg"}}
		
		var output = GetFileResult()
		output.success = json["ok"] as? Bool ?? false
		output.error = json["description"] as? String ?? ""
		
		if output.success {
			guard let result = json["result"] as? [String:Any] else {
				output.success = false
				output.error = "Unexpected Telegram server reply"
				return output
			}
			output.file_path = result["file_path"] as? String ?? ""
			if output.file_path == "" {
				output.success = false
				output.error = "Unexpected Telegram server reply"
				return output
			}
		}
		
		return output
	}
	
}

