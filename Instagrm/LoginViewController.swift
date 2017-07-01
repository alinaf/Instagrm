//
//  ViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/26/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    // outlets for the view
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let alertController = UIAlertController(title: "Data Needed", message: "Please ensure the username and password fields are filled", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the alert controller
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
        }
        
        // only add the cancel action if the alert controller doesn't already have actions
        if alertController.actions == [] {
            alertController.addAction(cancelAction)
        }
        
        // set up text field delegates
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        // shift the view with the appearance of the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // when the keyboard appears, shift the view up
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    // when the keyboard dissapears, shift the view down
    func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // make the keyboard dissapear on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func signIn(_ sender: Any) {
        // Make sure that the username and password text fields can be unwrapped
        if let username = usernameField.text, let password = passwordField.text {
            // try and log in to the Parse server
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                // print out the errors with logging in
                if let error = error {
                    print(error.localizedDescription)
                    // present that error data to the user
                    self.alertController.title = "Error"
                    self.alertController.message = error.localizedDescription
                    
                    self.present(self.alertController, animated: true)
                } else {
                    print("logged in")
                    self.performSegue(withIdentifier: "mainScreen", sender: sender)
                }
            }
        } else {
            // because we could not unwrap the fields, there is an error
            present(alertController, animated: true)
        }
    }

    @IBAction func signUpScreen(_ sender: Any) {
        // go to the sign up screen
        performSegue(withIdentifier: "signUpScreen", sender: sender)
    }
    
}

