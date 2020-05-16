//
//  Util.swift
//  GeoFireX-Swift
//
//  Created by Nob on 2020/05/10.
//  Copyright © 2020 Nob. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension GeoPoint {
    
    var latitudeInRadian : Double {
        get {
            return latitude * .pi / 180.0
        }
    }
    
    var longitudeInRadian : Double {
        get {
            return longitude * .pi / 180.0
        }
    }
    
    public func distance(to: GeoPoint) -> Double {
        let a = pow(sin((to.latitudeInRadian - self.latitudeInRadian) / 2), 2)
            + pow(sin((to.longitudeInRadian - self.longitudeInRadian) / 2), 2) * cos(self.latitudeInRadian) * cos(to.latitudeInRadian)
        return 2 * atan2(sqrt(a), sqrt(1 - a)) * 6_373_000.0
    }
    
    public func bearing(to: GeoPoint) -> Double {
        let a = sin(to.longitudeInRadian - self.longitudeInRadian) * cos(to.latitudeInRadian)
        let b = cos(self.latitudeInRadian) * sin(to.latitudeInRadian) - sin(self.latitudeInRadian) * cos(to.latitudeInRadian) * cos(to.longitudeInRadian - self.longitudeInRadian)
        return atan2(a, b) * 180.0 / .pi
    }
}
