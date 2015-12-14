//
//  TokenScanner.swift
//  LexerApp
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation


class TokenScanner {

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
            switch elem {
            case "a"..."z", "0"..."9":
                tempBuffer.append(elem)
            case " ":
                consumeWhiteSpaces()
                return [XMLToken.Id(tempBuffer), XMLToken.Whitespace]
            default:
                stream.back()
                return [XMLToken.Id(tempBuffer)]
            }
        } while true
    }
    private func consumeString() -> [XMLToken] {
        var tempBuffer = ""
        repeat {
            guard let elem = stream.consumeNext() else { return [XMLToken.Name(tempBuffer)] }
            switch elem {
            case "\"":
                return [XMLToken.Name(tempBuffer), XMLToken.Quotation]
            default:
                tempBuffer.append(elem)
            }
        } while true
    }
    func nextToken()  -> [XMLToken]?  {
        repeat {
            guard let elem = stream.consumeNext() else { return nil }
            switch elem {
            case "<":
                if let char = stream.peek() where char == "/" {
                    stream.consumeNext()
                    return [XMLToken.CloseToken]
                }
                return [XMLToken.BeginToken]
            case "/": if let char = stream.peek() where char == ">" {
                    stream.consumeNext()
                }
            case "=": return [XMLToken.EqualSign]
            case " ":
                consumeWhiteSpaces()
                return [XMLToken.Whitespace]
            case ">": return [XMLToken.EndToken]
            case "\"": return [XMLToken.Quotation] + consumeString()
            case "a"..."z" :
                return consumeId(elem)
            default: break
                
            }
        } while true
    }
}
