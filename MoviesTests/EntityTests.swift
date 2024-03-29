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
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entity = try decoder.decode(Movie.self, from: json)
        XCTAssertEqual(entity.originalTitle, "Godzilla vs. Kong")
    }

    func testDecodeTV() throws {
        guard let json = loadJsonFile(name: "TV") else {
            XCTAssert(false)
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entity = try decoder.decode(TV.self, from: json)
        XCTAssertEqual(entity.name, "Faltu")
    }

    func testDecodePerson() throws {
        guard let json = loadJsonFile(name: "Person") else {
            XCTAssert(false)
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entity = try decoder.decode(Person.self, from: json)
        XCTAssertEqual(entity.name, "Tom Cruise")
    }

    func testDecodeArray() throws {
        guard let json = loadJsonFile(name: "Multi") else {
            XCTAssert(false)
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entityArr = try decoder.decode([Media].self, from: json)

        guard case let .tv(tv) = entityArr[0] else {
            throw(Error.decodeError)
        }
        XCTAssertEqual(tv.name, "Tomorrow is Ours")
        XCTAssertEqual(tv.firstAirDate, "2017-07-17")

        guard case let .movie(movie) = entityArr[1] else {
            throw(Error.decodeError)
        }
        XCTAssertEqual(movie.title, "Little Man Tom")
        XCTAssertEqual(movie.releaseDate, "2022-05-11")

        guard case let .person(person) = entityArr[4] else {
            throw(Error.decodeError)
        }
        XCTAssertEqual(person.name, "Tom")
        XCTAssertEqual(person.profilePath, nil)
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

    enum Error: Swift.Error {
        case decodeError
    }

}
