//
//  PostCell.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/30/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
