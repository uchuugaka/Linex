//
//  LinexTests.swift
//  LinexTests
//
//  Created by Kaunteya Suryawanshi on 29/08/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import XCTest
@testable import Linex

class LinexTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testLineIndentatinOffset() {
        XCTAssertEqual("".lineIndentationOffset(), 0)
        //              123456
        XCTAssertEqual("      ".lineIndentationOffset(), 6)
        XCTAssertEqual("      ABC".lineIndentationOffset(), 6)
    }
    
    func testOneSpace() {

        XCTAssert(" ".lineOneSpaceAt(pin: 0) == (0, " "))
        XCTAssert("   ".lineOneSpaceAt(pin: 0) == (0, " "))
        XCTAssert("   ".lineOneSpaceAt(pin: 1) == (0, " "))

        XCTAssert("ABC".lineOneSpaceAt(pin: 0) == (0, "ABC"))
        XCTAssert("ABC".lineOneSpaceAt(pin: 1) == (1, "ABC"))
        XCTAssert("ABC".lineOneSpaceAt(pin: 2) == (2, "ABC"))

        //        0123456789
        let t1 = "A    BCD", t2 = "A BCD"
        XCTAssert(t1.lineOneSpaceAt(pin: 0) == (0, t1))
        XCTAssert(t1.lineOneSpaceAt(pin: 1) == (1, t2))
        XCTAssert(t1.lineOneSpaceAt(pin: 2) == (1, t2))
        XCTAssert(t1.lineOneSpaceAt(pin: 3) == (1, t2))
        XCTAssert(t1.lineOneSpaceAt(pin: 4) == (1, t2))
        XCTAssert(t1.lineOneSpaceAt(pin: 5) == (1, t2))
        XCTAssert(t1.lineOneSpaceAt(pin: 6) == (6, t1))
        XCTAssert(t1.lineOneSpaceAt(pin: 7) == (7, t1))
        XCTAssert(t1.lineOneSpaceAt(pin: 8) == (8, t1))
    }

}
