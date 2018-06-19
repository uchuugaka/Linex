//
//  Line.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 18/06/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

struct Line {
    var stringValue: String

    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    var indentationOffset: Int {
        //TODO: Replace with firstIndex { where } in Swift 4.2
        var i = 0
        for a in stringValue {
            if a == " " {
                i += 1
            } else { break }
        }
        return i
    }
    
    mutating func indent(by offset: Int) {
        let offsetString = String(repeating: " ", count: offset)
        stringValue = offsetString + stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Line: Collection {
    typealias Index = String.Index
    typealias Element = String.Element

    subscript(position: String.Index) -> Element {
        return stringValue[position]
    }

    subscript (position: Int) -> Element {
        let index = self.index(self.startIndex, offsetBy: position)
        return self[index]
    }
    
    func index(after i: String.Index) -> Index {
        return stringValue.index(after: i)
    }

    var startIndex: Line.Index {
        return stringValue.startIndex
    }
    var endIndex: Line.Index {
        return stringValue.endIndex
    }
}
