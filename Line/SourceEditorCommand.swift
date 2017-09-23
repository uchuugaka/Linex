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
        let selectedRanges: SelectionType = selectionRanges(of: buffer)
        let selectionIndexSet: IndexSet = selectedLinesIndexSet(for: selectedRanges)

        switch Options(command: invocation.commandIdentifier)! {

        case .duplicate:
            let range = buffer.selections.firstObject as! XCSourceTextRange
            let copyOfLines = buffer.lines.objects(at: selectionIndexSet)
            buffer.lines.insert(copyOfLines, at: selectionIndexSet)

            switch selectedRanges {
            case .none( _, let column):
                if column == 0 {
                    range.start.line += 1
                    range.end.line += 1
                }
            case .words(_, _, _)://TODO:
                break
            case .lines(_, _): break
//                range.start.line = start.column == 0 ? line : line + 1
//                range.end.column = end.column == 0 ? column : column + 1
            case .multiLocation(_): break
            }

        case .commentedDuplicate:

//            let range = buffer.selections.firstObject as! XCSourceTextRange
//            let (oldLineOffset, oldColumnOffset) = (range.end.line, range.end.column)

            let copyOfLines = buffer.lines.objects(at: selectionIndexSet)
            let commentedLines = copyOfLines.map { "//" + ($0 as! String) }
            buffer.lines.insert(commentedLines, at: selectionIndexSet)

//            switch selectedRanges {
//            case .noSelection( _):
//                if oldColumnOffset == 0 {
//                    range.start.line += 1
//                    range.end.line += 1
//                }
//                break
//            case .selection(_):
//                range.start.line = oldColumnOffset == 0 ? oldLineOffset : oldLineOffset + 1
//                range.end.column = oldColumnOffset == 0 ? oldColumnOffset : oldColumnOffset + 1
//            }

        case .openNewLineBelow:
            switch selectedRanges {
            case .none(let line, _),
                 .words(let line, _, _):
                let indentationOffset = (buffer.lines[line] as! String).lineIndentationOffset()
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: line + 1)
                //Selection
                let position = XCSourceTextPosition(line: line + 1, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .openNewLineAbove:
            switch selectedRanges {
            case .none(let line, _),
                 .words(let line, _, _):
                let indentationOffset = (buffer.lines[line] as! String).lineIndentationOffset()
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: line)
                //Selection
                let position = XCSourceTextPosition(line: line, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .deleteLine:
            switch selectedRanges {
            case .none(let line, _),
                 .words(let line, _, _):
                buffer.lines.removeObject(at: line)

            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .join:

            switch selectedRanges {
            case .none(let line, _),
                 .words(let line, _, _):
                if line == buffer.lines.count { return }

                let firstLine = (buffer.lines[line] as! String).trimmingCharacters(in: .newlines)
                let newLine = (buffer.lines[line + 1] as! String).trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: line, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: line + 1)

                //Selection/CaretPosition
                let range = buffer.selections.lastObject as! XCSourceTextRange
                range.start.column = firstLine.characters.count + 1
                range.end.column = firstLine.characters.count + 1

            case .lines(_, _):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let selectedLines = buffer.lines.objects(at: selectionIndexSet) as! [String]

                var joinedLine = ""
                for (i, line) in selectedLines.enumerated() {
                    if i == 0 {
                        joinedLine += " " + line.trimmingCharacters(in: .newlines)
                    } else {
                        joinedLine += " " + line.trimmedStart().trimmingCharacters(in: .newlines)
                    }
                }
                buffer.lines.removeObjects(at: selectionIndexSet)
                buffer.lines.insert(joinedLine, at: range.start.line)

                //Selection/CaretPosition
                range.end.line = range.start.line
                range.end.column = joinedLine.characters.count

            case .multiLocation(_): break
            }

        case .lineBeginning:

            switch selectedRanges {
            case .none(let line, _),
                 .words(let line, _, _):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let indentationOffset = (buffer.lines[line] as! String).lineIndentationOffset()
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
