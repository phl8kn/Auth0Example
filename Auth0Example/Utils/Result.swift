//
//  Result.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import Foundation
import Auth0


/// Used for async operations that can succeed or fail.
///
/// - success: Value returned upon success
/// - failure: Error returned upon failure
enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

/// Central place to keep track of different result types.
/// Note: If migrating to Swift 5.0, these types should reside in the Classes that use them.

typealias CredentialsResult = Result<Credentials, CredentialsManagerError>
