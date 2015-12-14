import Foundation


let generator = TokenScanner(stream: MemoryStream(string: "<name   attr=\"val\""))
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