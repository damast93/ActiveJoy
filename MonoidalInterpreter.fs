namespace ActiveJoy

open System.Collections.Generic

type Instruction = 
    | Eval of Atom
    | IfThenElse of Sentence * Sentence * Stack
    
type MonoidalInterpreter() = 
    
    let instr = List.map Eval
    let definitions = new Dictionary<string, Instruction list -> Stack -> Instruction list * Stack>()

    let evalWord word insts stack = 
        match word with
        | Word(name) ->
            if not (definitions.ContainsKey(name))
                then failwith "Identifier not found"
                else 
                    let f = definitions.[name]
                    f insts stack
        | value -> insts, (value::stack)

    let rec eval instructions stack = 
        match instructions with
        | [] -> stack
        | Eval(w)::rest -> 
            let (inst2, stack2) = evalWord  w rest stack
            eval inst2 stack2
        | IfThenElse(tp, fp, t)::rest ->
            let (Boolean(c)::_) = stack
            let part = if c then tp else fp
            eval ((instr part) @ rest) t


    let builtins = [
        "+", fun insts (Number(i)::Number(j)::t) -> insts, Number(j+i)::t
        "-", fun insts (Number(i)::Number(j)::t) -> insts, Number(j-i)::t
        "*", fun insts (Number(i)::Number(j)::t) -> insts, Number(j*i)::t
        "/", fun insts (Number(i)::Number(j)::t) -> insts, Number(j/i)::t
        "%", fun insts (Number(i)::Number(j)::t) -> insts, Number(j%i)::t

        "=", fun insts (a::b::t) -> insts, Boolean(a = b)::t
        "!=", fun insts (a::b::t) -> insts, Boolean(a <> b)::t
        "<", fun insts (Number(a)::Number(b)::t) -> insts, Boolean(b < a)::t
        "<=", fun insts (Number(a)::Number(b)::t) -> insts, Boolean(b <= a)::t
        ">", fun insts (Number(a)::Number(b)::t) -> insts, Boolean(b > a)::t
        ">=", fun insts (Number(a)::Number(b)::t) -> insts, Boolean(b >= a)::t
        
        "true", fun insts t -> insts, Boolean(true)::t
        "false", fun insts t -> insts, Boolean(false)::t
        "and", fun insts (Boolean(a)::Boolean(b)::t) -> insts, Boolean(a && b)::t
        "or", fun insts (Boolean(a)::Boolean(b)::t) -> insts, Boolean(a || b)::t
        "not", fun insts (Boolean(a)::t) -> insts, Boolean(not a)::t

        "print", fun insts (String(s)::t) -> printf "%s" s; insts, t
        "printn", fun insts (String(s)::t) -> printfn "%s" s; insts, t
        "readln", fun insts t -> let s = System.Console.ReadLine() in insts, String(s)::t
        "int", fun insts (String(s)::t) -> insts, Number(int s)::t
        "str", fun insts (a::t) 
                 -> match a with
                      | String(s) -> insts, a::t
                      | Number(n) -> insts, String(sprintf "%i" n)::t
                      | a         -> insts, String(sprintf "%A" a)::t

                      
        "i", fun insts (Quotation(q)::t) -> (instr q) @ insts, t
        "dip", fun insts (a::Quotation(q)::t) -> (instr (q @ [a])) @ insts, t
        "dup", fun insts (a::t) -> insts, (a::a::t)
        "swap", fun insts (a::b::t) -> insts, (b::a::t)
        "pop", fun insts (a::t) -> insts, t
        "if", fun insts (Quotation(fp)::Quotation(tp)::Quotation(cond)::t) 
                -> (instr cond) @ [IfThenElse(tp,fp,t)], t
    ]

    do
        builtins |> List.iter (definitions.Add)

    interface IInterpreter with 
        member this.AddDefinition(Defn(name, body)) = 
            if definitions.ContainsKey(name)
                then failwith "Cannot overwrite existing definition"
                else definitions.Add(name, fun insts t -> (instr body) @ insts, t)

        member this.Eval(sentence, stack) = eval (instr sentence) stack