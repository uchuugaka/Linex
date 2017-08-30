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
    case OpenNewLine, NewCommentedLine, Duplicate, DeleteLine
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
            let range1 = invocation.buffer.selections.lastObject as! XCSourceTextRange
            let currentCursorlineOffset = range1.start.line
            let currentLine = buffer.lines[currentCursorlineOffset] as! String
            invocation.buffer.lines.insert(currentLine, at: currentCursorlineOffset)

        case .NewCommentedLine:
            let range1 = invocation.buffer.selections.lastObject as! XCSourceTextRange
            let currentLineOffset = range1.start.line
            let currentLine = "// " + (buffer.lines[currentLineOffset] as! String)
            invocation.buffer.lines.insert(currentLine, at: currentLineOffset)

        case .OpenNewLine:
            let range1 = invocation.buffer.selections.lastObject as! XCSourceTextRange
            let currentLineOffset = range1.start.line
            let currentLine = buffer.lines[currentLineOffset] as! String
            let indentationOffset = currentLine.lineIndentationOffset()
            let offsetWhiteSpaces = Array(repeating: " ", count: indentationOffset).joined()
            invocation.buffer.lines.insert(offsetWhiteSpaces, at: currentLineOffset + 1)

            let position = XCSourceTextPosition(line: currentLineOffset + 1, column: indentationOffset)
            let lineSelection = XCSourceTextRange(start: position, end: position)
            invocation.buffer.selections.setArray([lineSelection])

        case .SelectLine:
            let range = invocation.buffer.selections.lastObject as! XCSourceTextRange
            range.start.column = 0
            range.end.line += 1
            range.end.column = 0

        case .OneSpace:
            let range = invocation.buffer.selections.lastObject as! XCSourceTextRange
            let currentLineOffset = range.start.line
            var currentLine = buffer.lines[currentLineOffset] as! String
            let pin = range.end.column
            let newOffset = currentLine.toOneSpaceAt(pin: pin)
            buffer.lines.replaceObject(at: currentLineOffset, with: currentLine)
            range.end.column = newOffset
            range.start.column = newOffset

        case .DeleteLine:
            let range = invocation.buffer.selections.lastObject as! XCSourceTextRange
            if range.start.line != range.end.line { break; }
            let currentLineOffset = range.start.line
            buffer.lines.removeObject(at: currentLineOffset)
        }

        completionHandler(nil)
    }

}










