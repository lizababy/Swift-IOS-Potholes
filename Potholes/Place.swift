//
//  PPlace.swift
//  Potholes
//
//  Created by Liza Linto on 11/8/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import Foundation
import MapKit

class Place : NSObject, MKAnnotation {
    let id : Int?
    let title:String?
    let subtitle:String?
    var coordinate:CLLocationCoordinate2D
    
    init(id: Int, title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}