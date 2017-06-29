//
//  SettingsViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/29/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // outlets for the settings view
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    // need an image picker controller in order to find an image to post
    let vc = UIImagePickerController()
    
    // recognize a tap
    let tapGestureRecognizer: UITapGestureRecognizer! = nil

    // set up an alert to select an image
    let chooseAlert = UIAlertController(title: "Choose an image", message: "Please choose a photo", preferredStyle:  .actionSheet)
    // set up alert in case camera cannot be accessed
    let alertController = UIAlertController(title: "Title", message: nil, preferredStyle: .alert)
    
    override func viewWillAppear(_ animated: Bool) {
        // deal with the initial alert
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            // act as if camera button has been pressed
            self.takePhoto(self.chooseAlert)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            // act as if photo library button has been pressed
            self.selectPhoto(self.chooseAlert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        // add the actions to the controller
        if chooseAlert.actions == [] {
            chooseAlert.addAction(cameraAction)
            chooseAlert.addAction(libraryAction)
            chooseAlert.addAction(cancelAction)
        }
    }
    
    func selectPhoto(_ sender: Any) {
        // photo library has been selected to pick photo
        vc.sourceType = .photoLibrary
        
        // present the images that are to be picked from
        self.present(vc, animated: true, completion: nil)
    }
    
    func takePhoto(_ sender: Any) {
        // check if the camera is available for use on the device
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("camera available for use")
            vc.sourceType = .camera
            
            // present the images that are to be picked from
            self.present(vc, animated: true, completion: nil)
        } else {
            print("cannot access camera")
            vc.sourceType = .photoLibrary
            
            
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                // present the images that are to be picked from
                self.present(self.vc, animated: true, completion: nil)
            })
            
            // add the action to the alert controller only if it does not already have actions
            if alertController.actions == [] {
                alertController.addAction(OKAction)
            }
            
            // change the message of the alert controller
            alertController.title = "Camera Unavailable"
            alertController.message = nil
            
            // present to alert controller so the user knows the issue
            present(alertController, animated: true)
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting the delegate for the image picker, and where to get images from
        vc.delegate = self
        vc.allowsEditing = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
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
        
        // put in image
        let profile = user?["profile_pic"] as? PFFile
        profile?.getDataInBackground { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let data = data {
                    let file = UIImage(data: data)
                    self.profileImage.image = file
                } else {
                    self.profileImage.image = #imageLiteral(resourceName: "profile_tab")
                }
            }
        }
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // if the image is tapped, show the alert that allows to choose an image
        present(chooseAlert, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get the image captured from the camera
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Include the images which you have gotten from the camera in the post
        profi.image = editedImage
        
        // Dismiss the UIImagePickerController
        dismiss(animated: true, completion: nil)
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
