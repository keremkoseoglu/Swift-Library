//
//  Location.swift
//  EasyLocation
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationClient {
	func addressDetected(address: String, success: Bool, error: String)
	func locationDetected(location: CLLocation?, success: Bool, error: String)
}

public class Location: NSObject, CLLocationManagerDelegate {
	
	private enum Purpose {
		case address
		case location
	}
	
	private static var singleton: Location!
	
	private var locationClient: LocationClient!
	private var lastLocationDate: Date!
	private var lastLocation: CLLocation!
	private var lastAddress: String!
	private var locationManager: CLLocationManager
	private var purpose: Purpose!
	private var geoCoder: CLGeocoder
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	private override init() {
		locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		geoCoder = CLGeocoder()
	}
	
	public static func getInstance() -> Location {
		if singleton == nil { singleton = Location() }
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Self stuff
	////////////////////////////////////////////////////////////
	
	public func requestAddress(client: LocationClient) {
		purpose = Purpose.address
		locationClient = client
		
		if lastAddress != nil && lastAddress != "" && lastLocationDate != nil  && didLastLocationExpire() {
			locationClient.addressDetected(address: lastAddress, success: true, error: "")
			return
		}
		
		startLocationDetection()
	}
	
	public func requestLocation(client: LocationClient) {
		purpose = Purpose.location
		locationClient = client
		
		if lastLocation != nil && lastLocationDate != nil  && didLastLocationExpire() {
			locationClient.locationDetected(location: lastLocation, success: true, error:"")
			return
		}
		
		startLocationDetection()
	}
	
	private func didLastLocationExpire() -> Bool {
		if lastLocationDate == nil {return true}
		let expireDate = Date(timeInterval: 15 * 60, since: lastLocationDate)
		return expireDate <= Date()
	}
	
	private func startLocationDetection() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
		}
		else {
			locationClient.locationDetected(location:nil, success:false, error:"Location services disabled")
		}
	}

	
	////////////////////////////////////////////////////////////
	// Location manager delegate
	////////////////////////////////////////////////////////////
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if locations.count > 0 {
			
			switch purpose! {
			case Purpose.address:
				parseAddress(locations)
			case Purpose.location:
				parseLocation(locations)
			}
			

			
		}
		else {
			self.locationClient.locationDetected(
				location: nil,
				success: false,
				error: "Can't detect own location"
			)
		}
		
	}
	
	private func parseAddress(_ locations: [CLLocation]) {
		geoCoder.reverseGeocodeLocation(
			locations[0],
			completionHandler: {
				(placemarks, error) in
				if error == nil {
					let firstLocation = placemarks?[0]
					self.lastAddress = firstLocation?.name ?? "Earth"
					self.lastLocationDate = Date.init()
					self.locationClient.addressDetected(address: self.lastAddress, success: true, error: "")
				}
				else {
					self.locationClient.addressDetected(address: "", success: false, error: error?.localizedDescription ?? "Error")
				}
		})
	}
	
	private func parseLocation(_ locations: [CLLocation]) {
		lastLocation = locations[0]
		lastLocationDate = Date.init()
		locationClient.locationDetected(
			location: self.lastLocation,
			success: true,
			error: ""
		)
	}
	
	
	
}
