//
//  SettingsViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/29/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the current user
        let user = PFUser.current()
        
        // put in username
        usernameLabel.text = user?.username
        
        // put in the joined date
        let time = user?.createdAt
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let since = formatter.string(from: time!)
        memberLabel.text = "Member since: \n\(since)"
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: Any) {
        // log out the user
        PFUser.logOutInBackground { (error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("successfully logged out")
                self.performSegue(withIdentifier: "logOut", sender: sender)
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
