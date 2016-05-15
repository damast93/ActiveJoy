VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fest Einfach
   Caption         =   "ActiveJoy"
   ClientHeight    =   10230
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   11580
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   10230
   ScaleWidth      =   11580
   StartUpPosition =   3  'Windows-Standard
   Begin VB.CommandButton Command2 
      Caption         =   "Run"
      Height          =   375
      Left            =   240
      TabIndex        =   5
      Top             =   840
      Width           =   3255
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Consolas"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Text            =   $"Form1.frx":0000
      Top             =   240
      Width           =   11415
   End
   Begin VB.Label lblResult 
      Height          =   8295
      Left            =   7680
      TabIndex        =   7
      Top             =   1800
      Width           =   3735
   End
   Begin VB.Label Label3 
      Caption         =   "Result"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7560
      TabIndex        =   6
      Top             =   1320
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Instructions"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3840
      TabIndex        =   4
      Top             =   1320
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Tokens"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   240
      TabIndex        =   3
      Top             =   1320
      Width           =   1455
   End
   Begin VB.Label lblAtoms 
      Height          =   8295
      Left            =   3960
      TabIndex        =   2
      Top             =   1800
      Width           =   3735
   End
   Begin VB.Label lblTokens 
      Height          =   8055
      Left            =   240
      TabIndex        =   1
      Top             =   1800
      Width           =   3615
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private tok As tokenizer
Private parser As parser

Private Sub Parse()
    Set tok = New tokenizer
    tok.Init Text1.Text
    
    tok.Tokenize
    
    lblTokens.Caption = tok.GetDesc
    
    Set parser = New parser
    parser.Init tok, 0, tok.NumTokens
    
    parser.Parse
    
    lblAtoms.Caption = parser.Result.ToString
End Sub

Private Sub Run()
    Parse
    
    Dim vm As New vm
    Set vm.Instructions = parser.Result
    Set vm.Stack = Nil
    
    vm.Eval
    
    lblResult.Caption = vm.Stack.ToString
End Sub

Private Sub Command2_Click()
    Run
End Sub

Private Sub Text1_KeyPress(KeyAscii As Integer)
    ' Check for return
    If KeyAscii = 13 Then
        KeyAscii = 0
        Run
    End If
End Sub
