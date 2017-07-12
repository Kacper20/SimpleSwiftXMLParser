//
//  ClosureSynchronizer.swift
//  SwiftXMLParser
//
//  Created by Kacper Harasim on 12/07/2017.
//  Copyright © 2017 Kacper Harasim. All rights reserved.
//

import Foundation

import Foundation

func synchronize<A>(closure: @escaping () -> (@escaping (A) -> Void) -> Void) -> A {
    let semaphore = DispatchSemaphore(value: 0)
    var value: A!
    closure()({ val in
        value = val
        semaphore.signal()
    })
    semaphore.wait()

    return value
}
