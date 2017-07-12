import Foundation

let args = CommandLine.arguments
guard args.count == 4 else {
    print("There should be 3 arguments passed:")
    print("script_name [google_query] [max_results] [result_file]")
    exit(-1)
}
let query = args[1]
let maxItems = Int(args[2])
let outputFile = args[3]

//let str = String(data: data, encoding: NSUTF8StringEncoding)
let maxResults: Int = maxItems ?? 100
var currentAdresses: [String] = []
var startingIndx = 1
while currentAdresses.count < maxResults {
    let str = try GSearchClient().queryRequest(queryString: query, index: startingIndx)
    let generator = TokenScanner(stream: MemoryStream(string: str))
    do{
        let anotherGenerator = TokenScanner(stream: MemoryStream(string: str))
        do {
            var tokens: [XMLToken] = []
            while let tokensNew =  anotherGenerator.nextToken() {
                tokens.append(contentsOf: tokensNew)
            }
        }
        let parser = Parser(tokenScanner: generator)

        if let xmlDocument = parser.parseDocument() {
            let analyzer = GSearchXMLAnalyzer(document: xmlDocument)
            if let (_, next) = analyzer.getCurrentStartIndxAndNextStartIndx() {
                startingIndx = next
            }
            else {
                break
            }
            currentAdresses.append(contentsOf: analyzer.getAdresses())
        }
    }
}

guard
    let json = try? JSONSerialization.data(withJSONObject: currentAdresses, options: .prettyPrinted),
    let url = URL(string: outputFile) else {
        print("Wrong output file given")
        exit(-1)
}
let string = String(data: json, encoding: .utf8)
try? json.write(to: url)
