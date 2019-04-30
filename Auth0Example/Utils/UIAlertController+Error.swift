//
//  UIAlertController+Error.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertController {

    /// Creates a simple `UIAlertController` to notify the user of an error
    ///
    /// - Parameter message: Message to show the user
    /// - Returns: a `UIAlertController` pre-configured for simple error messages
    class func errorAlert(with message: String) -> UIAlertController {
        let alertView = UIAlertController(title: "Our Apologies", message: "\n" + message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default))
        return alertView
    }
    
}
