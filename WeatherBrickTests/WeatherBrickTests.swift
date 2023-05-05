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
        self.record = false
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchWeatherDataWithValidLocation() {
        let networkManager = NetworkManager()
        let expectation = self.expectation(description: "Fetch weather data with valid location")

        let validLocation = CLLocation(latitude: 37.3324, longitude: -122.0308)
        networkManager.fetchWeatherData(location: validLocation, city: nil) { result in
            switch result {
            case .success(let weatherData):
                XCTAssertNotNil(weatherData, "Weather data should not be nil")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but received failure with error: \(error.localizedDescription)")
            }
        }

        self.waitForExpectations(timeout: 5.0, handler: nil)
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
