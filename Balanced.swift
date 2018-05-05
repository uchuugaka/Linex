//
//  Balanced.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 02/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

private let closingFor = ["{":"}", "(":")", "[":"]"]
private let openingFor = ["}":"{", ")":"(", "]":"["]


extension XCSourceTextBuffer {
    
    func findClosing(for openingChar: Character, at position: XCSourceTextPosition) -> XCSourceTextPosition? {
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

    func findOpening(for closingChar: Character, at position: XCSourceTextPosition) -> XCSourceTextPosition? {
        let openingChar = closingChar.opening
        var stackCount = 0
        var currentPosition = position.previous(in: self)?.previous(in: self)
        while currentPosition != nil {
            let currentChar = self.char(at: currentPosition!)
            switch currentChar {
            case closingChar: stackCount += 1
            case openingChar:
                if stackCount == 0 { return currentPosition! }
                stackCount -= 1
            default: break
            }
            currentPosition = currentPosition?.previous(in: self)
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

