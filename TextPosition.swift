//
//  TextPosition.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

typealias TextPosition = XCSourceTextPosition

extension TextPosition {
    var isStart: Bool {
        return self.line == 0 && self.column == 0
    }

    func next(in buffer: XCSourceTextBuffer) -> TextPosition? {
        guard self != buffer.lastPosition else { return nil }

        let currentLine = buffer.lines[self.line] as! String
        if self.column == currentLine.count - 1 {
            return TextPosition(line: self.line + 1, column: 0)
        }

        return TextPosition(line: self.line, column: self.column + 1)
    }

    func previous(in buffer: XCSourceTextBuffer) -> TextPosition? {
        guard !self.isStart else { return nil}

        if self.column == 0 {
            let currentLine = buffer.lines[self.line - 1] as! String
            return TextPosition(line: self.line - 1, column: currentLine.count - 1)
        }
        return TextPosition(line: self.line, column: self.column - 1)
    }
}

extension TextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        return lhs.line == rhs.line && lhs.column == rhs.column
    }
}
