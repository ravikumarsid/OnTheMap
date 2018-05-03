//
//  ViewController.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/7/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign up")
        attributedString.addAttribute(.link, value: "https://www.udacity.com/account/auth#!/signup", range: NSRange(location: 23, length: 7))
        signUpTextView.attributedText = attributedString
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        let bottomOffset = 20
        
        loginButton.frame.origin = CGPoint(x: self.view.center.x - (loginButton.frame.size.width/2), y: self.view.frame.size.height - loginButton.frame.size.height - CGFloat(bottomOffset))
        view.addSubview(loginButton)
      self.facebookLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.facebookLogin()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
    func loginWith(email: String, password: String) {
        let spinnerView = UIViewController.displaySpinner(onView: self.view)
        
        let _ = UdacityClient.sharedInstance().loginPOSTRequest(emailId: email, password: password) { (results, error) in
            UIViewController.removeSpinner(spinner: spinnerView)
            if let error = error {
                print(error)
                if error.localizedDescription == "The device is not connected to the internet." {
                    self.displayAlert(alertTitle: "Check Internet connection", alertMesssage: "The device is not connected to the internet.")
                    
                } else {
                    self.displayAlert(alertTitle: "No user found", alertMesssage: "Account not found or invalid credentials.")
                }
            } else {
                if let accountLogin = results?[ResponseKeys.account] as? [String:AnyObject], let accountRegistered = accountLogin[ResponseKeys.accountRegistered] as? Bool {
                    print("Account login: \(accountLogin) is registered: \(accountRegistered)" )
                    
                    self.completeLogin()
                    UdacityClient.sharedInstance().getUdacityUserData(userID:  UdacityClient.sharedInstance().userID!)
                }
            }
        }
    }
    
    func completeLogin(){
        DispatchQueue.main.async {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (email!.isEmpty) || (password!.isEmpty) {
            self.displayAlert(alertTitle: "Invalid username/password", alertMesssage: "Please enter valid username and password")
        }
        else {
            UdacityClient.sharedInstance().userID = self.emailField.text
            self.loginWith(email: email!, password: password!)
        }
    }
    
    func displayAlert(alertTitle: String, alertMesssage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMesssage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func facebookLogin(){
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (email!.isEmpty) || (password!.isEmpty) {
            if (FBSDKAccessToken .current() != nil) {
                DispatchQueue.main.async {
                    self.completeLogin()
                }
            }
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let fbDetails = result as! NSDictionary
                    print(fbDetails)
                    guard let lastName = fbDetails["last_name"], let firstName = fbDetails["first_name"], let key = fbDetails["id"]  else {
                        return
                    }
                    UdacityClient.sharedInstance().userFirstName = firstName as? String
                    UdacityClient.sharedInstance().userLastName = lastName as? String
                    UdacityClient.sharedInstance().userUniqueKey = key as? String
                    
                }else{
                    print(error?.localizedDescription ?? "Not found")
                }
            })
        }
    }
}

