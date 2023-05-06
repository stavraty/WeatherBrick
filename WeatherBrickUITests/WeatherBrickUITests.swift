//
//  WeatherBrickUITests.swift
//  WeatherBrickUITests
//
//  Created by AS on 05.05.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit
import XCTest
@testable import WeatherBrick

class WeatherBrickUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSwipeToUpdateWeather() {
        let brickImageElement = app.images["brickImage"]
        brickImageElement.swipeDown()
        XCTAssertEqual(app.staticTexts["LocationLabel"].label, " Odesa, UA ")
        XCTAssertTrue(app.staticTexts["temperature"].exists)
        XCTAssertTrue(app.staticTexts["typeOfWeather"].exists)
    }
    
    func testTapToUpdateWeather() {
        app.buttons["locationButton"].tap()
        XCTAssertEqual(app.staticTexts["LocationLabel"].label, " Odesa, UA ")
        XCTAssertTrue(app.staticTexts["temperature"].exists)
        XCTAssertTrue(app.staticTexts["typeOfWeather"].exists)
        
    }
    
    func testSearchUpdateWeatherForCity() {
        app.buttons["SearchButton"].tap()
        app.textFields["SearchTextField"].tap()
        app.textFields["SearchTextField"].typeText("New York")
        app.textFields["SearchTextField"].typeText("\n")
        
        let expectation = self.expectation(description: "Wait for location label to change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(app.staticTexts["LocationLabel"].label, " New York, US ")
        XCTAssertTrue(app.staticTexts["temperature"].exists)
        XCTAssertTrue(app.staticTexts["typeOfWeather"].exists)
    }
}
