//
//  CharacterSet+Linex.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 16/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension CharacterSet {
    init(_ string: String) {
        self.init(charactersIn: string)
    }
    static var validWordChars: CharacterSet {
        return CharacterSet("@$_").union(.alphanumerics)
    }
}
