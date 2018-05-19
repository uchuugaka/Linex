//
//  TextRange.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 19/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
extension TextRange {
    func update(selection: TextRange) {
        self.start = selection.start
        self.end = selection.end
    }
}
