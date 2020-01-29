//
//  ContainerViewController.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 18/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var locationsData: LocationsData?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .fullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadStudentLocations()
    }
    
    func setupUI() {
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocationTapped(_:)))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshLocationsTapped(_:)))
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutTapped(_:)))
        
        navigationItem.rightBarButtonItems = [plusButton, refreshButton]
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc private func addLocationTapped(_ sender: Any) {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func refreshLocationsTapped(_ sender: Any) {
        loadStudentLocations()
    }
    
    @objc private func logoutTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you wnat to logout?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            API.deleteSession { (err) in
                guard err == nil else {
                    self.showAlert(title: "Error", message: err!)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func loadStudentLocations() {
        let ai = startAnActivityIndicator()
        API.Parser.getStudentLocations { (data) in
            ai.stopAnimating()
            guard let data = data else {
                self.showAlert(title: "Error", message: "No internet connection found")
                return
            }
            guard data.results.count > 0 else {
                self.showAlert(title: "Error", message: "No pins found")
                return
            }
            self.locationsData = data
        }
    }
    
    @IBAction func anythign(_ sender: Any) {
        
    }

}
