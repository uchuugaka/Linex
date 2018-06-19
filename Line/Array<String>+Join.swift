//
//  Array<String>+Join.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 18/06/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension Array where Element == Line {
    func joined(separator: String, trimming: CharacterSet) -> Line {
        guard self.count > 1 else { return self.first! }
        let joinedString = self
            .map { $0.stringValue.trimmingCharacters(in: trimming)}
            .joined(separator: separator)

        return Line(joinedString)
    }
}
