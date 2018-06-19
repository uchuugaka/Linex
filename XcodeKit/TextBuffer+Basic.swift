//
//  TextBuffer+Basic.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 24/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

typealias TextBuffer = XCSourceTextBuffer

extension TextBuffer {

    subscript (offset: Int) -> Line {
        return Line(lines[offset] as! String)
    }

    subscript (indexSet: IndexSet) -> [Line] {
        return indexSet.map { self[$0] }
    }
    
    var selectionRanges: [TextRange] {
        return selections as! [TextRange]
    }

    var lastPosition: TextPosition {
        let lastLineIndex = self.lines.count - 1
        let lastLine = self[lastLineIndex]

        return TextPosition(line: lastLineIndex, column: lastLine.count - 1)
    }

    func isStart(postion: TextPosition) -> Bool {
        return postion.line == 0 && postion.column == 0
    }

    func isEnd(position: TextPosition) -> Bool {
        return lastPosition == position
    }

    func char(at position: TextPosition) -> Character {
        let currentLine = self[position.line]
        return currentLine[position.column]
    }
}











