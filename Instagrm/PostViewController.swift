//
//  PostViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // outlets for the view
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UITextView!
    
    // need an image picker controller in order to find an image to post
    let vc = UIImagePickerController()
    
    // bool for saving post
    var savingPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postCaption.delegate = self
        
        // setting the delegate for the image picker, and where to get images from
        vc.delegate = self
        vc.allowsEditing = true
        
        // checking if the camera is available for use on the device
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("camera available for use")
            vc.sourceType = .camera
        } else {
            print("cannot access camera")
            vc.sourceType = .photoLibrary
        }
        
        // present the images that are to be picked from
        self.present(vc, animated: true, completion: nil)

        // Do any additional setup after loading the view.
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
        postImage.image = originalImage
        
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
            
            // create a new object in the needed class
            let post = PFObject(className: "Posts")
            
            // create the adjectives for the object
            post["image"] = getPFFileFromImage(image: postImage.image)
            post["caption"] = postCaption.text ?? ""
            post["author"] = PFUser.current()
            post["likes"] = 0
            post["commentCount"] = 0
            
            // save the post to the database
            post.saveInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("post save successfully")
                    self.savingPost = false
                    // dismiss the post window after it has been uploaded to the server
                    self.dismiss(animated: true, completion: nil)
                }
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
