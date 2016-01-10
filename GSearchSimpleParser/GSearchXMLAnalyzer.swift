//
//  GSearchDocumentAnalyzer.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 09.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation

extension Array {
    func element(predicate: Element -> Bool) -> Element?{
        for elem in self where predicate(elem) { return elem }
        return nil
    }
}
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
    
    func getFromNode(node: XMLNode) -> [String] {
        if let elem  = node.attributes.filter ({ attribute -> Bool in attribute.key == "gd:kind" && attribute.value == "customsearch#result"}).first {
            switch node.content {
            case let .ChildNodes(nodes):
                return nodes.filter( {$0.name == "link"}).map {
                    if let hrefAttrIndx = $0.attributes.indexOf({attribute -> Bool in attribute.key == "href"}) {
                        return $0.attributes[hrefAttrIndx].value
                    }
                    return ""
                }
            default: return []
            }
        }
        else {
            switch node.content {
            case let .ChildNodes(nodes):
                return nodes.reduce([]) { result, current in
                    return result + getFromNode(current)
                    
                }
            default: return []
            }
        }

            
        }
    
    func getCurrentStartIndxAndNextStartIndx() -> (Int, Int)? {
        if let feed = document.nodes.first where feed.name == "feed", case let XMLNodeContent.ChildNodes(nodes: nodes) = feed.content {
            
            
            guard let reqnode = nodes.element ({ $0.attributes.contains({ (attr) -> Bool in
                attr.key == "role" && attr.value == "request"
            })  }),
            let nextPageNode = nodes.element ({ $0.attributes.contains({ (attr) -> Bool in
            attr.key == "role" && attr.value == "cse:nextPage"
            })  })  else { return nil }
            
            
            let currentStartIndx = reqnode.attributes.element ({$0.key == "startIndex"  })!.value
            let nextStartIndx = nextPageNode.attributes.element({$0.key == "startIndex"})!.value
            return (Int(currentStartIndx)!, Int(nextStartIndx)!)
            
        
            
        }
        return nil
    
    }
    
    
    
    
    }
    
    
    
    
    
    
    
    
    
    
    
    



