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

        let command = Options(command: invocation.commandIdentifier)!
        buffer.selectionRanges.forEach { range in
            switch range.selection {

            case .none(let line, let column):
                let currentLine = buffer[line]
                let currentChar = currentLine[column]
                if currentChar.presentIn(.decimalDigits), var num = Int(String(currentChar)) {
                    switch command {
                    case .increment: num += 1
                    case .decrement: num -= 1//currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                }

            default: break
            }
        }

/*
            switch selection {
            case .none(let position):
                var currentLine = buffer.lines[position.line] as! String
                let currentChar = currentLine[position.column]

                //If caret is beside number
                if currentChar.presentIn(.decimalDigits), let num = Int(String(currentChar)) {
                    let currentRange = currentLine.indexRangeFor(range: range.start.column...range.start.column)
                    switch command {
                    case .increment: currentLine.replaceSubrange(currentRange, with: "\(num + 1)")
                    case .decrement: currentLine.replaceSubrange(currentRange, with: "\(num - 1)")
                    }
                } else {
                    if let selectionRange:Range<String.Index> = currentLine.selectWord(pin: position.column, validChars: .validWordChars) {
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
            }
  */

//        }

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
