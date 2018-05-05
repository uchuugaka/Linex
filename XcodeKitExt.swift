//
//  XcodeKitExt.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 11/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

///// Returns nil if nothing is selected
//func selectionType(of buffer: XCSourceTextBuffer) -> SelectionType {
//    let selections = buffer.selections as! [XCSourceTextRange]
//    if selections.count == 1 {
//        let range = selections.first!
//        if range.start.line == range.end.line {
//            if range.start.column == range.end.column {
//                return .none(position: XCSourceTextPosition(line: range.start.line, column: range.start.column))
//            }
//            return .words(line: range.start.line, colStart: range.start.column, colEnd: range.end.column)
//        }
//        return .lines(start: range.start, end: range.end)
//    }
//    let textRangeList = buffer.selections.map { $0 as! XCSourceTextRange }
//    return .multiLocation(textRangeList)
//}
