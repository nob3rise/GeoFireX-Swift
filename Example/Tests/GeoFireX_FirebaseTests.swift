//
//  GeoFireX-FirebaseTests.swift
//  GeoFireX-SwiftTests
//
//  Created by Nob on 2020/05/12.
//  Copyright © 2020 Nob. All rights reserved.
//

import XCTest
import Firebase
import Combine
@testable import GeoFireX_Swift

let testData = [
    [
        "imgUrl": "https://test.test/test.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都千代田区２丁目神田多町",
        "vehicleType": "all",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.69289379194334, longitude: 139.77010741642454),
            "geohash": "xn77h99qp"
        ]
    ],
    [
        "imgUrl": "https://test.test/test.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都中央区日本橋本石町１２丁目",
        "vehicleType": "all",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.68606130826235, longitude: 139.77109446934202),
            "geohash": "xn77h86nq"
        ]
    ],
    [
        "imgUrl": "https://test.test/test.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都中央区１浜離宮庭園",
        "vehicleType": "all",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.660969765456294, longitude: 139.76206926911019),
            "geohash": "xn76u7gsh"
        ]
    ],
    [
        "imgUrl": "https://test.test/test.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都中央区築地６丁目",
        "vehicleType": "all",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.66379401503355, longitude: 139.7735276660218),
            "geohash": "xn76us7ux"
        ]
    ],
    [
        "imgUrl": "https://test.test/test.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都中央区新川１丁目",
        "vehicleType": "all",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.67558789946598, longitude: 139.78345071539033),
            "geohash": "xn76us7ux"
        ]
    ],
    [
        "imgUrl": "https://sadfas.sss/sdfas.jpg",
        "imgTimeStamp": Timestamp(date: Date()),
        "address": "東京都千代田区一ツ橋２丁目",
        "vehicleType": "bike",
        "createTime": Timestamp(date: Date()),
        "geography": [
            "geopoint": GeoPoint(latitude: 35.692928645885566, longitude: 139.75710406712034),
            "geohash": "xn77h38n2"
        ]
    ]]

class GeoFireX_FirebaseTests: XCTestCase {
    override func setUpWithError() throws {
        FirebaseTestHelper.setupFirebaseApp()
        
        let db = Firestore.firestore()
        let markers = testData
        
        markers.map { marker -> Void in
            var ref: DocumentReference? = nil
            //        db.collection("markers").document("5QHv5ZT9ZAv8trs7l37y").setData(
            ref = db.collection("markers").addDocument(data: marker) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }  else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    override func tearDownWithError() throws {
        FirebaseTestHelper.deleteFirebaseApp()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSetAndGetCollection() throws {

        let expectation = XCTestExpectation(description: "Complete getting data")
        
        let db = Firestore.firestore()
        let geohashList = ["xn77h99qp", "xn77h86nq", "xn76u7gsh"]
        var publishers = [PassthroughSubject<QuerySnapshot,Never>]()
        var resultData = [[String:Any]]()
        
        geohashList.forEach { geohash in
            let getQuery = db.collection("markers").order(by: "geography.geohash").start(at: [geohash]).end(at: ["\(geohash)~"])
            let publisher = PassthroughSubject<QuerySnapshot,Never>()
            getQuery.addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                publisher.send(snapshot)
                publisher.send(completion: Subscribers.Completion.finished)
            }
            publishers.append(publisher)
        }
        
        let mergedPub = Publishers.MergeMany(publishers).compactMap { snapshot -> [[String: Any]] in
            snapshot.documents.compactMap { document -> [String:Any] in
                var data = document.data()
                data["id"] = document.documentID
                return data
            }
        }
        
        let subscriber = mergedPub.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print(".sink() received the completion:", String(describing: completion))
                XCTAssert(resultData.count > 0)
                expectation.fulfill()
                break
            case .failure(let anError):
                print("received the error: ", anError)
                break
            }
        }) { (dataList) in
            resultData = resultData + dataList
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testWithin() {
        let client = GeoFireClient()
        let query = client.query("markers")
        let center = FirePoint(geopoint: GeoPoint(latitude: 35.68123620000001, longitude: 139.7671248))
        
        let expectation = XCTestExpectation(description: "Complete getting data")
        
        var result : [[String:Any]]!
        let subscriber = query.within(center: center, radius: 1.5, field: "geography", opts: GeoQueryOptions(units: .kilometer, log: true))?.sink( receiveCompletion: { completion in
            switch completion {
            case .finished:
                print(".sink() received the completion:", String(describing: completion))
                XCTAssertEqual(result.count, 2)
                expectation.fulfill()
                break
            case .failure(let anError):
                print("received the error: ", anError)
                break
            }
        }) { (dataList) in
            result = dataList
        }
        wait(for: [expectation], timeout: 2)
    }
}
