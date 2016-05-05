Attribute VB_Name = "TokenizerHelper"
Option Explicit

Public Enum TokenType
    TWORD
    TSTRING
    TNUMBER
    TLBRACE
    TRBRACE
End Enum

Public Type Token
    pos As Integer
    content As String
    type As TokenType
End Type

Public Function Token(ByVal content As String, ByVal pos As Long, ByVal tp As TokenType) As Token
    Token.content = content
    Token.pos = pos
    Token.type = tp
End Function
