import Foundation

/* (string: "<note> <to>Tove</to> <body>Dont forget to do it!</body> </note>")) */

let filePath = NSBundle.mainBundle().pathForResource("file", ofType: "xml")
let data = NSData(contentsOfFile: filePath!)!
let str = String(data: data, encoding: NSUTF8StringEncoding)
let generator = TokenScanner(stream: MemoryStream(string: str!))
do{
    var tokens = [XMLToken]()
    while let nextToken = try generator.nextToken() {
        tokens += nextToken
    }
    print(tokens)
}
catch {
    print(error)
}