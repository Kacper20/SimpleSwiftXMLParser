//
//  Parser.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 05.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation

extension Array{
     var description: String {
        return self.reduce("") { return $0 + "\($1)\n" }    }
}

enum XMLNodeContent: CustomStringConvertible {
    case stringContent(String)
    case childNodes(nodes: [XMLNode])
    case none
    
    var description: String {
        switch self {
        case .stringContent(let val): return "STRING: \(val)"
        case .childNodes(nodes: let nodes): return "NODES: \t \(nodes)"
        case .none: return "EMPTY CONTENT"
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
        if let newBatch = tokenScanner.nextToken(), newBatch.count > 0     {
            tokens.append(contentsOf: newBatch)
            return tokens[indx + 1]
        }
        else {
            return nil
        }
    }
    @discardableResult private func popToken() -> XMLToken? {
        if indx < tokens.count - 1 {
            indx += 1
            return tokens[indx]
        }
        if let newBatch = tokenScanner.nextToken(), newBatch.count > 0     {
            tokens.append(contentsOf: newBatch)
            indx += 1
            return tokens[indx]
        }
        else {
            return nil
        }
    }

    func tokensAvailable() -> Bool {
        return peekToken() != nil
    }

    //Better error handling in next versio
    enum ParseAttributeError: Error {
        case expectedAttributeName
        case expectedAttributeValue
        case expectedEqualSign
        case expectedQuotation
        case emptyInput
    }

    private func parseOneAttribute() throws -> XMLNodeAttribute {
        guard let token = popToken() else { fatalError("Empty token but called parseAttributeFunction") }
        guard case let XMLToken.id(keyValue) = token else {
            throw ParseAttributeError.expectedAttributeName
        }
        guard let token2 = popToken() else { throw ParseAttributeError.emptyInput }
        guard case XMLToken.equalSign = token2 else { throw ParseAttributeError.expectedEqualSign }
        let value = try parseAttributeValue()
        return XMLNodeAttribute(key: keyValue, value: value)
    }
    
    private func getOrThrowEmpty() throws -> XMLToken {
        if let token = popToken()  {
            return token
        }
        else {
            throw ParseAttributeError.emptyInput
        }
        
    }

    private func parseAttributeValue() throws -> String {
        guard case XMLToken.quotation = try getOrThrowEmpty() else {
            throw ParseAttributeError.expectedQuotation
        }
        guard case let XMLToken.name(val) = try getOrThrowEmpty() else {
            throw ParseAttributeError.expectedAttributeValue
        }
        guard case XMLToken.quotation = try getOrThrowEmpty() else {
            throw ParseAttributeError.expectedQuotation
        }
        return val
    }

    private func passThroughWhitespace() {
        if let next = peekToken() {
            if case XMLToken.whitespace = next  { let _ = popToken()  }
        }
    }
    
    enum ParseNodeError: Error {
        case expectedQuestionMark
        case expectedOpenToken
        case expectedNameToken
        case emptyInputWithoutClosingNode
        case noClosingNode
        case expectedClosingToken
        case expectedClosingNodeName
        case expectedEndTokenInClosing
        case beginningClosingElementInconsistentNames
    }

    func parseClosingElement() throws -> String {
        guard case XMLToken.closeToken = try getOrThrowEmpty() else { throw ParseNodeError.expectedClosingToken }
        guard case let XMLToken.id(id) = try getOrThrowEmpty() else { throw ParseNodeError.expectedClosingNodeName }
        passThroughWhitespace()
        guard case XMLToken.endToken = try getOrThrowEmpty() else { throw ParseNodeError.expectedEndTokenInClosing }
        return id
    }
    
    func parseChildNodes() throws -> [XMLNode] {
        var nodes: [XMLNode] = []
        while true {
            passThroughWhitespace()
            guard let token = peekToken() else { return nodes }
            guard case XMLToken.beginToken = token else { return nodes }
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
            return nil
        }
    }

    func parseHeader() throws -> XMLHeader{
        guard case XMLToken.beginToken = try getOrThrowEmpty() else { throw ParseNodeError.expectedOpenToken }
        guard case XMLToken.questionMark = try getOrThrowEmpty() else { throw ParseNodeError.expectedQuestionMark }
        guard case let XMLToken.id(name) = try getOrThrowEmpty() else { throw ParseNodeError.expectedNameToken }
        
        let attrs = try parseAttributes()
        passThroughWhitespace()
        guard case XMLToken.questionMark = try getOrThrowEmpty() else { throw ParseNodeError.expectedQuestionMark }
        guard case XMLToken.endToken = try getOrThrowEmpty() else { throw ParseNodeError.expectedEndTokenInClosing }

        return XMLHeader(name: name, attributes: attrs)
    }

    func parseAttributes() throws -> [XMLNodeAttribute] {
        var attributes: [XMLNodeAttribute] = []
        
        while true {
            guard let peek = peekToken() else { throw ParseNodeError.emptyInputWithoutClosingNode }
            if case XMLToken.id(_) = peek {
                let parsedAttribute = try parseOneAttribute()
                attributes.append(parsedAttribute)
                continue
            }
            if case XMLToken.whitespace = peek {
                popToken()
                guard let peek = peekToken() else { throw ParseNodeError.emptyInputWithoutClosingNode }
                if case XMLToken.id(_) = peek {
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
        guard case XMLToken.beginToken = try getOrThrowEmpty() else { throw ParseNodeError.expectedOpenToken }
        guard case let XMLToken.id(name) = try getOrThrowEmpty() else { throw ParseNodeError.expectedNameToken }
        
        var attributes: [XMLNodeAttribute] = []
        
        //REFACTOR LATER
        guard let nextAfter = popToken() else { throw ParseNodeError.emptyInputWithoutClosingNode }
        //If it's whitespace - we're checking for the attributes(there has to be whitespace). If there are no attributes, whitespace is consumed and we're looking for closing of the node.
        if case XMLToken.whitespace = nextAfter {
            attributes = try parseAttributes()
        }
        guard let closingElement = { Void -> XMLToken? in
            if case XMLToken.whitespace = nextAfter {
                return popToken()
            }
            else {
                return nextAfter
            }
            }() else {
                throw ParseNodeError.emptyInputWithoutClosingNode
        }
        if case XMLToken.autoCloseToken = closingElement {
            return XMLNode(name: name, attributes: attributes, content: XMLNodeContent.none)
        }
        else if case XMLToken.endToken = closingElement {
            passThroughWhitespace()
            guard var next = peekToken() else { throw ParseNodeError.noClosingNode }
            var childNodes: [XMLNode] = []
            
            
            if case XMLToken.beginToken = next {
                //Parse SUBNODES...
                childNodes = try parseChildNodes()
                guard let nodeAfterParsingSubnodes = peekToken() else { throw ParseNodeError.noClosingNode }
                next = nodeAfterParsingSubnodes
                
            }
            if case let XMLToken.name(val) = next {
                let _ = popToken()
                if try parseClosingElement() == name {
                    return XMLNode(name: name, attributes: attributes, content: XMLNodeContent.stringContent(val))
                }
                else {
                    throw ParseNodeError.beginningClosingElementInconsistentNames
                }
            }
            if case XMLToken.closeToken = next {
                if try parseClosingElement() == name {
                    let contentType = { Void -> XMLNodeContent in
                        if childNodes.count > 0 {
                            return XMLNodeContent.childNodes(nodes: childNodes)
                        }
                        else {
                            return XMLNodeContent.none
                        }
                        
                    }()
                    return XMLNode(name: name, attributes: attributes, content: contentType)
                }
                else {
                    throw ParseNodeError.beginningClosingElementInconsistentNames
                }
            }
        }
        throw ParseNodeError.emptyInputWithoutClosingNode
    }
    
}
