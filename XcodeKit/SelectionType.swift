//
//  SelectionType.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

enum SelectionType {
    case none(position: TextPosition)
    case words(line: Int, colStart: Int, colEnd: Int)
    case lines(start:TextPosition, end: TextPosition)//Complete line selection is counted multiline
//    case multiLocation([XCSourceTextRange])

//    var selectedLines: IndexSet {
//        switch self {
//        case .none(let position): return IndexSet(integer: position.line)
//        case .words(let line, _, _): return IndexSet(integer: line)
//        case .lines(let start, let end):
//            return IndexSet(integersIn: start.line...(end.column == 0 ? end.line - 1 : end.line))
//        case .multiLocation(let ranges):
//            let a = IndexSet()
//            for range in ranges {
//                range.
//            }
//            ranges.map
//        }
//    }
}
