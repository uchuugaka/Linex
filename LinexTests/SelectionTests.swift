//
//  SelectionTests.swift
//  LinexTests
//
//  Created by Kaunteya Suryawanshi on 02/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import XCTest
@testable import Linex

class SelectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testConditionalAssignment() {
        XCTAssert(true)
        var a = Optional("Kaunteya")
        a ?= "Mohan"
        XCTAssertEqual(a!, "Kaunteya")

        var a1: String?
        a1 ?= "Mohan"
        XCTAssertEqual(a1!, "Mohan")

        a1 ?= "Raju"
        XCTAssertEqual(a1!, "Mohan")
    }
}
