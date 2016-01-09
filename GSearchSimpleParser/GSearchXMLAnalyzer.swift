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
    }
    
    
    
    
    
    
    
    
    
    
    
    



