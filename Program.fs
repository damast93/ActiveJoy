open System
open FParsec
open ActiveJoy
open ActiveJoy.Parser

type MyInterpreter = CPSInterpreter

let rec repl (intp : IInterpreter) = 
        printf "> "
        let input = System.Console.ReadLine().Trim()
        if input <> "" && input <> ":q" then
            match run (ws >>. program .>> eof) input with
                | Failure(msg, _, _) -> printfn "Syntax error: %A" msg
                | Success(program, _, _)  -> 
                    try
                        let (Program(defns, main)) = program
                        defns |> List.iter (intp.AddDefinition)

                        if (List.length main) > 0 then do
                            let res = intp.Eval(main, [])
                            printfn "%A" (List.rev res)
                    with 
                      | exn -> printfn "Runtime error: %s" (exn.Message)
            repl intp 

let runFile path = 
    let source = IO.File.ReadAllText(path)
    match run (ws >>. program .>> eof) source with
        | Failure(msg, _, _) -> printfn "Syntax error: %A" msg
        | Success(program, _, _)  -> Interpreter.RunProgram<MyInterpreter>(program) |> ignore

let loadFileAndRepl path = 
    let source = IO.File.ReadAllText(path)
    match run (ws >>. program .>> eof) source with
        | Failure(msg, _, _) -> printfn "Syntax error %A" msg
        | Success(program, _, _)  -> 
            let (Program(defns, main)) = program

            let intp = new MyInterpreter() :> IInterpreter
            defns |> List.iter (intp.AddDefinition)

            let fn = IO.Path.GetFileName(path)
            printfn "%s -- %i definitions loaded" fn (defns |> List.length)

            if (List.length main) > 0 then do 
                try
                    let res = intp.Eval(main, [])
                    printfn "%A" (List.rev res)
                with 
                    | exn -> printfn "Runtime error: %s" (exn.Message)

            repl(intp)

match System.Environment.GetCommandLineArgs() with
    | [|_; path|] -> loadFileAndRepl(path)
    | [|_; "-r"; path|] -> runFile(path)
    | _ -> repl(new MyInterpreter())