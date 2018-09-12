//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/10/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import SwiftyJSON

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    var searchBar: UISearchBar!
    
    var businesses: [Business] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isMoreDataLoading = false
    var loadingMorePostsActivityView: InfiniteScrollActivityView?
    
    func parseToBusiness(json: JSON) -> Business {
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
        
        let reviewCount = json["review_count"].intValue
        return Business(name: name, address: address, imageURL: imageURL, categories: categories, distance: distance, ratingImage: ratingImage, reviewCount: reviewCount)
    }
    
    func fetchBusinesses(for term: String = "", offset: Int = 0) {
        let yelpAPIKey = APIKeys.YELP.rawValue
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=\(term)&latitude=37.785771&longitude=-122.406165&offset=\(offset)")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMorePostsActivityView!.stopAnimating()
            
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self.businesses += JSON(data)["businesses"].arrayValue.map { self.parseToBusiness(json: $0) }
            }
            
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creating search bar
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        navItem.titleView = searchBar
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMorePostsActivityView = InfiniteScrollActivityView(frame: frame)
        loadingMorePostsActivityView!.isHidden = true
        tableView.addSubview(loadingMorePostsActivityView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        fetchBusinesses()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMorePostsActivityView?.frame = frame
                loadingMorePostsActivityView!.startAnimating()
                
                fetchBusinesses(for: searchBar.text!, offset: businesses.count)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell") as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.businesses = []
        fetchBusinesses()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 0 {
            self.businesses = []
            searchBar.resignFirstResponder()
            fetchBusinesses(for: text)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
