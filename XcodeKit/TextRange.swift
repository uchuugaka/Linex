//
//  TextRange.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 19/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation
import XcodeKit

typealias TextRange = XCSourceTextRange

extension TextRange {
    func updateSelection(range: TextRange) {
        self.start = range.start
        self.end = range.end
    }
}
