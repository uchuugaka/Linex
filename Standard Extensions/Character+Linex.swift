//
//  Character+Linex.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension Character {
    func presentIn(_ string: String) -> Bool {
        return self.presentIn(CharacterSet(string))
    }

    func presentIn(_ characterSet:CharacterSet) -> Bool {
        return CharacterSet(String(self)).isSubset(of: characterSet)
    }

    var isOpening: Bool {
        return self.presentIn(CharacterSet("{[("))
    }

    var isClosing:Bool {
        return self.presentIn(CharacterSet("}])"))
    }

    var closing: Character {
        assert(self.isOpening, "Only opening characters can have closing characters")
        return ["{":"}", "(":")", "[":"]"][self]!
    }

    var opening: Character {
        assert(self.isClosing, "Only closing characters can have opening characters")
        return ["}":"{", ")":"(", "]":"["][self]!
    }
}
