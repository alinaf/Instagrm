//
//  DetailViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/28/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {

    // outlets for the view
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postCreate: UILabel!
    @IBOutlet weak var postComments: UILabel!
    @IBOutlet weak var postLikes: UILabel!
    
    
    var post: PFObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure that the post can be unwrapped, ie there is actually a post to display
        if let post = post {
            // set the caption for the post
            let caption = post["caption"] as! String
            self.postCaption.text = caption
            
            // set the creation time for the post
            let time = post.createdAt!
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let create = formatter.string(from: time)
            self.postCreate.text = create
            
            // set the likes for the post
            let likes = post["likes"] as! Int
            self.postLikes.text = "\(likes) Likes"
            
            // set the comments for the post
            let comments = post["commentCount"] as! Int
            self.postComments.text = "\(comments) Comments"
            
            // set the post's image by converting from a PFFile to a UIImage
            let image = post["image"] as! PFFile
            image.getDataInBackground(block: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let postIm = UIImage(data: data!)
                    self.postImage.image = postIm
                }
            })
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
