//
//  ViewController.swift
//  PinSample
//
//  Created by Jason on 3/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

/**
* This view controller demonstrates the objects involved in displaying pins on a map.
*
* The map is a MKMapView.
* The pins are represented by MKPointAnnotation instances.
*
* The view controller conforms to the MKMapViewDelegate so that it can receive a method 
* invocation when a pin annotation is tapped. It accomplishes this using two delegate 
* methods: one to put a small "info" button on the right side of each pin, and one to
* respond when the "info" button is tapped.
*/

class MapViewController: ContainerViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override var locationsData: LocationsData? {
        didSet {
            updatePins()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
//    func getLcoations() {
//        guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = HTTPMethod.get.rawValue
//        request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
//        request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//            var studentLocations: [StudentLocation] = []
//            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
//                if statusCode < 400 { //Response is ok
//                    
//                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
//                        let dict = json as? [String:Any],
//                        let results = dict["results"] as? [Any] {
//                        
//                        for location in results {
//                            let data = try! JSONSerialization.data(withJSONObject: location)
//                            let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
//                            studentLocations.append(studentLocation)
//                        }
//                        
//                    }
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self.locationsData = LocationsData(studentLocations: studentLocations)
//            }
//            
//        }
//        task.resume()
//    }
    
    func updatePins() {
        guard let locations = locationsData?.results else { return }
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        for location in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            guard let locationLat = location.latitude, let locationLong = location.longitude else { continue }
            let lat = CLLocationDegrees(locationLat)
            let long = CLLocationDegrees(locationLong)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first ?? "") \(last ?? "")"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate

    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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

    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
//    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
//        if control == annotationView.rightCalloutAccessoryView {
//            let app = UIApplication.sharedApplication()
//            app.openURL(NSURL(string: annotationView.annotation.subtitle))
//        }
//    } 
}
