//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/15/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var business: Business!
    var businessReviews: [BusinessReview] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = business.name
        mainImageView.af_setImage(withURL: business.imageURL)
        categoriesLabel.text = business.categories
        reviewsLabel.text = "\(business.reviewCount) Reviews"
        ratingImageView.image = business.ratingImage
        priceLabel.text = business.price
        phoneLabel.text = "Call: \(business.phoneNumber)"
        
        
        let yelpAPIKey = APIKeys.YELP.rawValue
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(business.yelpID)/reviews")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self.businessReviews = JSON(data)["reviews"].arrayValue.map {
                    BusinessReview.parseToBusinessReview(json: $0)
                }

            }
            
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
