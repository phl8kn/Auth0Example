//
//  UIImage+Data.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    
    /// Creates a `UIImage` from `Data` object.
    ///
    /// - Parameters:
    ///   - data: Image data
    ///   - defaultImage: Image to use if no data provided
    /// - Returns: new `UIImage` from `data` or the `defaultImage`
    static func from(data: Data?, defaultImage: UIImage) -> UIImage {
        guard let data = data else { return defaultImage }
        return UIImage(data: data) ?? defaultImage
    }
    
}
