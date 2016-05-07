namespace ActiveJoy

module Parser = 
    open FParsec

    // Whitespace & comment management, thanks to http://stackoverflow.com/questions/8405032
    let whitespaceChars = [' '; '\t'; '\n'; '\r']
    let spaceStr = anyOf whitespaceChars |>> string 

    let lineComment = pstring "//" >>. restOfLine true
    let multiLineComment = 
        (between 
            (pstring "/*")
            (pstring "*/")
            (charsTillString "*/" false System.Int32.MaxValue))

    let whitespace = lineComment <|> multiLineComment <|> spaceStr
    let ws = skipMany whitespace
    let strws st = pstring st .>> ws

    let parsec = new ParserCombinator()

    // The grammar
    let identifier = 
        let firstDigit = isNoneOf "(){}[]:;,$\"0123456789 \t\r\n"
        let successiveDigit = isNoneOf ".\()[]$,;{}\" \t\r\n"
        attempt (many1Satisfy2L firstDigit successiveDigit "identifier" .>> ws)
    
    let ident = identifier |>> Word
    let stringLiteral = (pstring "\"") >>. (charsTillString "\"" true System.Int32.MaxValue) .>> ws |>> String
    let number = 
        numberLiteral (NumberLiteralOptions.AllowMinusSign) "integer" .>> ws
        |>> fun res -> Number(int res.String)

    let word, wordref = createParserForwardedToRef<Atom, unit>()

    let sentence = many word
    let quote = between (strws "[") (strws "]") sentence |>> Quotation

    wordref := number <|> stringLiteral <|> ident <|> quote

    let definition = pipe2 (strws "define" >>. identifier) (between (strws "{") (strws "}") sentence) (fun name body -> Defn(name, body))
    let program = pipe2 (many definition) sentence (fun defs body -> Program(defs, body))