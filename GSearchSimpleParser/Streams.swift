//
//  Streams.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 14.12.2015.
//  Copyright © 2015 Kacper Harasim. All rights reserved.
//

import Foundation


protocol Stream {
    func consumeNext() -> Character?
    func peek() -> Character?
    func back()
    func isEmpty() -> Bool
}

/*
class FileStream: Stream {

}*/
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
        currIndx = currIndx.advancedBy(1)
        return toReturnCharacter
    }
    func peek() -> Character? {
        let nextIndx = currIndx
        return nextIndx < string.endIndex ? string[nextIndx] : nil
    }
    func back() {
        guard currIndx > string.startIndex else { return }
        currIndx = currIndx.advancedBy(-1)
    }
    func isEmpty() -> Bool {
        return currIndx == string.endIndex
    }
}
///FileStream : provides basic interface for reading characters sequentionally from file. Backed by NSFileHandle
/*
final class FileStream: Stream {
    
    var fileHandle: NSFileHandle
    init?(filePath: String) {
        guard let handle = NSFileHandle(forReadingAtPath: filePath) else { return nil }
        self.fileHandle = handle
    }
    func consumeNext() -> Character? {
        <#code#>
    }
} 
*/


