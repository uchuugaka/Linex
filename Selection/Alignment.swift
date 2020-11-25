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
    private func farthestOffsetFor(subStr: String) -> Int? {
        guard self.count > 0 else { return nil; }
        var farthest: Int = 0
        for str in self {
            let seperated = str.components(separatedBy: subStr)
            if seperated.count == 2 {
                let offset = seperated.first!.trimmedEnd.count
                if offset > farthest { farthest = offset }
            }
        }
        return farthest
    }

    private func alignedDefineStatements() -> [String] {
        var farthestOffset = 0
        var indexSet = [Int]()
        var alignedLines = self

        //Find the farthest offset
        for (i, line) in enumerated() {
            if line.hasPrefix("#define") {
                indexSet.append(i)
                let split = line.condensedWhitespace.components(separatedBy: " ")
                if split.count > 2 {
                    if farthestOffset < split[1].count {
                        farthestOffset = split[1].count
                    }
                }
            }
        }

        // If no #defines found in subsequent lines
        if indexSet.count < 2 { return self }

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

    private func alignedPropertyStatements() -> [String]? {
        let pattern = "@property\\s*(\\([\\w,= ]+\\))*\\s*(\\w+)\\s*(\\*)*\\s*(\\w+);(.*)"
        let mainRegex = try! NSRegularExpression(pattern: pattern)

        // Calculate max lengths
        var maxAttributeLength = 0
        var maxDataTypeLength = 0;
        for line in self {
            let range = NSRange(location: 0, length: line.count)
            if let property = mainRegex.firstMatch(in: line, options: [], range: range) {
                let attributeRange = property.range(at: 1)
                if attributeRange.lowerBound < attributeRange.upperBound &&
                    maxAttributeLength < line[attributeRange].count {
                    maxAttributeLength = line[attributeRange].count
                }
                let dataTypeRange = property.range(at: 2)
                if dataTypeRange.lowerBound < dataTypeRange.upperBound && maxDataTypeLength < line[dataTypeRange].count {
                    maxDataTypeLength = line[dataTypeRange].count
                }
            }
        }

        // Align the lines
        return self.map { line in
            guard line.hasPrefix("@property") else { return line }
            var newLine = "@property"
            let range = NSRange(location: 0, length: line.count)
            if let property = mainRegex.firstMatch(in: line, options: [], range: range) {

                let attributeRange = property.range(at: 1)
                let str = attributeRange.lowerBound < attributeRange.upperBound ? line[attributeRange] : ""
                newLine += " " + str.padding(toLength: maxAttributeLength, withPad: " ", startingAt: 0)

                let dataTypeRange = property.range(at: 2)
                let str1 = dataTypeRange.lowerBound < dataTypeRange.upperBound ? line[dataTypeRange] : ""
                newLine += " " + str1.padding(toLength: maxDataTypeLength, withPad: " ", startingAt: 0)

                let asterisk = property.range(at: 3)
                newLine += asterisk.lowerBound < asterisk.upperBound ? " *" : "  "

                let variable = property.range(at: 4)
                newLine += variable.lowerBound < variable.upperBound ? line[variable] + ";" : ";"

                let trailing = property.range(at: 5)
                newLine += trailing.lowerBound < trailing.upperBound ? line[trailing] : ""
            }
            return newLine
        }
    }

    private func aligned(seperator: String) -> [String]? {
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
                return "\(a)\(seperator)\(component[1].trimmedStart)"
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
        if first!.hasPrefix("@property") {
            return self.alignedPropertyStatements()
        }

        return self.aligned(seperator: ": ")?.aligned(seperator: " = ")
    }
}
