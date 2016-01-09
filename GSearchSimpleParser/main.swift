import Foundation

/* (string: "<note> <to>Tove</to> <body>Dont forget to do it!</body> </note>")) */

let filePath = NSBundle.mainBundle().pathForResource("file", ofType: "xml")
let data = NSData(contentsOfFile: filePath!)!
//let str = String(data: data, encoding: NSUTF8StringEncoding)


let str = GSearchClient.queryRequest("Stany zjednoczone")
let generator = TokenScanner(stream: MemoryStream(string: str!))
do{
    let anotherGenerator = TokenScanner(stream: MemoryStream(string: str!))
    do {
        var tokens: [XMLToken] = []
        while let tokensNew =  anotherGenerator.nextToken() {
            tokens.appendContentsOf(tokensNew)
        }
//        print(tokens)
    }
    
    
    let parser = Parser(tokenScanner: generator)
    
    if let xmlDocument = try parser.parseDocument() {
//        print(xmlDocument)
        let analyzer = GSearchXMLAnalyzer(document: xmlDocument)
        print("Adresses: \(analyzer.getAdresses())")
    }

    
    
}
catch {
    print(error)
}