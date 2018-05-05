//
//  Common.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
//MARK: - Basic
extension String {

    /// All multiple whitespaces are replaced by one whitespace
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript(range: Range<Int>) -> Substring {
        let rangeIndex:Range<Index> = self.indexRangeFor(range: range)
        return self[rangeIndex]
    }
    
    subscript(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }

    func index(at offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }

    func indexRangeFor(range: Range<Int>) -> Range<Index> {
        return index(at: range.lowerBound)..<index(at: range.upperBound)
    }

    func indexRangeFor(range: ClosedRange<Int>) -> ClosedRange<Index> {
        return index(at: range.lowerBound)...index(at: range.upperBound)
    }

    mutating func replace(range: Range<Int>, with replacement: String) {
        self.replaceSubrange(self.index(at: range.lowerBound)..<self.index(at: range.lowerBound), with: replacement)
    }

    /// Fetch indentation offset of lines in code
    /// "    var foo" -> 4
    func lineIndentationOffset() -> Int {
        var i = 0
        for a in self {
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
        let range = NSMakeRange(0, count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
        return modString
    }
}

//MARK: Advance
extension String {
    func lineOneSpaceAt(pin: Int) -> (Int, String) {

        var start = pin
        while start > 0 && self[start - 1] == " " {
            start -= 1
        }

        var end = pin
        while end < self.count && self[end] == " " {
            end += 1
        }

        var newString = self
        if start == end {//No space
            newString.replace(range: start..<start, with: " ")
        } else if end - start == 1 {//If one space replace with no-space
            newString.replace(range: start..<end, with: "")
        } else { //More than one space
            newString.replace(range: start..<end, with: " ")
        }
        return (start, newString)
    }

    func selectWord(pin: Int, validChars: CharacterSet) -> Range<Index>? {
        guard let range:Range<Int> = selectWord(pin: pin, validChars: validChars) else { return nil }
        return self.indexRangeFor(range: range)
    }

    func selectWord(pin: Int, validChars: CharacterSet) -> Range<Int>? {
        var pin = pin
        guard pin <= self.count else {
            return nil
        }
        guard self.count > 1  else {
            return nil
        }

        // Move pin to one position left when it is after last character
        if (pin > 0), self[pin - 1].isPresent(in: validChars) {
            pin -= 1
        }

        var start = pin
        while start >= 0 && self[start].isPresent(in: validChars) {
            start -= 1
        }

        var end = pin
        while end < count && self[end].isPresent(in: validChars) {
            end += 1
        }
        if start == end { return nil }
        return start + 1..<end
    }
}

extension RawRepresentable where RawValue == String {
    init?(command: String) {
        // Eg: com.kaunteya.Line.Duplicate
        let value = command.components(separatedBy: ".").last!
        self.init(rawValue: value)
    }
}

