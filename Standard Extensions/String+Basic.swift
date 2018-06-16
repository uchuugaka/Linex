//
//  String+Basic.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
extension String {

    /// All multiple whitespaces are replaced by one whitespace
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func index(at offset: Int) -> Index {
        return index(startIndex, offsetBy: offset)
    }

    subscript(i: Int) -> Character {
        return self[index(at: i)]
    }

    subscript(range: Range<Int>) -> Substring {
        let rangeIndex:Range<Index> = self.indexRangeFor(range: range)
        return self[rangeIndex]
    }

    subscript(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }

    func indexRangeFor(range: Range<Int>) -> Range<Index> {
        return index(at: range.lowerBound)..<index(at: range.upperBound)
    }

    func indexRangeFor(range: ClosedRange<Int>) -> ClosedRange<Index> {
        return index(at: range.lowerBound)...index(at: range.upperBound)
    }

    mutating func replace(range: Range<Int>, with replacement: String) {
        self.replaceSubrange(self.index(at: range.lowerBound)..<self.index(at: range.upperBound), with: replacement)
    }

    /// Fetch indentation offset of lines in code
    /// "    var foo" -> 4
    var indentationOffset: Int {
        var i = 0
        for a in self {
            if a == " " {
                i += 1
            } else { break }
        }
        return i
    }

    var trimmedStart: String {
        return self.replacingOccurrences(of: "^[ \t]+", with: "", options: .regularExpression)
    }

    var trimmedEnd: String {
        return self.replacingOccurrences(of: "[ \t]+$", with: "", options: .regularExpression)
    }

    func repeating(count: Int) -> String {
        return Array<String>(repeating: self, count: count).joined()
    }

    func replacedRegex(pattern: String, with template: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
        return modString
    }
}
