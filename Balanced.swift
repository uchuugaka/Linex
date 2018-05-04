//
//  Balanced.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 02/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

extension Character {
    var isOpening: Bool {
        let openStopper = CharacterSet(charactersIn: "{[(")
        return CharacterSet(charactersIn: String(self)).isSubset(of: openStopper)
    }
    var isClosing:Bool {
        let openStopper = CharacterSet(charactersIn: "}])")
        return CharacterSet(charactersIn: String(self)).isSubset(of: openStopper)
    }
    func isPresent(in characterSet:CharacterSet) -> Bool {
        return CharacterSet(charactersIn: String(self)).isSubset(of: characterSet)
    }
    var closing: Character {
        assert(self.isOpening, "Only opening characters can have closing characters")
        return ["{":"}", "(":")", "[":"]"][self]!
    }
    var opening: Character {
        assert(self.isClosing, "Only closing characters can have opening characters")
        return ["}":"{", ")":"(", "]":"["][self]!
    }
}

private let closingFor = ["{":"}", "(":")", "[":"]"]
private let openingFor = ["}":"{", ")":"(", "]":"["]

extension XCSourceTextBuffer {
    func findClosing(for openingChar: Character,
        at position: XCSourceTextPosition) -> XCSourceTextPosition? {
        let closingChar = openingChar.closing
        var stackCount = 0

        var currentPosition = position.next(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            switch currentChar {
            case openingChar: stackCount += 1
            case closingChar:
                if stackCount == 0 {
                    return XCSourceTextPosition(line: currentPosition!.line,
                                                column: currentPosition!.column + 1)
                }
                stackCount -= 1
            default: break
            }
            currentPosition = currentPosition!.next(in: self)
        }
        return nil
    }
}

extension XCSourceTextBuffer {
    var lastPosition: XCSourceTextPosition {
        let lastLine = self.lines[self.lines.count - 1] as! String
        return XCSourceTextPosition(line: self.lines.count - 1, column: lastLine.count - 1)
    }

    func isEnd(position: XCSourceTextPosition) -> Bool {
        return lastPosition == position
    }

    func char(at position: XCSourceTextPosition) -> Character {
        let currentLine = self.lines[position.line] as! String
        return currentLine[position.column] as Character
    }
}

extension XCSourceTextPosition {
    func next(in buffer: XCSourceTextBuffer) -> XCSourceTextPosition? {
        guard self != buffer.lastPosition else { return nil }

        let currentLine = buffer.lines[self.line] as! String
        if self.column == currentLine.count - 1 {
            return XCSourceTextPosition(line: self.line + 1, column: 0)
        }
        let newPosition = XCSourceTextPosition(line: self.line, column: self.column + 1)
        return newPosition
    }
}

extension XCSourceTextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        return lhs.line == rhs.line && lhs.column == rhs.column
    }
}
