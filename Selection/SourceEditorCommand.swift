//
//  SourceEditorCommand.swift
//  Selection
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

enum Options: String {
    case selectLine, selectLineAbove, oneSpace, expand, align
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer {
            completionHandler(nil)
        }
        let buffer = invocation.buffer
        let selection = buffer.selectionType
        let selectedLines = buffer.selectedLines
        var range = buffer.selections.lastObject as! TextRange

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            switch selection {
            case .none(let position):
                let indentationOffset = (buffer.lines[position.line] as! String).indentationOffset
                range.start.column = indentationOffset
                range.end.column = (buffer.lines[position.line] as! String).count - 1

            case .words(_, _, _),
                 .lines(_, _):
                range.start.column = 0
                range.end.line += 1
                range.end.column = 0

            case .multiLocation(_): break
            }

        case .selectLineAbove:
            range.start.column = 0
            range.start.line = max(range.start.line - 1, 0)
            range.end.column = 0

        case .oneSpace:
            switch selection {
            case .none(let position):
                let currentLine = buffer.lines[position.line] as! String
                let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: position.column)
                buffer.lines.replaceObject(at: position.line, with: newLine)
                range.end.column = newOffset
                range.start.column = newOffset
            case .words(_, _, _): break
            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .expand:
            switch selection {
            case .none(let position):
                let currentLine = buffer.lines[position.line] as! String
                if currentLine.count == 0 { return }
                let lineEnd = currentLine.count - 1

                let rightChar: Character? = position.column < lineEnd ? currentLine[position.column] : nil

                let leftChar: Character? = position.column > 0 ? currentLine[position.column - 1] :  nil

                if rightChar?.isOpening ?? false  {
                    range.end = buffer.closingPosition(for: rightChar!, startingAt: position) ?? range.end
                    return
                }

                if leftChar?.isClosing ?? false {
                    range.start = buffer.findOpening(for: leftChar!, at: position) ?? range.start
                    return
                }
                range = buffer.wordSelectionRange(for: .validWordChars, at: position)

            case .words(let line, let colStart, let colEnd):
                let currentLine = buffer.lines[line] as! String
                let indentationIndex = currentLine.indentationOffset
                let lineEnd = currentLine.count - 1
                let currentStart = currentLine[colStart]
                let currentEnd = currentLine[colEnd - 1]
                let borderStart = colStart == 0 ? nil : currentLine[colStart - 1]
                let borderEnd = currentLine[colEnd]

                if (borderStart == "." || borderEnd == ".") {
                    let validChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@$_."))
                    if let selectionRange:Range<Int> = currentLine.selectWord(pin: colStart, validChars: validChars) {
                        range.start.column = selectionRange.lowerBound
                        range.end.column = selectionRange.upperBound
                    }
                    return
                }
                if (borderEnd == "(") {
                    if let end = currentLine.findClosingPosition(from: colEnd + 1) {
                        range.end.column = end + 1
                    }
                }
                if (colStart == indentationIndex) {
                    range.end.column = lineEnd
                    return
                }

                if (colEnd == lineEnd) {
                    range.start.column = currentLine.indentationOffset
                    return
                }

                switch (borderStart, borderEnd) {
                case ("\"","\""), ("{", "}"), ("[","]"), ("(",")"):
                    range.start.column = colStart - 1
                    range.end.column = colEnd + 1
                    return
                default: break
                }

                if (currentStart == "(" && currentEnd == ")" && colEnd == lineEnd) {
                    range.start.column = currentLine.indentationOffset
                    return
                }

                if let start = currentLine.findOpeningPosition(from: colStart) {
                    range.start.column = start
                }

                if let end = currentLine.findClosingPosition(from: colEnd) {
                    range.end.column = end
                }

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .align:
            switch selection {
            case .none(_): break
            case .words(_, _, _): break
            case .lines(_, _):
                let lines = buffer.lines.objects(at: selectedLines) as! [String]
                if let aligned = lines.autoAlign() {
                    buffer.lines.replaceObjects(at: selectedLines, with: aligned)
                }

            case .multiLocation(_): break
            }
        }
        //        completionHandler(nil)
    }
    
}

let openStopper = CharacterSet(charactersIn: "{[(\"")
let closeStopper = CharacterSet(charactersIn: "}])\"")

extension String {
    func findOpeningPosition(from: Int) -> Int? {
        var from = from - 1
        var onTheWayBrackets = 0
        while from >= 0 {
            let currentChar = self[from]

            if currentChar.presentIn(openStopper) {
                if onTheWayBrackets == 0 {
                    return from + 1
                }
                onTheWayBrackets -= 1
            }
            if currentChar.presentIn(closeStopper) {
                onTheWayBrackets += 1
            }
            from -= 1
        }
        return nil
    }

    func findClosingPosition(from: Int) -> Int? {
        var from = from
        var onTheWayBrackets = 0
        let endOfLine = self.count
        while from < endOfLine {
            let currentChar = self[from]

            if currentChar.presentIn(closeStopper) {
                if onTheWayBrackets == 0 {
                    return from
                }
                onTheWayBrackets -= 1
            }
            if currentChar.presentIn(openStopper) {
                onTheWayBrackets += 1
            }
            from += 1
        }
        return nil
    }
}
