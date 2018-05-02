//
//  HomePageViewController.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/7/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbartop: UIToolbar!
    var allStudents: [Students] = []
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        toolbartop.clipsToBounds = true
        
        for dictionary in allStudents {
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let firstName = dictionary.firstName
            let lastName = dictionary.lastName
            let mediaUrl = dictionary.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaUrl
            
            annotations.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getStudentLocations()
        self.navigationController?.isNavigationBarHidden = true
    }
  
    func getStudentLocations() {
        let url: String = ParseMethods.GetStudentLocations
        var headers: [String:String] = [:]
        
        headers["X-Parse-Application-Id"] = ParseConstants.ParseApplicationId
        headers["X-Parse-REST-API-Key"] = ParseConstants.ParseRESTAPIKey
        
        let spinnerView = UIViewController.displaySpinner(onView: self.view)
        let task = UdacityClient.sharedInstance().taskForGETMethod(url, headers: headers, isSubDataNeeded:  false) { (results, error) in
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
            self.allStudents = Students.allStudentLocations
            
            DispatchQueue.main.async {
                self.viewDidLoad()
                self.mapView.addAnnotations(self.annotations)
                }
            }
        }
        task.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView =  UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            UIApplication.shared.open(URL(string: (view.annotation?.subtitle!)!)!, options: [:], completionHandler: nil)
        }
    }
    
    func displayAlert(alertTitle: String, alertMesssage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMesssage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() != true {
            self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
            return
        }
        self.getStudentLocations()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
         let spinnerView = UIViewController.displaySpinner(onView: self.view)
        let _ = UdacityClient.sharedInstance().logoutSession { (results, error) in
            UIViewController.removeSpinner(spinner: spinnerView)
            if error != nil {
                print(String(describing: error))
                return
            } else {
                let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
                fbLoginManager.logOut()
                
                DispatchQueue.main.async {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(controller, animated: true, completion: nil)
                }
           
            }
        }
    }
    
}
