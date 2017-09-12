//
//  Common.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension String {

    /// All multiple whitespaces are replaced by one whitespace
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    func indexAt(offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }

    func indexRangeFor(range: Range<Int>) -> Range<Index> {
        return indexAt(offset: range.lowerBound)..<indexAt(offset: range.upperBound)
    }

    func indexRangeFor(range: ClosedRange<Int>) -> ClosedRange<Index> {
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

    func trimmedStart() -> String {
        return self.replacingOccurrences(of: "^[ \t]+",
                                         with: "",
                                         options: CompareOptions.regularExpression)
    }

    func trimmedEnd() -> String {
        return self.replacingOccurrences(of: "[ \t]+$",
                                         with: "",
                                         options: CompareOptions.regularExpression)
    }

    func repeating(count: Int) -> String {
        return Array<String>(repeating: self, count: count).joined()
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
