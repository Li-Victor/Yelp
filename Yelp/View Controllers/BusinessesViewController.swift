//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/10/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import SwiftyJSON

class BusinessesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let yelpAPIKey = APIKeys.YELP.rawValue
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=Thai&latitude=37.785771&longitude=-122.406165")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                print(JSON(data))
            }
            
        }
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
