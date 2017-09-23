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
    case selectLine, selectLineAbove, oneSpace, expand, align
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        let buffer = invocation.buffer
        let selectedRanges: SelectionType = selectionRanges(of: buffer)
        let selectionIndex: IndexSet = selectedLinesIndexSet(for: selectedRanges)

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            range.start.column = 0
            range.end.line += 1
            range.end.column = 0

        case .selectLineAbove:
            let range = buffer.selections.lastObject as! XCSourceTextRange
            range.start.column = 0
            range.start.line = max(range.start.line - 1, 0)
            range.end.column = 0

        case .oneSpace:
            switch selectedRanges {
            case .none(let line, let column):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let currentLine = buffer.lines[line] as! String
                let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: column)
                buffer.lines.replaceObject(at: line, with: newLine)
                range.end.column = newOffset
                range.start.column = newOffset
            case .words(_, _, _): break
            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .expand:
            switch selectedRanges {
            case .none(let line, let column):
                let range = buffer.selections.lastObject as! XCSourceTextRange
                let currentLine = buffer.lines[line] as! String

                if let selectionRange:Range<Int> = currentLine.selectWord(pin: column) {
                    range.start.column = selectionRange.lowerBound
                    range.end.column = selectionRange.upperBound
                }
            case .words(_, _, _): break
            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .align:
            switch selectedRanges {
            case .none(_, _): break
            case .words(_, _, _): break
            case .lines(_, _):
                let selectedLines = buffer.lines.objects(at: selectionIndex) as! [String]
                if let aligned = selectedLines.autoAlign() {
                    buffer.lines.replaceObjects(at: selectionIndex, with: aligned)
                }

            case .multiLocation(_): break
            }
        }
        completionHandler(nil)
    }
    
}
