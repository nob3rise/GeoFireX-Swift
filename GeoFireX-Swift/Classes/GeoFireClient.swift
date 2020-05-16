//
//  GeoFireClient.swift
//  GeoFireX-Swift
//
//  Created by Nob on 2020/05/10.
//  Copyright © 2020 Nob. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

public class FirePoint {
    var geopoint: GeoPoint
    var geohash: String
    
    public init(geopoint : GeoPoint) {
        self.geopoint = geopoint
        geohash = Geohash.encode(latitude: geopoint.latitude, longitude: geopoint.longitude, length: 9)
    }
}

public class GeoFireClient {

    public func query(_ collectionPath : String) -> GeoFireQuery {
        if (FirebaseApp.app() != nil) {
            let collectionRef = Firestore.firestore().collection(collectionPath)
            return GeoFireQuery(collectionRef)
        } else {
            print("FirebaseApp is not initialized")
            exit(EXIT_FAILURE)
        }
    }
}

