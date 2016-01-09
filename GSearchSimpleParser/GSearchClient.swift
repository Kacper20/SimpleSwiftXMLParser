//
//  GSearchClient.swift
//  GSearchSimpleParser
//
//  Created by Kacper Harasim on 09.01.2016.
//  Copyright © 2016 Kacper Harasim. All rights reserved.
//

import Foundation






class GSearchClient {
    
    
    
    
    class func queryRequest(queryString: String) -> String? {
        let apiK = "AIzaSyADUlqmX-3mDo2PdDdoZTll0fOvY8_ETyg"
        let c = "001663399765669867942:y9ew9z4ysby"

        let components = NSURLComponents(string: "https://www.googleapis.com/customsearch/v1")
        let apiKey = NSURLQueryItem(name: "key", value: apiK)
        let query = NSURLQueryItem(name: "q", value: queryString)
        let cx = NSURLQueryItem(name: "cx", value: c)
        let atom = NSURLQueryItem(name: "alt", value: "atom")
        components?.queryItems = [apiKey, query, cx, atom]
        let url = components!.URL!
        let data = try? NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: url), returningResponse: nil)
        if let data = data  {
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil

        
        
    }
    
}

