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
        defer {
            completionHandler(nil)
        }
        let buffer = invocation.buffer
        let selection = buffer.selectionType
        let selectedLines = buffer.selectedLines
        let range = buffer.selections.lastObject as! TextRange

        switch Options(command: invocation.commandIdentifier)! {
        case .selectLine:
            switch selection {
            case .none(let position):
                let indentationOffset = (buffer.lines[position.line] as! String).indentationOffset
                range.start.column = indentationOffset
                range.end.column = (buffer.lines[position.line] as! String).count - 1

            case .words(_, _, _),
                 .lines(_, _):
                range.start.column = 0
                range.end.line += 1
                range.end.column = 0

            case .multiLocation(_): break
            }

        case .selectLineAbove:
            range.start.column = 0
            range.start.line = max(range.start.line - 1, 0)
            range.end.column = 0

        case .oneSpace:
            switch selection {
            case .none(let position):
                let currentLine = buffer.lines[position.line] as! String
                let (newOffset, newLine) = currentLine.lineOneSpaceAt(pin: position.column)
                buffer.lines.replaceObject(at: position.line, with: newLine)
                range.end.column = newOffset
                range.start.column = newOffset
            case .words(_, _, _): break
            case .lines(_, _): break
            case .multiLocation(_): break
            }

        case .expand: buffer.expand()

        case .align:
            switch selection {
            case .none(_): break
            case .words(_, _, _): break
            case .lines(_, _):
                let lines = buffer.lines.objects(at: selectedLines) as! [String]
                if let aligned = lines.autoAlign() {
                    buffer.lines.replaceObjects(at: selectedLines, with: aligned)
                }

            case .multiLocation(_): break
            }
        }
        //        completionHandler(nil)
    }
    
}
