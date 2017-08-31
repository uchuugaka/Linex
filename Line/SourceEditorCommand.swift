//
//  SourceEditorCommand.swift
//  Line
//
//  Created by Kaunteya Suryawanshi on 29/08/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

enum Options: String {
    case OpenNewLine, NewCommentedLine, Duplicate, DeleteLine, Join
    case SelectLine, OneSpace
    init(command: String) {
        // Eg: com.kaunteya.Line.Duplicate
        let bundle = Bundle.main.bundleIdentifier! + "."
        let str = command.substring(from: bundle.endIndex)
        self.init(rawValue: str)!
    }
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    public func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Swift.Void) {

        let buffer = invocation.buffer

        switch Options(command: invocation.commandIdentifier) {
        case .Duplicate:
            let selRange = buffer.selections.lastObject as! XCSourceTextRange
            var oldOffset = selRange.end.line
            let noSelection = selRange.start.column == selRange.end.column && selRange.start.line == selRange.end.line
            let linesIndexSet: IndexSet
            if noSelection {
                linesIndexSet = IndexSet(integersIn: selRange.start.line...selRange.end.line)
                oldOffset += 1
            } else {
                linesIndexSet = IndexSet(integersIn: selRange.start.line..<selRange.end.line)
            }
            let copyOfLines = buffer.lines.objects(at: linesIndexSet)
            buffer.lines.insert(copyOfLines, at: linesIndexSet)
            selRange.start.line = oldOffset
            if noSelection {
                selRange.end.line = oldOffset
            }

        case .NewCommentedLine:

            let selRange = buffer.selections.lastObject as! XCSourceTextRange
            var oldOffset = selRange.end.line
            let noSelection = selRange.start.column == selRange.end.column && selRange.start.line == selRange.end.line
            let linesIndexSet: IndexSet
            if noSelection {
                linesIndexSet = IndexSet(integersIn: selRange.start.line...selRange.end.line)
                oldOffset += 1
            } else {
                linesIndexSet = IndexSet(integersIn: selRange.start.line..<selRange.end.line)
            }
            let copyOfLines = buffer.lines.objects(at: linesIndexSet) as! [String]
            let commentedLines = copyOfLines.map { "//" + $0 }
            buffer.lines.insert(commentedLines, at: linesIndexSet)

            selRange.start.line = oldOffset
            if noSelection {
                selRange.end.line = oldOffset
            }

        case .OpenNewLine:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            let currentLineOffset = range.start.line
            let currentLine = buffer.lines[currentLineOffset] as! String
            let indentationOffset = currentLine.lineIndentationOffset()
            let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
            buffer.lines.insert(offsetWhiteSpaces, at: currentLineOffset + 1)

            let position = XCSourceTextPosition(line: currentLineOffset + 1, column: indentationOffset)
            let lineSelection = XCSourceTextRange(start: position, end: position)
            buffer.selections.setArray([lineSelection])

        case .SelectLine:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            range.start.column = 0
            range.end.line += 1
            range.end.column = 0

        case .OneSpace: //Does not work when caret is at end non white char
            let range = buffer.selections.lastObject as! XCSourceTextRange
            let currentLineOffset = range.start.line
            let currentLine = buffer.lines[currentLineOffset] as! String
            let pin = range.end.column
            let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: pin)
            buffer.lines.replaceObject(at: currentLineOffset, with: newLine)
            range.end.column = newOffset
            range.start.column = newOffset

        case .DeleteLine:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            if range.start.line != range.end.line { break; }
            let currentLineOffset = range.start.line
            buffer.lines.removeObject(at: currentLineOffset)

        case .Join:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            let noSelection = range.start.column == range.end.column && range.start.line == range.end.line
            let currentLineOffset = range.start.line
            if noSelection {
                if currentLineOffset == buffer.lines.count { return }

                var firstLine = buffer.lines[currentLineOffset] as! String
                firstLine = firstLine.trimmingCharacters(in: .newlines)

                var newLine = buffer.lines[currentLineOffset + 1] as! String
                newLine = newLine.trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: currentLineOffset, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: currentLineOffset + 1)

                range.start.column = firstLine.characters.count + 1
                range.end.column = firstLine.characters.count + 1
            } else {

            }

        }

        completionHandler(nil)
    }
}










