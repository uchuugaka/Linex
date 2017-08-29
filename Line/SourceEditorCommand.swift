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
        switch Options(command: invocation.commandIdentifier) {
        case .Duplicate:
            let buffer = invocation.buffer
            let range1 = invocation.buffer.selections.lastObject as! XCSourceTextRange
            let currentCursorlineOffset = range1.start.line
            let currentLine = buffer.lines[currentCursorlineOffset] as! String
            invocation.buffer.lines.insert(currentLine, at: currentCursorlineOffset)

        case .NewCommentedLine:
            Swift.print("Here")
            invocation.buffer.lines.insert("Commented line", at: 0)

        case .OpenNewLine:
            Swift.print("Here")
            invocation.buffer.lines.insert("Open New line", at: 0)
        }
//        Swift.print("Here")



        completionHandler(nil)
    }
}
