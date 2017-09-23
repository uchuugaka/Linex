//
//  Util.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 06/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
extension Array where Element == String {

    // Return nil when offset is not found in any line
    func farthestOffsetFor(subStr: String) -> Int? {
        guard self.count > 0 else { return nil; }
        var farthest: Int = 0
        for str in self {
            let seperated = str.components(separatedBy: subStr)
            if seperated.count == 2 {
                let offset = seperated.first!.trimmedEnd().characters.count
                if offset > farthest { farthest = offset }
            }
        }
        return farthest
    }

    func alignedDefineStatements() -> [String]? {
        var farthestOffset = 0
        var indexSet = [Int]()
        var alignedLines = self

        //Find the farthest offset
        for (i, line) in enumerated() {
            if line.hasPrefix("#define") {
                indexSet.append(i)
                let split = line.condensedWhitespace.components(separatedBy: " ")
                if split.count > 2 {
                    if farthestOffset < split[1].characters.count {
                        farthestOffset = split[1].characters.count
                    }
                }
            }
        }

        // If no #defines found in subsequent lines
        if indexSet.count < 2 { return nil }

        //Align all #defines according to farthest offset
        for i in indexSet {
            let line = alignedLines[i].condensedWhitespace
            var split = line.components(separatedBy: " ")
            if split.count > 2 {
                split[1] = split[1].padding(toLength: farthestOffset, withPad: " ", startingAt: 0)
            }
            alignedLines[i] = split.joined(separator: " ")
        }
        return alignedLines
    }


    func aligned(seperator: String) -> [String]? {
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
                return "\(a)\(seperator)\(component[1].trimmedStart())"
            }
            return str
        }
        return aligned
    }

    func autoAlign() -> [String]? {
        guard self.count != 0 else {
            return nil
        }
        if first!.hasPrefix("#define") {
            return self.alignedDefineStatements()
        }
        return self.aligned(seperator: ": ")?.aligned(seperator: " = ")
    }
}
