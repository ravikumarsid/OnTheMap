//
//  StudentsArray.swift
//  On the Map
//
//  Created by Ravi Kumar Venuturupalli on 5/5/18.
//  Copyright © 2018 Ravi Kumar Venuturupalli. All rights reserved.
//

import UIKit

class StudentsArray: NSObject {
    
    static let sharedInstance = StudentsArray()
    
     var allStudents: [Students] = []
}
