namespace ActiveJoy

type Atom = 
    | Word of string
    | Quotation of Atom list
    | Number of int
    | String of string
    | Boolean of bool

type Sentence = Atom list
type Stack = Atom list

type Definition = Defn of string * Sentence
type Program = Program of Definition list * Sentence

type IInterpreter = 

    // Homomorphic evaluation law
    // Consider the curried version
    //     eval : Sentence -> (Stack -> Stack)
    // Then we have
    //     eval (s @ t) = eval s >> eval t
    abstract member Eval : Sentence * Stack -> Stack

    abstract member AddDefinition : Definition -> unit

module Interpreter = 
    let RunProgram<'t when 't :> IInterpreter and 't : (new : unit -> 't)> (Program(defns, main)) = 
        let intp = new 't()
        defns |> List.iter (intp.AddDefinition)
        intp.Eval(main, [])