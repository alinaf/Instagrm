//
//  UserFeedViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/28/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class UserFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // outlets for the view
    @IBOutlet weak var userFeed: UICollectionView!
    
    // posts to load data from
    var posts: [PFObject] = []
    
    // make the standards for the layout
    let userLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var standard: CGSize = CGSize()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign delegate and data source of the collection view
        userFeed.delegate = self
        userFeed.dataSource = self
        
        // set the standard
        standard = CGSize(width: (self.view.frame.size.width)/3, height: (self.view.frame.size.width)/3)
        
        // set a custom collection view flow layout so that posts present in grid and a header appears
        userLayout.minimumLineSpacing = 0
        userLayout.minimumInteritemSpacing = 0
        userLayout.itemSize = standard
        userLayout.headerReferenceSize = CGSize(width: (self.view.frame.size.width), height: (self.view.frame.size.width)/5)
        userFeed.collectionViewLayout = userLayout

        
        
        getPosts()
        
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
        // the number of posts to display
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // make the header available for use in the collection view
        switch kind {
        // for only the header
        case UICollectionElementKindSectionHeader:
            let header = userFeed.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
            
            // set the header properties (username)
            let user = PFUser.current()
            let name = user?.username
            header.userLabel.text = name
            // profile picture
            let profile = user?["profile_pic"] as? PFFile
            profile?.getDataInBackground { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let data = data {
                        let file = UIImage(data: data)
                        header.profileImage.image = file
                    } else {
                        header.profileImage.image = #imageLiteral(resourceName: "profile_tab")
                    }
                }
            }
            // followers not yet implemented so hide the label
            header.followerLabel.isHidden = true
            
            // give the header to the collection view to display
            return header
            
        // the footer should not be called for so the program should pass an error
        default:
            assert(false, "Unexpected kind")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeue cells for their use as cells within the collection view
        let pic = userFeed.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! PictureCell
        
        // for all the cells, do the following
        let post = posts[indexPath.row]
        // get and convert the image for the post
        let image = post["image"] as! PFFile
        image.getDataInBackground { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let data = data {
                    let pict = UIImage(data: data)
                    pic.postImage.image = pict
                    pic.postImage.sizeThatFits(self.standard)
                } else {
                    pic.postImage.image = #imageLiteral(resourceName: "image_placeholder")
                }
            }
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
