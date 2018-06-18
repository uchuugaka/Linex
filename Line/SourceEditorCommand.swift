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
                case .none:
                    if range.start.column == 0 {
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
                case .none:
                    if range.start.column == 0 {
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
                    let indentationOffset = (buffer.lines[range.start.line] as! String).indentationOffset
                    let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
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
                    let indentationOffset = (buffer.lines[range.start.line] as! String).indentationOffset
                    let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
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
            case .none:
                if range.start.line == buffer.lines.count { return }

                let firstLine = (buffer.lines[range.start.line] as! String).trimmingCharacters(in: .newlines)
                let newLine = (buffer.lines[range.start.line + 1] as! String).trimmingCharacters(in: .whitespaces)

                buffer.lines.replaceObject(at: range.start.line, with: "\(firstLine) \(newLine)")
                buffer.lines.removeObject(at: range.start.line + 1)

                //Selection/CaretPosition
                range.start.column = firstLine.count + 1
                range.end.column = firstLine.count + 1

            case .words: break

            case .lines:
                let lines = buffer.lines.objects(at: range.selectedLines) as! [String]

                var joinedLine = lines.lineJoined

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
                case .none:
                    let indentationOffset = (buffer.lines[range.start.line] as! String).indentationOffset
                    if range.start.column == indentationOffset {
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
