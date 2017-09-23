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
        let selectedRanges: SelectionType = selectionRanges(of: buffer)

        //For case conversion
        if let selectedCase = Case(command: invocation.commandIdentifier) {
            convertToCase(selectedCase, buffer: buffer)
            completionHandler(nil)
            return
        }

        //For other commands
        if let command = Options(command: invocation.commandIdentifier) {

            switch selectedRanges {
            case .none(let line, let column):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                var currentLine = buffer.lines[line] as! String
                let currentChar = currentLine[column] as String
                if let _ = currentChar.rangeOfCharacter(from: .decimalDigits), let num = Int(currentChar) {
                    let currentRange = currentLine.indexRangeFor(range: range.start.column...range.start.column)
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                } else {
                    if let selectionRange:Range<String.Index> = currentLine.selectWord(pin: column) {
                        let selectedString = currentLine[selectionRange]
                        if let newString = toggle(boolString: selectedString) {
                            currentLine.replaceSubrange(selectionRange, with: newString)
                        }
                    }
                }
                buffer.lines.replaceObject(at: line, with: currentLine)

            case .words(let line, let colStart, let colEnd):
                var currentLine = buffer.lines[line] as! String
                let currentRange = currentLine.indexRangeFor(range: colStart..<colEnd)
                if let num = Int(currentLine[currentRange]) {
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                }
                buffer.lines.replaceObject(at: line, with: currentLine)

            case .lines(_, _): break
            case .multiLocation(_): break
            }
        }

        completionHandler(nil)
    }

    private func toggle(boolString: Substring) -> String? {
        switch boolString {
        case "true": return "false"
        case "false": return "true"
        case "YES": return "NO"
        case "NO": return "YES"
        default: return nil
        }
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
