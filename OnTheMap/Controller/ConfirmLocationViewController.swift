//
//  ConfirmLocationViewController.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 19/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: StudentLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupMap()
    }
    
    @IBAction func finishTapped(_ sender: UIButton) {
        
        API.Parser.postLocation(self.location!) { (err) in
            guard err == nil else {
                self.showAlert(title: "Error", message: err!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    private func setupMap() {
        guard let location = location else { return }
        
        let lat = CLLocationDegrees(location.latitude!)
        let long = CLLocationDegrees(location.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location.mapString
        
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }

}

extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
