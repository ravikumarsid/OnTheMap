//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/14/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    var longitude: CLLocationDegrees = 40.755931
    var latitude: CLLocationDegrees = -73.984606
    var locationName: String = "New York, NY"
    var annotation = MKPointAnnotation()
    
    
    var geocoder = CLGeocoder()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar.clipsToBounds = true
        mapView.delegate = self
        locationTextField.delegate = self
        websiteTextField.delegate = self
     
    }

    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(true)
           self.mapViewHidden(isHidden: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        	self.view.endEditing(true)
            return true
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func finishButtonTapped(_ sender: Any) {
        //Post Student location
         let spinnerView = UIViewController.displaySpinner(onView: self.view)
        
        let jsonLocation = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance.userUniqueKey!)\",\"firstName\": \"\(UdacityClient.sharedInstance.userFirstName!)\",\"lastName\": \"\(UdacityClient.sharedInstance.userLastName!)\",\"mapString\": \"\(self.locationName)\",\"mediaURL\": \"\(self.websiteTextField.text!)\",\"latitude\": \(self.latitude),\"longitude\": \(self.longitude)}"

        let _ = UdacityClient.sharedInstance.taskForStudentLocationPOSTMethod(jsonBody: jsonLocation) { (results, error) in
            UIViewController.removeSpinner(spinner: spinnerView)
            if let error = error {
                print(error)
                print("localizes description: \(error.localizedDescription)")
                if error.localizedDescription == "The device is not connected to the internet." {
                    self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
                    return
                    
                } else {
                    self.displayAlert(alertTitle: "Something went wrong", alertMesssage: "Please try again.")
                    return
                }
            } 
                    self.cancelTapped(self.view)
            
        }
        
    }
    
    @IBAction func findLocationTapped(_ sender: Any) {
        if ((locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))?.isEmpty)! || ((websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))?.isEmpty)!{
            self.displayAlert(alertTitle: "Invalid location/url", alertMesssage: "Please enter valid location and url")
        }
        else {
            let address = (locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))
            let spinnerView = UIViewController.displaySpinner(onView: self.view)
            geocoder.geocodeAddressString(address!) { (placemarks, error) in
                UIViewController.removeSpinner(spinner: spinnerView)
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
            
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print(error)
            print("localizes description: \(error.localizedDescription)")
            if error.localizedDescription == "The device is not connected to the internet." {
                self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
                return
                
            } else {
            print("Unable to forward geocode address \(error)")
            self.displayAlert(alertTitle: "Location Error", alertMesssage: "Unable to find location for address")
            }
        } else {
            var loc: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                loc = placemarks.first?.location
                let countryName = placemarks.first?.country
                self.locationName = (placemarks.first?.locality!)! + ", " + (placemarks.first?.administrativeArea!)! + ", " + countryName!
            }
            if let loc = loc {
                let coordinate = loc.coordinate
                print("The coordinates are: Lat:\(coordinate.latitude) Long:\(coordinate.longitude)")
                self.location = loc
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                
                _ = self.textFieldShouldReturn(locationTextField)
                _ = self.textFieldShouldReturn(websiteTextField)
                self.mapViewHidden(isHidden: false)
                self.hideTextFields(isHidden: true)
                
                self.annotation.coordinate = (self.location?.coordinate)!
                self.annotation.title = "\(self.locationName)"
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(self.annotation)
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
                
            } else {
                self.displayAlert(alertTitle: "Location Error", alertMesssage: "Unable to find location for address")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func displayAlert(alertTitle: String, alertMesssage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMesssage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapViewHidden(isHidden: Bool){
        self.mapView.isHidden = isHidden
        self.finishButton.isHidden = isHidden
    }
    
    func hideTextFields(isHidden: Bool){
        self.locationTextField.isHidden = isHidden
        self.websiteTextField.isHidden = isHidden
        self.findLocationButton.isHidden = isHidden
    }
    
}
