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

        if let command = Options(command: invocation.commandIdentifier) {

            switch selectedRanges {
            case .none(let position):
                let range = buffer.selections.firstObject as! XCSourceTextRange
                var currentLine = buffer.lines[position.line] as! String
                let currentChar = currentLine[position.column] as String

                //If caret is beside number
                if let _ = currentChar.rangeOfCharacter(from: .decimalDigits), let num = Int(currentChar) {
                    let currentRange = currentLine.indexRangeFor(range: range.start.column...range.start.column)
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                } else {
                    let validChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@$_"))
                    if let selectionRange:Range<String.Index> = currentLine.selectWord(pin: position.column, validChars: validChars) {
                        let selectedSubString = currentLine[selectionRange]
                        if let newString = toggle(boolString: selectedSubString) {
                            currentLine.replaceSubrange(selectionRange, with: newString)
                        }
                    }
                }
                buffer.lines.replaceObject(at: position.line, with: currentLine)

            case .words(let line, let colStart, let colEnd):
                var currentLine = buffer.lines[line] as! String
                let currentRange = currentLine.indexRangeFor(range: colStart..<colEnd)

                if let newBool = toggle(boolString: currentLine[currentRange]) {
                    currentLine.replaceSubrange(currentRange, with: newBool)
                    buffer.lines.replaceObject(at: line, with: currentLine)

                    //Selection / Caret posistion
                    if (colEnd - colStart != newBool.count) {
                        let range = buffer.selections.firstObject as! XCSourceTextRange
                        range.end.column = colStart + newBool.count
                    }
                } else if let num = Int(currentLine[currentRange])  {
                    let newNum: String
                    switch command {
                    case .increment: newNum = "\(num + 1)"
                    case .decrement: newNum = "\(num - 1)"
                    }

                    currentLine.replaceSubrange(currentRange, with: newNum)
                    buffer.lines.replaceObject(at: line, with: currentLine)
                    
                    //Selection / Caret posistion
                    if (colEnd - colStart != newNum.count) {
                        let range = buffer.selections.firstObject as! XCSourceTextRange
                        range.end.column = colStart + newNum.count
                    }
                }

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
}
