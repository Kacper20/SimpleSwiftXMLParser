//
//  TokenScanner.swift
//  LexerApp
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation





final class TokenScanner {

    private enum Context {
        case Inside, Outside
    }

    private var contextStack: [Context] = [.Outside]
    private let alphanumericSet = NSCharacterSet.alphanumericCharacterSet()
    private let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    private let punctuationSet = NSCharacterSet.punctuationCharacterSet()
    private var bufferedString: String = ""
    private var stream: Stream
    init(stream: Stream) {
        self.stream = stream
    }
    private func consumeWhiteSpaces() {
        while let elem = stream.consumeNext() {
            if elem == " " { continue }
            else {
                stream.back()
                return
            }
        }
    }
    
    private func consumeId(startingElem: Character) -> [XMLToken]{
        var tempBuffer = String(startingElem)
        repeat {
            guard let elem = stream.consumeNext() else { return [XMLToken.Id(tempBuffer)] }
            
            if elem == "/" {
                stream.back()
                return [XMLToken.Id(tempBuffer)]
            }
            if elem.isIn(alphanumericSet) || elem.isIn(punctuationSet) {
                tempBuffer.append(elem)
            }
            else if elem.isIn(whitespaceSet) {
                consumeWhiteSpaces()
                return [XMLToken.Id(tempBuffer), XMLToken.Whitespace]
            }
            else {
                stream.back()
                return [XMLToken.Id(tempBuffer)]
            }

        } while true
    }
    private enum StringType {
        case InsideQuotation
        case OutsideQuotation
    }
    
    private func consumeString(type: StringType = .InsideQuotation) -> [XMLToken] {
        var tempBuffer = ""
        repeat {
            guard let elem = stream.consumeNext() else { print("MEE: \(tempBuffer)"); return [XMLToken.Name(tempBuffer)] }
            
            if elem == "<" && type == .OutsideQuotation { stream.back(); return [XMLToken.Name(tempBuffer)] }
            if elem == "\"" && type == .InsideQuotation {
                return [XMLToken.Name(tempBuffer), XMLToken.Quotation]
            }
            tempBuffer.append(elem)
        } while true
    }
    
    
    func nextToken()  -> [XMLToken]?  {
        repeat {
            guard let elem = stream.consumeNext() else { return nil }
            
            if elem.isIn(alphanumericSet) && contextStack.last == .Inside { return consumeId(elem) }
        
            else if elem.isIn(alphanumericSet) && contextStack.last == .Outside {
                stream.back()
                return consumeString(.OutsideQuotation)
            }
            else if elem.isIn(whitespaceSet) { consumeWhiteSpaces(); return [XMLToken.Whitespace]}
        
            else {
                switch elem {
                case "<":
                    contextStack.append(.Inside)
                    if let char = stream.peek() where char == "/" {
                        stream.consumeNext()
                        return [XMLToken.CloseToken]
                    }
                    return [XMLToken.BeginToken]
                case "/": if let char = stream.peek() where char == ">" {
                        contextStack.removeLast()
                        stream.consumeNext()
                        return [XMLToken.AutoCloseToken]
                    }
                case "=": return [XMLToken.EqualSign]
                case ">": self.contextStack.removeLast(); return [XMLToken.EndToken]
                case "\"": return [XMLToken.Quotation] + consumeString()
                case "?": return [XMLToken.QuestionMark]
                default: break
                    
                }
            }
        } while true
    }
}

extension Character {
    //Checks if given character set contains character
    func isIn(set: NSCharacterSet) -> Bool {
        let unicodeScalars = String(self).unicodeScalars
        let scalar = unicodeScalars[unicodeScalars.startIndex]
        return set.longCharacterIsMember(scalar.value)
    }
    
}
