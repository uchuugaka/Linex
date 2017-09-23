//
//  SourceEditorCommand.swift
//  Convert
//
//  Created by Kaunteya Suryawanshi on 02/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

enum Options: String {
    case increment, decrement
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        let buffer = invocation.buffer

        //For case conversion
        if let selectedCase = Case(command: invocation.commandIdentifier) {
            convertToCase(selectedCase, buffer: buffer)
            completionHandler(nil)
            return
        }
        if let command = Options(command: invocation.commandIdentifier) {
            let selRange = buffer.selections.firstObject as! XCSourceTextRange
            let noSelection = selRange.start.column == selRange.end.column && selRange.start.line == selRange.end.line
            if noSelection {
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let currentLineOffset = range.start.line
                var currentLine = buffer.lines[currentLineOffset] as! String
                let currentRange = currentLine.indexRangeFor(range: range.start.column...range.start.column)
                let currentChar = currentLine[range.start.column] as String
                if let _ = currentChar.rangeOfCharacter(from: .decimalDigits), let num = Int(currentChar) {
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                }
                buffer.lines.replaceObject(at: currentLineOffset, with: currentLine)
            } else {
                let range = buffer.selections.firstObject as! XCSourceTextRange
                let currentLineOffset = range.start.line
                var currentLine = buffer.lines[currentLineOffset] as! String
                let currentRange = currentLine.indexRangeFor(range: range.start.column..<range.end.column)
                if let num = Int(currentLine[currentRange]) {
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                }
                buffer.lines.replaceObject(at: currentLineOffset, with: currentLine)
            }
        }

        completionHandler(nil)
    }


    func convertToCase(_ selectedCase: Case, buffer: XCSourceTextBuffer) {
        let range = buffer.selections.lastObject as! XCSourceTextRange
        let currentLineOffset = range.start.line
        let currentLine = buffer.lines[currentLineOffset] as! String
        let strRange = currentLine.index(currentLine.startIndex, offsetBy: range.start.column)..<currentLine.index(currentLine.startIndex, offsetBy: range.end.column)
        let selectedString = String(currentLine[strRange]).toRaw()?.convertTo(case: selectedCase) ?? "++++++++"
        let finalStr = currentLine.replacingCharacters(in: strRange, with: selectedString)
        buffer.lines.replaceObject(at: currentLineOffset, with: finalStr)
    }
    
}
