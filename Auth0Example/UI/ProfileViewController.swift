//
//  ProfileViewController.swift
//  Auth0Example
//
//  Created by Phillipp Aitken on 2019-04-29.
//  Copyright © 2019 Wellthon. All rights reserved.
//

import UIKit
import Auth0


/// To notify `MainViewController` of profile based operations
protocol ProfileViewControllerDelegate: class {
    func onLogoutRequested(_ callback: @escaping (_ success: Bool) -> Void)
}


class ProfileViewController: UIViewController {

    // MARK: - Variables
    
    var profile: UserInfo?
    weak var delegate: ProfileViewControllerDelegate?
    
    // MARK: - IBActions
    
    /// Handler for "Log Out" button press
    @IBAction func onLogoutRequested(_ sender: Any) {
        self.delegate?.onLogoutRequested { success in
            if success {
                // Go back to previous view
                self.dismiss(animated: true)
            } else {
                
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If no profile data object, go back to previous view
        guard let profile = self.profile else {
            self.dismiss(animated: true)
            return
        }
        
        self.loadUserImage()
        // Show name in NavigationBar
        self.navigationItem.title = profile.name ?? "New User"
    }
    
    // MARK: - Profile Functions
    
    /// Loads the user's image from the `profile: UserInfo`
    func loadUserImage() {
        // Use default image if no URL provided
        guard let pictureURL = self.profile?.picture else {
            self.imageView.image = #imageLiteral(resourceName: "default_user")
            self.activityIndicator.stopAnimating()
            return
        }
        // Load image in background thread
        let task = URLSession.shared.dataTask(with: pictureURL) { (data, response, error) in
            // Return to main thread
            DispatchQueue.main.async {
                // Create image from data, or use default
                let image = UIImage.from(data: data, defaultImage: #imageLiteral(resourceName: "default_user"))
                // Fade in the image
                UIView.transition(
                    with: self.imageView,
                    duration: 1.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.imageView.image = image
                    },
                    completion: nil
                )
                // Fade out loader
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self.activityIndicator.alpha = 0.0
                    }, completion: { finished in
                        self.activityIndicator.stopAnimating()
                    }
                )
            }
        }
        task.resume()
    }
    
}
