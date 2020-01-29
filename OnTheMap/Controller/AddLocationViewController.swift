//
//  AddLocationViewController.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 19/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaLinkTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotificationsObserver()
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        guard let location = locationTextField.text,
              let mediaLink = mediaLinkTextField.text,
              location != "", mediaLink != "" else {
            self.showAlert(title: "Missing information", message: "Please fill both fields and try again")
            return
        }
        
        let studentLocation = StudentLocation.init(createdAt: "",
                                                   firstName: nil,
                                                   lastName: nil,
                                                   latitude: 0,
                                                   longitude: 0,
                                                   mapString: location,
                                                   mediaURL: mediaLink,
                                                   objectId: "",
                                                   uniqueKey: "",
                                                   updatedAt: "")
        pass(studentLocation)
    }
    
    private func pass(_ location: StudentLocation) {
        let geocoder = CLGeocoder()
        let ai = self.startAnActivityIndicator()
        geocoder.geocodeAddressString(location.mapString!) { (placeMarks, _) in
            ai.stopAnimating()
            guard let marks = placeMarks else {
                self.showAlert(title: "Error", message: "Couldn't geocode you're location. Please try again.")
                return
            }
            
            var studentLocation = location
            studentLocation.longitude = Float((marks.first!.location?.coordinate.longitude)!)
            studentLocation.latitude = Float((marks.first!.location?.coordinate.latitude)!)
            self.performSegue(withIdentifier: "mapSegue", sender: studentLocation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue", let vc = segue.destination as? ConfirmLocationViewController {
            vc.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelTapped(_:)))
        
        locationTextField.delegate = self
        mediaLinkTextField.delegate = self
    }
    
    @objc private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}


