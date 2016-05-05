Attribute VB_Name = "StackHelper"
Option Explicit

Public Function Nil() As Stack
    Set Nil = New Stack
    Nil.InitEmpty
End Function

Public Function Cons(ByVal a As Atom, ByVal s As Stack)
    Set Cons = New Stack
    Cons.InitCons a, s
End Function

Public Function Concat(ByVal a As Stack, ByVal b As Stack) As Stack
    Dim r As Stack
    Set r = Nil
    
    ' Reverse a first
    Dim t As Stack
    Set t = a
    Do While t.Size > 0
        Set r = Cons(t.Head, r)
        Set t = t.Tail
    Loop
    
    'Prepend a to b
    Do While r.Size > 0
        Set b = Cons(r.Head, b)
        Set r = r.Tail
    Loop
    
    Set Concat = b
End Function

Public Function Stack(ParamArray Data() As Variant) As Stack
    Dim i As Long
    Dim s As Stack
    Set s = Nil
    
    For i = UBound(Data) To 0 Step -1
        Set s = Cons(Data(i), s)
    Next
    
    Set Stack = s
End Function


