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

    func testCamelPascalToSnake() {
        XCTAssertEqual("W".camelPascalToSnake(), "w")
        XCTAssertEqual("WWF".camelPascalToSnake(), "w_w_f")
        XCTAssertEqual("WeThePeopleOfIndia".camelPascalToSnake(), "we_the_people_of_india")
        XCTAssertEqual("WeThe123PeopleOfIndia".camelPascalToSnake(), "we_the123_people_of_india")

        XCTAssertEqual("w".camelPascalToSnake(), "w")
        XCTAssertEqual("WWF".camelPascalToSnake(), "w_w_f")
        XCTAssertEqual("weThePeopleOfIndia".camelPascalToSnake(), "we_the_people_of_india")
        XCTAssertEqual("weThe123PeopleOfIndia".camelPascalToSnake(), "we_the123_people_of_india")
    }

    func testToRaw() {
        XCTAssertEqual("I".toRaw(), "i")
        XCTAssertEqual("i".toRaw(), "i")
        XCTAssertEqual("I Have A Book".toRaw(), "i_have_a_book")
        XCTAssertEqual("I HAVE A BOOK".toRaw(), "i_have_a_book")
        XCTAssertEqual("i have a book".toRaw(), "i_have_a_book")
        XCTAssertEqual("i_have_a_book".toRaw(), "i_have_a_book")
        XCTAssertEqual("iHaveABook".toRaw(), "i_have_a_book")
        XCTAssertEqual("IHaveABook".toRaw(), "i_have_a_book")
    }

    func testRawTo() {
        XCTAssertEqual("i_have_a_book".rawTo(.title), "I Have A Book")
        XCTAssertEqual("i_have_a_book".rawTo(.upper), "I HAVE A BOOK")
        XCTAssertEqual("i_have_a_book".rawTo(.lower), "i have a book")
        XCTAssertEqual("i_have_a_book".rawTo(.snake), "i_have_a_book")
        XCTAssertEqual("i_have_a_book".rawTo(.camel), "iHaveABook")
        XCTAssertEqual("i_have_a_book".rawTo(.pascal), "IHaveABook")
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
