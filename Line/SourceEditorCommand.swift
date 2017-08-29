//
//  SourceEditorCommand.swift
//  Line
//
//  Created by Kaunteya Suryawanshi on 29/08/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    public func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Swift.Void) {
        Swift.print("Here")
        let buffer = invocation.buffer
        let range1 = invocation.buffer.selections.firstObject as! XCSourceTextRange
        let currentCursorlineOffset = range1.start.line
        let currentLine = buffer.lines[currentCursorlineOffset] as! String
        invocation.buffer.lines.insert(currentLine, at: currentCursorlineOffset)


        completionHandler(nil)
    }
}
