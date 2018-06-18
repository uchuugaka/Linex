//
//  Array<String>+Join.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 18/06/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension Array where Element == String {
    var lineJoined: String {
        guard self.count > 1 else { return self.first! }

        let offset = String(repeating: " ", count: self.first!.indentationOffset)
        return
            offset +
            self
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
                .joined(separator: " ")
    }
}
