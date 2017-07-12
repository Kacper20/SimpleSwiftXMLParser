//
//  Token.swift
//  LexerApp
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation

public enum XMLToken {
    case questionMark
    case equalSign
    case beginToken
    case id(String)
    case name(String)
    case quotation
    case endToken
    case closeToken
    case whitespace
    case autoCloseToken
    case headerOpen
    case headerClose
}
