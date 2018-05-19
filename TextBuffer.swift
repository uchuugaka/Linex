//
//  TextBuffer.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

typealias TextBuffer = XCSourceTextBuffer
typealias TextRange = XCSourceTextRange

extension TextBuffer {
    var lastPosition: TextPosition {
        let lastLine = self.lines[self.lines.count - 1] as! String
        return TextPosition(line: self.lines.count - 1, column: lastLine.count - 1)
    }

    func isEnd(position: TextPosition) -> Bool {
        return lastPosition == position
    }

    func char(at position: TextPosition) -> Character {
        let currentLine = self.lines[position.line] as! String
        return currentLine[position.column] as Character
    }
}


extension TextBuffer {

    func wordSelectionRange(for chars: CharacterSet, at position: TextPosition) -> TextRange {
        let end = nextPosition(.forward, from: position, until: chars) ?? position
        let start = nextPosition(.backward, from: position, until: chars) ?? position
        return TextRange(start: start, end: end)
    }

    func nextPosition(_ direction: TextDirection,
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

    func findClosing(for openingChar: Character, at position: TextPosition) -> TextPosition? {
        assert(openingChar.isOpening, "Char must be opening")
        var stackCount = 0
        var currentPosition = position.next(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            switch currentChar {
            case openingChar.closing: stackCount += 1
            case openingChar:
                if stackCount == 0 {
                    return TextPosition(line: currentPosition!.line,
                                                column: currentPosition!.column + 1)
                }
                stackCount -= 1
            default: break
            }
            currentPosition = currentPosition!.next(in: self)
        }
        return nil
    }

    func findOpening(for closingChar: Character, at position: TextPosition) -> TextPosition? {
        assert(closingChar.isClosing, "'closingChar' must be '), }, ]'")
        var stackCount = 0
        var currentPosition = position.previous(in: self)?.previous(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            switch currentChar {
            case closingChar.closing: stackCount += 1
            case closingChar:
                if stackCount == 0 { return currentPosition! }
                stackCount -= 1
            default: break
            }
            currentPosition = currentPosition?.previous(in: self)
        }
        return nil
    }
}

extension TextBuffer {
    var selectedLines: IndexSet {
        return self.selectionType.selectedLines
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
