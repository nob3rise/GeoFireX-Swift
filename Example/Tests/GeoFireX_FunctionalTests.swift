//
//  GeoFireX_FunctionalTests.swift
//  GeoFireX-FunctionalTests
//
//  Created by Nob on 2020/05/09.
//  Copyright © 2020 Nob. All rights reserved.
//

import XCTest
import Firebase
@testable import GeoFireX_Swift

class GeoFireX_FunctionalTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testGeoHashEncode() throws {
        let hashStr = Geohash.encode(latitude: 48.668983, longitude: -4.329021, length: 9)
        XCTAssertEqual(hashStr, "gbsuv7ztq")
    }
    
    func testGeoHashDecode() throws {
        let (latRange, lonRange) = Geohash.decode(hash: "xn76urx66")!
        XCTAssert(latRange.min < 35.681255 && 35.681255 < latRange.max)
        XCTAssert(lonRange.min < 139.767144 && 139.767144 < lonRange.max)
    }

    func testGeoHashDecodeToPoint() throws {
        let (lat, lon, err) = Geohash.decodeToPoint("xn76ur453")!
        XCTAssertEqual(lat, (35.6786584854126 + 35.678701400756836) / 2)
        XCTAssertEqual(lon, (139.7598695755005 + 139.75991249084473) / 2)
        XCTAssertEqual(err.latErr, 35.678701400756836 - (35.6786584854126 + 35.678701400756836) / 2)
        XCTAssertEqual(err.lonErr, 139.75991249084473 - (139.7598695755005 + 139.75991249084473) / 2)
    }

    func testGeoPointDistance() throws {
        let srcPoint = GeoPoint(latitude: 39.984, longitude: -75.343)
        let dstPoint = GeoPoint(latitude: 39.123, longitude: -75.534)
        
        let distance = srcPoint.distance(to: dstPoint) / 1000
        let diff = abs(distance - 97.15957803131901)
        
        XCTAssert(diff < 0.0000001)
    }
    
    func testGeoPointBearing() throws {
        let srcPoint = GeoPoint(latitude: 39.984, longitude: -75.343)
        let dstPoint = GeoPoint(latitude: 39.123, longitude: -75.534)
        
        let bearing = srcPoint.bearing(to: dstPoint)
        let diff = abs(bearing - -170.23304913492177)
        
        XCTAssert(diff < 0.0000001)
    }
    
    func testGeohashNeighbors() {
        guard let neighborList = Geohash.neighbors(hashStr: "dr47m") else { XCTFail(); return }
        
        XCTAssertEqual(neighborList[0], "dr47t")
        XCTAssertEqual(neighborList[1], "dr47w")
        XCTAssertEqual(neighborList[2], "dr47q")
        XCTAssertEqual(neighborList[3], "dr47n")
        XCTAssertEqual(neighborList[4], "dr47j")
        XCTAssertEqual(neighborList[5], "dr47h")
        XCTAssertEqual(neighborList[6], "dr47k")
        XCTAssertEqual(neighborList[7], "dr47s")
    }
    
    func testGeohashSetPrecision() {
        XCTAssertEqual(Geohash.setPrecision(2.0), 5)
        XCTAssertEqual(Geohash.setPrecision(0.0002), 9)
        XCTAssertEqual(Geohash.setPrecision(100.0), 3)
    }
}
