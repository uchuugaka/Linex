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
    case duplicate, openNewLineBelow, openNewLineAbove, commentedDuplicate, deleteLine, join
    case lineBeginning
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    public func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Swift.Void) {

        let buffer = invocation.buffer
        let selection = buffer.selectionType
        let selectedLines = buffer.selectedLines

        switch Options(command: invocation.commandIdentifier)! {
        case .duplicate:
            let range = buffer.selections.firstObject as! XCSourceTextRange
            let copyOfLines = buffer.lines.objects(at: selectedLines)
            buffer.lines.insert(copyOfLines, at: selectedLines)

            switch selection {
            case .none(let position):
                if position.column == 0 {
                    range.start.line += 1
                    range.end.line += 1
                }
            case .words(_, _, _)://TODO:
                break
            case .lines(_, let endPosition): range.start = endPosition
            case .multiLocation(_): break
            }

        case .commentedDuplicate:
            let range = buffer.selections.firstObject as! XCSourceTextRange
            let copyOfLines = buffer.lines.objects(at: selectedLines)
            let commentedLines = copyOfLines.map { "//" + ($0 as! String) }
            buffer.lines.insert(commentedLines, at: selectedLines)

            switch selection {
            case .none(let position):
                if position.column == 0 {
                    range.start.line += 1
                    range.end.line += 1
                }
            case .words(_, _, _)://TODO:
                break
            case .lines(_, let endPosition): range.start = endPosition
            case .multiLocation(_): break
            }

        case .openNewLineBelow:
            switch selection {
            case .none(let position):
                let indentationOffset = (buffer.lines[position.line] as! String).indentationOffset
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: position.line + 1)
                //Selection
                let position = TextPosition(line: position.line + 1, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .words(let line, _, _):

                let indentationOffset = (buffer.lines[line] as! String).indentationOffset
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: line + 1)
                //Selection
                let position = TextPosition(line: line + 1, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .openNewLineAbove:
            switch selection {
            case .none(let position):
                let indentationOffset = (buffer.lines[position.line] as! String).indentationOffset
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: position.line)
                //Selection
                let position = TextPosition(line: position.line, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .words(let line, _, _):
                let indentationOffset = (buffer.lines[line] as! String).indentationOffset
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: line)
                //Selection
                let position = TextPosition(line: line, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .deleteLine:
            switch selection {
            case .none(let position):
                buffer.lines.removeObject(at: position.line)

            case .words(let line, _, _):
                buffer.lines.removeObject(at: line)

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .join:
            switch selection {
            case .none(let position):
                if position.line == buffer.lines.count { return }

                let firstLine = (buffer.lines[position.line] as! String).trimmingCharacters(in: .newlines)
                let newLine = (buffer.lines[position.line + 1] as! String).trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: position.line, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: position.line + 1)

                //Selection/CaretPosition
                let range = buffer.selections.lastObject as! XCSourceTextRange
                range.start.column = firstLine.count + 1
                range.end.column = firstLine.count + 1

            case .words(let line, _, _):
                if line == buffer.lines.count { return }

                let firstLine = (buffer.lines[line] as! String).trimmingCharacters(in: .newlines)
                let newLine = (buffer.lines[line + 1] as! String).trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: line, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: line + 1)

                //Selection/CaretPosition
                let range = buffer.selections.lastObject as! XCSourceTextRange
                range.start.column = firstLine.count + 1
                range.end.column = firstLine.count + 1

            case .lines(_, _):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let lines = buffer.lines.objects(at: selectedLines) as! [String]

                var joinedLine = ""
                for (i, line) in lines.enumerated() {
                    if i == 0 {
                        joinedLine += line.trimmingCharacters(in: .newlines)
                    } else {
                        joinedLine += " " + line.trimmedStart().trimmingCharacters(in: .newlines)
                    }
                }
                buffer.lines.removeObjects(at: selectedLines)
                buffer.lines.insert(joinedLine, at: range.start.line)

                //Selection/CaretPosition
                range.end.line = range.start.line
                range.end.column = joinedLine.count

            case .multiLocation(_): break
            }

        case .lineBeginning:
            switch selection {
            case .none(let position):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let indentationOffset = (buffer.lines[position.line] as! String).indentationOffset
                if range.start.column == indentationOffset {
                    range.start.column = 0; range.end.column = 0;
                } else {
                    range.start.column = indentationOffset; range.end.column = indentationOffset;
                }

            case  .words(let line, _, _):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let indentationOffset = (buffer.lines[line] as! String).indentationOffset
                if range.start.column == indentationOffset {
                    range.start.column = 0; range.end.column = 0;
                } else {
                    range.start.column = indentationOffset; range.end.column = indentationOffset;
                }
            case .lines(_, _): break
            case .multiLocation(_): break
            }
        }
        completionHandler(nil)
    }
}
