//
//  BusinessReviewCell.swift
//  Yelp
//
//  Created by Victor Li on 9/16/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import AlamofireImage

class BusinessReviewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    var businessReview: BusinessReview! {
        didSet {
            profileImageView.af_setImage(withURL: businessReview.profileImageURL)
            profileNameLabel.text = businessReview.profileName
            ratingImageView.image = businessReview.ratingImage
            dateLabel.text = businessReview.date
            reviewTextLabel.text = businessReview.reviewText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        profileNameLabel.preferredMaxLayoutWidth = profileNameLabel.frame.size.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
