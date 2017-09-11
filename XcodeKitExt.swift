//
//  XcodeKitExt.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 11/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

enum SelectionType {
    case selection([XCSourceTextRange])
    case noSelection(XCSourceTextPosition)
}

/// Returns nil if nothing is selected
func selectionRanges(of buffer: XCSourceTextBuffer) -> SelectionType {
    let selections = buffer.selections as! [XCSourceTextRange]
    if selections.count == 1 {
        let range = selections.first!
        if range.start.line == range.end.line && range.start.column == range.end.column {
            return SelectionType.noSelection(range.start)
        }
    }
    let textRangeList = buffer.selections.map { $0 as! XCSourceTextRange }
    return SelectionType.selection(textRangeList)
}


/// Indexes of all the lines
///
/// - Returns: Returns nil if no selection
func selectedLinesIndexSet(for selectedRanges: SelectionType) -> [IndexSet] {
    switch selectedRanges {
    case .noSelection(let range):
        return [IndexSet(integer: range.line)]

    case .selection(let selectedRanges):
        let indexList: [IndexSet] = selectedRanges.map { (textRange) -> IndexSet in
            let selectionRangeEndLine = textRange.end.line + (textRange.end.column == 0 ? 0 : 1 )
            let targetRange = Range(uncheckedBounds: (
                lower: textRange.start.line,
                upper: selectionRangeEndLine))
            return IndexSet(integersIn: targetRange)
        }
        return indexList
    }
}
