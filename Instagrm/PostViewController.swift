//
//  PostViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // outlets for the view
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UITextView!
    
    // need an image picker controller in order to find an image to post
    let vc = UIImagePickerController()
    
    // bool for saving post
    var savingPost = false
    
    // make an alert controller for unuseable camera and choosing an image
    let alertController = UIAlertController(title: "Title", message: nil, preferredStyle: .alert)
    let chooseAlert = UIAlertController(title: "Choose an image", message: "Please choose a photo", preferredStyle:  .actionSheet)
    
    // recognize a tap
    let tapGestureRecognizer: UITapGestureRecognizer! = nil
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postCaption.delegate = self
        
        // setting the delegate for the image picker, and where to get images from
        vc.delegate = self
        vc.allowsEditing = true
        
        // code to create an object to recognize user touches
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
        
        // present the controller to start with
        present(chooseAlert, animated: true)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // if the image is tapped, show the alert that allows to choose an image
        present(chooseAlert, animated: true)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        // photo library has been selected to pick photo
        vc.sourceType = .photoLibrary
        
        // present the images that are to be picked from
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
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
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if postCaption.text == "Add a caption..." {
            postCaption.text = ""
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get the image captured from the camera
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Include the images which you have gotten from the camera in the post
        postImage.image = editedImage
        
        // Dismiss the UIImagePickerController
        dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPost(_ sender: Any) {
        if !savingPost {
            // change bool so that the post button is locked
            savingPost = true
            
            // show that the post is being uploaded
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            // create a new object in the needed class
            let post = PFObject(className: "Posts")
            
            // create the adjectives for the object
            if let pic = postImage.image {
                post["image"] = getPFFileFromImage(image: pic)
                post["author"] = PFUser.current()
                post["likes"] = 0
                post["commentCount"] = 0
                
                // make sure the caption is not the stock text
                if postCaption.text == "Add a caption..." {
                    post["caption"] = ""
                } else {
                    post["caption"] = postCaption.text ?? ""
                }
                
                // save the post to the database
                post.saveInBackground { (success: Bool, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("post save successfully")
                        self.savingPost = false
                        
                        // post has finished loading so dismiss progress HUD
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        // dismiss the post window after it has been uploaded to the server
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                // we encountered a problem so we are not loading
                MBProgressHUD.hide(for: self.view, animated: true)
                
                // change the message of the alert controller
                chooseAlert.title = "Need a Photo"
                
                // make sure that we can save the post again once they do choose a photo
                savingPost = false
                
                // present the choice alert
                present(chooseAlert, animated: true)
            }
        }
    }
    
    func getPFFileFromImage (image: UIImage?) ->PFFile? {
        // get the correct kind of data from a UI image to store for Parse
        if let image = image {
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }

    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
