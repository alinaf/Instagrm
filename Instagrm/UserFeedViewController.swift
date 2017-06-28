//
//  UserFeedViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/28/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class UserFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // outlets for the view
    @IBOutlet weak var userFeed: UICollectionView!
    
    // posts to load data from
    var posts: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign delegate and data source of the collection view
        userFeed.delegate = self
        userFeed.dataSource = self

        // Do any additional setup after loading the view.
    }

    func getPosts() {
        // make query to the database for a certain user. must be sorted by most recent and have a limit
        let query = PFQuery(className: "Posts")
        query.limit = 20
        query.order(byDescending: "_created_at")
        query.whereKey("author", equalTo: PFUser.current()!)
        
        // find the objects in the table
        query.findObjectsInBackground { (objects: [PFObject]?, error) in
            if let objects = objects {
                // set the posts for the collection
                self.posts = objects
                
                // reload the collection view
                self.userFeed.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeue cells for their use as cells within the collection view
        let user = userFeed.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        let pic = userFeed.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! PictureCell
        
        if indexPath.row == 0 {
            // make the user cell first with its username and image
            let profile = PFUser.current()
            
            let name = profile?.username
            user.userLabel.text = name
            
            let propic = profile?["profile_pic"] as! PFFile
            propic.getDataInBackground { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let data = data {
                        let file = UIImage(data: data)
                        user.profileImage.image = file
                    } else {
                        user.profileImage.image = #imageLiteral(resourceName: "profile_tab")
                    }
                }
            }
            
            user.followerLabel.isHidden = true
            return user
        }
        
        
        return pic
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
