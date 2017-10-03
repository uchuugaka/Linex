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

    func testFarthestDistance() {
        XCTAssertEqual(["var name = Kaunteya",].farthestOffsetFor(subStr: "=")!, 8)

        XCTAssertEqual(["var name = Kaunteya",
                        "self.lastupdated = createdOn",
                        ].farthestOffsetFor(subStr: "=")!,16)

        XCTAssertEqual(["var name = Kaunteya",
                        "self.lastupdated = createdOn",
                        "self.name = name",
                        ].farthestOffsetFor(subStr: "=")!, 16)

        XCTAssertEqual(["var name  = Kaunteya",
                        "self.lastupdated     = createdOn",
                        "self.name = name",
                        ].farthestOffsetFor(subStr: "=")!, 16)

        XCTAssertEqual(["var name  = Kaunteya",
                        "self.lastupdated     = createdOn",
                        "self.name                             = name",
                        ].farthestOffsetFor(subStr: "=")!, 16)

    }

    func testAlign() {
        XCTAssertEqual(["let name = \"Kaunteya\""].autoAlign()!,
                       ["let name = \"Kaunteya\""])

        XCTAssertEqual(["var name = Kaunteya",
                        "self.lastupdated = createdOn",
                        "self.name = name",
                        "self.uuid = UUID().uuidString",
                        "self.createdOn = Date()",
                        ].autoAlign()!,
                       [
                        "var name         = Kaunteya",
                        "self.lastupdated = createdOn",
                        "self.name        = name",
                        "self.uuid        = UUID().uuidString",
                        "self.createdOn   = Date()"
            ])

        XCTAssertEqual(["let name = \"Kaunteya\"",
                        "var telephoneNumber = \"8973459878945734\"",
                        "var age: Int! = 45"
            ].autoAlign()!,
                       [
                        "let name            = \"Kaunteya\"",
                        "var telephoneNumber = \"8973459878945734\"",
                        "var age: Int!       = 45"

            ])
        
        XCTAssertEqual(["let name = \"Kaunteya\"",
                        "var telephoneNumber: String = \"8973459878945734\"",
                        "var age: Int! = 45"
            ].autoAlign()!,
                       [
                        "let name                    = \"Kaunteya\"",
                        "var telephoneNumber: String = \"8973459878945734\"",
                        "var age            : Int!   = 45"

            ])
        
        XCTAssertEqual(["var name: String",
                        "var telephoneNumber: String",
                        "var age: Int!"
            ].autoAlign()!,
                       [
                        "var name           : String",
                        "var telephoneNumber: String",
                        "var age            : Int!"

            ])

        XCTAssertEqual(["var name: String",
                        "var telephoneNumber: String",
                        "",
                        "var age: Int!"
            ].autoAlign()!,
                       [
                        "var name           : String",
                        "var telephoneNumber: String",
                        "",
                        "var age            : Int!"

            ])
        XCTAssertEqual(["var name: String",
                        "var telephoneNumber: String",
                        "// Age of the person",
                        "var age: Int!"
            ].autoAlign()!,
                       [
                        "var name           : String",
                        "var telephoneNumber: String",
                        "// Age of the person",
                        "var age            : Int!"

            ])

        ///////////////////////////////////////////

        XCTAssertEqual(["var name           : String",
                        "var age            : Int!"
            ].autoAlign()!,
                       [
                        "var name: String",
                        "var age : Int!"

            ])

        //Case where previously aligned content was disturbed
        XCTAssertEqual(["self.name          = campaignDict[kName];",
                        "self.trackUserOnLaunch      = [campaignDict[kTrackUserOnLaunch] boolValue];",
                        "self.segmentObject = campaignDict[kSegmentObject];"
            ].autoAlign()!,
                       [
                        "self.name              = campaignDict[kName];",
                        "self.trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];",
                        "self.segmentObject     = campaignDict[kSegmentObject];"
            ])

        XCTAssertEqual(["let name                         = \"Kaunteya\"",
                        "var telephoneNumber: String = \"8973459878945734\"",
                        "var age: Int! = 45"
            ].autoAlign()!,
                       [
                        "let name                    = \"Kaunteya\"",
                        "var telephoneNumber: String = \"8973459878945734\"",
                        "var age            : Int!   = 45"

            ])

        
    }
}
