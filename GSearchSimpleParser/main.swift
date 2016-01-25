import Foundation

/* (string: "<note> <to>Tove</to> <body>Dont forget to do it!</body> </note>")) */

let args = dump(Process.arguments)
let query = args[1]
let maxItems = Int(args[2])
let outputFile = args[3]



//let str = String(data: data, encoding: NSUTF8StringEncoding)
let maxResults: Int = maxItems ?? 100
var currentAdresses: [String] = []
var startingIndx = 1

while currentAdresses.count < maxResults {

    let str = GSearchClient.queryRequest(query, index: startingIndx)
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
            if let (curr, next) = analyzer.getCurrentStartIndxAndNextStartIndx() {
                startingIndx = next
            }
            else {
                break
            }
            currentAdresses.appendContentsOf(analyzer.getAdresses())

        }
    }
    catch {
        print(error)
    }
}


let json = try! NSJSONSerialization.dataWithJSONObject(currentAdresses, options: .PrettyPrinted)
let string = String(data: json, encoding: NSUTF8StringEncoding)
json.writeToFile(outputFile, atomically: true)
