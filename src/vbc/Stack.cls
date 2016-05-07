VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Stack"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private m_Size As Long
Private m_Head As Atom
Private m_Tail As Stack

Public Property Get IsEmpty() As Boolean
    IsEmpty = (m_Size = 0)
End Property

Public Property Get Size() As Integer
    Size = m_Size
End Property

Public Property Get Head() As Atom
    If m_Size > 0 Then
        Set Head = m_Head
    Else
        Call Err.Raise(vbObjectError + 1, Description:="Stack empty")
    End If
End Property

Public Property Get Tail() As Stack
    If m_Size > 0 Then
        Set Tail = m_Tail
    Else
        Call Err.Raise(vbObjectError + 1, Description:="Stack empty")
    End If
End Property

Public Sub InitEmpty()
    m_Size = 0
End Sub

Public Sub InitCons(ByVal phead As Atom, ByVal ptail As Stack)
    m_Size = ptail.Size + 1
    Set m_Head = phead
    Set m_Tail = ptail
End Sub

Public Function ToString() As String
    Dim res As String, s As Stack
    Set s = Me
    
    Do While s.Size > 0
        res = res & s.Head.ToString
        If s.Size > 1 Then res = res & vbCrLf
        Set s = s.Tail
    Loop
    
    ToString = res
End Function
