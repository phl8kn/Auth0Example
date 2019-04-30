//
//  LoginState.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import Foundation


/// To keep track of user login flow
///
/// - notLoggedIn: Starting from fresh (no saved credentials)
/// - loggingIn: User is attempting to log in or sign up
/// - loggedIn: User is logged in
/// - loggingOut: User is attempting to log out (not used because log out currently is synchronous)
/// - loggedOut: User has been logged out from a previously logged in state
enum LoginState {
    
    case notLoggedIn
    case loggingIn
    case loggedIn
    case loggingOut
    case loggedOut
    
}
