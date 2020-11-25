//
//  Common.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 01/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension RawRepresentable where RawValue == String {
    init?(command: String) {
        // Eg: com.kaunteya.Line.Duplicate
        let value = command.components(separatedBy: ".").last!
        self.init(rawValue: value)
    }
}

