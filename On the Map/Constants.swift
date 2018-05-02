//
//  Constants.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/12/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import Foundation

struct ParseMethods {
    static let GetStudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation"
}

struct ParseConstants {
    static let ParseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ParseRESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let ApiScheme = "https"
    static let ApiHost = "parse.udacity.com"
    static let ApiPath = "/parse/classes/StudentLocation"
}

struct ParseMethodsExt {
    static let GetStudentLocations = "/classes/StudentLocation"
}

struct UdacityConstants {
    static let AuthorizationURL = "https://www.udacity.com/api/session"
}



struct ResponseKeys {
    static let status = "status"
    static let account = "account"
    static let session = "session"
    static let accountRegistered = "registered"
}


