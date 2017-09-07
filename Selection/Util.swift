//
//  Util.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 06/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
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
        if start == end {
            return (pin, self)
        }
        let range = self.index(self.startIndex, offsetBy: start)..<self.index(self.startIndex, offsetBy: end)
        var newString = self
        newString.replaceSubrange(range, with: " ")
        return (start, newString)
    }
}
extension Array where Element == String {

    // Return nil when offset is not found in any line
    func farthestOffsetFor(subStr: String) -> Int? {
        guard self.count > 0 else { return nil; }
        var farthest: Int = 0
        for str in self {
            let seperated = str.components(separatedBy: subStr)
            if seperated.count == 2 {
                let offset = seperated.first!.characters.count
                if offset > farthest { farthest = offset }
            }
        }
        return farthest
    }

    func aligned(seperator: String) -> [String]? {
        guard self.count != 0 else {
            return nil
        }
        guard self.count > 1 else {
            assert(self.count == 1)
            return self
        }
        guard let alignOffset = self.farthestOffsetFor(subStr: seperator) else {
            //Farthest Offset Not Available
            return self
        }

        let aligned = self.map { (str) -> String in
            let component = str.components(separatedBy: seperator)
            if component.count == 2 {
                let a = component.first!.padding(toLength: alignOffset, withPad: " ", startingAt: 0)
                return a + seperator + component[1]
            }
            return str
        }
        return aligned
    }

    func autoAlign() -> [String]? {
        return self.aligned(seperator: ":")?.aligned(seperator: "=")
    }
}
