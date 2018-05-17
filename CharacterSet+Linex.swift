//
//  CharacterSet+Linex.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 16/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension CharacterSet {
    static var validWordChars: CharacterSet {
        return CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@$_"))
    }
}
