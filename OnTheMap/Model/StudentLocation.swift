//
//  StudentLocation.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 15/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct StudentLocation {
    var createdAt: String?
    var firstName: String?
    var lastName: String?
    var latitude: Float?
    var longitude: Float?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: String?
}


extension StudentLocation: Codable {
    
}

enum SLParam: String {
    case createdAt
    case firstName
    case lastName
    case latitude
    case longitude
    case mapString
    case mediaURL
    case objectId
    case uniqueKey
    case updatedAt
}
