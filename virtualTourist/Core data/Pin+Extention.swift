//
//  Pin+Extention.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 07/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    
    public override func awakeFromInsert() {
           super.awakeFromInsert()
           creationDate = Date()
       }
    public var coordinate: CLLocationCoordinate2D {
        
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

