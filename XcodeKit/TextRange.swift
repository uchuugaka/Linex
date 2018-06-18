//
//  TextRange.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 19/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

typealias TextRange = XCSourceTextRange

extension TextRange {

    var selectedLines: IndexSet {
        if start.line == end.line {
            return IndexSet(integer: start.line)
        }
        return IndexSet(integersIn: start.line...(end.column == 0 ? end.line - 1 : end.line))
    }

    var isSelectionEmpty: Bool {
        return start == end
    }

    func updateSelection(range: TextRange) {
        self.start = range.start
        self.end = range.end
    }
}
