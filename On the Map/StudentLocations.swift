//
//  StudentLocations.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 4/14/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import Foundation

struct Students {
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let objectID: String
    let uniqueKey: String
    let mapString: String
    let createdAt: String
    let updatedAt: String
    
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let mediaURLKey = "mediaURL"
    static let latitideKey = "latitude"
    static let longitudeKey = "longitude"
    static let objectIDKey = "objectId"
    static let uniqueKeyKey = "uniqueKey"
    static let mapStringKey = "mapString"
    static let createdAtKey = "createdAt"
    static let updatedAtKey = "updatedAt"
    
    init(dictionary: [String:Any]) {
        self.firstName = dictionary[Students.firstNameKey] as? String ?? ""
        self.lastName = dictionary[Students.lastNameKey] as? String ?? ""
        self.mediaURL = dictionary[Students.mediaURLKey] as? String ?? "http://en.wikipedia.org"
        self.latitude = dictionary[Students.latitideKey] as? Double ?? -1
        self.longitude = dictionary[Students.longitudeKey] as? Double ?? -1
        self.objectID = dictionary[Students.objectIDKey]! as! String
        self.uniqueKey = dictionary[Students.uniqueKeyKey] as? String ?? ""
        self.mapString = dictionary[Students.mapStringKey] as? String ?? "New York, NY"
        self.createdAt = dictionary[Students.createdAtKey]! as! String
        self.updatedAt = dictionary[Students.updatedAtKey]! as! String
    }
}

extension Students {
    
    //Generate array full of all student location data
    static var allStudentLocations: [Students] {
        var studentsArray = [Students]()
        for s in Students.studentsData {
            studentsArray.append(Students(dictionary: s))
        }
        
        return studentsArray
    }
    
    static var studentsData: [[String:Any]] = [[String:Any]]()
}
