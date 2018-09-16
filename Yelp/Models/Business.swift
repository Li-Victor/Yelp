//
//  Business.swift
//  Yelp
//
//  Created by Victor Li on 9/10/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import MapKit

struct Business {
    let name: String
    let address: String
    let imageURL: URL
    let categories: String
    let distance: String
    let ratingImage: UIImage
    let reviewCount: Int
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    
    static func parseToBusiness(json: JSON) -> Business {
        let name = json["name"].stringValue
        let imageURLString = json["image_url"].stringValue
        let imageURL = URL(string: imageURLString)!
        
        var address = ""
        let addressArray = json["location", "display_address"].arrayValue
        if addressArray.count > 0 {
            address = addressArray[0].stringValue
        }
        if addressArray.count > 1 {
            address += ", " + addressArray[1].stringValue
        }
        
        let categoriesArray = json["categories"].arrayValue
        var categoryNames = [String]()
        for category in categoriesArray {
            let categoryName = category["title"].stringValue
            categoryNames.append(categoryName)
        }
        let categories = categoryNames.joined(separator: ", ")
        
        let distanceMeters = json["distance"].doubleValue
        let milesPerMeter = 0.000621371
        let distance = String(format: "%.2f mi", milesPerMeter * distanceMeters)
        
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
        
        let latitude = json["coordinates", "latitude"].doubleValue
        let longitude = json["coordinates", "longitude"].doubleValue
        
        let reviewCount = json["review_count"].intValue
        return Business(name: name, address: address, imageURL: imageURL, categories: categories, distance: distance, ratingImage: ratingImage, reviewCount: reviewCount, latitude: latitude, longitude: longitude)
    }
}
