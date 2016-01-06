import Foundation

/* (string: "<note> <to>Tove</to> <body>Dont forget to do it!</body> </note>")) */

let filePath = NSBundle.mainBundle().pathForResource("file", ofType: "xml")
let data = NSData(contentsOfFile: filePath!)!
let str = String(data: data, encoding: NSUTF8StringEncoding)
let generator = TokenScanner(stream: MemoryStream(string: str!))
do{
    let anotherGenerator = TokenScanner(stream: MemoryStream(string: str!))
    do {
        var tokens: [XMLToken] = []
        while let tokensNew =  anotherGenerator.nextToken() {
            tokens.appendContentsOf(tokensNew)
        }
        print(tokens)
    }
    
    
    let parser = Parser(tokenScanner: generator)
    let node = try parser.parseNode()
    print(node)
    
}
catch {
    print(error)
}