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
    case selectLine, oneSpace, expand, align
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        let buffer = invocation.buffer
        let selectedRanges: SelectionType = selectionRanges(of: buffer)
        let selectionIndexes:[IndexSet] = selectedLinesIndexSet(for: selectedRanges)

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            range.start.column = 0
            range.end.line += 1
            range.end.column = 0

        case .oneSpace:
            switch selectedRanges {
            case .noSelection(let caretPosition):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let currentLine = buffer.lines[caretPosition.line] as! String
                let pin = range.end.column
                let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: pin)
                buffer.lines.replaceObject(at: caretPosition.line, with: newLine)
                range.end.column = newOffset
                range.start.column = newOffset
            case .selection(_): break
            }


        case .expand:
            break

        case .align:
            switch selectedRanges {
            case .noSelection(_): break
            case .selection(_):
                let selectedLines = buffer.lines.objects(at: selectionIndexes.first!) as! [String]
                if let aligned = selectedLines.autoAlign() {
                    buffer.lines.replaceObjects(at: selectionIndexes.first!, with: aligned)
                }
            }
        }
        completionHandler(nil)
    }
    
}
