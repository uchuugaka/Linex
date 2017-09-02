//
//  SourceEditorCommand.swift
//  Convert
//
//  Created by Kaunteya Suryawanshi on 02/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        let selectedCase = Case(command: invocation.commandIdentifier)!
        let buffer = invocation.buffer

        let range = buffer.selections.lastObject as! XCSourceTextRange
        let currentLineOffset = range.start.line
        let currentLine = buffer.lines[currentLineOffset] as! String
        let strRange = currentLine.index(currentLine.startIndex, offsetBy: range.start.column)..<currentLine.index(currentLine.startIndex, offsetBy: range.end.column)
        let selectedString = currentLine.substring(with: strRange).toRaw()?.convertTo(case: selectedCase) ?? "++++++++"
        let finalStr = currentLine.replacingCharacters(in: strRange, with: selectedString)
        buffer.lines.replaceObject(at: currentLineOffset, with: finalStr)

        completionHandler(nil)
    }
    
}
