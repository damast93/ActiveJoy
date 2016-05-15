VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Tokenizer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private source As String
Private eof As Long

Private tokenCount As Long
Private tokens() As Token

Private start As Long
Private current As Long

Private Sub Class_Initialize()
    tokenCount = 0
    ReDim tokens(100)
End Sub

Public Sub Init(ByRef psource As String)
    source = psource
    eof = Len(psource) + 1
    start = 1
    current = 1
End Sub

Private Sub PushToken(ByRef Token As Token)
    If tokenCount >= UBound(tokens) Then
        ReDim Preserve tokens(2 * UBound(tokens))
    End If
    tokens(tokenCount) = Token
    tokenCount = tokenCount + 1
End Sub

Private Function IsWhitespace(ByVal s As String) As Boolean
    Select Case Asc(s)
        Case 8, 9, 10, 13, 32, 160
            IsWhitespace = True
        Case Else
            IsWhitespace = False
    End Select
End Function

Private Function IsNumber(ByVal s As String) As Boolean
    Select Case s
        Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
            IsNumber = True
        Case Else
            IsNumber = False
    End Select
End Function

Private Function IsWordChar(ByVal s As String) As Boolean
    If IsWhitespace(s) Then
        IsWordChar = False
    Else
        Select Case s
            Case "[", "]", "{", "}", """"
                IsWordChar = False
            Case Else
                IsWordChar = True
        End Select
    End If
End Function

Private Function Peek(ByVal s As String) As Boolean
    If current + Len(s) > eof Then
        Peek = False
        Exit Function
    End If
    
    Peek = (Mid$(source, current, Len(s)) = s)
End Function

Private Property Get CurrentChar() As String
    CurrentChar = Mid$(source, current, 1)
End Property

Public Sub Word()
    start = current
    
    Do While current < eof
        Dim p As String
        p = Mid$(source, current, 1)
        
        If IsWordChar(p) Then
            current = current + 1
        Else
            Exit Do
        End If
    Loop
    
    PushToken Token(Mid$(source, start, current - start), start, TWORD)
End Sub

Public Sub SkipWhitespace()
    Do While current < eof
        If IsWhitespace(CurrentChar) Then
            current = current + 1
        ElseIf Peek("/*") Then
            current = current + 2
            SkipBlockCommentInner
        ElseIf Peek("//") Then
            current = current + 2
            SkipLineCommentInner
        Else
            Exit Do
        End If
    Loop
End Sub

Public Sub SkipBlockCommentInner()
    Dim hitEof As Boolean
    hitEof = True
    
    Do While current < eof
        If Not Peek("*/") Then
            current = current + 1
        Else
            current = current + 2
            hitEof = False
            Exit Do
        End If
    Loop
    
    If hitEof Then
        Err.Raise vbObjectError + 3, Description:="Unexpected eof"
    End If
End Sub

Public Sub SkipLineCommentInner()
    Do While current < eof
        If Peek(vbCrLf) Then
            current = current + 2
            Exit Do
        ElseIf Peek(vbCr) Or Peek(vbLf) Then
            current = current + 1
            Exit Do
        Else
            current = current + 1
        End If
    Loop
End Sub

Public Sub StringInner()
    Dim hitEof As Boolean
    hitEof = True
    
    Do While current < eof
        If Peek("""") Then
            current = current + 1
            hitEof = False
            Exit Do
        Else
            current = current + 1
        End If
    Loop
        If hitEof Then
            Err.Raise vbObjectError + 3, Description:="Unexpected eof"
        End If
        
        PushToken Token(Mid$(source, start, current - start - 1), start, TSTRING)
End Sub

Public Sub NumberLiteral()
    start = current
    Do While current < eof
        If IsNumber(CurrentChar) Then
            current = current + 1
        Else
            Exit Do
        End If
    Loop
    PushToken Token(Mid$(source, start, current - start), start, TNUMBER)
End Sub

Public Sub Tokenize()
    Do While current < eof
        start = current
        
        SkipWhitespace
        If current = eof Then Exit Do
        
        If Peek("[") Then
            PushToken Token("[", current, TLBRACE)
            current = current + 1
        ElseIf Peek("]") Then
            PushToken Token("]", current, TRBRACE)
            current = current + 1
        ElseIf Peek("""") Then
            current = current + 1
            start = current
            StringInner
        ElseIf IsNumber(CurrentChar) Then
            NumberLiteral
        Else
            Word
        End If
    Loop
End Sub

Public Sub Show()
    Dim r As String
    
    r = source
    r = r & vbCrLf & "----------------------" & vbCrLf
    
    r = r & "start = " & CStr(start) & vbCrLf
    r = r & "current = " & CStr(current) & vbCrLf
    r = r & "eof = " & CStr(eof) & vbCrLf
    r = r & "#tokens = " & CStr(tokenCount) & vbCrLf
    r = r & "----------------------" & vbCrLf
    
    Dim i As Long
    Dim descs As Variant
    descs = Array("Word", "String", "Number", "LBrace", "RBrace")
    
    For i = 0 To tokenCount - 1
        r = r & "[" & descs(tokens(i).type) & "] : " & tokens(i).content & vbCrLf
    Next i
    
    MsgBox r
End Sub

