//
//  MapTableViewController.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/11/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class MapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var studenTableView: UITableView!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    var student_locations_array = [Students]()
    //var allStudents: [Students] = []
    
    func getStudentLocations() {
        let url: String = ParseMethods.GetStudentLocations
        var headers: [String:String] = [:]
        var parameters: [String:AnyObject] = [:]
        
        parameters["order"] = "-updatedAt" as AnyObject
        parameters["limit"] = 100 as AnyObject
        
        headers["X-Parse-Application-Id"] = ParseConstants.ParseApplicationId
        headers["X-Parse-REST-API-Key"] = ParseConstants.ParseRESTAPIKey
        
        let spinnerView = UIViewController.displaySpinner(onView: self.view)
        
        let task = UdacityClient.sharedInstance.taskForGETMethod(url, headers: headers, parameters: parameters, isSubDataNeeded:  false) { (results, error) in
            UIViewController.removeSpinner(spinner: spinnerView)
            
            if let error = error {
                print(error)
                if error.localizedDescription == "The device is not connected to the internet." {
                    self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
                    
                } else {
                    self.displayAlert(alertTitle: "Something went wrong", alertMesssage: "Please try again later.")
                }
            } else {
                
                guard let resultsArrayOfDictionaries = results!["results"] as? [[String:AnyObject]] else {
                    print("No key called results in \(String(describing: results))")
                    return
                }
                
                Students.studentsData = resultsArrayOfDictionaries
                StudentsArray.sharedInstance.allStudents = Students.allStudentLocations
                
                DispatchQueue.main.async {
                    self.viewDidLoad()
                    self.studenTableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsArray.sharedInstance.allStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell")
        cell?.textLabel?.text = StudentsArray.sharedInstance.allStudents[indexPath.row].firstName
        cell?.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        cell?.detailTextLabel?.text = StudentsArray.sharedInstance.allStudents[indexPath.row].mediaURL
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: StudentsArray.sharedInstance.allStudents[indexPath.row].mediaURL)!, options: [:], completionHandler: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar.clipsToBounds = true
        studenTableView.delegate = self
        studenTableView.dataSource = self
        studenTableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getStudentLocations()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func displayAlert(alertTitle: String, alertMesssage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMesssage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let spinnerView = UIViewController.displaySpinner(onView: self.view)
        let _ = UdacityClient.sharedInstance.logoutSession { (results, error) in
            UIViewController.removeSpinner(spinner: spinnerView)
            if error != nil {
                print(String(describing: error))
                return
            }
            else {
                 FBSDKAccessToken.setCurrent(nil)
                let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
                fbLoginManager.logOut()
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
    @IBAction func refreshTapped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() != true {
            self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
            return
        }
        DispatchQueue.main.async {
            self.getStudentLocations()
        }
    }
}
