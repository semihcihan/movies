//
//  MoviesUITests.swift
//  MoviesUITests
//
//  Created by Semih Cihan on 17.04.2023.
//

import XCTest

final class MoviesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        Snapshot.app?.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        Snapshot.app?.terminate()
    }
    
    override class func setUp() {
        setupSnapshot(XCUIApplication())
    }

    func testScreenshotHome() throws {
        snapshot("Home")        
    }
    
    func testScreenshotFilter() throws {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["7+"]/*[[".cells.buttons[\"7+\"]",".buttons[\"7+\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.buttons["TV"].tap()
        
        snapshot("Filter")
    }
}
