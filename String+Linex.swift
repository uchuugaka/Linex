//
//  String+Basic.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

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
        if (pin > 0), self[pin - 1].presentIn(validChars) {
            pin -= 1
        }

        var start = pin
        while start >= 0 && self[start].presentIn(validChars) {
            start -= 1
        }

        var end = pin
        while end < count && self[end].presentIn(validChars) {
            end += 1
        }
        if start == end { return nil }
        return start + 1..<end
    }
}
