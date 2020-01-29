//
//  TableTableViewController.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 18/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class TableViewController: ContainerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override var locationsData: LocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.results
        }
    }
    var locations: [StudentLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentTableViewCell
     
        cell.studentLocation = locations[indexPath.row]
     
        return cell
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let studentLocation = locations[indexPath.row]
        let mediaURL = studentLocation.mediaURL!
        let url = URL(string: mediaURL)!
//        guard let mediaURL = studentLocation.mediaURL, let url = URL(string: mediaURL), UIApplication.shared.canOpenURL(url) else {
//            self.showAlert(title: "Error", message: "Invalid url")
//            return
//        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
 
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
