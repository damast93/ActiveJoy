Attribute VB_Name = "AtomHelper"
Option Explicit

Public Function Number(ByVal n As Long) As Number
    Dim w As New Number
    w.Init n
    Set Number = w
End Function

Public Function Chars(ByVal s As String) As Chars
    Dim w As New Chars
    w.Init s
    Set Chars = w
End Function

Public Function word(ByVal s As String) As word
    Dim w As New word
    w.Init s
    Set word = w
End Function

Public Function Bool(ByVal b As Boolean) As Bool
    Dim w As New Bool
    w.Init b
    Set Bool = w
End Function

Public Function Quote(ParamArray Data() As Variant) As Quotation
    Dim i As Long
    Dim s As Stack
    Set s = Nil
    
    For i = UBound(Data) To 0 Step -1
        Set s = Cons(Data(i), s)
    Next
    
    Dim q As New Quotation
    q.Init s
    Set Quote = q
End Function

