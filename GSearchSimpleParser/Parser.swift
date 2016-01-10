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

extension Array{
     var description: String {
        return self.reduce("") { return $0 + "\($1)\n" }    }
}

enum XMLNodeContent: CustomStringConvertible {
    case StringContent(String)
    case ChildNodes(nodes: [XMLNode])
    case None
    
    var description: String {
        switch self {
        case .StringContent(let val): return "STRING: \(val)"
        case .ChildNodes(nodes: let nodes): return "NODES: \t \(nodes)"
        case .None: return "EMPTY CONTENT"
        }
    }
}


struct XMLNodeAttribute: CustomStringConvertible {
    let key: String
    let value: String
    
    var description: String {
        return "ATTRIBUTE: \(key), value: \(value)\n"
    }
}

struct XMLHeader: CustomStringConvertible {
    let name: String
    var attributes: [XMLNodeAttribute]
    
    
    var description: String {
        let attrs = attributes.reduce("") { return $0 +  "\($1)\n" }
        return "name: \(name)\n, attrs: \n\(attrs)\n"
    }
    
}
struct XMLNode: CustomStringConvertible {
    
    let name: String
    var attributes: [XMLNodeAttribute]
    var content: XMLNodeContent
    
    var description: String {
        return "\n\nNODE name: \(name), \nattrs: \(attributes), \(content)"
    }
}
struct XMLDocument: CustomStringConvertible{
    
    let header: XMLHeader
    let nodes: [XMLNode]
    var description: String {
        let nodesDesc = nodes.reduce("") { return $0 +  "\($1)\n" }
        return "XML DOCUMENT:\nHEADER: \(header)\nCONTENT: \(nodesDesc)"
    }
    
}



enum ParseError: ErrorType {
    case ExpectedSomething
}

final class Parser {
    
    private var tokenScanner: TokenScanner
    private var tokens: [XMLToken] = []
    
    //It points to lastly consumed element(current)
    var indx: Int = -1
    init(tokenScanner: TokenScanner) {
        self.tokenScanner = tokenScanner
    }
    //Function that peeks into the next token, but not consumes it.
    
    private func peekToken() -> XMLToken? {
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
    private func popToken() -> XMLToken? {
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
    
    

    private func parseOneAttribute() throws -> XMLNodeAttribute {
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
    
    private func getOrThrowEmpty() throws -> XMLToken {
        if let token = popToken()  {
            return token
        }
        else {
            throw ParseAttributeError.EmptyInput
        }
        
    }
    private func parseAttributeValue() throws -> String {
        guard case XMLToken.Quotation = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedQuotation }
        guard case let XMLToken.Name(val) = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedAttributeValue }
        guard case XMLToken.Quotation = try getOrThrowEmpty() else { throw ParseAttributeError.ExpectedQuotation }
        return val
    }
    private func passThroughWhitespace() {
        if let next = peekToken() {
            if case XMLToken.Whitespace = next  { let _ = popToken()  }
        }
    }
    
    enum ParseNodeError: ErrorType {
        case ExpectedQuestionMark
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
    
    func parseChildNodes() throws -> [XMLNode] {
        var nodes: [XMLNode] = []
        while true {
            passThroughWhitespace()
            guard let token = peekToken() else { return nodes }
            guard case XMLToken.BeginToken = token else { return nodes }
            let nodeParsed = try parseChildNode()
            
            nodes.append(nodeParsed)
        }

        
        
        
    }
    
    func parseDocument() -> XMLDocument? {
        do {
            let header = try parseHeader()
            passThroughWhitespace()
            let nodes = try parseChildNodes()
            
            return XMLDocument(header: header, nodes: nodes)
        }
        catch {
            
            print("Error: \(error)")
            return nil
        }


    }
    func parseHeader() throws -> XMLHeader{
        
        guard case XMLToken.BeginToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedOpenToken }
        guard case XMLToken.QuestionMark = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedQuestionMark }
        guard case let XMLToken.Id(name) = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedNameToken }
        
        let attrs = try parseAttributes()
        passThroughWhitespace()
        guard case XMLToken.QuestionMark = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedQuestionMark }
        guard case XMLToken.EndToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedEndTokenInClosing }
        

        return XMLHeader(name: name, attributes: attrs)
        
        
    }
    

    func parseAttributes() throws -> [XMLNodeAttribute] {
        
        var attributes: [XMLNodeAttribute] = []
        
        while true {
            guard let peek = peekToken() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
            if case let XMLToken.Id(_) = peek {
                let parsedAttribute = try parseOneAttribute()
                attributes.append(parsedAttribute)
                continue
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
        return attributes
        
    }

        

    func parseChildNode() throws -> XMLNode {
        guard case XMLToken.BeginToken = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedOpenToken }
        guard case let XMLToken.Id(name) = try getOrThrowEmpty() else { throw ParseNodeError.ExpectedNameToken }
        
        var attributes: [XMLNodeAttribute] = []
        
        //REFACTOR LATER
        guard let nextAfter = popToken() else { throw ParseNodeError.EmptyInputWithoutClosingNode }
        //If it's whitespace - we're checking for the attributes(there has to be whitespace). If there are no attributes, whitespace is consumed and we're looking for closing of the node.
        if case XMLToken.Whitespace = nextAfter {
            attributes = try parseAttributes()
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
            passThroughWhitespace()
            guard var next = peekToken() else { throw ParseNodeError.NoClosingNode }
            var childNodes: [XMLNode] = []
            
            
            if case let XMLToken.BeginToken = next {
                //Parse SUBNODES...
                childNodes = try parseChildNodes()
                guard let nodeAfterParsingSubnodes = peekToken() else { throw ParseNodeError.NoClosingNode }
                next = nodeAfterParsingSubnodes
                
            }
            if case let XMLToken.Name(val) = next {
                let _ = popToken()
                if try parseClosingElement() == name {
                    return XMLNode(name: name, attributes: attributes, content: XMLNodeContent.StringContent(val))
                }
                else {
                    throw ParseNodeError.BeginningClosingElementInconsistentNames
                }
            }
            if case let XMLToken.CloseToken = next {
                if try parseClosingElement() == name {
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