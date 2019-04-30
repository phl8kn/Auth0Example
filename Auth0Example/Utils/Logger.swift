//
//  Logger.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import Foundation


class Logger {

    /// Wraps `print` in order to easily filter out my logs from Auth0 logs.
    static func log(_ items: Any...) {
        for item in items {
            print("WLTHN: \(item)")
        }
    }
    
}
