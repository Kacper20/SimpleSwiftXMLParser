//
//  Parser.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 05.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation
struct Node {
    
}


enum XMLNodeContent: CustomStringConvertible {
    case StringContent(String)
    case ChildNodes(nodes: [XMLNode])
    case None
    
    var description: String {
        switch self {
        case .StringContent(let val): return "STRING: \(val)"
        case .ChildNodes(nodes: let nodes): return "NODES: \(nodes)"
        case .None: return "EMPTY CONTENT"
        }
    }
}
struct XMLNodeAttribute: CustomStringConvertible {
    let key: String
    let value: String
    
    var description: String {
        return "ATTRIBUTE: \(key), value: \(value)"
    }
}
struct XMLNode: CustomStringConvertible {
    
    let name: String
    var attributes: [XMLNodeAttribute]
    var content: XMLNodeContent
    
    var description: String {
        return "NODE name: \(name), attrs: \(attributes), \(content)"
    }
}



enum ParseError: ErrorType {
    case ExpectedSomething
}

class Parser {
    
    private var tokenScanner: TokenScanner
    private var tokens: [XMLToken] = []
    
    //It points to lastly consumed element(current)
    var indx: Int = -1
    init(tokenScanner: TokenScanner) {
        self.tokenScanner = tokenScanner
    }
    //Function that peeks into the next token, but not consumes it.
    
    func peekToken() -> XMLToken? {
        //If we have
        if indx < tokens.count - 1 {
            return tokens[indx + 1]
        }
        if let newBatch = tokenScanner.nextToken() where newBatch.count > 0     {
            tokens.appendContentsOf(newBatch)
            return tokens[indx + 1]
        }
        else {
            return nil
        }
    }
    func popToken() -> XMLToken? {
        if indx < tokens.count - 1 {
            indx += 1
            return tokens[indx]
        }
        if let newBatch = tokenScanner.nextToken() where newBatch.count > 0     {
            tokens.appendContentsOf(newBatch)
            indx += 1
            return tokens[indx]
        }
        else {
            return nil
        }
    }
    func tokensAvailable() ->  Bool {
        return peekToken() != nil
    }
    
    
    
    
    //Better error handling in next versio
    enum ParseAttributeError: ErrorType {
        case ExpectedAttributeName
        case ExpectedAttributeValue
        case ExpectedEqualSign
        case ExpectedQuotation
        case EmptyInput
    }
    
    //attribute ::= <Id> <equal_sign> >attr_value>
    
    

    func parseAttribute() throws -> XMLNodeAttribute {
        //refactor later...
        guard let token = popToken() else { fatalError("Empty token but called parseAttributeFunction") }
        guard case let XMLToken.Id(keyValue) = token else {
            throw ParseAttributeError.ExpectedAttributeName
        }
        guard let token2 = popToken() else { throw ParseAttributeError.EmptyInput }
        guard case XMLToken.EqualSign = token2 else { throw ParseAttributeError.ExpectedEqualSign }
        let value = try parseAttributeValue()
        return XMLNodeAttribute(key: keyValue, value: value)
    }
    
    func getOrThrowEmpty() throws -> XMLToken {
        if let token = popToken()  {
            return token
        }
        else {
            throw ParseAttributeError.EmptyInput
        }
        
    }
    func parseAttributeValue() throws -> String {
        guard case XMLToken.Quotation = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedQuotation }
        guard case let XMLToken.Name(val) = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedAttributeValue }
        guard case XMLToken.Quotation = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedQuotation }
        return val
    }
    func passThroughWhitespace() {
        if let next = peekToken() {
            if case XMLToken.Whitespace = next  { let _ = popToken()  }
        }
    }
    
    enum ParseNodeError: ErrorType {
        case ExpectedOpenToken
        case ExpectedNameToken
        case EmptyInputWithoutClosingNode
        case NoClosingNode
        case ExpectedClosingToken
        case ExpectedClosingNodeName
        case ExpectedEndTokenInClosing
        case BeginningClosingElementInconsistentNames
    }
    //open_end_tag D
    //
    //
    
    //Returns name of node of the closing element
    func parseClosingElement() throws -> String {
        guard case XMLToken.CloseToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedClosingToken }
        guard case let XMLToken.Id(id) = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedClosingNodeName }
        passThroughWhitespace()
        guard case XMLToken.EndToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedEndTokenInClosing }
        return id

    }
    func parseNode() throws -> XMLNode {
        guard case XMLToken.BeginToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedOpenToken }
        guard case let XMLToken.Id(name) = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedNameToken }
        
        var attributes: [XMLNodeAttribute] = []
        
        //REFACTOR LATER
        guard let nextAfter = popToken() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
        //If it's whitespace - we're checking for the attributes(there has to be whitespace). If there are no attributes, whitespace is consumed and we're looking for closing of the node.
        if case XMLToken.Whitespace = nextAfter {
            while true {
                guard let peek = peekToken() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
                if case let XMLToken.Id(_) = peek {
                    let parsedAttribute = try parseAttribute()
                    attributes.append(parsedAttribute)
                    
                    
                }
                if case XMLToken.Whitespace = peek {
                    popToken()
                    guard let peek = peekToken() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
                    if case let XMLToken.Id(_) = peek {
                        continue
                    }
                    else {
                        break
                    }
                }
                break

            }
            //Parse attributes..
            //TODO: Parse attrs.
            
        }
        guard let closingElement = { Void -> XMLToken? in
            if case XMLToken.Whitespace = nextAfter {
                return popToken()
            }
            else {
                return nextAfter
            }
            
            }() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
        
        if case XMLToken.AutoCloseToken = closingElement {
            return XMLNode(name: name, attributes: attributes, content: XMLNodeContent.None)
        }
        else if case XMLToken.EndToken = closingElement {
            guard let next = peekToken() else { throw ParseNodeError.NoClosingNode }
            var childNodes: [XMLNode] = []
            if case let XMLToken.Name(val) = next {
                if try parseClosingElement() == name {
                    let _ = popToken()
                    return XMLNode(name: name, attributes: attributes, content: XMLNodeContent.StringContent(val))
                }
                else {
                    throw ParseNodeError.BeginningClosingElementInconsistentNames
                }
            }
            if case let XMLToken.BeginToken = next {
                
                
                
                
                //Parse SUB!
            }
            if case let XMLToken.CloseToken = next {
                if try parseClosingElement() == name {
                    let _ = popToken()
                    let contentType = { Void -> XMLNodeContent in
                        if childNodes.count > 0 {
                            return XMLNodeContent.ChildNodes(nodes: childNodes)
                        }
                        else {
                            return XMLNodeContent.None
                        }
                        
                    }()
                    return XMLNode(name: name, attributes: attributes, content: contentType)
                }
                else {
                    throw ParseNodeError.BeginningClosingElementInconsistentNames
                }
            }
        }
        throw ParseNodeError.EmptyInputWithoutClosingNode
    }
    
}