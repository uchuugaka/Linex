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

    enum Selection {
        case none(line: Int, column: Int)
        case words, lines
    }

    var selectedLines: IndexSet {
        switch selection {
        case .none, .words:
            return IndexSet(integer: start.line)

        //Complete line selection is counted multiline
        case .lines:
            return IndexSet(integersIn: start.line...(end.column == 0 ? end.line - 1 : end.line))
        }
    }

    var selection: Selection {
        if start == end {
            return .none(line: start.line, column: start.column)
        } else if start.line == end.line {
            return .words
        }
        return .lines
    }

    var isSelectionEmpty: Bool {
        if case Selection.none(_, _) = selection {
            return true
        }
        return false
    }

    func updateSelection(range: TextRange) {
        self.start = range.start
        self.end = range.end
    }
}
