//
//  MigrationTests.swift
//  RealmManagerTests
//
//  Created by Admin on 2022/07/14.
//

import XCTest
@testable import RealmManager

final class MigrationTests: XCTestCase {
    let repository = MigrationRepository()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Read more: https://www.mongodb.com/docs/realm/sdk/swift/model-data/change-an-object-model/
    func testFirstVersion() throws {
        let expectation = self.expectation(description: "Realm manager API")
        let sample = MigrationSample()
        sample.firstName = "firstName 0"
        sample.lastName = "lastName 0"

        repository.save(entity: sample, update: false) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure:
                XCTAssertTrue(false)
                expectation.fulfill()
            }
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
