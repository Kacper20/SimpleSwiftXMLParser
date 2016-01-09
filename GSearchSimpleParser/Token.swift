//
//  Token.swift
//  LexerApp
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation
/* 

BASIC GRAMMAR:



*/
public enum XMLToken {
    case QuestionMark
    case EqualSign
    case BeginToken
    case Id(String)
    case Name(String)
    case Quotation
    case EndToken
    case CloseToken
    case Whitespace
    case AutoCloseToken
    case HeaderOpen
    case HeaderClose
    
}
