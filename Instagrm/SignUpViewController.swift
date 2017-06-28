//
//  SignUpViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    // outlets for the view
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        let newUser = PFUser()
        
        
        
        newUser.username = usernameField.text
        newUser.password = passwordField.text
//        newUser.email = emailField.text
        
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
            } else {
                print("newUser created")
                self.dismiss(animated: true, completion: nil)
            }
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
