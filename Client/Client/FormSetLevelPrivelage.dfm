object FormPrivilage: TFormPrivilage
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1055#1088#1080#1074#1080#1083#1077#1075#1080#1080' '#1079#1072#1087#1091#1089#1082#1072' '#1087#1088#1086#1094#1077#1089#1089#1072
  ClientHeight = 145
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object PanelButton: TPanel
    Left = 0
    Top = 111
    Width = 220
    Height = 34
    Align = alBottom
    ParentBackground = False
    TabOrder = 0
    object ButtonCancel: TSpeedButton
      Left = 1
      Top = 1
      Width = 32
      Height = 32
      Hint = #1047#1072#1082#1088#1099#1090#1100' '#1086#1082#1085#1086' '#1085#1072#1089#1090#1088#1086#1077#1082' '#1087#1088#1080#1074#1080#1083#1077#1075#1080#1081
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      ImageIndex = 3
      ImageName = 'Exit'
      Images = Form_set.ImageButList
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBackground
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Layout = blGlyphTop
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = ButtonCancelClick
    end
    object ButtonSave: TSpeedButton
      Left = 187
      Top = 1
      Width = 32
      Height = 32
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1091#1088#1086#1074#1085#1080' '#1087#1088#1080#1074#1080#1083#1077#1075#1080#1081
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      ImageIndex = 8
      ImageName = 'save'
      Images = Form_set.ImageButList
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBackground
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Layout = blGlyphTop
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = ButtonSaveClick
      ExplicitLeft = 193
      ExplicitTop = 4
      ExplicitHeight = 25
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 220
    Height = 111
    Align = alClient
    TabOrder = 1
    object LAutoRun: TLabel
      Left = 39
      Top = 2
      Width = 142
      Height = 15
      Caption = #1040#1074#1090#1086#1079#1072#1087#1091#1089#1082' '#1074' RDP '#1089#1077#1072#1085#1089#1072#1093
    end
    object LManualRun: TLabel
      Left = 27
      Top = 50
      Width = 162
      Height = 15
      Caption = #1055#1088#1080#1074#1080#1083#1077#1075#1080#1080' '#1088#1091#1095#1085#1086#1075#1086' '#1079#1072#1087#1091#1089#1082#1072
    end
    object ComboLevelAuto: TComboBox
      Left = 10
      Top = 22
      Width = 200
      Height = 22
      Hint = #1042#1099#1073#1086#1088' '#1091#1088#1086#1074#1085#1103' '#1087#1088#1080#1074#1077#1083#1077#1075#1080#1081' '#1072#1074#1090#1086#1079#1072#1087#1091#1089#1082#1072' '#1087#1088#1086#1094#1077#1089#1089#1072
      Style = csOwnerDrawFixed
      DropDownCount = 3
      DropDownWidth = 100
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = #1042#1099#1089#1086#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100
      Items.Strings = (
        #1042#1099#1089#1086#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100
        #1057#1088#1077#1076#1085#1080#1081' '#1091#1088#1086#1074#1085#1100
        #1053#1080#1079#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100)
    end
    object ComboLevelManual: TComboBox
      Left = 10
      Top = 70
      Width = 200
      Height = 22
      Hint = #1042#1099#1073#1086#1088' '#1091#1088#1086#1074#1085#1103' '#1087#1088#1080#1074#1077#1083#1077#1075#1080#1081' '#1088#1091#1095#1085#1086#1075#1086' '#1079#1072#1087#1091#1089#1082#1072' '#1087#1088#1086#1094#1077#1089#1089#1072
      Style = csOwnerDrawFixed
      DropDownCount = 3
      DropDownWidth = 100
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = #1042#1099#1089#1086#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100
      Items.Strings = (
        #1042#1099#1089#1086#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100
        #1057#1088#1077#1076#1085#1080#1081' '#1091#1088#1086#1074#1085#1100
        #1053#1080#1079#1082#1080#1081' '#1091#1088#1086#1074#1077#1085#1100)
    end
  end
end
