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


XML ::= header node*
header ::= begin_token ? xml <attribute>* ? end_token
name ::= ciag_znakow_bez_spacji
string ::= name  | whitespaces |  name whitespaces string
attribute ::= <name> <equal_sign> >attr_value>
whitespace ::= //comment: couple of whitespaces in converted into just one.
equal_sign ::= =
attr_value ::= " <string> "
begin_token -> <
end_token -> >
close_token -> </
autoclose_token -> />
open_end_tag ::=  begin_token name <attribute> <autoclose_token>
| begin_token name <autoclose_token>
open_tag ::= <begin_token> <name> <end_token>
| <begin_token> <name> <attribute> <end_token>
end_tag ::= <close_token> <name> <end_token>
node ::= <open_tag> <content> <end_tag>
| <open_tag> <node> <end_tag>
| <open_end_tag>

*/
enum XMLToken {
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
    
}
