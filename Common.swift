//
//  Common.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import Foundation

extension String {

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
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

    func lineOneSpaceAt(pin: Int) -> (Int, String) {

        var start = pin
        while start > 0 && self[start - 1] == " " {
            start -= 1
        }

        var end = pin
        while end < self.characters.count && self[end] == " " {
            end += 1
        }
        if start == end {
            return (pin, self)
        }
        let range = self.index(self.startIndex, offsetBy: start)..<self.index(self.startIndex, offsetBy: end)
        var newString = self
        newString.replaceSubrange(range, with: " ")
        return (start, newString)
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
        let bundle = Bundle.main.bundleIdentifier! + "."
        let str = command.substring(from: bundle.endIndex)
        self.init(rawValue: str)
    }
}
