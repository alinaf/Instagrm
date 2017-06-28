//
//  FeedViewController.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/27/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var feedTable: UITableView!
    
    // storage for posts in the feed
    var posts: [PFObject] = []
    
    // variables for loading more posts (infinite scrolling)
    var postCount = 1
    var loadingData = false
    
    // initialize the xib to be able to use it
    let nib = UINib(nibName: "UserSectionHeader", bundle: nil)
    
    // initialze control for refreshing
    var refreshControl: UIRefreshControl!
    
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

        //get the posts for the table
        loadingData = true
        getPosts()
        
        // Do any additional setup after loading the view.
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let image = feedTable.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        
        if !posts.isEmpty {
            let post = posts[indexPath.row]
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
        }
        
        return image
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
        
        // set the username and the profile picture within the section header
        let post = posts[section]
        let user = post["author"] as! PFUser
        let username = user.username
        
        cell.userLabel.text = username
        
        return cell
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
