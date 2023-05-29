//
//  EntityTests.swift
//  MoviesTests
//
//  Created by Semih Cihan on 26.05.2023.
//

import XCTest
@testable import Movies

final class EntityTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodeMovie() throws {
        guard let json = loadJsonFile(name: "Movie") else {
            XCTAssert(false)
            return
        }
        
        let decoder = JSONDecoder()
        let entity = try decoder.decode(Movie.self, from: json)
        XCTAssertEqual(entity.originalTitle, "Godzilla vs. Kong")
        
    }
    
    func testDecodeTV() throws {
        guard let json = loadJsonFile(name: "TV") else {
            XCTAssert(false)
            return
        }
        
        let decoder = JSONDecoder()
        let entity = try decoder.decode(TV.self, from: json)
        XCTAssertEqual(entity.name, "Faltu")
    }
    
    func testDecodePerson() throws {
        guard let json = loadJsonFile(name: "Person") else {
            XCTAssert(false)
            return
        }
        
        let decoder = JSONDecoder()
        let entity = try decoder.decode(Person.self, from: json)
        XCTAssertEqual(entity.name, "Tom Cruise")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private func loadJsonFile(name: String) -> Data? {
        if let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("error:\(error)")
            }
        }
        return nil

    }

}


