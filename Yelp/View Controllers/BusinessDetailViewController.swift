//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/15/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import AlamofireImage

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = business.name
        mainImageView.af_setImage(withURL: business.imageURL)
        categoriesLabel.text = business.categories
        reviewsLabel.text = "\(business.reviewCount) Reviews"
        ratingImageView.image = business.ratingImage
        priceLabel.text = business.price
        phoneLabel.text = "Call: \(business.phoneNumber)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
