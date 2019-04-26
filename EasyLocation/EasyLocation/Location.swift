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
	
	private var geoCoder: CLGeocoder
	private var locationClient: LocationClient!
	private var lastLocationDate: Date!
	private var lastLocation: CLLocation!
	private var lastAddress: String!
	private var locationInProgress: Bool
	private var locationManager: CLLocationManager
	private var purpose: Purpose!
	private var timeOutTimer: Timer!
	
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	private override init() {
		locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		geoCoder = CLGeocoder()
		locationInProgress = false
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
			notifyAddress(address: lastAddress, success: true, error: "")
			return
		}
		
		startLocationDetection()
	}
	
	public func requestLocation(client: LocationClient) {
		purpose = Purpose.location
		locationClient = client
		
		if lastLocation != nil && lastLocationDate != nil  && didLastLocationExpire() {
			notifyLocation(location: lastLocation, success: true, error: "")
			return
		}
		
		startLocationDetection()
	}
	
	private func didLastLocationExpire() -> Bool {
		if lastLocationDate == nil {return true}
		let expireDate = Date(timeInterval: 15 * 60, since: lastLocationDate)
		return expireDate <= Date()
	}
	
	private func notifyAddress(address: String, success: Bool, error: String) {
		locationInProgress = false
		locationClient.addressDetected(address: address, success: success, error: error)
	}
	
	private func notifyLocation(location: CLLocation?, success: Bool, error: String) {
		locationInProgress = false
		locationClient.locationDetected(location: location, success: success, error: error)
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
					self.notifyAddress(address: self.lastAddress, success: true, error: "")
				}
				else {
					self.notifyAddress(address: "", success: false, error: error?.localizedDescription ?? "Error")
				}
		})
	}
	
	private func parseLocation(_ locations: [CLLocation]) {
		lastLocation = locations[0]
		lastLocationDate = Date.init()
		notifyLocation(location: self.lastLocation, success: true, error: "")
	}
	
	private func startLocationDetection() {
		if CLLocationManager.locationServicesEnabled() {
			if locationInProgress {return}
			locationInProgress = true
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
			
			timeOutTimer = Timer.scheduledTimer(
				withTimeInterval: 5,
				repeats: false,
				block: { timeOutTimer in self.timeOut() }
			)
		}
		else {
			notifyLocation(location: nil, success: false, error: "Location services disabled")
		}
	}
	
	private func timeOut() {
		
		if !locationInProgress {return} // Progress may have been finished just now
		
		let error = "Time out"
		
		switch purpose! {
		case Purpose.address:
			notifyAddress(address: "", success: false, error: error)
		case Purpose.location:
			notifyLocation(location: nil, success: false, error: error)
		}

	}

	
	////////////////////////////////////////////////////////////
	// Location manager delegate
	////////////////////////////////////////////////////////////
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if !locationInProgress {return} // Progress may have been stopped due to timeout
		
		if locations.count > 0 {
			switch purpose! {
			case Purpose.address:
				parseAddress(locations)
			case Purpose.location:
				parseLocation(locations)
			}
		}
		else {
			notifyLocation(location: nil, success: false, error: "Can't detect own location")
		}
		
	}
	
	
}
