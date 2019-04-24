//
//  Http.swift
//  EasyHTTP
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public protocol HttpClient {
	func handle_http_error(error: Error)
	func handle_http_response(json: [String: Any])
}

public class Http {
	
	public init() {}
	
	public enum ImageDownloadError:Error {
		case cantBuildImageUrl(url: String)
		case downloadedDataNotImage(url: String)
	}
	
	public func downloadImage(_ url: String) throws -> UIImage {
		if let imageUrl = URL(string: url) {
			let data = try Data(contentsOf: imageUrl)
			if let image = UIImage(data: data) {return image} else { throw ImageDownloadError.downloadedDataNotImage(url: url) }
		}
		else { throw ImageDownloadError.cantBuildImageUrl(url: url) }
	}
	
	public func get(client: HttpClient, parameters: [String: String], url: String) {
		
		// Set URL
		var complete_url = url
		if parameters.count > 0 {
			complete_url += "?"
			var firstParameter = true
			for p in parameters {
				var suffix = p.key + "=" + p.value
				suffix = suffix.replacingOccurrences(of: " ", with: "%20")
				if !firstParameter {suffix = "&" + suffix}
				complete_url += suffix
				firstParameter = false
			}
		}
		
		let url2 = URL(string: complete_url)!
		
		// Set Request
		var request = URLRequest(url: url2)
		request.httpMethod = "GET" //set http method as GET
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		// Fire
		start_request(client: client, request: request)
		
	}
	
	public func post(client: HttpClient, parameters: [String: String], url: String) {
		
		// Set URL
		let url2 = URL(string: url)!
		
		// Set Request
		var request = URLRequest(url: url2)
		request.httpMethod = "POST"
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
		} catch let error {
			print(error.localizedDescription)
		}
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		// Fire
		start_request(client: client, request: request)
	}
	
	private func start_request(client: HttpClient, request: URLRequest) {
		
		let session = URLSession.shared
		
		//create dataTask using the session object to send data to the server
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
			
			guard error == nil else {
				client.handle_http_error(error:error!)
				return
			}
			guard let data = data else { return }
			
			do {
				//create json object from data
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
					client.handle_http_response(json: json)
				}
			} catch let error {
				client.handle_http_error(error:error)
			}
		})
		task.resume()
		
	}
}
