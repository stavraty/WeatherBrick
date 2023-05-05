//
//  WeatherBrickTests.swift
//  WeatherBrickTests
//
//  Created by AS on 05.05.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import XCTest
import SnapshotTesting
import CoreLocation
@testable import WeatherBrick

class NetworkManagerTests: XCTestCase, XCTestObservation {
    
    let networkManager = NetworkManager()
    var record: Bool = false

    override func setUp() {
        super.setUp()
//        // Register test observers on the main thread
//        DispatchQueue.main.async {
//            XCTAssertNil(Failure.diff(snapshotsDir: "Snapshots"))
//            self.record = false
//        }
    }

    override func tearDown() {
        super.tearDown()
        // Unregister test observer on the main thread
        DispatchQueue.main.async {
            XCTestObservationCenter.shared.removeTestObserver(self)
        }
    }

    func testFetchWeatherDataWithInvalidLocation() {
        let networkManager = NetworkManager()
        let expectation = self.expectation(description: "Fetch weather data with invalid location")

        let invalidLocation = CLLocation(latitude: -9999, longitude: -9999)
        networkManager.fetchWeatherData(location: invalidLocation, city: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but received success")
            case .failure(let error):
                assertSnapshot(matching: error.localizedDescription, as: .description, record: self.record)
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
}
