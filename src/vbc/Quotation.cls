VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Quotation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements atom

Private m_Data As Stack

Public Property Get Data() As Stack
    Set Data = m_Data
End Property

Public Sub Init(ByVal pdata As Stack)
    Set m_Data = pdata
End Sub

Private Function Atom_ToString() As String
    Dim res As String
    Dim s As Stack
    
    res = "["
    
    Set s = m_Data
    Do While s.Size > 0
        res = res & s.Head.ToString
        If s.Size > 1 Then res = res & " "
        Set s = s.Tail
    Loop
    
    res = res & "]"
    Atom_ToString = res
End Function



