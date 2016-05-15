VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "VM"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Instructions As Stack
Public Stack As Stack

Public Sub Eval()
    Do While Instructions.Size > 0
        Dim p As atom: Set p = Instructions.Head
        
        If TypeOf p Is word Then
            Set Instructions = Instructions.Tail
            Dim word As word
            Set word = p
            ProcessWord word.Value
            
        ElseIf TypeOf p Is Instruction Then
            ' proc instr
        Else
            Set Instructions = Instructions.Tail
            Set Stack = Cons(p, Stack)
        End If
    Loop
End Sub

Private Sub ProcessWord(ByVal s As String)
    Dim a As Number, b As Number
    Dim x As atom
    Dim q As Quotation
    
    Dim i As Long

    Select Case s
        Case "hi"
            MsgBox "Hi from Joy"
        
        Case "+"
            Set a = Stack.Head
            Set b = Stack.Tail.Head
            Set Stack = Cons(Number(b.Value + a.Value), Stack.Tail.Tail)
        Case "-"
            Set a = Stack.Head
            Set b = Stack.Tail.Head
            Set Stack = Cons(Number(b.Value - a.Value), Stack.Tail.Tail)
        Case "*"
            Set a = Stack.Head
            Set b = Stack.Tail.Head
            Set Stack = Cons(Number(b.Value * a.Value), Stack.Tail.Tail)
        Case "/"
            Set a = Stack.Head
            Set b = Stack.Tail.Head
            Set Stack = Cons(Number(b.Value \ a.Value), Stack.Tail.Tail)
            
        Case "i"
            Set q = Stack.Head
            Set Instructions = Concat(q.Data, Instructions)
            Set Stack = Stack.Tail
        
        Case "dip"
            Set x = Stack.Head
            Set q = Stack.Tail.Head
            Set Stack = Stack.Tail.Tail
            Set Instructions = Concat(q.Data, Cons(x, Instructions))
        
        Case "dup"
            Set Stack = Cons(Stack.Head, Stack)
            
        Case "swap"
            Set Stack = Cons(Stack.Tail.Head, Cons(Stack.Head, Stack.Tail.Tail))
        
        
                        
        Case Else
            Err.Raise vbObjectError + 2, Description:="Word `" & s & "` not known"
    End Select
End Sub
