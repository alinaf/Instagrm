//
//  FeedViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets for the view
    @IBOutlet weak var feedTable: UITableView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    // storage for posts in the feed
    var posts: [PFObject] = []
    
    // variables for loading more posts (infinite scrolling)
    var postCount = 1
    var loadingData = false
    
    // initialize the xib to be able to use it
    let nib = UINib(nibName: "UserSectionHeader", bundle: nil)
    
    // initialze control for refreshing
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        // whenever we come back to this view controller, reload the posts to get the most up-to-date
        loadingData = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        getPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //enable refresh control for the table view
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        // dsiplay the loading symbol for refreshing at the top of the table
        feedTable.insertSubview(refreshControl, at: 0)
        
        // register the xib file to be able to use it as a section header
        feedTable.register(nib, forHeaderFooterViewReuseIdentifier: "UserSectionHeader")
        
        // set the table's delegate and data source
        feedTable.delegate = self
        feedTable.dataSource = self

    }
    
    func didPullToRefresh (_ refreshControl: UIRefreshControl) {
        // we have tried to refresh the feed so get the most recent posts
        loadingData = true
        postCount = 1
        getPosts()
    }
    
    func getPosts() {
        // make a query to the database. the query should be sorted by most recent, include the poster, and have a limit to the number loaded
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "_created_at")
        query.includeKey("author")
        query.limit = 20 * postCount
        
        // find the objects in the table
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let objects = objects {
                // set the post objects for the table
                self.posts = objects
                
                // stop the refresh indicator
                self.refreshControl.endRefreshing()
                
                // reload the table view
                self.feedTable.reloadData()
                
                // we are no longer loading data so this bool can be reset
                self.loadingData = false
                
                // if the loading indicator was on, should change that
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // do not want to be loading data already
        if !loadingData {
            // should set up the distance from the bottom where new data should start being loaded
            let tableHeight = feedTable.contentSize.height
            let scrollThreshold = tableHeight - feedTable.bounds.size.height
            
            // under the conditions, load more data for the user
            if scrollView.contentOffset.y > scrollThreshold, feedTable.isDragging {
                loadingData = true
                postCount += 1
                getPosts()
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedTable.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // make caption cell and image cell available to use
        let image = feedTable.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        let caption = feedTable.dequeueReusableCell(withIdentifier: "CaptionCell") as! CaptionCell
        
        // check if the posts are empty before loading data into cells
        if !posts.isEmpty {
            // get the correct post to display
            let post = posts[indexPath.section]

            if indexPath.row == 0 {
                // load the image cell for the section
                let load = post["image"] as! PFFile
                load.getDataInBackground(block: { (data: Data?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let postPicture = UIImage(data: data!)
                        print("successfully got data")
                        image.postImage.image = postPicture
                    }
                })
                return image
            } else if indexPath.row == 1 {
                // load the caption cell for the section
                let load = post["caption"] as! String
                let likes = post["likes"] as! Int
                let comments = post["commentCount"] as! Int
                
                caption.captionLabel.text = load
                caption.commentsLabel.text = " \(comments) comments"
                caption.likesLabel.text = "\(likes) likes"
                
                return caption
            }
        }
        
        return caption
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // make section headers
        let post = posts[section]
        let user = post["author"] as! PFUser
        return user.objectId
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // dequeue the header to be able to reuse it for whichever the seciton is
        let cell = self.feedTable.dequeueReusableHeaderFooterView(withIdentifier: "UserSectionHeader") as! UserSectionHeader
        
        // get the correct post for the section and set the time posted
        let post = posts[section]
        let time = post.createdAt
        // make a formatter for a way to display the date of the post
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let display = formatter.string(from: time!)
        cell.createdLabel.text = display
        
//        for time interval calculation
//        let now = Date()
//        let interval = DateInterval(start: time!, end: now)
        
        // get the user from the post and set the username
        let user = post["author"] as! PFUser
        let username = user.username
        cell.userLabel.text = username
        
        // set the user profile picture
        if let pic = user["profile_pic"] {
            let file = pic as! PFFile
            file.getDataInBackground(block: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let data = data {
                        let pic = UIImage(data: data)
                        cell.profileImage.image = pic
                    }
                }
            })
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let from = sender as? UITableViewCell
        if let cell = from {
            // get the destination and cell to access their member variables/functions
//            let cell = sender as! UITableViewCell
            let control = segue.destination as! DetailViewController
            let index = feedTable.indexPath(for: cell)
            
            // get the correct post to give to the detail view
            let post = self.posts[index!.section]
            
            // set the post in the detail view to whatever was selected
            control.post = post
        }
        
    }

}
