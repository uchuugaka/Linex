//
//  Extras.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 30/08/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit


extension XCSourceEditorCommandInvocation {


    func selectionRanges() -> [XCSourceTextRange]? {
        assert(self.buffer.selections.count > 0, "Count can be zero. Wrong assumption")

        return self.buffer.selections.map { $0 as! XCSourceTextRange }
    }

    func moveCursorTo(location: XCSourceTextPosition) {
        let lineSelection = XCSourceTextRange(start: location, end: location)
        buffer.selections.setArray([lineSelection])
    }
}
