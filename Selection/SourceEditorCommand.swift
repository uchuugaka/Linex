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
        let selectedRanges: SelectionType = selectionRanges(of: buffer)
        let selectionIndex: IndexSet = selectedLinesIndexSet(for: selectedRanges)
        let range = buffer.selections.lastObject as! XCSourceTextRange

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            switch selectedRanges {
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
            switch selectedRanges {
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
            switch selectedRanges {
            case .none(let position):
                let currentLine = buffer.lines[position.line] as! String
                if currentLine.count == 0 { return }
                let lineEnd = currentLine.count - 1

                if position.column < lineEnd {
                    let rightChar = currentLine[position.column] as Character
                    if rightChar.isOpening {
                        if let position = buffer.findClosing(for: rightChar, at: position) {
                            range.end = position
                        }
                    }
                }

                if (position.column > 0) {
                    let leftChar = currentLine[position.column - 1] as Character
                    if leftChar.isClosing {
                        if let position = buffer.findOpening(for: leftChar, at: position) {
                            range.start = position
                        }
                    }
                }


                let validChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@$_"))
                if let selectionRange:Range<Int> = currentLine.selectWord(pin: position.column, validChars: validChars) {
                    range.start.column = selectionRange.lowerBound
                    range.end.column = selectionRange.upperBound
                }
            case .words(let line, let colStart, let colEnd):
                let currentLine = buffer.lines[line] as! String
                let indentationIndex = currentLine.indentationOffset
                let lineEnd = currentLine.count - 1
                let currentStart = currentLine[colStart] as Character
                let currentEnd = currentLine[colEnd - 1] as Character
                let borderStart = currentLine[colStart - 1] as Character
                let borderEnd = currentLine[colEnd] as Character

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
            switch selectedRanges {
            case .none(_): break
            case .words(_, _, _): break
            case .lines(_, _):
                let selectedLines = buffer.lines.objects(at: selectionIndex) as! [String]
                if let aligned = selectedLines.autoAlign() {
                    buffer.lines.replaceObjects(at: selectionIndex, with: aligned)
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

            if currentChar.isPresent(in: openStopper) {
                if onTheWayBrackets == 0 {
                    return from + 1
                }
                onTheWayBrackets -= 1
            }
            if currentChar.isPresent(in: closeStopper) {
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

            if currentChar.isPresent(in: closeStopper) {
                if onTheWayBrackets == 0 {
                    return from
                }
                onTheWayBrackets -= 1
            }
            if currentChar.isPresent(in: openStopper) {
                onTheWayBrackets += 1
            }
            from += 1
        }
        return nil
    }
}
