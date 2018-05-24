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
    var lastPosition: TextPosition {
        let lastLine = self.lines[self.lines.count - 1] as! String
        return TextPosition(line: self.lines.count - 1, column: lastLine.count - 1)
    }

    func isStart(postion: TextPosition) -> Bool {
        return postion.line == 0 && postion.column == 0
    }

    func isEnd(position: TextPosition) -> Bool {
        return lastPosition == position
    }

    func char(at position: TextPosition) -> Character {
        let currentLine = self.lines[position.line] as! String
        return currentLine[position.column] as Character
    }
}
