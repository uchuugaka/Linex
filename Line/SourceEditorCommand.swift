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
    case OpenNewLine, NewCommentedLine, Duplicate
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
        }
        completionHandler(nil)
    }

}










