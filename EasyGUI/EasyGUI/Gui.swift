//
//  Gui.swift
//  EasyGUI
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit

public class Gui {
	
	public static func hideSpinner(_ spinner: UIView) {
		DispatchQueue.main.async {
			spinner.removeFromSuperview()
		}
	}
	
	public static func isEmailValid(email: String) -> Bool {
		let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
		return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
	}
	
	public static func share(activityItems: [Any], viewController:UIViewController) {
		let activityController = UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: nil
		)
		
		activityController.popoverPresentationController?.sourceRect = viewController.view.frame
		activityController.popoverPresentationController?.sourceView = viewController.view
		activityController.popoverPresentationController?.permittedArrowDirections = .any
		
		viewController.present(activityController, animated: true)
	}
	
	public static func showErrorPopup(error: Error, parent: UIViewController) {
		let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		parent.present(alert, animated: true, completion: nil)
	}
	
	public static func showPopup(title: String, message: String, parent: UIViewController) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		parent.present(alert, animated: true, completion: nil)
	}
	
	public static func showToast(controller: UIViewController, message : String, seconds: Double = 2) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.view.backgroundColor = UIColor.black
		alert.view.alpha = 0.6
		alert.view.layer.cornerRadius = 15
		
		controller.present(alert, animated: true)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
			alert.dismiss(animated: true)
		}
	}
	
	public static func showSpinner(onView : UIView) -> UIView {
		let spinnerView = UIView.init(frame: onView.bounds)
		spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
		let ai = UIActivityIndicatorView.init(style: .whiteLarge)
		ai.startAnimating()
		ai.center = spinnerView.center
		
		DispatchQueue.main.async {
			spinnerView.addSubview(ai)
			onView.addSubview(spinnerView)
		}
		
		return spinnerView
	}
	
}
