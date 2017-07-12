//
//  Character+Sets.swift
//  SwiftXMLParser
//
//  Created by Kacper Harasim on 12/07/2017.
//  Copyright © 2017 Kacper Harasim. All rights reserved.
//

import Foundation

extension Character {
    //Checks if given character set contains character
    func isIn(set: CharacterSet) -> Bool {
        let unicodeScalars = String(self).unicodeScalars
        let scalar = unicodeScalars[unicodeScalars.startIndex]
        return (set as NSCharacterSet).longCharacterIsMember(scalar.value)
    }
}
