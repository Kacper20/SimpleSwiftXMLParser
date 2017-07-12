//
//  Streams.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation

protocol Stream {
    @discardableResult func consumeNext() -> Character?
    func peek() -> Character?
    func back()
    func isEmpty() -> Bool
}

final class MemoryStream: Stream {
    private var string: String
    private var currIndx: String.Index

    init(string: String) {
        self.string = string
        self.currIndx = self.string.startIndex
    }

    func consumeNext() -> Character? {
        guard currIndx < string.endIndex else { return nil }
        let toReturnCharacter = self.string[currIndx]
        currIndx = string.index(after: currIndx)
        return toReturnCharacter
    }

    func peek() -> Character? {
        let nextIndx = currIndx
        return nextIndx < string.endIndex ? string[nextIndx] : nil
    }

    func back() {
        guard currIndx > string.startIndex else { return }
        currIndx = string.index(before: currIndx)
    }

    func isEmpty() -> Bool {
        return currIndx == string.endIndex
    }
}
