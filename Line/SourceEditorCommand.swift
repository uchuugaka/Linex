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
        let selectionIndexes:[IndexSet] = selectedLinesIndexSet(for: selectedRanges)

        switch Options(command: invocation.commandIdentifier)! {

        case .duplicate:
            let range = buffer.selections.firstObject as! XCSourceTextRange
            let (oldLineOffset, oldColumnOffset) = (range.end.line, range.end.column)
            let copyOfLines = buffer.lines.objects(at: selectionIndexes.first!)
            buffer.lines.insert(copyOfLines, at: selectionIndexes.first!)

            switch selectedRanges {
            case .noSelection( _):
                if oldColumnOffset == 0 {
                    range.start.line += 1
                    range.end.line += 1
                }
                break
            case .selection(_):
                range.start.line = oldColumnOffset == 0 ? oldLineOffset : oldLineOffset + 1
                range.end.column = oldColumnOffset == 0 ? oldColumnOffset : oldColumnOffset + 1
            }

        case .commentedDuplicate:
            let range = buffer.selections.firstObject as! XCSourceTextRange
            let (oldLineOffset, oldColumnOffset) = (range.end.line, range.end.column)

            let copyOfLines = buffer.lines.objects(at: selectionIndexes.first!)
            let commentedLines = copyOfLines.map { "//" + ($0 as! String) }
            buffer.lines.insert(commentedLines, at: selectionIndexes.first!)

            switch selectedRanges {
            case .noSelection( _):
                if oldColumnOffset == 0 {
                    range.start.line += 1
                    range.end.line += 1
                }
                break
            case .selection(_):
                range.start.line = oldColumnOffset == 0 ? oldLineOffset : oldLineOffset + 1
                range.end.column = oldColumnOffset == 0 ? oldColumnOffset : oldColumnOffset + 1
            }

        case .openNewLineBelow:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                let indentationOffset = (buffer.lines[caretPosition.line] as! String).lineIndentationOffset()
                let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
                buffer.lines.insert(offsetWhiteSpaces, at: caretPosition.line + 1)

                let position = XCSourceTextPosition(line: caretPosition.line + 1, column: indentationOffset)
                let lineSelection = XCSourceTextRange(start: position, end: position)
                buffer.selections.setArray([lineSelection])
            case .selection(_): break
            }

        case .openNewLineAbove:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let indentationOffset = (buffer.lines[caretPosition.line] as! String).lineIndentationOffset()
                buffer.lines.insert(" ".repeating(count: indentationOffset), at: caretPosition.line)
                range.start.line = caretPosition.line
                range.end.line = caretPosition.line
                range.start.column = indentationOffset
                range.end.column = indentationOffset

            case .selection(_): break
            }

        case .deleteLine:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                buffer.lines.removeObject(at: caretPosition.line)
            case .selection(_): break
            }

        case .join:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                if caretPosition.line == buffer.lines.count { return }

                var firstLine = buffer.lines[caretPosition.line] as! String
                firstLine = firstLine.trimmingCharacters(in: .newlines)

                var newLine = buffer.lines[caretPosition.line + 1] as! String
                newLine = newLine.trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: caretPosition.line, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: caretPosition.line + 1)

                let range = buffer.selections.lastObject as! XCSourceTextRange
                range.start.column = firstLine.characters.count + 1
                range.end.column = firstLine.characters.count + 1

            case .selection(_):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let selectedLines = buffer.lines.objects(at: selectionIndexes.first!) as! [String]

                var joinedLine = ""
                for (i, line) in selectedLines.enumerated() {
                    if i == 0 {
                        joinedLine += " " + line.trimmingCharacters(in: .newlines)
                    } else {
                        joinedLine += " " + line.trimmedStart().trimmingCharacters(in: .newlines)
                    }
                }
                buffer.lines.removeObjects(at: selectionIndexes.first!)
                buffer.lines.insert(joinedLine, at: range.start.line)

                range.end.line = range.start.line
                range.end.column = joinedLine.characters.count
            }

        case .lineBeginning:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let indentationOffset = (buffer.lines[caretPosition.line] as! String).lineIndentationOffset()
                if range.start.column == indentationOffset {
                    range.start.column = 0; range.end.column = 0;
                } else {
                    range.start.column = indentationOffset; range.end.column = indentationOffset;
                }
            case .selection(_): break
            }

        }
        completionHandler(nil)
    }
}
