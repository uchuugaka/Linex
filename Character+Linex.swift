//
//  Character+Linex.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 05/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

extension Character {
    var isOpening: Bool {
        let openStopper = CharacterSet(charactersIn: "{[(")
        return CharacterSet(charactersIn: String(self)).isSubset(of: openStopper)
    }
    var isClosing:Bool {
        let openStopper = CharacterSet(charactersIn: "}])")
        return CharacterSet(charactersIn: String(self)).isSubset(of: openStopper)
    }
    func presentIn(_ characterSet:CharacterSet) -> Bool {
        return CharacterSet(charactersIn: String(self)).isSubset(of: characterSet)
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
