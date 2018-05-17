//
//  ConditionalAssignment.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 17/05/18.
//  Copyright © 2018 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

infix operator ?= : AssignmentPrecedence

func ?= <T: Any>( left: inout T?, right: T?) {
    if left == nil {
        left = right
    }
}
