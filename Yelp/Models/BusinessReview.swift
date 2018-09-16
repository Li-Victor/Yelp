//
//  BusinessReview.swift
//  Yelp
//
//  Created by Victor Li on 9/16/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BusinessReview {
    let profileName: String
    let profileImageURL: URL
    let ratingImage: UIImage
    let date: String
    let reviewText: String
    let reviewURL: URL
    
    static func parseToBusinessReview(json: JSON) -> BusinessReview {
        let profileName = json["user", "name"].stringValue
        let profileImageString = json["user", "image_url"].stringValue
        let profileImageURL = URL(string: profileImageString)!
        
        let rating = json["rating"].doubleValue
        let ratingImage: UIImage
        switch rating {
        case 1:
            ratingImage = UIImage(named: "stars_1")!
        case 1.5:
            ratingImage = UIImage(named: "stars_1_half")!
        case 2:
            ratingImage = UIImage(named: "stars_2")!
        case 2.5:
            ratingImage = UIImage(named: "stars_2_half")!
        case 3:
            ratingImage = UIImage(named: "stars_3")!
        case 3.5:
            ratingImage = UIImage(named: "stars_3_half")!
        case 4:
            ratingImage = UIImage(named: "stars_4")!
        case 4.5:
            ratingImage = UIImage(named: "stars_4_half")!
        case 5:
            ratingImage = UIImage(named: "stars_5")!
        default:
            ratingImage = UIImage(named: "stars_0")!
        }
        
        let date = json["time_created"].stringValue
        let reviewText = json["text"].stringValue
        let reviewString = json["url"].stringValue
        let reviewURL = URL(string: reviewString)!
        
        return BusinessReview(profileName: profileName, profileImageURL: profileImageURL, ratingImage: ratingImage, date: date, reviewText: reviewText, reviewURL: reviewURL)
    }
}
