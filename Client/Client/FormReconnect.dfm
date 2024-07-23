object FReconnect: TFReconnect
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1055#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1089#1090#1086#1083#1072
  ClientHeight = 94
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object ButtonReconnect: TSpeedButton
    Left = 24
    Top = 22
    Width = 193
    Height = 49
    Caption = #1055#1086#1074#1090#1086#1088#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 20
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    OnClick = ButtonReconnectClick
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 216
    Top = 64
  end
end
