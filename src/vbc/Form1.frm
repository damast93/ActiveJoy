VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3030
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   4560
   LinkTopic       =   "Form1"
   ScaleHeight     =   3030
   ScaleWidth      =   4560
   StartUpPosition =   3  'Windows-Standard
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    Dim instrs As Stack
    
    ' 1 2 + 3 *
    Set instrs = Stack(Number(1), Number(2), Word("+"), Number(3), Word("*"))
    
    ' 1 2 4 [+] swap dip *
    Set instrs = Stack(Number(1), Number(2), Number(4), Quote(Word("+")), Word("swap"), Word("dip"), Word("*"))
    
    Dim vm As New vm
    Set vm.Instructions = instrs
    Set vm.Stack = Nil
    
    vm.Eval
    
    'MsgBox vm.Stack.ToString

    ' Tokenizer Test
    Dim source As String
    source = "1 2 + 3 /* Arithmetics demo " & vbCrLf & " ... */ * [[dup]] " & """" & "Hallo, Welt" & """" & " swip print // Final comment "
    
    Dim tok As New Tokenizer
    tok.Init source
    
    tok.Tokenize
    
    tok.Show
End Sub
