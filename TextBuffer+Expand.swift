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
        let range = selections.lastObject as! TextRange
        guard lines.count != 0 else { return }


        if isSelectionEmpty,
            let newRange = rangeForExpandedSelection(for: .validWordChars, at: range) {
            range.update(selection: newRange)
            return
        }

        let borderStart: Character? = range.start.previous(in: self).map { char(at: $0)}
        let borderEnd: Character? = char(at: range.end)

        if (borderStart == "." || borderEnd == ".") {
            let validChars = CharacterSet("@$_.!?").union(.alphanumerics)
            if let newRange = rangeForExpandedSelection(for: validChars, at: range) {
                range.update(selection: newRange)
            }
            return
        }
        if (borderEnd?.presentIn("!?:") ?? false) {// Optionals
            range.end.column += 1
            return
        }
        if (borderEnd == "(") {
            range.end = findClosing(for: "(", at: range.end) ?? range.end
            return
        }

        switch (borderStart, borderEnd) {
        case ("\"","\""), ("{", "}"), ("[","]"), ("(",")"):
            range.start = range.start.previous(in: self) ?? range.start
            range.end = range.end.next(in: self) ?? range.end
            return
        default: break
        }

        if let newRange = smartExpand(current: range) {
            range.update(selection: newRange)
        }
    }

}
