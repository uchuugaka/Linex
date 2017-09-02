//
//  CaseHandler.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 02/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Foundation

enum Case {
    case title // "We Have A Book"
    case upper // "WE HAVE A BOOK"
    case lower // "we have a book"
    case snake // "we_have_a_book"
    case camel // "weHaveABook"
    case pascal // "WeHaveABook"
}

extension String {

    func camelPascalToSnake() -> String? {
        guard !self.contains("_") else { return nil }
        let pattern = "(?!^)([A-Z])([a-z0-9]*)"
        let template = "_$1$2"
        return self.replacedRegex(pattern: pattern, with: template).lowercased()
    }

    func toRaw() -> String? {
        guard self.characters.count > 0 else {
            return nil
        }
        if self.contains("_") { return self }
        if self.contains(" ") {
            return self.replacingOccurrences(of: " ", with: "_").lowercased()
        }
        return camelPascalToSnake()
    }
    func rawTo(_ case: Case) -> String? {
        switch `case` {
        case .title: return self.replacingOccurrences(of: "_", with: " ").capitalized
        case .upper: return self.replacingOccurrences(of: "_", with: " ").uppercased()
        case .lower: return self.replacingOccurrences(of: "_", with: " ").lowercased()
        case .snake: return self
        case .camel:
            return self.components(separatedBy: "_").reduce("") {
                //For first case dont capitalize
                $0.isEmpty ? $1 : $0 + $1.capitalized
            }
        case .pascal:
            return self.components(separatedBy: "_").map { $0.capitalized }.joined()
        }
    }

    func convertTo(case: Case) -> String? {
        return self.toRaw()?.rawTo(`case`)
    }
}










