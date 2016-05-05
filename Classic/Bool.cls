VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Bool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements Atom

Private m_Value As Boolean

Public Property Get Value() As Boolean
    Value = m_Value
End Property

Public Sub Init(ByVal val As Boolean)
    m_Value = val
End Sub

Private Function Atom_ToString() As String
    Atom_ToString = IIf(m_Value, "true", "false")
End Function

