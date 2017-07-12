//
//  TokenScanner.swift
//  LexerApp
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation

final class TokenScanner {

    private enum ParsingContext {
        case inside, outside
    }

    private var contextStack: [ParsingContext] = [.outside]
    private let alphanumericSet = CharacterSet.alphanumerics
    private let whitespaceSet = CharacterSet.whitespacesAndNewlines
    private let punctuationSet = CharacterSet.punctuationCharacters
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
    
    private func consumeId(startingWith startingElem: Character) -> [XMLToken]{
        var tempBuffer = String(startingElem)
        repeat {
            guard let elem = stream.consumeNext() else { return [XMLToken.id(tempBuffer)] }
            
            if elem == "/" {
                stream.back()
                return [XMLToken.id(tempBuffer)]
            }
            if elem.isIn(set: alphanumericSet) || elem.isIn(set: punctuationSet) {
                tempBuffer.append(elem)
            }
            else if elem.isIn(set: whitespaceSet) {
                consumeWhiteSpaces()
                return [XMLToken.id(tempBuffer), XMLToken.whitespace]
            }
            else {
                stream.back()
                return [XMLToken.id(tempBuffer)]
            }

        } while true
    }
    private enum StringType {
        case insideQuotation
        case outsideQuotation
    }
    
    private func consumeString(withType type: StringType = .insideQuotation) -> [XMLToken] {
        var tempBuffer = ""
        repeat {
            guard let elem = stream.consumeNext() else {
                return [XMLToken.name(tempBuffer)]
            }
            if elem == "<" && type == .outsideQuotation { stream.back(); return [XMLToken.name(tempBuffer)] }
            if elem == "\"" && type == .insideQuotation {
                return [XMLToken.name(tempBuffer), XMLToken.quotation]
            }
            tempBuffer.append(elem)
        } while true
    }

    func nextToken()  -> [XMLToken]?  {
        repeat {
            guard let elem = stream.consumeNext() else { return nil }
            
            if elem.isIn(set: alphanumericSet) && contextStack.last == .inside {
                return consumeId(startingWith: elem)

            } else if elem.isIn(set: alphanumericSet) && contextStack.last == .outside {
                stream.back()
                return consumeString(withType: .outsideQuotation)
            } else if elem.isIn(set: whitespaceSet) {
                consumeWhiteSpaces()
                return [XMLToken.whitespace]
            } else {
                switch elem {
                case "<":
                    contextStack.append(.inside)
                    if let char = stream.peek(), char == "/" {
                        stream.consumeNext()
                        return [XMLToken.closeToken]
                    }
                    return [XMLToken.beginToken]
                case "/": if let char = stream.peek(), char == ">" {
                        contextStack.removeLast()
                        stream.consumeNext()
                        return [XMLToken.autoCloseToken]
                    }
                case "=": return [XMLToken.equalSign]
                case ">": self.contextStack.removeLast(); return [XMLToken.endToken]
                case "\"": return [XMLToken.quotation] + consumeString()
                case "?": return [XMLToken.questionMark]
                default: break
                }
            }
        } while true
    }
}
