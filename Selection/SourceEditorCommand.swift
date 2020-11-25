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
    
    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void ) -> Void {

        let buffer = invocation.buffer

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            buffer.selectionRanges.forEach { range in
                if range.isSelectionEmpty {
                    let indentationOffset = buffer[range.start.line].indentationOffset
                    range.start.column = indentationOffset
                    range.end.column = (buffer.lines[range.start.line] as! String).count - 1
                } else {
                    range.start.column = 0
                    range.end.line += 1
                    range.end.column = 0
                }
            }

        case .selectLineAbove:
            buffer.selectionRanges.forEach { range in
                range.start.column = 0
                range.start.line = max(range.start.line - 1, 0)
                range.end.column = 0
            }

        case .oneSpace:
            buffer.selectionRanges.forEach { range in
                if range.isSelectionEmpty {
                    let currentLine = buffer.lines[range.start.line] as! String
                    let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: range.start.column)
                    buffer.lines.replaceObject(at: range.start.line, with: newLine)
                    range.end.column = newOffset
                    range.start.column = newOffset
                }
            }

        case .expand:
            buffer.outerExpand()

        case .align:
            buffer.selectionRanges.forEach { range in
                if range.start.line != range.end.line {
                    let lines = buffer.lines.objects(at: range.selectedLines) as! [String]
                    if let aligned = lines.autoAlign() {
                        buffer.lines.replaceObjects(at: range.selectedLines, with: aligned)
                    }
                }
            }
        }

        completionHandler(nil)
    }
}
