//
//  MainViewController.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

//==-- From Auth0 --==\\

//  Tenant           dev-07apz4jq
//  Domain           .auth0.com
//  Client ID        r6cLecfb21s1qYy4YSVQb2L0PC9Xqf30

import UIKit
import Lock
import Auth0


/// ## Handles:
///  - Checking for previously authenticated user
///  - User initiated log in, sign up and log out
///  - Presenting the user's profile
class MainViewController: UIViewController {

    // MARK: - Variables
    
    /// `NSObject` containing authenticated credentials, e.g. `accessToken`, `refershToken`
    private var credentials: Credentials?
    
    /// Manager provided by Auth0 to safely (using encrypted Keychain) store and retrieve `Credentials`
    private var credentialsManager: CredentialsManager?
    
    /// Keeps track of user login state, can react accordingly
    private var loginState: LoginState = .notLoggedIn {
        didSet {
            switch (oldValue, loginState) {
            case (.notLoggedIn, .loggingIn):
                Logger.log("User is attempting first log in")
            case (.loggingIn, .loggedIn):
                Logger.log("User has logged in")
                self.getUserProfile()
            case (.notLoggedIn, .loggedIn):
                Logger.log("User was automatically logged in from saved credentials")
                self.getUserProfile()
            case (.loggedIn, .loggedOut):
                Logger.log("User has logged out")
            case (.loggedOut, .loggingIn):
                Logger.log("User attempting log in")
            default:
                // This will fail only during debug builds, to catch unexpected user flows
                assertionFailure("Unexpected login state change: \(oldValue) -> \(loginState)")
            }
        }
    }
    
    /// `UserInfo` Object provided by Auth0
    private var profile: UserInfo?
    
    // MARK: - IBActions
    
    /// Handler for "Log In" button press
    @IBAction func onLoginRequested(_ sender: Any) {
        self.login()
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    /// To animate the logo moving up
    @IBOutlet weak var verticalConstraint: NSLayoutConstraint!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used to manage Auth0 credentials (and persist using encrypted Keychain)
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        
        // Prep UI for animation
        self.activityIndicator.alpha = 1.0
        self.introLabel.alpha = 0.0
        self.loginButton.alpha = 0.0
        self.loginButton.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check for existing credentials
        self.checkForExistingCredentials { result in
            switch result {
            case .success(let credentials):
                // Save credentials object
                self.credentials = credentials
                self.loginState = .loggedIn
                Logger.log("credentials (from manager): \(String(describing: self.credentials))")
            case .failure:
                Logger.log("No saved credentials found")
                self.showFirstTimeExperience()
            }
        }
    }
    
    /// Captures Seques to inject data depending on destination `UIViewController`
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let navViewController as UINavigationController:
            switch navViewController.topViewController {
            case let profileViewController as ProfileViewController:
                // Prep the ProfileViewController 
                profileViewController.profile = self.profile
                profileViewController.delegate = self
            default:
                // This will fail only during debug builds, to catch unexpected UI flows
                assertionFailure("Expected ProfileViewController, check Main.storyboard")
            }
        default:
            // This will fail only during debug builds, to catch unexpected UI flows
            assertionFailure("Expected UINavigationController, check Main.storyboard")
        }
    }
    
    // MARK: - Animations
    
    /// Present Log In UI
    func showFirstTimeExperience() {
        self.hideActivityIndicator()
        // Fade in first time UI
        self.verticalConstraint.constant = -150
        UIView.animate(
            withDuration: 1.5,
            delay: 1.0, // To account for transition from LaunchScreen to Main
            options: .curveEaseInOut,
            animations: {
                self.introLabel.alpha = 1.0
                self.loginButton.alpha = 1.0
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                self.loginButton.isUserInteractionEnabled = true
            }
        )
    }
    
    /// Quickly fade out the activity indicator
    func hideActivityIndicator() {
        UIView.animate (
            withDuration: 0.5,
            delay: 1.0, // To account for transition from LaunchScreen to Main
            options: .curveEaseIn,
            animations: {
                self.activityIndicator.alpha = 0.0
            },
            completion: { completed in
                self.activityIndicator.stopAnimating()
            }
        )
    }
    
    // MARK: - Credentials
    
    /// Leverages `Auth0.CredentialManager` to check if there is an existing session.
    ///
    /// - Parameter callback: Contains error or credentials
    func checkForExistingCredentials(callback: @escaping (CredentialsResult) -> Void) {
        var credentialsFromManager: Credentials?
        var error: CredentialsManagerError? = nil
        // Handle callbacks
        defer {
            // Ensure execution is on the main thread as Auth0.CredentialsManager likely uses some background thread
            DispatchQueue.main.async {
                if let credentials = credentialsFromManager {
                    callback(.success(credentials))
                } else {
                    callback(.failure(.noCredentials))
                }
            }
            
        }
        // Ensure we have valid credentials before continuing
        guard let credentialsManager = self.credentialsManager, credentialsManager.hasValid() else {
            return
        }
        // From Auth0 documentation:
        //  -> If the credentials have expired, the credentials manager will automatically renew them for you with the Refresh Token.
        credentialsManager.credentials { error, credentials in
            credentialsFromManager = credentials
        }
    }
    
    /// Leverages `Auth0.CredentialManager` to securely persist user credentials.
    /// Also saves value to local variable.
    ///
    /// - Parameter credentials: The `Auth0.Credentials` Object to be saved
    func save(_ credentials: Credentials) {
        guard let credentialsManager = self.credentialsManager, credentialsManager.store(credentials: credentials) else {
            let errorAlert = UIAlertController.errorAlert(with: "We weren't able to save your login details. You will have to login again next time you start the app.")
            self.present(errorAlert, animated: true)
            return
        }
        self.credentials = credentials
        Logger.log("Credentials saved")
    }
    
    // MARK: - Log In and Sign Up
    
    /// Presents user with a Native login prompt, using `Auth0.Lock`.
    func login() {
        // Prevent Lock from presenting if user is already logging in
        guard self.loginState != .loggingIn else {
            return
        }
        // Keep track of user flow
        self.loginState = .loggingIn
        // Display the native Lock login UI
        Lock
            .classic()
            .withOptions {
                $0.oidcConformant = true
                // "offline_access" to get refreshToken which is used by CredentialsManager to reauthenticate upon "accessToken" expiration
                $0.scope = "openid profile offline_access"
                $0.logLevel = .all
                $0.logHttpRequest = true
            }
            .withStyle {
                let primaryColor = UIColor(named: "primary_color")!
                $0.tabTextColor = primaryColor
                $0.inputBorderColor = primaryColor
                $0.primaryColor = primaryColor
                $0.hideTitle = true
                $0.logo = LazyImage(name: "wellthon_logo_small")
            }
            .onAuth { [weak self] credentials in // [weak self] to prevent reference cycle
                Logger.log("Lock: User authenticated")
                guard let strongSelf = self else { return }
                strongSelf.save(credentials)
                strongSelf.loginState = .loggedIn
            }
            .onCancel { [weak self] in // [weak self] to prevent reference cycle
                Logger.log("Lock: User cancelled")
                guard let strongSelf = self else { return }
                strongSelf.loginState = .notLoggedIn
            }
            .onError { [weak self] error in // [weak self] to prevent reference cycle
                Logger.log("Lock: (\(type(of: error)) -> \(error)")
                guard let strongSelf = self else { return }
                strongSelf.loginState = .notLoggedIn
            }
            .present(from: self)
    }
    
    /// Leverages `Auth0.CredentialManager` to clear user credentials.
    func logout(_ callback: ((Bool) -> Void)? = nil) {
        // Prevent log out if not logged in
        guard let credentialsManager = self.credentialsManager, loginState == .loggedIn else {
            return
        }
        // Clear local data object
        self.credentials = nil
        // Clear credentials from the manager
        let logoutSuccess = credentialsManager.clear()
        if logoutSuccess {
            self.loginState = .loggedOut
        } else {
            let errorAlert = UIAlertController.errorAlert(with: "We weren't able to log you out. Please try again later")
            self.present(errorAlert, animated: true)
        }
        callback?(logoutSuccess)
    }
    
    // MARK: - Profile
    
    /// Leverages `Auth0.Authentication` to retrieve a `UserInfo` object for the current user
    func getUserProfile() {
        // Prevent if we have no accessToken
        guard let accessToken = self.credentials?.accessToken else {
            self.userProfileNotFound()
            return
        }
        
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                // Ensure execution is on the main thread as Auth0 likely uses other background thread
                DispatchQueue.main.async {
                    switch(result) {
                    case .success(let profile):
                        self.profile = profile
                        self.showUserProfile()
                    case .failure:
                        self.userProfileNotFound()
                    }
                }
            }
    }
    
    /// Transitions to the `ProfileViewController` as long as there is a `profile`.
    func showUserProfile() {
        guard let _ = self.profile else { return }
        self.performSegue(withIdentifier: "ProfileSegue", sender: self)
    }
    
    /// Alerts the user that there was an issues getting their profile
    func userProfileNotFound() {
        let errorAlert = UIAlertController.errorAlert(with: "We weren't able to retrieve your profile. Please try again later")
        self.present(errorAlert, animated: true)
    }
    
}

extension MainViewController: ProfileViewControllerDelegate {
    
    /// Handler for user initiated log out from ProfileViewController
    ///
    /// - Parameter callback: To inform the `ProfileViewController` of logout success or failure
    func onLogoutRequested(_ callback:  @escaping (_ success: Bool) -> Void) {
        self.logout(callback)
    }
    
}
