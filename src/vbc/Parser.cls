VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Parser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_Tokens As tokenizer

Private m_Stack As Stack

Private eof As Long
Private current As Long

Public Sub Init(ByVal tokenizer As tokenizer, ByVal start As Long, ByVal reof As Long)
    Set m_Tokens = tokenizer
    current = start
    eof = reof
    
    Set m_Stack = Nil
End Sub

Public Property Get Result() As Stack
    Set Result = m_Stack
End Property

Private Property Get CurrentToken() As Token
    CurrentToken = m_Tokens.GetToken(current)
End Property

Private Sub PushAtom(ByVal atom As atom)
    Set m_Stack = Concat(m_Stack, Cons(atom, Nil))
End Sub

Public Sub ParseQuotation()
    ' Find balanced closing ]
    ' We're starting at +1
    
    Dim i, balance As Long
    Dim hitEof As Boolean
    
    hitEof = True
    balance = 1
    i = current
    
    Do While i < eof
        If m_Tokens.GetToken(i).type = TLBRACE Then
            balance = balance + 1
        ElseIf m_Tokens.GetToken(i).type = TRBRACE Then
            balance = balance - 1
        End If
        
        i = i + 1
        
        If balance = 0 Then
            hitEof = False
            Exit Do
        End If
    Loop
    
    If hitEof Then
        Err.Raise vbObjectError + 4, Description:="Unexpected eof"
    End If
    
    ' Parse recursively
    Dim recParser As New parser
    recParser.Init m_Tokens, current, i - 1
    recParser.Parse
    
    Dim quot As New Quotation
    quot.Init recParser.Result
    PushAtom quot
    
    current = i
End Sub

Public Sub Parse()
    Do While current < eof
        If CurrentToken.type = TWORD Then
            PushAtom word(CurrentToken.content)
            current = current + 1
            
        ElseIf CurrentToken.type = TSTRING Then
            PushAtom Chars(CurrentToken.content)
            current = current + 1
            
        ElseIf CurrentToken.type = TNUMBER Then
            PushAtom Number(CInt(CurrentToken.content))
            current = current + 1
            
        ElseIf CurrentToken.type = TRBRACE Then
            Err.Raise vbObjectError + 4, Description:="Unexpected ]"
            
        ElseIf CurrentToken.type = TLBRACE Then
            current = current + 1
            ParseQuotation
        End If
    Loop
End Sub
