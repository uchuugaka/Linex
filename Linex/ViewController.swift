//
//  ViewController.swift
//  Linex
//
//  Created by Kaunteya Suryawanshi on 29/08/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBAction func actionOpenGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/kaunteya/Linex")!)
    }
}

