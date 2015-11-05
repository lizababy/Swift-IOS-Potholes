//
//  PotHole.swift
//  Potholes
//
//  Created by Liza Linto on 11/5/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import Foundation

struct PotHole {
    let type : Type
    let id : Int
    let latitude : Float
    let longitude : Float
    let imageType : String
    let description : String
    let date : NSDate
    let user : String
    
}
struct Type {
    
    let typeId : Int
    let description : String
}
