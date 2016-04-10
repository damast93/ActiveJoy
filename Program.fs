open System
open FParsec
open ActiveJoy
open ActiveJoy.Parser

type MyInterpreter = CPSInterpreter

let rec repl = 
    let interpreter = new MyInterpreter () :> IInterpreter
    fun () ->
        printf "> "
        let input = System.Console.ReadLine().Trim()
        if input <> "" && input <> ":q" then
            match run (ws >>. program .>> eof) input with
                | Failure(msg, _, _) -> printfn "Syntax error %A" msg
                | Success(program, _, _)  -> 
                    try
                        let (Program(defns, main)) = program
                        defns |> List.iter (interpreter.AddDefinition)

                        if (List.length main) > 0 then do
                            let res = interpreter.Eval(main, [])
                            printfn "%A" (List.rev res)
                    with 
                      | exn -> printfn "Runtime error %s" (exn.Message)
            repl()

let runFile fn = 
    let source = IO.File.ReadAllText(fn)
    match run (ws >>. program .>> eof) source with
        | Failure(msg, _, _) -> printfn "Syntax error %A" msg
        | Success(program, _, _)  -> 
            let ret = Interpreter.RunProgram<MyInterpreter>(program) 
            ignore ret

printfn "CPS"
match System.Environment.GetCommandLineArgs() with
     | [|_; fn|] -> runFile(fn)
     | _ -> repl()