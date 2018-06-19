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
    
    public func perform(with invocation: XCSourceEditorCommandInvocation,
                        completionHandler: @escaping (Error?) -> Swift.Void) {
        let buffer = invocation.buffer

        switch Options(command: invocation.commandIdentifier)! {
        case .duplicate:
            buffer.selectionRanges.forEach { range in
                let end = range.end//Required for updating selection
                let copyOfLines = buffer.lines.objects(at: range.selectedLines)
                buffer.lines.insert(copyOfLines, at: range.selectedLines)

                switch range.selection {
                case .none(_, let column):
                    if column == 0 {
                        range.start.line += 1
                        range.end.line += 1
                    }
                case .words: break
                case .lines: range.start = end
                }
            }

        case .commentedDuplicate:
            buffer.selectionRanges.forEach { range in
                let end = range.end//Required for updating selection
                let copyOfLines = buffer.lines.objects(at: range.selectedLines)
                let commentedLines = copyOfLines.map { "//" + ($0 as! String) }
                buffer.lines.insert(commentedLines, at: range.selectedLines)

                switch range.selection {
                case .none(_, let column):
                    if column == 0 {
                        range.start.line += 1
                        range.end.line += 1
                    }
                case .words: break
                case .lines: range.start = end
                }
            }

        case .openNewLineBelow:
            buffer.selectionRanges.forEach { range in
                if range.isSelectionEmpty {
                    let indentationOffset = buffer[range.start.line].indentationOffset
                    let offsetWhiteSpaces = String(repeating: " ", count: indentationOffset)
                    buffer.lines.insert(offsetWhiteSpaces, at: range.start.line + 1)
                    //Selection
                    let position = TextPosition(line: range.start.line + 1, column: indentationOffset)
                    let lineSelection = XCSourceTextRange(start: position, end: position)
                    buffer.selections.setArray([lineSelection])
                }
            }

        case .openNewLineAbove:
            buffer.selectionRanges.forEach { range in
                if range.isSelectionEmpty {
                    let indentationOffset = buffer[range.start.line].indentationOffset
                    let offsetWhiteSpaces = String(repeating: " ", count: indentationOffset)
                    buffer.lines.insert(offsetWhiteSpaces, at: range.start.line)
                    //Selection
                    let position = TextPosition(line: range.start.line, column: indentationOffset)
                    let lineSelection = XCSourceTextRange(start: position, end: position)
                    buffer.selections.setArray([lineSelection])
                }
            }

        case .deleteLine:
            buffer.selectionRanges.forEach { range in
                switch range.selection {
                case .none, .words:
                    buffer.lines.removeObject(at: range.start.line)

                case .lines: break

                }
            }

        case .join:
            buffer.selectionRanges.forEach { range in

            switch range.selection {
            case .none(let line, _):
                if line == buffer.lines.count { return }

                let caretOffset = buffer[line].count + 1
                let lineIndexSet = IndexSet(arrayLiteral: line, line + 1)
                let lines = buffer[lineIndexSet]

                var joinedLine = lines.joined(separator: " ", trimming: .whitespacesAndNewlines)
                joinedLine.indent(by: lines.first!.indentationOffset)

                buffer.lines.replaceObject(at: line, with: joinedLine)
                buffer.lines.removeObject(at: line + 1)

                //Selection/CaretPosition
                range.start.column = caretOffset
                range.end.column = caretOffset

            case .words: break

            case .lines:
                let lines = buffer[range.selectedLines]
                var joinedLine = lines.joined(separator: " ", trimming: .whitespacesAndNewlines)
                joinedLine.indent(by: lines.first!.indentationOffset)

                buffer.lines.removeObjects(at: range.selectedLines)
                buffer.lines.insert(joinedLine, at: range.start.line)

                //Selection/CaretPosition
                range.end.line = range.start.line
                range.end.column = joinedLine.count

                }//switch range.selection
            }//for each range

        case .lineBeginning:
            buffer.selectionRanges.forEach { range in
                switch range.selection {
                case .none(let line, let column):
                    let indentationOffset = buffer[line].indentationOffset
                    if column == indentationOffset {
                        range.start.column = 0; range.end.column = 0;
                    } else {
                        range.start.column = indentationOffset; range.end.column = indentationOffset;
                    }
                case .words, .lines: break
                }
            }
        }

        defer {
            completionHandler(nil)
        }
    }
}
