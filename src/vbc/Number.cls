VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Number"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements Atom

Private m_Value As Long

Public Property Get Value() As Long
    Value = m_Value
End Property

Public Sub Init(ByVal val As Long)
    m_Value = val
End Sub

Private Function Atom_ToString() As String
    Atom_ToString = CStr(m_Value)
End Function


