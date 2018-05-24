//
//  TextBuffer+Selection.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 25/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

extension TextBuffer {
    var selectedLines: IndexSet {
        return self.selectionType.selectedLines
    }
    var isSelectionEmpty: Bool {
        let selections = self.selections as! [XCSourceTextRange]
        let range = selections.first!
        return range.start == range.end
    }
    var selectionType: SelectionType {
        let selections = self.selections as! [XCSourceTextRange]
        if selections.count == 1 {
            let range = selections.first!
            if range.start.line == range.end.line {
                if range.start.column == range.end.column {
                    return .none(position: TextPosition(line: range.start.line, column: range.start.column))
                }
                return .words(line: range.start.line, colStart: range.start.column, colEnd: range.end.column)
            }
            return .lines(start: range.start, end: range.end)
        }
        return .multiLocation(selections)
    }
}

