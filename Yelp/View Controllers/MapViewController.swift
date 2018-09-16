//
//  MapViewController.swift
//  Yelp
//
//  Created by Victor Li on 9/15/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    var mapAnnotations: [MKAnnotation] = []
    var userLatitude: CLLocationDegrees!
    var userLongitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up nav bar
        navItem.leftBarButtonItem =  UIBarButtonItem(title: "Back", style: .plain, target: nil, action: #selector(MapViewController.goBack(_:)))
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude), span)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotations(mapAnnotations)
    }
    
    @objc func goBack(_ navLeftBar: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
