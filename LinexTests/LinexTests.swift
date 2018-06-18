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

    func testLineJoined() {
        let arr = ["    Kaunteya\n", "    Suryawanshi\n"]
        XCTAssertEqual(arr.lineJoined, "    Kaunteya Suryawanshi", arr.lineJoined)

    }
    
    func testLineIndentatinOffset() {
        XCTAssertEqual("".indentationOffset, 0)
        //              123456
        XCTAssertEqual("      ".indentationOffset, 6)
        XCTAssertEqual("      ABC".indentationOffset, 6)
    }
    
    func testOneSpace() {
        XCTAssert(" ".lineOneSpaceAt(pin: 0) == (0, ""))
        XCTAssert("   ".lineOneSpaceAt(pin: 0) == (0, " "))
        XCTAssert("   ".lineOneSpaceAt(pin: 1) == (0, " "))

        XCTAssert("ABC".lineOneSpaceAt(pin: 0) == (0, " ABC"))
        XCTAssert("ABC".lineOneSpaceAt(pin: 1) == (1, "A BC"))
        XCTAssert("ABC".lineOneSpaceAt(pin: 2) == (2, "AB C"))
        XCTAssert("AB C".lineOneSpaceAt(pin: 2) == (2, "ABC"))

        //         0123456789
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 0) == (0,  " A    BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 1) == (1, "A BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 2) == (1, "A BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 3) == (1, "A BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 4) == (1, "A BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 5) == (1, "A BCD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 6) == (6,  "A    B CD"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 7) == (7,  "A    BC D"))
        XCTAssert("A    BCD".lineOneSpaceAt(pin: 8) == (8,  "A    BCD "))
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
