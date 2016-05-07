namespace ActiveJoy

open System.Collections.Generic

type CPSInterpreter() = 

    let definitions = new Dictionary<string, Stack -> (Stack -> Stack) -> Stack>()

    let rec evalCPS sentence stack k = 
        match sentence with
        | [] -> k stack
        | Word(name)::rest ->
            if not (definitions.ContainsKey(name))
                then failwith (sprintf "Identifier `%s` not found" name)
                else 
                    let f = definitions.[name]
                    f stack (fun stack2 -> evalCPS rest stack2 k)
        | v::rest -> evalCPS rest (v::stack) k

    let eval sentence stack = evalCPS sentence stack (fun t -> t)

    // Runtime

    let tostr = function
        | String(s) -> s
        | Number(n) -> sprintf "%i" n
        | a -> sprintf "%A" a

    let builtins = [
        // Arithmetics
        "+", fun (Number(i)::Number(j)::t) k -> k (Number(j+i)::t)
        "-", fun (Number(i)::Number(j)::t) k -> k (Number(j-i)::t)
        "*", fun (Number(i)::Number(j)::t) k -> k (Number(j*i)::t)
        "/", fun (Number(i)::Number(j)::t) k -> k (Number(j/i)::t)
        "%", fun (Number(i)::Number(j)::t) k -> k (Number(j%i)::t)

        // Relations
        "=", fun (a::b::t) k -> k (Boolean(a = b)::t) 
        "!=", fun (a::b::t) k -> k (Boolean(a <> b)::t)
        "<", fun (Number(a)::Number(b)::t) k -> k (Boolean(b < a)::t)
        "<=", fun (Number(a)::Number(b)::t) k -> k (Boolean(b <= a)::t)
        ">", fun (Number(a)::Number(b)::t) k -> k (Boolean(b > a)::t)
        ">=", fun (Number(a)::Number(b)::t) k -> k (Boolean(b >= a)::t)

        // Boolean
        "true", fun t k -> k (Boolean(true)::t)
        "false", fun t k -> k (Boolean(false)::t)
        "and", fun (Boolean(a)::Boolean(b)::t) k -> k (Boolean(a && b)::t)
        "or", fun (Boolean(a)::Boolean(b)::t) k -> k (Boolean(a || b)::t)
        "not", fun (Boolean(a)::t) k -> k (Boolean(not a)::t)

        // I/O
        "print", fun (a::t) k -> printf "%s" (tostr a); k t
        "printn", fun (a::t) k -> printfn "%s" (tostr a); k t
        "readln", fun t k -> let s = System.Console.ReadLine() in k (String(s)::t)
        "int", fun (String(s)::t) k -> k (Number(int s)::t)
        "str", fun (a::t) k -> k (String(tostr a)::t)
        "rand", (let rnd = new System.Random() 
                 in fun (Number(b)::Number(a)::t) k -> k (Number(rnd.Next(a, b))::t))
        
        // Quotation/list manipulation 
        "length", fun (Quotation(l)::t) k -> k (Number(List.length l)::t)
        "head", fun (Quotation(x::xs)::t) k -> k (x::t)
        "cons", fun (Quotation(l)::a::t) k -> k (Quotation(a::l)::t)
        "quote", fun (a::t) k -> k (Quotation([a])::t)
        "concat", fun (Quotation(a)::Quotation(b)::t) k -> k (Quotation(b @ a)::t)

        "fold", fun (a::Quotation(op)::Quotation(list)::t) k 
                  -> let rec fold list acc cont = 
                       match list with
                       | [] -> cont (acc::t)
                       | x::xs -> evalCPS op (x::acc::t) (fun (res::_) -> fold xs res cont)
                     fold list a k

        // Combinators
        "i", fun (Quotation(q)::t) k -> evalCPS q t k
        "dip", fun (a::Quotation(q)::t) k -> evalCPS q t (fun t2 -> k (a::t2))
        "swip", fun (Quotation(q)::a::t) k -> evalCPS q t (fun t2 -> k (a::t2))
        "dup", fun (a::t) k -> k (a::a::t)
        "swap", fun (a::b::t) k -> k (b::a::t)
        "pop", fun (a::t) k -> k t
        
        "iif", fun (fp::tp::Boolean(c)::t) k -> k ((if c then tp else fp)::t)
        "if", fun (Quotation(fp)::Quotation(tp)::Quotation(cond)::t) k 
                -> evalCPS cond t (fun (Boolean(c)::_) ->
                     let part = if c then tp else fp
                     evalCPS part t k)
    ]

    do
        builtins |> List.iter (definitions.Add)

    interface IInterpreter with
        member this.AddDefinition(Defn(name, body)) = 
            if definitions.ContainsKey(name)
                then failwith "Cannot overwrite existing definition"
                else definitions.Add(name, fun t k -> evalCPS body t k)

        member this.Eval(sentence, stack) = eval sentence stack