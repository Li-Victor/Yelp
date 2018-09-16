//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/10/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    var searchBar: UISearchBar!
    
    var businesses: [Business] = [] {
        didSet {
            tableView.reloadData()
            updateMap()
        }
    }
    
    var isMoreDataLoading = false
    var loadingMorePostsActivityView: InfiniteScrollActivityView?
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var first = true
    

    func updateMap() {
        
        // recenters to user location
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span)
        mapView.setRegion(region, animated: false)
        
        // map annotations
        mapView.removeAnnotations(mapView.annotations)
        for business in businesses {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: business.latitude, longitude: business.longitude)
            annotation.title = business.name
            mapView.addAnnotation(annotation)
        }
    }
    
    func fetchBusinesses(for term: String = "", offset: Int = 0) {
        guard let latitude = latitude, let longitude = longitude else {
            return
        }
        
        let yelpAPIKey = APIKeys.YELP.rawValue
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=\(term)&latitude=\(latitude)&longitude=\(longitude)&offset=\(offset)")!
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
                self.businesses += JSON(data)["businesses"].arrayValue.map { Business.parseToBusiness(json: $0) }
            }
            
        }
        task.resume()
    }

    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            break
            
        case .restricted, .denied:
            // Disable location features
            print("disableMyLocationBasedFeatures")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            print("enableMyWhenInUseFeatures")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            locationManager.stopUpdatingLocation()
            print("disableMyLocationBasedFeatures")
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        case .notDetermined:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // global locationManager? let coords = locationManager.location!.coordinate
        // using function parameters? let coords = manager.location!.coordinate
        let coords = locations.last!.coordinate
        latitude = coords.latitude
        longitude = coords.longitude
        print("latitude: \(latitude), longitude: \(longitude)")
        
        if first {
            first = false
            fetchBusinesses(for: "")
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegionMake(coords, span)
            mapView.setRegion(region, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
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
        
        enableLocationServices()
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
