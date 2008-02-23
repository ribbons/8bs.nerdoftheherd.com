VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   6960
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   9270
   LinkTopic       =   "Form1"
   ScaleHeight     =   6960
   ScaleWidth      =   9270
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   510
      Left            =   5310
      TabIndex        =   2
      Top             =   5310
      Width           =   1005
   End
   Begin VB.PictureBox Picture2 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000007&
      BorderStyle     =   0  'None
      Height          =   2220
      Left            =   405
      ScaleHeight     =   2220
      ScaleWidth      =   2805
      TabIndex        =   1
      Top             =   4275
      Width           =   2805
   End
   Begin VB.PictureBox Picture1 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000007&
      Height          =   3705
      Left            =   450
      ScaleHeight     =   3645
      ScaleWidth      =   7695
      TabIndex        =   0
      Top             =   360
      Width           =   7755
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long

Private Sub SaveTiles()
    Picture1.Picture = LoadPicture(App.Path + "\saved.bmp")
    
    DoEvents

    Dim lngDown As Long
    Dim lngAcross As Long
    
    For lngDown = 0 To 15
        For lngAcross = 0 To 15
            Call SaveTile(lngDown, lngAcross)
        Next lngAcross
    Next lngDown
End Sub

Private Sub SaveTile(lngDown As Long, lngAcross As Long)
    DoEvents

    Const lngWidth As Long = 58
    Const lngHeight As Long = 96
    
    Picture2.Width = lngWidth * Screen.TwipsPerPixelY
    Picture2.Height = lngHeight * Screen.TwipsPerPixelX
    
    Call BitBlt(Picture2.hDC, 0, 0, lngWidth, lngHeight, Picture1.hDC, lngAcross * lngWidth, lngDown * lngHeight, vbSrcCopy)
    Picture2.Refresh
    
    Call SavePicture(Picture2.Image, App.Path + "\font\" + Format((lngDown * 16) + lngAcross) + ".bmp")
End Sub

Private Sub Command1_Click()
    Call SaveTiles
End Sub

