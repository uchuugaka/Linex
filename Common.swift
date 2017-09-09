//
//  Common.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

extension String {

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    func indexAt(offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }

    func rangeFor(range: Range<Int>) -> Range<Index> {
        return indexAt(offset: range.lowerBound)..<indexAt(offset: range.upperBound)
    }

    func rangeFor(range: ClosedRange<Int>) -> ClosedRange<Index> {
        return indexAt(offset: range.lowerBound)...indexAt(offset: range.upperBound)
    }

    /// Fetch indentation offset of lines in code
    /// "    var foo" -> 4
    func lineIndentationOffset() -> Int {
        var i = 0
        for a in self.characters {
            if a == " " {
                i += 1
            } else { break }
        }
        return i
    }

    func trimStart() -> String {
        return self.replacingOccurrences(of: "^[ \t]+",
                                         with: "",
                                         options: CompareOptions.regularExpression)
    }

    static func spaces(count: Int) -> String {
        return Array<String>(repeating: " ", count: count).joined()
    }

    func replacedRegex(pattern: String, with template: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, characters.count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
        return modString
    }
}

extension RawRepresentable where RawValue == String {
    init?(command: String) {
        // Eg: com.kaunteya.Line.Duplicate
        let value = command.components(separatedBy: ".").last!
        self.init(rawValue: value)
    }
}

func selectionRanges(of buffer: XCSourceTextBuffer) -> [XCSourceTextRange] {
    return buffer.selections.map { $0 as! XCSourceTextRange }
}

func firstSelectionRange(of buffer: XCSourceTextBuffer) -> XCSourceTextRange? {
    return selectionRanges(of: buffer).first
}

func selectedLinesIndexSet(of buffer: XCSourceTextBuffer) -> IndexSet? {
    guard let selectionRange = firstSelectionRange(of: buffer), buffer.lines.count > 0 else { return nil }
    let selectionRangeEndLine = selectionRange.end.line + (selectionRange.end.column == 0 ? 0 : 1 )
    let targetRange = Range(uncheckedBounds: (
        lower: selectionRange.start.line,
        upper: min(selectionRangeEndLine, buffer.lines.count)))
    return IndexSet(integersIn: targetRange)
}
