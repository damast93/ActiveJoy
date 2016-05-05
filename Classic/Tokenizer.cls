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
Private tokens() As token

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

Private Sub PushToken(ByRef token As token)
    If tokenCount >= UBound(tokens) Then
        ReDim Preserve tokens(2 * UBound(tokens))
    End If
    tokens(tokenCount) = token
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
    
    Call PushToken(token(Mid$(source, start, current - start), start, TWORD))
End Sub

Public Sub Show()
    Dim r As String
    r = r & "start = " & CStr(start) & vbCrLf
    r = r & "current = " & CStr(current) & vbCrLf
    r = r & "eof = " & CStr(eof) & vbCrLf
    r = r & "#tokens = " & CStr(tokenCount) & vbCrLf
    
    MsgBox r
End Sub

