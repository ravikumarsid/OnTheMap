//
//  UdacityClient.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/21/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    var session = URLSession.shared
    var sessionID: String? = nil
    var userID: String? = nil
    var userFirstName: String? = nil
    var userLastName: String? = nil
    var userUniqueKey: String? = nil
    
    func taskForGETMethod(_ url: String, headers: [String:String]? = nil, isSubDataNeeded: Bool? = true, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) ->URLSessionDataTask {
        
        print("Get request url: \(url)")
        var request = URLRequest(url: URL(string: url)!)
        
        if let headers = headers {
            for (key, val) in headers {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }

        let task = session.dataTask(with: request) { (data, response, error) in

            func sendError (error: String) {
                let userinfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userinfo))
            }
 
            if Reachability.isConnectedToNetwork() != true{
                sendError(error: "The device is not connected to the internet.")
                return
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error in your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2XX!")
                return
            }
            
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            if isSubDataNeeded! {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                print("old data: \(String(data: data, encoding: .utf8)!)")
                print("new data: \(String(data: newData, encoding: .utf8)!)")
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            }

        }
        task.resume()
        return task
    }

    
    func taskForStudentLocationPOSTMethod( jsonBody: String, completiohHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        var request = URLRequest(url: URL(string: createURLForStudentLocations().absoluteString)!)
        
        request.httpMethod = "POST"
        request.addValue(ParseConstants.ParseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ParseRESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        print("Json body: \(jsonBody)")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                let userinfo = [NSLocalizedDescriptionKey : error]
                completiohHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userinfo))
            }
            
            if Reachability.isConnectedToNetwork() != true{
                sendError("The device is not connected to the internet.")
                return
            }
            guard (error == nil) else {
                sendError("There was an error in your request: \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completiohHandlerForPOST)
        }
        task.resume()
        return task
    }

    
    func loginPOSTRequest(emailId: String, password: String, completionHandlerForLogin: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(emailId)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(_ error: String)  {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForLogin(nil, NSError(domain: "taskForLogin", code: 1, userInfo: userInfo))
            }
            
            if Reachability.isConnectedToNetwork() != true{
                sendError("The device is not connected to the internet.")
                return
            }
            
            if error != nil{
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            print(String(data: newData, encoding: .utf8)!)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForLogin)
        }
        task.resume()
        return task
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            //print("Parsed result: \(parsedResult)")
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            print("JSON data error: \(data))")
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
        
    }
    
    private func createURLForStudentLocations( withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = ParseConstants.ApiScheme
        components.host = ParseConstants.ApiHost
        components.path = ParseConstants.ApiPath + (withPathExtension ?? "")
        
        return components.url!
    }
    
    func logoutSession(completionHandlerForLogout: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: UdacityConstants.AuthorizationURL)!)
        var xsrfCookie: HTTPCookie? = nil
        request.httpMethod = "DELETE"
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = UdacityClient.sharedInstance().session
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(String(describing:error) )
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            print("New Data: \(String(describing: String(data: newData!, encoding: .utf8)))")
            
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForLogout)
        }
        task.resume()
        
        return task
    }
    
    func getUdacityUserData(userID: String) {
        
        let url = "https://www.udacity.com/api/users/" + userID
        
        let _ = taskForGETMethod(url) { (results, error) in
            if let error = error {
                print(error)
            } else {
                print("Error getUserData res1 : \(String(describing: results))")
                if let results = results!["user"] as? [String:Any] {
                    print("Error getUserData res: \(results)")
                    let userNickName: String = (results["nickname"] as? String)!
                    print("User Nickname: \(userNickName)")
                    let newuserFirstName: String = (results["first_name"] as? String)!
                    let newuserLastName: String = results["last_name"] as! String
                    let newuserUniqueKey: String = (results["key"] as? String)!
                    
                    print("Firts name: \(String(describing: newuserFirstName)) LastName: \(String(describing: newuserLastName)) Unique Key: \(String(describing: newuserUniqueKey))")
                    
                    UdacityClient.sharedInstance().userFirstName = newuserFirstName
                    UdacityClient.sharedInstance().userLastName = newuserLastName
                    UdacityClient.sharedInstance().userUniqueKey = newuserUniqueKey
                }
            }
        }
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
