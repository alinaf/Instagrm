//
//  SignUpViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // outlets for the view
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // create alert controllers
    let alertController = UIAlertController(title: "Data Needed", message: "Please ensure all required fields are filled out", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // make the action to dismiss the alert
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
        }
        
        // add the dismiss action to the alert
        if alertController.actions == [] {
            alertController.addAction(cancelAction)
        }
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.emailField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        let newUser = PFUser()
        
        if let username = usernameField.text, let password = passwordField.text {
            
            newUser.username = username
            newUser.password = password
            // let the email field be optional
            if let email = emailField.text {
                newUser.email = email
            }
            
            newUser["followers"] = 0
            newUser["description"] = ""
            // get the correct kind of data from a UI image to store for Parse
            let image = #imageLiteral(resourceName: "profile_tab")
            if let imageData = UIImagePNGRepresentation(image) {
                let pic = PFFile(name: "image.png", data: imageData)
                newUser["profile_pic"] = pic
            }
            
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                    
                    self.alertController.title = "Error"
                    self.alertController.message = error.localizedDescription
                    
                    self.present(self.alertController, animated: true)
                } else {
                    print("newUser created")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            // something has not been filled out
            present(alertController, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
