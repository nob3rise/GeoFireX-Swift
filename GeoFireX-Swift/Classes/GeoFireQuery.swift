//
//  GeoFireQuery.swift
//  GeoFireX-Swift
//
//  Created by Nob on 2020/05/10.
//  Copyright © 2020 Nob. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

public struct GeoQueryOptions {
    enum Unit {
        case kilometer
        case meter
    }
    
    let units: Unit!
    let log: Bool!
}

public class GeoFireQuery {
    var collectionRef : CollectionReference
    let defaultOption = GeoQueryOptions(units: .kilometer, log: false)
    
    public convenience init(_ collectionRef : CollectionReference) {
        self.init(collectionRef: collectionRef)
    }
    
    init(collectionRef : CollectionReference) {
        self.collectionRef = collectionRef
    }
    
    public func within(center: FirePoint, radius: Double, field: String, opts: GeoQueryOptions?) -> AnyPublisher<[[String:Any]],Never>? {
        let options : GeoQueryOptions! = (opts != nil) ? opts : defaultOption
        let precision = Geohash.setPrecision(radius)
        let radiusBuffer = radius * 1.02
        let centerHash = String(center.geohash.prefix(precision))
        guard var area = Geohash.neighbors(hashStr: centerHash) else { return nil }
        area.append(centerHash)
        
        let dataListPublisher = getDataListPublisher(area: area, field: field)
        
        if (options?.log == true) {
            print("GeoFireX Query: 🌐 Center \(center.geopoint.latitude), \(center.geopoint.longitude). Radius \(radius)")
        }
        
        return dataListPublisher.map { (dataList) -> [[String: Any]] in
            if (options?.log == true) {
                print("GeoFireX Query: 📍 Hits: \(dataList.count)")
            }
            
            let filteredList = dataList.filter { (data) -> Bool in
                let geo = data[field] as! [String: Any]
                let geoPoint = geo["geopoint"] as! GeoPoint
                
                var distance = center.geopoint.distance(to: geoPoint)
                if (options?.units == GeoQueryOptions.Unit.kilometer) {
                    distance = distance / 1000
                }
                return distance <= radiusBuffer
            }
            
            if (options?.log == true) {
                print("GeoFireX Query: 🟢 Within Radius: \(filteredList.count)")
            }
            
            return filteredList.map { (data) -> [String: Any] in
                var newData = data
                let geo = data[field] as! [String: Any]
                let geoPoint = geo["geopoint"] as! GeoPoint
                
                var distance = center.geopoint.distance(to: geoPoint)
                if (options?.units == GeoQueryOptions.Unit.kilometer) {
                    distance = distance / 1000
                }
                let hitMetadata = [ "distance": distance,
                                    "bearing": center.geopoint.bearing(to: geoPoint)]
                newData["hitMetadata"] = hitMetadata
                return newData
            }.sorted { (first, second) -> Bool in
                let hitMetaFirst = first["hitMetadata"] as! [String: Any]
                let distanceFirst = hitMetaFirst["distance"] as! Double
                let hitMetaSecond = second["hitMetadata"] as! [String: Any]
                let distanceSecond = hitMetaSecond["distance"] as! Double
                return distanceFirst < distanceSecond
            }
        }.eraseToAnyPublisher()
    }
    
    public func getDataListPublisher(area:[String], field: String) -> AnyPublisher<[[String:Any]],Never> {
        var publishers = [PassthroughSubject<QuerySnapshot,Never>]()
        
        area.forEach { (geohash) in
            let query = queryPoint(geohash: geohash, field: field)
            let publisher = PassthroughSubject<QuerySnapshot,Never>()
            query.addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                publisher.send(snapshot)
                publisher.send(completion: Subscribers.Completion<Never>.finished)
            }
            publishers.append(publisher)
        }
        
        let merged = Publishers.MergeMany(publishers).collect().compactMap { snapshots -> [[String: Any]] in
            snapshots.reduce([[String: Any]]()) { dataList, snapshot -> [[String: Any]] in
                let newList = snapshot.documents.compactMap { document -> [String:Any] in
                    var data = document.data()
                    data["id"] = document.documentID
                    return data
                }
                return dataList + newList
            }
        }.eraseToAnyPublisher()
        
        return merged
    }
    
    public func queryPoint(geohash: String, field: String) -> Query {
        return collectionRef
            .order(by: "\(field).geohash")
            .start(at: [geohash])
            .end(at: ["\(geohash)~"])
    }
}
