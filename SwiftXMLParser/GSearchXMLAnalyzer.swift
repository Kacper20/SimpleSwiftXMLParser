//
//  GSearchDocumentAnalyzer.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 09.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation

public class GSearchXMLAnalyzer {
    
    let document: XMLDocument
    
    init(document: XMLDocument) {
        self.document = document
    }
    
    func getAdresses() -> [String] {
        return document.nodes.flatMap {
            return self.getFromNode($0)
        }
        
    }
    
    func getFromNode(_ node: XMLNode) -> [String] {
        if let _ = node.attributes.first(where: { attribute -> Bool in attribute.key == "gd:kind" && attribute.value == "customsearch#result"}) {
            switch node.content {
            case let .childNodes(nodes):
                return nodes.filter( {$0.name == "link"}).map {
                    if let hrefAttrIndx = $0.attributes.index(where: {attribute -> Bool in attribute.key == "href"}) {
                        return $0.attributes[hrefAttrIndx].value
                    }
                    return ""
                }
            default: return []
            }
        } else {
            switch node.content {
            case let .childNodes(nodes):
                return nodes.reduce([]) { result, current in
                    return result + getFromNode(current)
                    
                }
            default: return []
            }
        }
    }
    
    func getCurrentStartIndxAndNextStartIndx() -> (Int, Int)? {
        if let feed = document.nodes.first, feed.name == "feed",
            case let XMLNodeContent.childNodes(nodes: nodes) = feed.content {

            guard let reqnode = nodes.first(where: { $0.attributes.contains(where: { (attr) -> Bool in
                attr.key == "role" && attr.value == "request"
            })  }),
                let nextPageNode = nodes.first (where: { $0.attributes.contains(where: { (attr) -> Bool in
            attr.key == "role" && attr.value == "cse:nextPage"
            })  })  else {
                return nil
            }
            let currentStartIndx = reqnode.attributes.first (where: {$0.key == "startIndex"})!.value
            let nextStartIndx = nextPageNode.attributes.first(where: {$0.key == "startIndex"})!.value
            return (Int(currentStartIndx)!, Int(nextStartIndx)!)
        }
        return nil
    }
}
