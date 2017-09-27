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

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (range: Range<Int>) -> Substring {
        let rangeIndex:Range<Index> = self.indexRangeFor(range: range)
        return self[rangeIndex]
    }
    
    subscript(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
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

//MARK: Advance
extension String {
    func lineOneSpaceAt(pin: Int) -> (Int, String) {

        var start = pin
        while start > 0 && self[start - 1] == " " {
            start -= 1
        }

        var end = pin
        while end < self.characters.count && self[end] == " " {
            end += 1
        }

        var newString = self
        if start == end {//No space
            newString.replaceSubrange(self.indexAt(offset: start)..<self.indexAt(offset: start), with: " ")
        } else if end - start == 1 {//If one space
            let range = self.indexAt(offset: start)..<self.indexAt(offset: end)
            newString.replaceSubrange(range, with: "")
        } else { //More than one space
            let range = self.indexAt(offset: start)..<self.indexAt(offset: end)
            newString.replaceSubrange(range, with: " ")
        }
        return (start, newString)
    }

    func selectWord(pin: Int) -> Range<Index>? {
        guard let range:Range<Int> = selectWord(pin: pin) else { return nil }
        return self.indexRangeFor(range: range)
    }

    func selectWord(pin: Int) -> Range<Int>? {
        var pin = pin
        guard pin <= self.characters.count else {
            return nil
        }
        guard self.characters.count > 1  else {
            return nil
        }

        // Move pin to one position left when it is after last character
        let invalidLastChars = CharacterSet(charactersIn: " :!?,.")
        var validChars = CharacterSet.alphanumerics
        validChars.insert(charactersIn: "@_")
        if (pin > 0), let _ = (self[pin] as String).rangeOfCharacter(from: invalidLastChars) {
            if let _ = (self[pin - 1] as String).rangeOfCharacter(from: validChars) {
                pin -= 1
            }
        }

        var start = pin
        while start >= 0 && (self[start] as String).rangeOfCharacter(from: validChars) != nil {
            start -= 1
        }

        var end = pin
        while end < characters.count && (self[end] as String).rangeOfCharacter(from: validChars) != nil {
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

