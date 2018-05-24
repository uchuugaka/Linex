//
//  TextBuffer.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

//MARK - Word selection
extension TextBuffer {
    func rangeForWordSelection(for chars: CharacterSet, at range: TextRange) -> TextRange? {
        guard let start = nextPosition(.backward, from: range.start, until: chars),
            let end = nextPosition(.forward, from: range.end, until: chars) else {
                return nil
        }
        return TextRange(start: start, end: end)
    }

    private func nextPosition(_ direction: TextDirection,
                      from startPosition: TextPosition,
                      until charSet: CharacterSet) -> TextPosition? {
        var currentPosition = Optional(startPosition)
        if direction == .backward { currentPosition = startPosition.previous(in: self)}

        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            if !currentChar.presentIn(charSet) {
                return direction == .backward ? currentPosition!.next(in: self) : currentPosition
            }
            currentPosition = currentPosition!.move(direction, in: self)
        }
        return nil
    }
}

//MARK - Find specific opening/closing bracket
extension TextBuffer {
    func findClosing(for openingChar: Character, at position: TextPosition) -> TextPosition? {
        assert(openingChar.isOpening, "Char must be opening")
        var stackCount = 0
        var currentPosition = position.next(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            if currentChar.isOpening { stackCount += 1}
            else if currentChar.isClosing {
                if stackCount == 0 {
                    return TextPosition(line: currentPosition!.line,
                                        column: currentPosition!.column + 1)
                }
                stackCount -= 1
            }

            currentPosition = currentPosition!.next(in: self)
        }
        return nil
    }

    /// Invoke this when cursor is on close bracket
    func findOpening(for closingChar: Character, at position: TextPosition) -> TextPosition? {
        assert(closingChar.isClosing, "'closingChar' must be '), }, ]'")
        var stackCount = 0
        var currentPosition = position.previous(in: self)?.previous(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            if currentChar.isClosing { stackCount += 1 }
            else if currentChar.isOpening {
                if stackCount == 0 { return currentPosition! }
                stackCount -= 1
            }

            currentPosition = currentPosition?.previous(in: self)
        }
        return nil
    }
}

//MARK - Smart expansion
extension TextBuffer {
    func smartExpand(current range: TextRange) -> TextRange? {
        guard let newStart = searchLeft(from: range.start),
            let newEnd = searchRight(from: range.end) else { return nil }
        return TextRange(start: newStart, end: newEnd)
    }

    private func searchLeft(from position: TextPosition) -> TextPosition? {
        var stackCount = 0
        var currentPosition = position.previous(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            if currentChar.isClosing {
                stackCount += 1
            } else if currentChar.isOpening {
                if stackCount == 0 { return currentPosition!.next(in: self)! }
                stackCount -= 1
            } else if currentChar == "\"" {
                if stackCount == 0 { return currentPosition! }
            }

            currentPosition = currentPosition?.previous(in: self)
        }
        return nil
    }

    private func searchRight(from position: TextPosition) -> TextPosition? {
        var stackCount = 0
        var currentPosition: TextPosition? = position
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            if currentChar.isOpening {
                stackCount += 1
            } else if currentChar.isClosing {
                if stackCount == 0 { return currentPosition! }
                stackCount -= 1
            } else if currentChar == "\"" {
                if stackCount == 0 { return currentPosition!.next(in: self) }
            }

            currentPosition = currentPosition?.next(in: self)
        }
        return nil
    }
}

