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

    func noSelection() -> Bool {
        assert(self.buffer.selections.count > 0, "Count can be zero. Wrong assumption")
        let range = self.buffer.selections.lastObject as! XCSourceTextRange
        return range.start.column == range.end.column && range.start.line == range.end.line
    }

    func selectionRanges(of buffer: XCSourceTextBuffer) -> [XCSourceTextRange]? {
        assert(self.buffer.selections.count > 0, "Count can be zero. Wrong assumption")
        return buffer.selections.map { $0 as! XCSourceTextRange }
    }

    func moveCursorTo(location: XCSourceTextPosition) {
        let lineSelection = XCSourceTextRange(start: location, end: location)
        buffer.selections.setArray([lineSelection])
    }
}
