//
//  ViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/26/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signIn(_ sender: Any) {
        // Make sure that the username and password text fields can be unwrapped
        if let username = usernameField.text, let password = passwordField.text {
            // try and log in to the Parse server
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                // print out the errors with logging in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("logged in")
                    self.performSegue(withIdentifier: "mainScreen", sender: sender)
                }
            }
        } else {
            // because we could not unwrap the fields, there is an error
        }
    }

    @IBAction func signUpScreen(_ sender: Any) {
        // go to the sign up screen
        performSegue(withIdentifier: "signUpScreen", sender: sender)
    }
    
}

