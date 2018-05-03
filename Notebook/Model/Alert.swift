//
//  Alert.swift
//  Notebook
//
//  Created by Garrett Votaw on 5/3/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    static func presentAlert(with controller: UIViewController, title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
