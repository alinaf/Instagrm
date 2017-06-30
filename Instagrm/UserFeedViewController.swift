//
//  UserFeedViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/28/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class UserFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // outlets for the view
    @IBOutlet weak var userFeed: UICollectionView!
    
    // posts to load data from
    var posts: [PFObject] = []
    
    // make the standards for the layout
    let userLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var standard: CGSize = CGSize()
    
    // initialize control for refreshing
    var refreshControl: UIRefreshControl!
    
    // variables for loading more posts
    var loadingData = false
    var postCount = 1
    
    override func viewWillAppear(_ animated: Bool) {
        // whenever we come back to this view controller, reload the posts to get the most up-to-date
        loadingData = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        getPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable refresh control for the table view
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(UserFeedViewController.didPullToRefresh(_:)), for: .valueChanged)
        // display the refresh control's loading symbol
        userFeed.insertSubview(refreshControl, at: 0)
        
        // assign delegate and data source of the collection view
        userFeed.delegate = self
        userFeed.dataSource = self
        
        // set the standard
        standard = CGSize(width: (self.view.frame.size.width)/3, height: (self.view.frame.size.width)/3)
        
        // set a custom collection view flow layout so that posts present in grid and a header appears
        userLayout.minimumLineSpacing = 0
        userLayout.minimumInteritemSpacing = 0
        userLayout.itemSize = standard
        //CGFloat for height is from the current size of the image for the profile picture
        userLayout.headerReferenceSize = CGSize(width: (self.view.frame.size.width), height: CGFloat(50))
        userFeed.collectionViewLayout = userLayout
        
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        // tried to refresh the feed, so get most recent posts
        loadingData = true
        postCount = 1
        getPosts()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // do not want to be loading data already
        if !loadingData {
            // should set up the distance from the bottom where new data should start being loaded
            let tableHeight = userFeed.contentSize.height
            let scrollThreshold = tableHeight - userFeed.bounds.size.height
            
            // under the conditions, load more data for the user
            if scrollView.contentOffset.y > 1.5*scrollThreshold, userFeed.isDragging {
                loadingData = true
                postCount += 1
                getPosts()
            }
        }
    }

    func getPosts() {
        // make query to the database for a certain user. must be sorted by most recent and have a limit
        let query = PFQuery(className: "Posts")
        query.limit = 20*postCount
        query.order(byDescending: "_created_at")
        query.whereKey("author", equalTo: PFUser.current()!)
        
        // find the objects in the table
        query.findObjectsInBackground { (objects: [PFObject]?, error) in
            if let objects = objects {
                if self.posts != objects {
                    // set the posts for the collection
                    self.posts = objects
                    
                    // stop the refreshing indicator
                    self.refreshControl.endRefreshing()
                    
                    // reload the collection view
                    self.userFeed.reloadSections(IndexSet(integer:0))
                    print("data reloaded")
                    
                    
                    // no longer loading data
                    self.loadingData = false
                    
                    // turn of the loading indicator when done
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let from = sender as? UICollectionViewCell
        if let cell = from {
            let control = segue.destination as! DetailViewController
            let index = userFeed.indexPath(for: cell)
            
            // get the correct post to give to the detail view
            let post = self.posts[index!.row]
            
            // set the post in the detail view to whatever was selected
            control.post = post
        }
        
    }

}
