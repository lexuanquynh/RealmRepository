//
//  RealmManagerTests.swift
//  RealmManagerTests
//
//  Created by Admin on 2022/07/14.
//

import XCTest
@testable import RealmManager

final class RealmManagerTests: XCTestCase {
    let repository = CoffeeDrinkRepository()

    func testSaveObjectNonPrimaryKey() throws {
        let coffeDrink = CoffeeDrink()
        coffeDrink.name = "Capuchino"
        coffeDrink.hotOrCold = "hot"
        coffeDrink.rating = 4
        let expectation = self.expectation(description: "Realm manager API")

        repository.save(entity: coffeDrink, update: false) { result in
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
}
