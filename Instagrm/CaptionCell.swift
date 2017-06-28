//
//  CaptionCell.swift
//  Instagrm
//
//  Created by Mei-Ling Laures on 6/28/17.
//  Copyright © 2017 Mei-Ling Laures. All rights reserved.
//

import UIKit

class CaptionCell: UITableViewCell {

    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
