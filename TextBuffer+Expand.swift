//
//  TextBuffer+Expand.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 18/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

extension TextBuffer {
    func expand() {
        switch (selectionType) {

        case .none(let position): expandNoSelection(position)
        case .words(let line, let colStart, let colEnd):
            expandOnWordsSelection(line, colStart: colStart, colEnd: colEnd)
        case .lines(let start, let end):
            break
        case .multiLocation(_):
            break
        }
    }

    private func expandNoSelection(_ position: TextPosition) {
        var range = selections.lastObject as! TextRange

        let currentLine = lines[position.line] as! String
        if currentLine.count == 0 { return }
        let lineEnd = currentLine.count - 1

        let rightChar: Character? = position.column < lineEnd ? currentLine[position.column] : nil

        let leftChar: Character? = position.column > 0 ? currentLine[position.column - 1] :  nil

        if rightChar?.isOpening ?? false  {
            range.end = findClosing(for: rightChar!, at: position) ?? range.end
            return
        }

        if leftChar?.isClosing ?? false {
            range.start = findOpening(for: leftChar!.opening, at: position) ?? range.start
            return
        }
        range.update(selection: wordSelectionRange(for: .validWordChars, at: position))
    }

    private func expandOnWordsSelection(_ line: Int, colStart: Int, colEnd: Int) {
        let currentLine = lines[line] as! String
        let indentationIndex = currentLine.indentationOffset
        let lineEnd = currentLine.count - 1
        let currentStart = currentLine[colStart]
        let currentEnd = currentLine[colEnd - 1]
        let borderStart = colStart == 0 ? nil : currentLine[colStart - 1]
        let borderEnd = currentLine[colEnd]
        let range = selections.lastObject as! TextRange

        if (borderStart == "." || borderEnd == ".") {
            let validChars = CharacterSet("@$_.").union(.alphanumerics)
            range.update(selection: wordSelectionRange(for: validChars, at: TextPosition(line: line, column: colStart)))
            return
        }
        if (borderEnd == "(") {
            range.end = findClosing(for: "(", at: TextPosition(line: line, column: colEnd + 1)) ?? range.end
        }
        if (colStart == indentationIndex) {
            range.end.column = lineEnd
            return
        }

        if (colEnd == lineEnd) {
            range.start.column = currentLine.indentationOffset
            return
        }

        switch (borderStart, borderEnd) {
        case ("\"","\""), ("{", "}"), ("[","]"), ("(",")"):
            range.start.column = colStart - 1
            range.end.column = colEnd + 1
            return
        default: break
        }

        if (currentStart == "(" && currentEnd == ")" && colEnd == lineEnd) {
            range.start.column = currentLine.indentationOffset
            return
        }

//        if let start = currentLine.findOpeningPosition(from: colStart) {
//            range.start.column = start
//        }
//
//        if let end = currentLine.findClosingPosition(from: colEnd) {
//            range.end.column = end
//        }
    }
}
