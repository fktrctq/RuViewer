object MainF: TMainF
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1050#1086#1085#1089#1086#1083#1100' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103' '#1089#1077#1088#1074#1077#1088#1072#1084#1080' RuViewer'
  ClientHeight = 555
  ClientWidth = 1058
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object PanelServer: TPanel
    Left = 0
    Top = 0
    Width = 161
    Height = 555
    Align = alLeft
    TabOrder = 0
    object LVListServer: TListView
      Left = 1
      Top = 42
      Width = 159
      Height = 512
      Hint = #1057#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074' RuViewer '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      Align = alClient
      Columns = <
        item
          Caption = #1057#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074
          Width = 155
        end
        item
          Caption = #1055#1086#1088#1090
          MaxWidth = 1
          Width = 0
        end
        item
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
          MaxWidth = 1
          Width = 0
        end
        item
          Caption = #1055#1072#1088#1086#1083#1100
          MaxWidth = 1
          Width = 0
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      LargeImages = VirtualImageList1
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      ParentShowHint = False
      PopupMenu = PPLVListServer
      ShowHint = True
      SmallImages = VirtualImageList1
      StateImages = VirtualImageList1
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = LVListServerDblClick
    end
    object PanelServerControl: TPanel
      Left = 1
      Top = 1
      Width = 159
      Height = 41
      Align = alTop
      TabOrder = 1
      object ButAddSrv: TSpeedButton
        Left = 5
        Top = 10
        Width = 25
        Height = 25
        Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '
        ImageIndex = 3
        ImageName = 'add'
        Images = VirtualImageList2
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = ButAddSrvClick
      end
      object ButDelServer: TSpeedButton
        Left = 34
        Top = 10
        Width = 26
        Height = 25
        Hint = #1059#1076#1072#1083#1080#1090#1100
        ImageIndex = 2
        ImageName = 'Delete'
        Images = VirtualImageList2
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = ButDelServerClick
      end
      object ButEditServer: TSpeedButton
        Left = 64
        Top = 10
        Width = 25
        Height = 25
        Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
        ImageIndex = 0
        ImageName = 'Edit'
        Images = VirtualImageList2
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = ButEditServerClick
      end
      object ButSaveServer: TSpeedButton
        Left = 95
        Top = 10
        Width = 25
        Height = 25
        Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074
        ImageIndex = 4
        ImageName = 'Save'
        Images = VirtualImageList2
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = ButSaveServerClick
      end
      object ButLoadServer: TSpeedButton
        Left = 125
        Top = 10
        Width = 25
        Height = 25
        Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1086#1093#1088#1072#1085#1077#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074
        ImageIndex = 1
        ImageName = 'Load'
        Images = VirtualImageList2
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = ButLoadServerClick
      end
    end
  end
  object PageControl1: TPageControl
    Left = 161
    Top = 0
    Width = 897
    Height = 555
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1082#1080' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      object GroupBox3: TGroupBox
        Left = 0
        Top = 89
        Width = 889
        Height = 349
        Align = alClient
        TabOrder = 1
        object Label1: TLabel
          Left = 7
          Top = 1
          Width = 251
          Height = 15
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091' '#1082#1083#1072#1089#1090#1077#1088#1072
        end
        object Label2: TLabel
          Left = 368
          Top = 2
          Width = 248
          Height = 15
          Caption = #1057#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074' '#1082#1083#1072#1089#1090#1077#1088#1072' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
        end
        object GroupBox8: TGroupBox
          Left = 2
          Top = 17
          Width = 359
          Height = 330
          Hint = 
            #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1082' '#1076#1072#1085#1085#1086#1084#1091' '#1089#1077#1088 +
            #1074#1077#1088#1091
          Align = alLeft
          TabOrder = 0
          object CBBlackListClaster: TCheckBox
            Left = 91
            Top = 287
            Width = 251
            Height = 17
            Hint = #1042#1082#1083#1102#1095#1077#1085#1080#1077' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' '#1085#1077#1091#1076#1072#1095#1085#1099#1093' '#1074#1093#1086#1076#1103#1097#1080#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081
            Alignment = taLeftJustify
            Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1091' '#1074' '#1095#1077#1088#1085#1086#1084' '#1089#1087#1080#1089#1082#1077
            ParentShowHint = False
            ShowHint = True
            TabOrder = 10
          end
          object CBGetListServers: TCheckBox
            Left = 91
            Top = 268
            Width = 251
            Height = 17
            Hint = 
              #1055#1086#1083#1091#1095#1072#1090#1100' '#1088#1077#1082#1074#1080#1079#1080#1090#1099' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1072#1084' '#1082#1083#1072#1089#1090#1077#1088#1072' '#1086#1090' '#1076#1088#1091#1075#1080#1093 +
              ' '#1089#1077#1088#1074#1077#1088#1086#1074
            Alignment = taLeftJustify
            Caption = #1055#1086#1083#1091#1095#1072#1090#1100' '#1088#1077#1082#1074#1080#1079#1080#1090#1099' '#1089#1077#1088#1074#1077#1088#1086#1074' '#1082#1083#1072#1089#1090#1077#1088#1072
            ParentShowHint = False
            ShowHint = True
            TabOrder = 9
          end
          object CBSendListServers: TCheckBox
            Left = 84
            Top = 249
            Width = 258
            Height = 17
            Hint = 
              #1044#1077#1083#1080#1090#1089#1103' '#1088#1077#1082#1074#1080#1079#1080#1090#1072#1084#1080' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1072#1084' '#1082#1083#1072#1089#1090#1077#1088#1072' '#1076#1083#1103' '#1087#1086#1076#1082 +
              #1083#1102#1095#1077#1085#1085#1099#1093' '#1089#1077#1088#1074#1077#1088#1086#1074
            Alignment = taLeftJustify
            Caption = #1055#1077#1088#1077#1076#1072#1074#1072#1090#1100' '#1088#1077#1082#1074#1080#1079#1080#1090#1099' '#1089#1077#1088#1074#1077#1088#1086#1074' '#1082#1083#1072#1089#1090#1077#1088#1072
            ParentShowHint = False
            ShowHint = True
            TabOrder = 8
          end
          object EditIPExternalClaster: TLabeledEdit
            Left = 240
            Top = 74
            Width = 102
            Height = 23
            Hint = 
              #1042#1085#1077#1096#1085#1080#1081' IP '#1072#1076#1088#1077#1089' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1093' ' +
              #1082' '#1076#1088#1091#1075#1080#1084' '#1089#1077#1088#1074#1077#1088#1072#1084' '#1082#1083#1072#1089#1090#1077#1088#1072
            EditLabel.Width = 193
            EditLabel.Height = 15
            EditLabel.Caption = #1042#1085#1077#1096#1085#1080#1081' IP '#1076#1083#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' '#1082#1083#1072#1089#1090#1077#1088#1072
            LabelPosition = lpLeft
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            Text = ''
          end
          object EditLiveTimeBlackList: TLabeledEdit
            Left = 240
            Top = 161
            Width = 102
            Height = 23
            Hint = 
              #1042#1088#1077#1084#1103' '#1085#1072#1093#1086#1078#1076#1077#1085#1080#1103' '#1072#1076#1088#1077#1089#1072' '#1074' '#1095#1077#1088#1085#1086#1084' '#1089#1087#1080#1089#1082#1077', '#1087#1086#1089#1083#1077' '#1095#1077#1075#1086' '#1086#1085' '#1091#1076#1072#1083#1103#1077#1090#1089#1103 +
              '.'
            EditLabel.Width = 235
            EditLabel.Height = 15
            EditLabel.Caption = #1042#1088#1077#1084#1103' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' '#1074' '#1095#1077#1088#1085#1086#1084' '#1089#1087#1080#1089#1082#1077' ('#1084#1080#1085')'
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 5
            Text = ''
          end
          object EditMaxNumInConnect: TLabeledEdit
            Left = 240
            Top = 103
            Width = 102
            Height = 23
            Hint = 
              #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1074#1093#1086#1076#1103#1097#1080#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081' '#1076#1083#1103' '#1076#1072#1085#1085#1086#1075#1086' '#1089#1077#1088#1074#1077#1088#1072 +
              ' '#1082#1083#1072#1089#1090#1077#1088#1072
            EditLabel.Width = 211
            EditLabel.Height = 15
            EditLabel.Caption = #1052#1072#1082#1089'. '#1082#1086#1083'-'#1074#1086' '#1074#1093#1086#1076#1103#1097#1080#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 3
            Text = ''
          end
          object EditNumOccurentc: TLabeledEdit
            Left = 240
            Top = 190
            Width = 102
            Height = 23
            Hint = 
              #1050#1086#1083'-'#1074#1086' '#1085#1077#1091#1076#1072#1095#1085#1099#1093' '#1074#1093#1086#1076#1103#1097#1080#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081' '#1082' '#1089#1077#1088#1074#1077#1088#1091' '#1076#1086' '#1087#1086#1087#1072#1076#1072#1085#1080#1103' '#1074' '#1089 +
              #1087#1080#1089#1086#1082' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' (BlackList)'
            EditLabel.Width = 204
            EditLabel.Height = 15
            EditLabel.Caption = #1055#1086#1087#1099#1090#1086#1082' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' '#1076#1086' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 6
            Text = ''
          end
          object EditPortServerClaster: TLabeledEdit
            Left = 240
            Top = 42
            Width = 102
            Height = 23
            Hint = #1042#1093#1086#1076#1103#1097#1080#1081' TCP '#1087#1086#1088#1090' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091' '#1082#1083#1072#1089#1090#1077#1088#1072
            EditLabel.Width = 96
            EditLabel.Height = 15
            EditLabel.Caption = 'TCP '#1087#1086#1088#1090' '#1089#1077#1088#1074#1077#1088#1072
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            Text = ''
          end
          object EditPrefixLifeTime: TLabeledEdit
            Left = 240
            Top = 132
            Width = 102
            Height = 23
            Hint = 
              #1055#1086' '#1080#1089#1090#1077#1095#1077#1085#1080#1102' '#1076#1072#1085#1085#1086#1075#1086' '#1074#1088#1077#1084#1077#1085#1080' '#1085#1077' '#1086#1073#1085#1086#1074#1083#1077#1085#1085#1099#1077' '#1087#1088#1077#1092#1080#1082#1089#1099' '#1089#1077#1088#1074#1077#1088#1086#1074' '#1074' ' +
              #1082#1083#1072#1089#1090#1077#1088#1077' '#1073#1091#1076#1091#1090' '#1091#1076#1072#1083#1077#1085#1099
            EditLabel.Width = 225
            EditLabel.Height = 15
            EditLabel.Caption = #1042#1088#1077#1084#1103' '#1078#1080#1079#1085#1080' '#1087#1088#1077#1092#1080#1082#1089#1086#1074' '#1089#1077#1088#1074#1077#1088#1086#1074' ('#1084#1080#1085')'
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
            Text = ''
          end
          object EditPswdClaster: TLabeledEdit
            Left = 240
            Top = 10
            Width = 102
            Height = 23
            Hint = #1055#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091' '#1082#1083#1072#1089#1090#1077#1088#1072
            EditLabel.Width = 199
            EditLabel.Height = 15
            EditLabel.BiDiMode = bdRightToLeft
            EditLabel.Caption = #1055#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091
            EditLabel.ParentBiDiMode = False
            LabelPosition = lpLeft
            ParentShowHint = False
            PasswordChar = '*'
            PopupMenu = PPpassword
            ShowHint = True
            TabOrder = 0
            Text = ''
            OnMouseActivate = EditConsolePswdMouseActivate
            OnMouseLeave = EditConsolePswdMouseLeave
          end
          object EditTimeOutReconnect: TLabeledEdit
            Left = 240
            Top = 219
            Width = 102
            Height = 23
            Hint = 
              #1042#1088#1077#1084#1103' '#1086#1078#1080#1076#1072#1085#1080#1103' '#1076#1086' '#1087#1086#1074#1090#1086#1088#1085#1086#1081' '#1091#1089#1090#1072#1085#1086#1074#1082#1080' '#1080#1089#1093#1086#1076#1103#1097#1077#1075#1086' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' '#1089' '#1089#1077 +
              #1088#1074#1077#1088#1086#1084' '#1082#1083#1072#1090#1077#1088#1072
            EditLabel.Width = 223
            EditLabel.Height = 15
            EditLabel.Caption = 'Timeout '#1080#1089#1093#1086#1076#1103#1097#1080#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081' ('#1084#1080#1085')'
            LabelPosition = lpLeft
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 7
            Text = ''
          end
          object CBAutoRunSrvClaster: TCheckBox
            Left = 67
            Top = 307
            Width = 275
            Height = 17
            Alignment = taLeftJustify
            Caption = #1057#1090#1072#1088#1090' '#1089#1077#1088#1074#1077#1088#1072' '#1082#1083#1072#1089#1090#1077#1088#1072' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077' '#1089#1083#1091#1078#1073#1099
            TabOrder = 11
          end
        end
        object GroupBox9: TGroupBox
          Left = 361
          Top = 17
          Width = 526
          Height = 330
          Align = alRight
          TabOrder = 1
          object ButEditSrvClaster: TSpeedButton
            Left = 68
            Top = 6
            Width = 25
            Height = 25
            Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
            ImageIndex = 0
            ImageName = 'Edit'
            Images = VirtualImageList2
            Flat = True
            ParentShowHint = False
            ShowHint = True
            OnClick = ButEditSrvClasterClick
          end
          object ButDelSrvClaster: TSpeedButton
            Left = 37
            Top = 6
            Width = 25
            Height = 25
            Hint = #1059#1076#1072#1083#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
            ImageIndex = 2
            ImageName = 'Delete'
            Images = VirtualImageList2
            Flat = True
            ParentShowHint = False
            ShowHint = True
            OnClick = ButDelSrvClasterClick
          end
          object ButAddSrvClaster: TSpeedButton
            Left = 6
            Top = 6
            Width = 25
            Height = 25
            Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
            ImageIndex = 3
            ImageName = 'add'
            Images = VirtualImageList2
            Flat = True
            ParentShowHint = False
            ShowHint = True
            OnClick = ButAddSrvClasterClick
          end
          object LVServerClaster: TListView
            Left = 6
            Top = 36
            Width = 517
            Height = 291
            Hint = 
              #1057#1087#1080#1089#1086#1082' '#1072#1076#1088#1077#1089#1086#1074' '#1080' '#1088#1077#1082#1074#1080#1079#1080#1090#1086#1074' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1072#1084' '#1076#1083#1103' '#1089#1086#1079#1076#1072 +
              #1085#1080#1103' '#1082#1083#1072#1089#1090#1077#1088#1072
            Columns = <
              item
                Caption = #8470
              end
              item
                Alignment = taCenter
                Caption = #1040#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072
                Width = 150
              end
              item
                Alignment = taCenter
                Caption = 'TCP '#1087#1086#1088#1090
                Width = 150
              end
              item
                Alignment = taCenter
                Caption = #1055#1072#1088#1086#1083#1100
                Width = 150
              end>
            GridLines = True
            ReadOnly = True
            RowSelect = True
            ParentShowHint = False
            PopupMenu = PPLVServerClaster
            ShowHint = True
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = LVServerClasterDblClick
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 438
        Width = 889
        Height = 87
        Align = alBottom
        TabOrder = 2
        object GroupBoxService: TGroupBox
          Left = 2
          Top = -2
          Width = 136
          Height = 89
          Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1089#1083#1091#1078#1073#1086#1081
          TabOrder = 0
          object ButService: TButton
            Left = 30
            Top = 44
            Width = 75
            Height = 25
            Hint = #1055#1077#1088#1077#1079#1072#1087#1091#1089#1082' '#1089#1083#1091#1078#1073#1099' RuViewerSrvService '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077
            Caption = 'No status'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            OnClick = ButServiceClick
          end
        end
        object GroupBox10: TGroupBox
          Left = 144
          Top = 2
          Width = 392
          Height = 85
          Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1089#1077#1088#1074#1077#1088#1072#1084#1080
          TabOrder = 1
          object GroupBox11: TGroupBox
            Left = 202
            Top = 17
            Width = 200
            Height = 66
            Align = alLeft
            Caption = '     '#1057#1077#1088#1074#1077#1088' '#1082#1083#1072#1089#1090#1077#1088#1072
            TabOrder = 1
            object LabelStatusClaster: TLabel
              Left = 64
              Top = 48
              Width = 3
              Height = 15
            end
            object ImageStatusClaster: TVirtualImage
              Left = 3
              Top = 1
              Width = 16
              Height = 16
              ImageCollection = ImageCollection1
              ImageWidth = 0
              ImageHeight = 0
              ImageIndex = 6
              ImageName = 'Disconnect'
            end
            object ButStartClaster: TButton
              Left = 100
              Top = 23
              Width = 75
              Height = 25
              Hint = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1082#1083#1072#1089#1090#1077#1088#1072
              Caption = #1057#1090#1072#1088#1090
              ParentShowHint = False
              ShowHint = True
              TabOrder = 1
              OnClick = ButStartClasterClick
            end
            object ButStopClaster: TButton
              Left = 14
              Top = 23
              Width = 75
              Height = 25
              Hint = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1082#1083#1072#1089#1090#1077#1088#1072
              Caption = #1057#1090#1086#1087
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
              OnClick = ButStopClasterClick
            end
          end
          object GroupBox12: TGroupBox
            Left = 2
            Top = 17
            Width = 200
            Height = 66
            Align = alLeft
            Caption = '     '#1057#1077#1088#1074#1077#1088' RuViewer'
            TabOrder = 0
            object LabelStatusRuViwewer: TLabel
              Left = 64
              Top = 48
              Width = 3
              Height = 15
            end
            object ImageStatusRuViewer: TVirtualImage
              Left = 4
              Top = 1
              Width = 16
              Height = 16
              ImageCollection = ImageCollection1
              ImageWidth = 0
              ImageHeight = 0
              ImageIndex = 6
              ImageName = 'Disconnect'
            end
            object ButStartRuViewer: TButton
              Left = 106
              Top = 23
              Width = 75
              Height = 25
              Hint = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1086#1073#1089#1083#1091#1078#1080#1074#1072#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer'
              Caption = #1057#1090#1072#1088#1090
              ParentShowHint = False
              ShowHint = True
              TabOrder = 1
              OnClick = ButStartRuViewerClick
            end
            object ButStopRuViewer: TButton
              Left = 16
              Top = 23
              Width = 75
              Height = 25
              Hint = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1086#1073#1089#1083#1091#1078#1080#1074#1072#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer'
              Caption = #1057#1090#1086#1087
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
              OnClick = ButStopRuViewerClick
            end
          end
          object ButStatusServer: TButton
            Left = 382
            Top = 7
            Width = 10
            Height = 10
            Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1090#1072#1090#1091#1089#1099' '#1089#1077#1088#1074#1077#1088#1086#1074
            Caption = '*'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            OnClick = ButStatusServerClick
          end
        end
        object ButDataUpdate: TButton
          Left = 552
          Top = 26
          Width = 150
          Height = 32
          Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1089' '#1089#1077#1088#1074#1077#1088#1072
          Caption = #1054#1073#1085#1086#1074#1080#1090#1100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = ButDataUpdateClick
        end
        object ButSaveSettings: TButton
          Left = 721
          Top = 26
          Width = 150
          Height = 32
          Hint = #1055#1077#1088#1077#1076#1072#1090#1100' '#1074#1089#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1085#1072' '#1089#1077#1088#1074#1077#1088
          Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnClick = ButSaveSettingsClick
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 889
        Height = 89
        Align = alTop
        TabOrder = 0
        object GroupBox2: TGroupBox
          Left = 371
          Top = -1
          Width = 400
          Height = 85
          Hint = 
            #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1082' '#1076#1072#1085#1085#1086#1084#1091' '#1089#1077#1088 +
            #1074#1077#1088#1091
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          object EditRuViewerPswd: TLabeledEdit
            Left = 270
            Top = 39
            Width = 105
            Height = 23
            Hint = #1055#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091
            EditLabel.Width = 42
            EditLabel.Height = 15
            EditLabel.Caption = #1055#1072#1088#1086#1083#1100
            ParentShowHint = False
            PasswordChar = '*'
            PopupMenu = PPpassword
            ShowHint = True
            TabOrder = 2
            Text = ''
            OnMouseActivate = EditConsolePswdMouseActivate
            OnMouseLeave = EditConsolePswdMouseLeave
          end
          object EditRuViewerPrefix: TLabeledEdit
            Left = 143
            Top = 39
            Width = 121
            Height = 23
            Hint = 
              #1055#1088#1077#1092#1080#1082#1089' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1089#1077#1088#1074#1077#1088#1072', ID '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1085#1072#1095#1080#1085#1072#1102#1090#1089#1103' '#1089' '#1076#1072#1085#1085 +
              #1086#1075#1086' '#1087#1088#1077#1092#1080#1082#1089#1072
            EditLabel.Width = 97
            EditLabel.Height = 15
            EditLabel.Caption = #1055#1088#1077#1092#1080#1082#1089' '#1089#1077#1088#1074#1077#1088#1072
            ParentShowHint = False
            ReadOnly = True
            ShowHint = True
            TabOrder = 1
            Text = ''
          end
          object EditRuViewerPort: TLabeledEdit
            Left = 16
            Top = 39
            Width = 121
            Height = 23
            Hint = 'TCP '#1087#1086#1088#1090' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1083#1080#1077#1085#1090#1086#1074' RuViewer '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091
            EditLabel.Width = 96
            EditLabel.Height = 15
            EditLabel.Caption = 'TCP '#1087#1086#1088#1090' '#1089#1077#1088#1074#1077#1088#1072
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            Text = ''
          end
          object CBAutoRunSrvRuViewer: TCheckBox
            Left = 16
            Top = 65
            Width = 265
            Height = 17
            Caption = #1057#1090#1072#1088#1090' '#1089#1077#1088#1074#1077#1088#1072' RuViewer '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077' '#1089#1083#1091#1078#1073#1099
            TabOrder = 3
          end
        end
        object GroupBox6: TGroupBox
          Left = 9
          Top = -1
          Width = 346
          Height = 85
          Hint = 
            #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' '#1087#1086#1076#1083#1102#1095#1077#1085#1080#1103' '#1082#1086#1085#1089#1086#1083#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103' '#1082' '#1076#1072#1085#1085#1086#1084#1091' '#1089#1077#1088 +
            #1074#1077#1088#1091
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1086#1085#1089#1086#1083#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object EditConsoleLogin: TLabeledEdit
            Left = 87
            Top = 39
            Width = 121
            Height = 23
            Hint = 
              #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1086#1085#1089#1086#1083#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103' '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089 +
              #1077#1088#1074#1077#1088#1091
            EditLabel.Width = 102
            EditLabel.Height = 15
            EditLabel.Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            Text = ''
          end
          object EditConsolePort: TLabeledEdit
            Left = 16
            Top = 39
            Width = 65
            Height = 23
            Hint = #1055#1086#1088#1090' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1086#1085#1089#1086#1083#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103' '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091
            EditLabel.Width = 49
            EditLabel.Height = 15
            EditLabel.Caption = 'TCP '#1087#1086#1088#1090
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            Text = ''
          end
          object EditConsolePswd: TLabeledEdit
            Left = 214
            Top = 39
            Width = 105
            Height = 23
            Hint = #1055#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '#1082#1086#1085#1089#1086#1083#1080' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103' '#1082' '#1090#1077#1082#1091#1097#1077#1084#1091' '#1089#1077#1088#1074#1077#1088#1091
            EditLabel.Width = 42
            EditLabel.Height = 15
            EditLabel.Caption = #1055#1072#1088#1086#1083#1100
            ParentShowHint = False
            PasswordChar = '*'
            PopupMenu = PPpassword
            ShowHint = True
            TabOrder = 2
            Text = ''
            OnMouseActivate = EditConsolePswdMouseActivate
            OnMouseLeave = EditConsolePswdMouseLeave
          end
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1058#1077#1082#1091#1097#1080#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 889
        Height = 472
        Align = alTop
        Caption = #1058#1077#1082#1091#1097#1080#1077' '#1076#1072#1085#1085#1099#1077' '#1089#1077#1088#1074#1077#1088#1072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object GroupBox4: TGroupBox
          Left = 2
          Top = 17
          Width = 885
          Height = 184
          Align = alTop
          Caption = #1050#1083#1080#1077#1085#1090#1099' RuViewer '#1086#1085#1083#1072#1081#1085
          TabOrder = 0
          object LVClient: TListView
            Left = 2
            Top = 17
            Width = 881
            Height = 165
            Align = alClient
            Columns = <
              item
                Caption = #8470
                Width = 40
              end
              item
                Alignment = taCenter
                Caption = 'ID '#1082#1083#1080#1077#1085#1090#1072
                Width = 150
              end
              item
                Alignment = taCenter
                Caption = #1042#1088#1077#1084#1103' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
                Width = 150
              end
              item
                Alignment = taCenter
                Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1081' ID'
                Width = 150
              end>
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            GridLines = True
            Items.ItemData = {}
            ReadOnly = True
            RowSelect = True
            ParentFont = False
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object GroupBox5: TGroupBox
          Left = 2
          Top = 201
          Width = 1072
          Height = 269
          Align = alLeft
          Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077' '#1082' '#1089#1077#1088#1074#1077#1088#1072#1084' '#1082#1083#1072#1089#1090#1077#1088#1072
          TabOrder = 1
          object LVServer: TListView
            Left = 2
            Top = 17
            Width = 1068
            Height = 250
            Align = alClient
            Columns = <
              item
                Caption = #8470
                Width = 30
              end
              item
                Alignment = taCenter
                Caption = #1040#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072
                Width = 100
              end
              item
                Alignment = taCenter
                Caption = #1057#1090#1072#1090#1091#1089' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
                Width = 150
              end
              item
                Alignment = taCenter
                Caption = #1042#1088#1077#1084#1103' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
                Width = 120
              end
              item
                Alignment = taCenter
                Caption = #1042#1093'\'#1048#1089#1093
                Width = 100
              end
              item
                Alignment = taCenter
                Caption = #1055#1088#1077#1092#1080#1082#1089' '#1089#1077#1088#1074#1077#1088#1072
                Width = 110
              end
              item
                Alignment = taCenter
                Caption = 'ID'
              end>
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            GridLines = True
            Items.ItemData = {}
            ReadOnly = True
            RowSelect = True
            ParentFont = False
            PopupMenu = PPLVServer
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object GroupBox7: TGroupBox
          Left = 659
          Top = 201
          Width = 228
          Height = 269
          Align = alRight
          Caption = #1057#1087#1080#1089#1086#1082' '#1087#1088#1077#1092#1080#1082#1089#1086#1074' '#1082#1083#1072#1089#1090#1077#1088#1072
          TabOrder = 2
          object LVPrefix: TListView
            Left = 2
            Top = 17
            Width = 224
            Height = 250
            Align = alClient
            Columns = <
              item
                Caption = #8470
                Width = 30
              end
              item
                Alignment = taCenter
                Caption = #1055#1088#1077#1092#1080#1082#1089
                Width = 65
              end
              item
                Alignment = taCenter
                Caption = #1042#1088#1077#1084#1103' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
                Width = 120
              end>
            GridLines = True
            Items.ItemData = {}
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
      end
      object Button1: TButton
        Left = 703
        Top = 477
        Width = 150
        Height = 32
        Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1089' '#1089#1077#1088#1074#1077#1088#1072
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = Button1Click
      end
    end
  end
  object PPLVServer: TPopupMenu
    Left = 28
    Top = 176
    object N1: TMenuItem
      Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100
      OnClick = N1Click
    end
  end
  object PPLVServerClaster: TPopupMenu
    Left = 707
    Top = 595
    object N2: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = N4Click
    end
  end
  object ImageCollection1: TImageCollection
    Images = <
      item
        Name = 'Edit'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000006A5494441545847B5570B
              5094451CFFEDDD71BC0EEEE038E00E10110E0DD440ECE158563ED27C3BCD548E
              4D6953324E6F28B5C9A6C64C4660886A1AABA914D194342D9BA6ACA6A6E79499
              0E2430CAE378CA1DC71DC781771CC7DDF6DF4FCEBC860CB07E37BF6FF7DBDB6F
              7FBFFDEFEEF7ED32DB0BB972EDCB677C94EA011410D71145FE3F0107A31F1FB9
              4317F100B18C34BB843613A5949945C9716212B1895847F413C5FF979F1E2718
              F7FBC3E912CA19F33326738331239567103B892BC9C469118104BAF98D9842CC
              27EEA33F06299D30F86630AB1509BA78A42202D154340C2B7A7A598C856B26AF
              A6FBB789EDC41B84819D94798E984FC2EF502A22224566AC60DC0739F7C0C3C3
              A0F3D487D82F7A5362F548FFB69ECF78F46BAC9B1603D3D1FBD887BC9FB7CACA
              F10BB5BF911E13268A848136CA7888D9646088EE65948AF08F09F66D3399DCEF
              827A6723E79B958A0B766F9241C7337F6C43D69AA378B6C72D0D2B16A5E2B32F
              37B00A38789B039AF3FEA8B493541C2AA38B087DCD88381B8FB840EC8E1A2E89
              3F83900BB621832181A7F53890BAFA236C16E23246E1A751F9AA15CB9657F075
              8860C9CA8B8E482AAB26A6080302A2D284C19F45488F13C906038C3F9930A3CB
              8BF03C3D4E49FF7188992E4DE4CF4C58F5C11FDC18918A30BF9F4BC31C3030AE
              31BF1234E1145DBD488A8B477A6D2732571DC396A55578ECC44338B2380D9F90
              326323EB305D8DDAC529CC4213D2478552A403062604BE150A732F92F5F1C8A8
              EB42C6C22A3C63A3B077F42333AD145BBF781047C9C4713F45615214CE7F731F
              DED06AD06EB6C346A6AECD80E8B9D986A4441DD21BAC485F548542F3454CA186
              7D34EEBE963E6419CB5158B9069FDE7F1D0E542EC5EE498968B2D998495F09E7
              48331333C09F83C2E28021518B8C161BA6CC3F84820B03C810E262CC458F69E0
              871B1D98B9EA10D6563E8EC3F3F4A8EDB5B0266D4CA858FF02417360CC1061B7
              F4C090100B63871369F30EA240843C202EEA88F0FA3814DA307415DE88136880
              DBEA427D8C4AD161ED9BEC951A1AC1B80C08F16E1BF40931305A06907ACB013C
              DDEEC4342178A538E5659A507457AD42C9DD37E0B4C385469D0A6656EAF52A63
              82DFEC633640E2F26E3B12E33530DA063169CE7E3CD54AE31C1014750279B512
              D6832B51BC200BB55DCD68D3A8D1C1CA30EC7C3E8DF9E5A1527B018CC9004DB8
              4BE26A189D5EA4DCB40F4F9A1C98319A78B412B6FD2B50B2643ACE9ADBD1AA8F
              432B2BC690A813FD8A2950FD32FED500DF02B9D58184F86864BA7D48994DE24D
              0E5C3F9A7854087AF72E43F1F2EB5143E22DB4425AD82EE935FF8FB8AA017AC3
              49E2BA2864521792732BF044831DB9A389AB42E07877294AD6CC42B5A515AD89
              B1245E747571816003D452DF36A3B43CA49E3B114F932793CB497C2F1E3B6743
              DE68E2110A38DF5A82927B66E38CA5056D095A122FFE777181200332E6837A47
              032771197D5074BA484C85024933F7E0D1BA1EDC389A78B802FD6FDE89927537
              E1B4E839AD1013898F793F1164C0E30B012F0C95DBFA101F1741E2A1D0E7ECC1
              A6B356DC3C9A789802175F5F88D2F57371AA5BF45C43E2A5631717083210EFE9
              64FDEEA1586D04326927A39FBD07F9D5DD983BAAB81CAEB2F9287D781E4E769B
              D04ECBB379BCE2024106FA07EDE1E10A3E59843DEF3D6CFADD8CDB44F96571DA
              278ABC520E77F11D28DB743B7EED6E46C744C505820C38DC3EB52209D1F92730
              FF8C19B76C988E8AD51938223615244EDA242EC360D16D287B7C017EA69E0BF1
              2612778F34316E0419880BE31ADA9A447DDD8A39D37538F9FE467C7EEC091CBE
              598FEFC4775D886F9F87F28245F8C9DA44E26A345E8BB840C080BF7A1994111A
              A87FAD478A790093D666E37B1A0AFF5007A22C2EE844A5EDB7A27CCB12FC606D
              46675CD4B5F59C207D14460C30B95C8548A8A1AAAC43F6E030548D76C4CDDF85
              F571E5D8451F9CA92FCD45E996BBF0434F133AB52A34CA5E85EBD2B31386425C
              A45D3159F184F4D4AD88D67BA665BFC65EACB3F11C057D5E692976CC4AC099FC
              5CFCBC723AEA9D16B44786CB1A8707135D6E950AA09740CCF6BAE0CFDB5510D8
              7153AAA4DB5A62A83050442D6C5531D74BA7EBCFD53CF22DB66568D0B6360BA7
              EECD86095A668703AE3E1B2CEA7059C7D070A26B202206B210B124E822BD37C7
              061297CC92E695E7821C3A19B1DFA89D14FFA06377A4AFFDBB30C370170628C4
              56384DBD7078190632FD70B383133EA64920E1304A1E20FE7532A28BF8238F92
              8F69A79A4C67B94EAFCFDF48790F718818D8B28FA3AF4110CF09E362BE6511D3
              894167C391D3710E9D885921D55C4B4F18A8C2FF81BF9D8E73E57F029E81E68B
              163FE81D0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000023000000220806000000D58560
              FC000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000849494441545847AD987B
              5054D71DC7BFE7EE835D96C7C22E0B2CB0CB82D88028605BC7344EC089231A9B
              18D3FA28462B643249EB4CE31F519BC67662FC2B63933119636C3556343E88E2
              23C6576C146BD5C4477D24266A44605D9605E4BD2CFB3EFD9D852536CB4C01FD
              31DF7BCFDD7BEE391F7EE777CEFD9DCBDAFE5C24D3ADB912A0B30AC06F48AF90
              8A480AD223330E467F7CE00A3ED215D246D22EEADF2D3898B84385243A7D407A
              8EE427DD153F9364246183AD8CC0426D9371326530108CA2B244D6CB241643E5
              2C92F8870F90961250ABF08C922EB691E6936A486B49374841D24399249305DD
              ED6DDA2885D398901E5043C9E06F64BEB66ED57D45822E996ABC46D58A4955A4
              C502662115B690CE939611E1553A3F12AB9F8998C4029863A3612CAB42A9CB0B
              D5EA2771A6A000DFEEDF8486E2795352E1EDFD1B557D9C542160CE50E1A7A4E7
              09E4185D0BF70AF70548C335C6C8917E9F0FFAA438DEDBDE2A391A6D7AB3C16F
              5124F394455BF882A37751EAF643F3443A4EAE2B95F6E7E6072F9EFD07BF99FB
              74017946DA436D5C16306E2ADC22CD22189B18363A7B450F23B1EF2AD258EE96
              46DEB208524B8025641979A6D78B9CF2239873B41E33092456D49368A44A4C38
              BE6996EC50962170B6B1CD12506BB5BBE8D663121D44603593C2413A128F0C9A
              00E1BF83CC29832EC5C02DEA44A4C6474375A9198502845C17904BF00439E4A7
              AD98B1ECF3E02FA9A7A4289547CD395AA8892801232C3C6B466DFE57205DED82
              CE9209934A01CB1FF662D69B67317EC513A84A8D412D75280B04A124206F80CA
              B51DC8EEED863A4ACD65742FB48C84611ECAF84A48D73BA12B34C144FE35FDE5
              148A375CC58BEF7C8525A95AF4BCF924B6A7685047AE677E024A52A3F15739A8
              D1A4A0C3D921F332A97F341E1A86FF15EC6B1B74052698A144C6F22398FAC115
              2C212F289C5E2496EFC3EBC97170AD2EC6364334ACB10A74568CC7BEB7CAD851
              870DED4C19DB195E901E0A866F05BB7915BAEC6498A55818571EC3D4F504E209
              404331E2A7600DF4789150BE1FAFC52AE15D3E193B574DC6A63525F897C7C15A
              3BBF812D2A2ED6434D8578460DC3F781D5D720519F004BB401292B0EE129F2C8
              A270B0521CC8295865B4C6FB3A3C30AC3A894506231C2B5EC0E73DADB075F728
              EA724FA397FB7D83F13A2A187E18CC7A10898A6864EBB3A15FBE0FD3375EC5C2
              5E1FB40320A10EC4E243C12A5750D09698717E6E12ECB883FBCD5E763B312EB9
              23D4D803366218BE0BCCB607093C0AD969794858BE1333365DC37C1A0E9DE8FC
              41102AD36B08C197C6A3F2FD6771244A89863B7568CCDBC1DB3DCAC488256444
              30FC24819C80D6AF40B6B910DA951F63C647D731B78B8621DCB9A837E01D8986
              28509E8FCA7767E184460EABB51D0D63B2432F60F4793CE1B81DB461C3F01D60
              0DDB11CFE5C8CA2C44C2AAED28DD7C0DF33ADC481520A11C813844D00AEFC829
              5616E662E7C6D93816C570EFDB3BB029BBD1C6DEEE7F014BB2C80C655830BC9A
              66CD31C447AB90959107FD5BBBF114C5C8FCF63E18C320620D11202268150CDE
              E7C7626FE5AF71880561BB6D85D5148F96B4AA507A1232AA169196FC5F18BE1B
              EC4A35E2D3E3614EB22079ED4114BF7F09656D7D48FB11883F0442C1FA74363E
              AD2A43B5DB077B9D150D9624B4C46EF801A4DF22582261281B1B1C4BFE05D885
              03881F6F8029C608E3FA1378FCED2FB18840D2870009CD9AE999387C6031AA9C
              6E389A1A601D6341B3F2DD1F830C6D1130C1E00FCF5DDC84F89FA52043AE43FA
              E63398B4FA2C96844144B03E3034721123534D38FAD912EC14202D7761B54C82
              83AD19FE8B37024626F58FE5E505882B302043D22163EB9798F8A7D3A8B8EF42
              C60088786E3046C479AA19478F2FC60E4AA01C4DB568C89A063B5B363C8F842D
              0246AB0AB03BE52C6EAC0E66652A8C951750F87A0D2A5A5D30114868CA8A7AA2
              2C4044799A19470E9561272541F6A6EF61CD994E202F8D3C158980B9DFD4A08E
              5770738C05295BCF61E21BA7B0C4D10BCB00C8E082264EA25C9A89433BE661B7
              428946DB6DD8B28BD1C85E1C5D4E1401E372F5A5EA73A0DFFC0526BF5183F246
              27724237C21E1948D4858704C8DFE7608F5E036BC3F7B89795431EF9FDE84084
              0DC24832293887725F531ED75CBE05CBBA0B98DDE5867EC158544DD0E32B11AC
              04125ADA04C874333E7BEF59549B12515F5F0B9B219E40D684F643A3B6300CE3
              929CBF3C1131941E29B7DDC0B8965EA41519716ED71FF1C9B269D89BA3C575AA
              475B2048D34C38F2CE33A8FE49126A1B6A718FD6527BCC868703111686E16E97
              4FCA9F000DDAB8F6BA1D8FA9E470BE3A05A73007ADE545B0CB24F8C83B52493A
              8EBF371B7BF393516BBB0B5BB017F6F46D1871023F940DC0307F4F779F92DEC2
              6ADB773CCDDE059352863E0DF5BE7426E64E588B576B3B913F290535EB9F4355
              5E4A3F88DB89A6AC3D8F042414670246645A86A0D7A9A50DA7B2F206CB73B860
              ACEFC6D8A587515E7D0D735AE8FA1769A8A99C8D8FC7A5A2B6915E7ADCCDEC39
              7BE0393F376D70C51EA185932AF13CED2EE191D3E112072F4C4A8C9A88FBF8CF
              BFEB78A64ACE549426B6C72911F8791ACE958EC1D71545EC1685706BF31DE6D0
              6A631D1AF3587F73BA53AE5449B457378846438BE5304D8084632C9F2466EC45
              B1897B815AF948C102D754AE960F171F74E4F4046198978B4BBF9D4279592E21
              BAD0E7BE085FED75B4E5FF135DA1261E8151DF85745A470A6F6F27D0C65FB69D
              BC358F07BC37758AAE5DD0BBBE818FB93A1D92AFBB4BEE7405553D9A38B52B26
              46EDE3C1200DED489C30A489F018475A4E2A21F56FFCE930F8498431F60C4D5D
              0402413BCDE1764AD502F49B2FB4BEF48F6D383E4643137E5604AB8E243E8988
              30F99F4F22031F8B26A8C84365D4CBCB7453ECFE2353B14767437C2C2A92FD17
              7A5F5DE23B77ED0D0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003D08060000001DD56F
              C1000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000FA3494441546843D59B0B
              941C5599C7FFB7AABBA71F93CC7BA21240392BBA41924936022A687886BC13F2
              20427C2582B220BB7AF48887041522B066D59573D0B367D54C42DCF058D76854
              8849082A4284E824229198401E13659279C83CBAA77BBAABAEFFEF56554FCF64
              029999CC74F8CEB9D3D575EFADBEBFEFFBEE77BF5B53A550202D2BEB14EC10AA
              BFBA4BB7DC3929A62C6B3A4FCF61B994653C4B9CE5CD202996A32C4FB36C86D6
              5BAA56EFEE6EF9F254052787EAD5BBB53412C92BA075D564ABEA9E06D73F5EC6
              8F2FB3FC937CF7453A99FA334C0A8D1880592C85E7F7B37C957C3F942F85ACA6
              510B4F54F3C4B13BEBC2214B6DE0A925729E9265097B8767A2F471605FF2C60D
              A490E1D19CAB978DFBDAEE6CC0ACC4EDC5257CF8A7D8E8FD2C3D2C11E94139C4
              B28DE50596A49C289E68A5B4B615DC88D24E540A9D324217B7A0142D6A65B5B2
              D2AE0A595AD9E7534197B3D3DBBDBE79A667A8846946096457322F64CED32D1E
              66E5F52C69165E186D2C7768B8EBABEFD993E1F11921B4AFC20A9413A5928E5E
              9EC9A194E742AC72A2B631D06B446DC30174A4A78C8BA5126F5DCA2EF7F17C25
              4BC0F608A7C05261373E44F81BF921AE1F68691F2F3A9D2E7298C7526FCBE7A8
              0B47A7923984ED4E2B927B2D6C239D503A57A1A06B1C5757718CA5E10AC625C1
              A7FD751BEC9C8B64C856AD5AAB66CBCD1D530FE0EF6D2B27BE9D1EF1045BBD8B
              25605C263141B5AEAC8BD27DFEC813EF641169A39AA754AD6E384C70993B3936
              3C61628D96E8DB6867410C234147AF541AB5591735218531AA14EA0B4FE07D4F
              1DC5851754E160FD0CEC60979E4C0F522521348B121C2BDE11FE66B2A975E5C4
              7740D9BB582F9E20B25FBBEE4445C879FCB2892508163713F87F049E9F72AE68
              A23F0DA5631C936B96DF4AFAEB388167881F6B970157D5E386ED8D98E1B506A8
              845D7FFA18BE4BCF49A7A984A851028E3B76BC33FC8D5453EBAABA9BE953FFCD
              A601EB7C592E649D179113079576D7795F91F33F8B22FADF896123448BD34351
              4EF81AC2571BF872E82BEB71A3C07396688BAB3BEBDD175B3175423D6E65F792
              6818F17416353C5F6B39DD63F4ED288FA59B36B24E827AB02ACC1105489213C8
              B6CAD57B7A64CE17D5ED69794EC390B611A505CB0859C5B95D1D0EA1D4AE847B
              D55ADCF86423AE157819A4AB61F3C0A222DC3FB761CA84B5B88D5728899620CE
              2049A5E92AD70E55C5D73475B2CB76EF578C5C2A0A389B258095A5AEA8A26FE5
              9CE78C27509C10152C358E460DD7BE31AE83D895DFC7B2C0F2FEA079E80915D1
              57092EA22511C4A9BC4AB62ED33311A166F7FACDA5FBD9A200995F418657D475
              DEC02BE2DB48F0D3CC7942D5A673A85051847FB41FE369796FCE8B8F14C007E2
              2BC111254CD9C00533C4694446ADF518D42206ED76074D59E2A28042093C61D4
              457F8AF062FB502F3C2D378E83AF4894B3866BFDE24968FCD27BF11DD39EA0E2
              0572DC5F644A485D4333DEFFAD67318131C3CD388C2511F10073ADBCF4574051
              8473DE62580AF36F8244B24CC952574BC232AB1CEA8AF558F6F1CDB882AAC9DE
              3B1BBFBBE3BD8CF4D28F1E703225F81E82D634ADCE2C46DAD2E63CABD9A5578A
              AE007D33C720760FD14DC5F202EF784B9DC5A5EE6A06BC1D0C78EBF662D9AD8F
              E17271DCFB6661E717A79E5C093205C443C69762FF9D17E14FCC0D4325361320
              173926D3C17437525405E8CFF0F739B7C5ED49D00BAFB8D455405FCD757EDB11
              CC24A119F477F660F9AD9BF021C1BD7F3676D213BCE950A004F675650AD4C671
              64CB023C182B45AA27878CAD5492118EF35F39D22E90A22940DFC2DF16DBDBB4
              FC00F0D7ACC5870D3C9B16CE7751C26DBE12E8097DA6031B719F03AB3686C61D
              8BF0CD0967A3A5BB0BD94808AFD1F2EDEA112AE04CF000E3F66277C559AD7BE1
              69C63CFCD6239865E0833E05567ED053C2077D25E4A703E14362F9ED023F1E2D
              C90E38B110DA789156EE12DBA58D46911560025E84F00C7812ED79CAE4F6021F
              22FCF4FA13E079E8493F25AC089470FF3C3C737B1DBEF7D6045EA1DB7FEB3DE7
              E078B21D4E2284165EA485CD5B5D44BAA41F2FE15FD693515580FE571FDE9FF3
              1CBC496F093536C40C8FF04B7F797860F84078BE8F12FEED27B88C11C2FAF655
              D8F9B79B706FDD5968CEB4239B087BFB00366BE6553A1C95905DA048711460E0
              99DB8BE5059E10E2F6B5FC2C13F86BE9F6849FFD7AF081142AE181DDF8E46737
              E10328414F8F836CB61BDD6627081C63A366FE5EBBB291E971CAFB04BF404645
              01C6ED059E195EE15267DC9EF033D662E9965384CF8BBFCED3CDDB27D5A0895B
              3709805D21DBC037B1AA999ED1AE2CA4F17B38B9B8C4DA1365C415A0978BCD19
              F204DEB3BCE7F605F04F1C363BD25386675F978D2D817F7416FEE3E397E2C5EE
              24B2511B2D9CE1C7798116717B960CF6C0553BA82CB96932808CA8028CDB9711
              3E27B938E199D7E772BD6E3FB31ED707F05E8FC1C13F3C135F9F5987435D4D50
              8CF68CF40C7ADEADBC2EAEF619FC86F0DBFC6B07BFD04F464C0126B72FA1DEB9
              AB33F0747BE6F6351C87B1BCC03F7E0873A5A9D76370F01B093F7B0A5EE96A81
              2E8D105EA2BDF6E079A51EF500E1FF7032EC5E191105982447E05DBABDC02BC2
              33E2D34263C3557067ADC392E1C2CF11F866B92968E07984567A58A7CA31E5DD
              FDC6E0819C7605F8FB792FDAFB01CF585E7BF0B309FF8B8390DB7083868F13FE
              7F67620DE10F16C01FE7959A19633AA8F40C0EFB73FE14E5B42A40AFE0F5BCF4
              56929C0A92D5C89D1C8EC683AFC7E29F0F037EE30CAC99DBD7F279785A3F8D6D
              70D4CF4E1D5EE4B429C0B87DCCB73CF7F01C4630E7CBC2D570E7AC33F0F3A5A9
              D763909617F87FC9C34B86779C5768E12F76A810E19F237CC3E0E0454E8B02FC
              FDBC97E17996AFCD719DE7200DFCDC7A2CFAD9D0E13B047E5E21BCACF116E16D
              AEF32EE17F47F8DF0E1E5E64D80AC8A7B7B2DAD3F206BEC0F273D761D1E68358
              E0B5363228F81FCEC0D709FF723FCB7B199EE35BFED7438317199602F2373302
              B7F7E1999119F879EBB070F32B797819E4E0E0AFC59AF984EF2C84F7921CCFF2
              7B08FFCCD0E14586AC0093E1C952C72DADC0079617F808E1E7AFC7C29FBE82EB
              82E62C8382DF20F0537180F06A4C6FC0F3DC5E02DE6F093F88687F321992028C
              DBC709DF1BED4F80FFC9CB1E3CEB0605CF8CCEC02F08E0BD2DAD6779064313F0
              98DBABE7860F2F326805980C2F0878FDDC5EE017ACC77585F06C3374782FE079
              F06279D9D83C3FBC39DF5F06A5006379717B6EC204DE589ED1DE8777AE23FCA6
              97B150DA0E01BEF3A1E958735D217CE0F632E7E55FDB62F9D3E0F68572CA0A30
              199EBF9FE7807ADD9ED15E2C2FF03F1E26FCC28B7080D1BED7ED055EDC5E11BE
              E1F4C38B9C9202F427D8CEBF81C9AF79B777C4F23570173E8405845F246D8702
              BFDE83DFDFC905CE5FE77BDD7E842C1FC81B2A40DFC43641C093DB5801BC8BB2
              921A388BD663FEFF1F181EFC221FBE8FE5659D97392F4BDD699CF3FD656005F8
              08B4BC32498E77EBBAD7F2025F6BE017FCE800164BDBA1C0AFBBA600DEB37C73
              DEED057E17E1B78F1CBCC8C00AE0C4D67308530A5B9720AA2D9493CC6C6C02F8
              C50F61FE70E1175F5C002F9B1AC9F082682FF0BF1A5978910115A07AA881711C
              8ED8DFC1180EA38A91BE8A83346EBF84F0FFB71F4B049C85558382EFAABF06FF
              B958025E2FBC77F736707B0978A3002F32A0022CD5A3E45F8AA493A733CA78AA
              82D62F0B9703D76FC0BCC7082FED049C25FF5F9B9349001FB50DFC9A2517E32F
              055B5A1EF973DE26BCACF323ECF68532A002EC5CB7585FD67B89FA63D20EC646
              B89FBFEDA798F6E87EF3289D91B111B448DA2A8AF04F9D207978B13C039EC0FB
              D1DE4B6F2DDFEDC3BEE54730E00D24032B4065C4B26162C55C1789B0A43FDD88
              32C39B26F5651134AFB90CDF38B81C5F79E123B86BE9F97864202FE86FF9EB7D
              78BA7D2B1B7BF06279D9D8FC86F0C10DCC519481A78095B1091FE170E4F19278
              880BE0A6BD18DF94C239523FFB3C6CFBFC123C575682DC7995486DBC053F9E7B
              9E79D24C5CC1FCEFAD107E6D7FF8C2392F5BDA1708FFECE8C38B0CAC00272B0A
              90272A6339794A2B01F7E17D780F95110959E859FA2EEC4523C6F0BB4A67E8C0
              AFA2F49649D8652BB0B9F7884A00FF0306BCA597E4E17B035EB0AB7B7174E77C
              7FE9AF00339795938BD08E318E2A4188303A11DDD9843AA93BAB140767BF1B7F
              73320811549358F12AF22F6C9936343C3497059BFD9202FFE14BB0AFC0F2B2CE
              7B9697F4F629C26F2D1EBCC8801EA02CA78435892CDDDFA6FBFFFC259CF5D72E
              9C277517BF85B95914B9EE1CAC303F4BAB914435BABFDD804B045C94E0C3AFE9
              07DF6B7989F6E2F6A770DF7EA4A59F0264591737D0E2FE71263D51AE037AC39F
              71A1B83F5D3CFBE90B19ABC7A2A7B40CE9E71B51294F6C5C702F3EBFF508AE95
              BE02FFFDABFBC0F7757BC9ED9F26FC96A2C11BC6404401F27645A08852F3576B
              7940311E11F7EF42C9B3AF62B29CE6E627BCFA394CFBEC065CF1EEEFE2F60F3E
              86BBE4898DBD6D98C2BA90CCF9EF11FE86F7F5737B810FB6B462F99D45B5BCEC
              69440CBBFC696409B4329129B03C7F1FA5FB4743B4FE2FF6E16D47939EFBB391
              7EB211D3FFAB0137EDFB3BEAD2394F61D531FCF5B2B3B0F5D159B8EFC68BB02F
              497BE72D2F0A08DC7E37E18BB0D4F5930BFD4F616E1405C87B35BEA82BB3EF8C
              BFC5D28E95735509F1DC8D2FE1024E85305BF749796B62387AC5D978FC8169B8
              FFD072DCFDEB5BF083391370B0BB0D39F37082B7A5F5E083DCFEC9E2C0B7AE9A
              ACAAEE6970DA564E92C7E4AFF2CE1A795A14B0D93B360F479F9B8C9E7B037A90
              8A842D71FFC88EA3B8582A39724B2C7DE53978FCC1CB71DF9115B87BFBCD58FF
              99CBB027114157EA55E84C129DCCF58FB16D133B1C27B8770F4FDC7E9472FB93
              88F9E7B856D6C7F8F10E96E029F8CDAAE5CE4951655985EF0BBC16491D5E511A
              69EBDCF2923575F956F793FF5C8197969C8F864F5C80C3E11A2E8AF2B04917AC
              540F725C0A33211BDD0C90292226E9231DACEDE03297E4CFF498757E846E66BC
              9188E5F91192C7FE5B574E3E9763FB03BFE7DF17E0549F685C9A0DFBBE31A2DD
              23E53D87BE72ACB9BD636C1C6589B75929DA91218ED05902119AE971CA524A02
              688AABBF94B47655B75676B71B8A647256692E9B2E759D44DC7B38A1082A10B7
              97CF965593CF25E8161E9EF8C6C800EF0CC9FB41251C7167CC69AF8F651A7FD5
              9DCC75DAECC855411E34EE264C8A8952924A49E118D2EA71D3E78C939655934A
              98A57D9487F7B388E54F7C6728FFD6D81D9322A1B025AF9CE4DF1A93244F69A7
              C9D2D9E71918FF42A570E767DECCCA325BCAB29E71C3E20AC8ED8C79664792C1
              E2B87B3F91A54EA2BD04BCD77F6B4C6A687DF32261CBE7264454A244A682B9D3
              4391C04807CE077FCA99C0372879FDF706FD0AB4DE4525DC1DBC395AB78CD06F
              963747071259DD0AAD768045DE1C15E3E60D2EC7858DA8843AE5BA51D4ACDEA9
              DBBE3431A66D7B3A5BBCE9DF1DD6AEBBA5FA6B7B06787718F80790D2C4A5DCE3
              4DC40000000049454E44AE426082}
          end>
      end
      item
        Name = 'Load'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000050349444154484B8D566B
              6C145514FE666677BBDD164AD95A901083918205A42F2841253E428456898FA4
              26F8E007C612FE484C781809C440305112113498A021068D62A2018DB1A2C557
              4CD51003E161A0DA076D2D60296CB7DDA5BBD399EB77EECC6E9F51BEE4ECB973
              CFB9E7BBE7DC3377D600D1BBAD620AD5CB94F5943C8A4BC9407C942F63A1D78F
              81494950DEA1BC1ADD793266F8045F51E650F6525A28E23832A8B26D37E0BA4A
              E635A969994E30603A1C8E2492B16CF00ECA064A33A556485EE7602DA586AC27
              A8C741AD4511CA3015F9246758589438D2F81E978C2F70433B8D01E32EA66AA0
              1C14927E0E76936007C7218E250C822A659C74CBDDF9F12385D1486AE9BA636A
              F59F7D989663C14E0D2154760B5AF7D49AEF5FE8C83F9553523D5898EC361C33
              94C9DE62BC34E36DE77853803F11CA5F62211C1A3589873FD055CF7D4F81D9D0
              8A259DFDBA0C1A571228C024E783BEBE3E6BC9D66F47ACD159F8231D37223596
              1A4A012684E9573C3780A4E8808194E87000835C6904273AFA61485C377B9032
              3311320647791B717DAD946E0ED1FF05B11ADA9118E7AAB67BEDC99F8CF6901D
              786B0CFF59BD30C2320CED932119076387E7104B51B3A0E37621749CEF1EF0C9
              F64DE4E2610C89E7D75A07436D4144ED42B4B490AD1B80C56D8E0DE2B270A195
              B351AC5EC354B511B9FEFC388C22B1545AA77CFB2CE4C7FBB1B8A9153567D258
              141B44C1A8F6216C0523D68FE2730A4B7F6946CD8D415492486E0BC6498D2A9D
              B470167C8DB5B68710B60328DE7C14F5CD31CC622725D8B2B7892D73F02DD7B0
              A06C2FB6266C14544CC3D96F9EC45BB138E43D4BA8CC41F9C864A26755FF65EB
              F7C79177BE93EF4B14ED75653896B431B9338E3BD34EB61CDA777008933AE228
              7559B43555386684F177CB15A8534F2062247ABCDDFABEA3BAABD0BA36AF7229
              AAEE9A8FD2BE2ED81B56E1BB6DF762BF6442B3ECCF3B649D108CC9215CDBFD10
              F63E7B3F7E8E5F865155CEECAAB1A8C0E89D2B7E84F6D7248E32947A1739E7AF
              BA150FBC8D6D9B1BF054C174E43737E1CA965A343E5F860FE928818549B41934
              917AB11A079FBB0F3FB59D404F4E218AD61FC1DA9A03D87429A916AA971096B8
              5912BDFA6E185D03C8FBA103CB1B2F62212623E85AE83D7B066DFBEA7074D56C
              7C4E2F495F2F5C331F875F790C0D4DBFA26D661106EC10728F77A0B2B11D2BAE
              DB2A8F975598718749346240C882CB5E55D436AF499570E12C3A848B573BD172
              F4191CAA9A8E1FF9865BCB67E1CBF79EC6276DE7D17ACFA7E8E6850993E14226
              D2BC4093BC7AFCAD781826E15131804176111343EC3C1791FD0F23F8DB45FCC3
              8BBD7DCF4A7CBC7A1E3E7AA3069FA1175DA72FA3F7CDE50827D2080F3AB0F86E
              9AB2565F35C391BD16D62D4003EBADBF40418B2167205465A2B42AC4B145EB0D
              449695E0FAB26A96AD97CF01441F7D90EF85C3E52EC2D27BAC425ABA43E2C86D
              40E89C8444D8153F4226DBD4E2ADEB9EEBC182255BB1D17611CC7A8AF047EFC5
              DB8C4C8949A048E0B4C63087134EDA35B82DFD15152A534812A6A14A8C15481E
              AF33ADA9B96E72C046F1E91EDCAAC38C808EE8338E31E9FE26DC68043D4ABA6A
              26FACC7655C2B964F6F36BB9AA56759F4A365C4739AF10397CBF37FE1F3A2592
              F05CCC5CEEFF91429C484DAF9CE49AEA6B9AF4E737F34762AEA9EC03A180DDCD
              6592E14D528C82147228ED0467B846B09ECF1728B53A499F48FE12AD63DDF319
              DDA541DB6E86C9AB94F695B33299D5001F0F507645779E8CFD0BFAC1F8D23B36
              A1B60000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000006A4494441545847B55769
              6C545514FEDE7BB3B4B49DE974665A96B2B5740A148A55316ADC8846A3448C46
              C50812904540A3188D26107F1015138DCB0FC4DD6834C6DD68DC4D5CD0444571
              501B42D562595ADA690B332D339DEDBDEB77EFCCB433B48531C6937C73EFBC7B
              DE39DF3BF7DC73EFD5FAEF6B31BCF7074DB63500361137115388FF433A895788
              27E8B347FAD6E453764E63F3013195D84FB412163196882CC612694FD91C4374
              621E51471C229690C41E19816AFEF98998466C205EE2409CED98226E45494718
              25220D1B2D2A67A680D01D48CE7023A63D89B4521C43E8AB84CD4AE229E220B1
              501278909DCDC4063A7E9AAD541CFE0A5DA460D2BA2715D244ACCB676822003F
              CA61A77391FD5AD94B2025FA108266B4475367C6D2DE4108CB06A1C90FCF08ED
              ABC8D1FE7A3692C436494032491173A990E07F9DED70F80736D76BAE6DEDA263
              B5DD36DD956E88A6C5E96BBEC0E29E182A19025332489AB03778D0F9EC6578CF
              8C6BC18F7AFD5DE7D457C341F295DBDA86A72B679BAD937FF71276F95010EF66
              15C69B3FB4AD8053DC8596BE5B71B3CB813E3ECAE582426D05DAC4665C93BE0D
              F56FADC8FBEC1324E743FA94BE738A66B61D57EC196ABA6C4A6C8866FF98849A
              733E937923EDE9934A863FFA64A27CE6088CFBE539C99A548D2532EF09B612D9
              7EC60635CCA4EA9D4A947E8E40519429A7242A452B4A2BE33347E094529CCD8C
              A8792A528A26C010172DE95366D488144560E85E6836479141D0A0F99DD0A3B7
              14A77F5202D61DB05BB7C39B0863064BD84C26973765C2961D2E1019A0640ACE
              A11426FA2CD4A5354C139BE0E1FB63EAE7641481C8968062CE922BC7FCFC5DE0
              AE4553F54C048C8970D7F89160928DDA27B8AB988E4948954F464D751D1A5D93
              309F25BA9915C12B3664A211D9D2382A2A05EC3459E02DB5C4B12F0C63762D3C
              FB42A85BF736AE8BA5E1B4EB48A7B9EC0693A8923AFCEA6183DD51D49EFD28D6
              6A5C8E090B0E7F29C2AF5F81D73D4E1CF9ED982A5CA621A2DC3764111C918208
              A46C15287BA853A55B7525ACC101C4674F41685A0542BBBB71E10F5DB8F8E723
              58144F732F18114582A47C3F76E212A913ECC6F9737D38E0A9C2B17014319F27
              13B1F26D878569C8FD68440A087807F7E9C93BF4B2432BE18F1E878FB57E2819
              41DFABABF0CEE23ABC27757295EF44210BC1A951F9BFAE192F3CBE149FC7FA71
              D46E433A154575E72AF8CC4DFA04D7D1F682692820205211975DB7E6D43660DE
              D439682A2D451D97DF60F210C21F2EC39BCD7E7CCF2A681B2B07C84050D7B864
              3A3E7AE67A7C7C7C3FC27603F1B27204A637A169721DE6EBB002862D921FBD42
              0236BB553590C0AC7BDEC7351BDFC0D2DF7BD1E42C83339AE4DE1D43FF3737E2
              F9A92E6E3ACC837C12B22F9F31ECBBBE588ED7CC10FA988087ED65A8F8AA03A7
              AF7D0D376EFD148BB932EA0D61FAB2AF2929200027EC7D71946DFF05AB9E0A62
              DDB7DD98C4D976C49208F70FA2BDB20C5DEF5F85279958A11C899CF329E5F8EB
              CB1BF02CCF05DD0349FC49D209B850F2C1DFA87FFE57ACDE11C475091DA5F4E2
              5A9497BC85043820CB28B33D2EE794396031D575EEF796D78DC33DBDE868A947
              FB631763077512D2B184DB81FEB79760470D754211B47B2AD0ABAC714A380D2A
              526C135C21D29FB1D62F9F64E4440239A12E9129BF821684F6089235E538D0DB
              85CE95E761F7A68550A727AEFFD4C38BB0FDECD968EB09E140B51B47A89B4B54
              9917D94EF6AB992B89E3AAA7643C024AD44B268C044F3C1F5F0DDBAE4E9E8074
              1C3CDA81FE879760E7B58D786355335E5E7711823D0711D20D74EDDC0FF1F5F5
              B0B316D8F8AE9E5F2B72927F5C392901278F7434533EB71A332E9F8DC059F598
              E5ABC4E4AA4A1AED87E3ADA5F8E4B92BF11D4F828E1A2F0C7F25A65ED088860B
              EBD130D3CD13B64315AF512BC6C82B7FE31290B4999025DD3D98B2E718CE68ED
              C1B9AD2185735AFB306F6F04DED6C370B776C1BD7700FED65E34AB31A943DDE0
              31CC8FF4C01F4E9286B49717870915CABC9A9C1C1783502A5CE74A64B37527D6
              3FF0AD3C758F0E6331C297AC94C810A05D9957CA70554076944F1501794958D0
              BAB1AE94932EF50CB912A4C7A1342A65893DCE5DF044709915602C1DBEEB4FA6
              51A11C49368A8388CF583053D66379193A347C2FE0C806EF8FC11763015CF14A
              3B9AB9F9D8B90C15E9FF2A490BBACF89A165B310B43D83CFFAEF6E59433E7215
              A97BC1C8CD4898B77B627F7CAE79E2F2F871D27DFC5F4B9A07A570693C521EB8
              94CB603B9F646E46728C24F2EE8662BF65596DF239FB72FCBF468136346548D3
              F546FE8EBA1BE6DF8EEF249613FFE7EDF855E271FAE4EDB8C5F807956AB31FC7
              41D1230000000049454E44AE426082}
          end>
      end
      item
        Name = 'Delete'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000002B449444154484BBD56CF
              6B1341149ED9DDA426BD182311FA43A43F44858205E9C183F42082C583207AD0
              620D885E140A56104AAB183C55A150103D8854A8FA07887AE8C99B3F300751A8
              9893AD9A983435694C93DD99F17B93A444144C368D8F7C3B6F6667BEEFED7BB3
              B3E10C969AE80FA01907CE03AD8004F4BD3A4D01069003EE02378291689A4360
              333ACF809DC03410034C8016D46B149800BA8151E023709844A6E0848121A8BE
              42BB2106DE01344F81FB249285330581EBF0BDF0299246CD045F117C93F0C748
              510027E90E5A4A53C356E1215EE2A7225191F520170537C5FEC3B85CE7D1FC74
              A1015D64B3AD9B041B3633D455CDC3A9260E9C11E4706EFE58A8359E4C482139
              94DD6C2E848E90DBDBB619838FE339709FC2D02C89D8E00B6F49449F63E3F530
              BF29986AE03521958C34D927B6B0DCDE3F84C1599E848829D62EE6B389D8E487
              CE0BDF326B1E8F6948E5E2410CAE5451306B47A02537D3F7FE56AA65D71E6E5A
              77B48825B2973EE77D8B07E77E3C8A27BE7839A271FB262AA95857E7F6955858
              9C48167CBDDCEB9FA6C29329042F2DEE1418731857B660D256802CB7FF829EA7
              D761BD873B7990A852A84A6FB192618CF34A970A4FDB023F3835801ABD4E5FA9
              5795EF75118557C516C2221F05313105B1D401CCA775B4DE16CA6294F3B2956B
              B23AFAF5275B3AFEC4BABDF43DE5B72CC3A1272BCFA9C9286E3C81726C69F576
              84D22F8F26CEA6E4D61EEED934A3B7B0219D73BE9577D11772F78155612913B1
              51F64ACB6B3768281BD7A0515483C6C2FC7260EF00BAF7CA2F233F1D8CBC7DA8
              AEB10E644DBADA5A64B48E0A50C46E8EB04570D399F8800E310718A6396387CE
              6CC801397E64A472400E133FE9EA74D2E0D5FDAFEB4ED1DFECCABE37151E6A15
              8910F437A4E878DC26EA37ABE2215E836A928173B3891FADCB24F25F3EBFCDFF
              23810BA936F12F5134FD0BC25972943B11A4F10000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000355494441545847C5575B
              485441189E99B3EE7157EDE86E686104DA0D2A90A57AE9F2D65B6144D94B10D8
              9B41600F492A3D45DA534A44F5100441141812BE5944CFD9C39A54D045E9AE64
              5AAEEECD3D3BD3F7CFD9B39AD54B9E753FF8CECC9C33FB7FDFCCFC33670F9F3A
              1F31C217A259946B186367C0E3602D58087C01EF803DD09C206D4E775189A018
              00D78163E04B5082F45C81CB811B4380DBC07AF033D80813519A816A349E81EB
              C153E02D3C48A1F41CD02A45D10C5E033F82BBC840172AEDE029085F47491DF5
              CC780DC4D7B389F82D28C8443719202719702B3AA4D1162869FA3D871B1BA589
              E62BD0473715D89FEB5090912F86AB419AA44D8941C8E6CA9584D6740D68575C
              D96CA66373C166816273951FABD6710D385B4D716675BD59EEB6FB2774EC85E8
              BA46494895FB488EA61FA7EBB9F2CF0961A56982BC352230F8391F13194B5ABD
              A394777DB87B346F2034183D96DDE3AB4924ED72EAEE4C9087800A174C064D5F
              CCE8B1BFFD69E07BB48595B29DCC2A0B32C3C4D2B807A11770D4593A29D96C32
              864D3F341D8ADCC483266D0078108E0F9F1B4A6D39D0FA34DC9C88FF3484303C
              5B020C43D9521AE1CAAAF8BDDDA337AA33E30FA72A2397396747B401A9E4C0EA
              D4F3CEC1D91D8D87EE8E5F4CC7BEE67EEA2D42D575899113FEB6DAE4EB475355
              914B307058EF02724817834BE537389D8A9433121D9417A45814D334781A6940
              825A52EBE8EB0238AD1655A854B0E50917C7A4CA222C3500E8BE2B8605038E35
              85938AA60B078692B0E2092996135D52FB3768035A1B92B612226B94F9990870
              555261A89272E10D2B0CC603CC368265599CB60025829675CE01A5FA43B1E1B3
              6372EDFEABEF37EC9D9FCF083AB896AED7FF0289C86CA9B8152849B7D78D3C59
              65C71E63175CC1EDFC41D4179A8C9E6441B69D59CCC4BC88DC9278071A780623
              8FB138B3D98BE9AAC86DDC710E2254F4BB20D91A289F4CC80097F65F92737920
              11217CB226C81325BDA93874F551ECFE21A106FBD07970698E788E89B67D5A83
              3449DB1DA9BE69F13136D3BEB16026663A3671D39CCEB51C4DD7805E71C9FCCC
              EA7EE7F5EAE76175BDC56BC7976B399AAE01832E746E161A8ADE8A0EB426B5E8
              5F7103D6C34422523EE47B780D8A9DD3A07FC50DE027DA0545FF2E28EE97112E
              F4A0A8DF8645FC3A8E18BF00B530E545BE28FBA80000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003D08060000001DD56F
              C1000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000006E4494441546843ED5B5B
              6C1455183EE7CC7476DBD2DD5E11249488C61281B6DB1813127911128C81F0AA
              98201A05C448840711C23684929018E041A3089A608811346A8812138CF85289
              6F6C41208A48221028E95E28BDEFCC9CE3F7CFA5DD76B7F882C9CE6EBFE6EBB9
              4FCEF79FFBEC1CCE72908AC7B8649C35759D57C9782C84C455885E0D2E07E783
              55E0A4324508050E8337C16EF034E7EC4CFDDEC4585FBC830B24377425288F83
              7131102F90203DFF8B70F6802D14F640859CF4004080B90DF527B807FA4E5220
              57AB93C98FE8DB1DD30567C711F512C5032658E17A038B5C0D27A462EB9BF625
              2C5F338787C3A33CF1BF201375F72C685009E006F83378111CA488006016D80A
              AE049B2902F03575C308CF7946E09CC6058D7904BE4422B5FC281806FBC19D9C
              AB63F57B7B282E70C8C46361F4F357E1DD0F46415FDB0934FABABEDD1D981E00
              8827E16400DF4AD7C055C8741D2EA56BE4060DA8BF4D2EEABF10CE19F009D0D7
              B80EE92778BA3316568A5D40C49320815ABE83C4A3208D1D0BFEF159334840FD
              A98175D4DFF48C701EA49E40B80A516D3407AC45E014E84F165B50E03089A782
              08071EBE16B86F22F831E86B5D4BCB05ADF3048AB88188CFDD20B33CB714E06A
              E18AB4D1A4EEAF0A6BC80034EBFB385BD7951881A5B4A076FB42202D8EA6BD3D
              23089E75631D2C2703D00ECF174B4B5DA9C3D7489AE79301687BEBEFF0863CB7
              94E16B24CD556480B2C68C013CB76C316300CF2D5B143640EE49BA54308D26DA
              0AD37A4887063AF06CC4A6E1D3F4BB6D5AFDFB176CF52C8ACD43EC22B8B483A6
              FD54B11B87D49012DAF25C45A81755FE89A9D44E6C84F6276CE87D0329474147
              7341030CEE5850516DFEA3B0520A88D65808B27DE1FE96A998E1D7358BDA6AD0
              26983DC0178AC881EB741E9864808243C0B032068A56E341B54C670D304213B2
              CFF6F8080C33BB28E9D78DEA69A2CE82D5231C05AB4222A37BF226614A0F509B
              1BBA7A8ED8DB8CB94265AB15E33552F14AA4E9397D2028A09D9EA529398C9AF7
              DB5A78503F389A84DE8D883F02E60F01AEEC2D755F5D3CAA56EB8BB8B2EA5130
              82C78440CD3140904C20D187690073E72D505A0A3DA91DB2FE4EC5DB37A1DD3F
              415CBE018432DFAEBD71E9B86AD05A618C065BF1881D6E0A697A48281AFC4118
              FF3E3867F6D87DDB30FB87E1CD28AEDDE597ED4B99675A5F879FDE094C3580D2
              8434DFA94D5E3E99AD346286C8CEFA7178D9E25D575AB69803776C2E74D2FF50
              FB003DECFFB0299EAB2CA9F439B31F4D7FBFF8D4C1884C262DA627F57E2B9199
              B77483E2FA87C8966F004D66B7475357BE1E0B191D2191ADFC36FB42EC95EF6E
              BF3774A7879E1B383CB6F4F9810B6BAEEDA819B896B2343DA50F5A897B7396BC
              2C79C50748767BBD93731C8AC6B9F0C8059352D79C4657820B245286E2A7E0DC
              39DEEB826539CD85A407625D97B24C207F19A4E4892C5CB97D94630E00C90D06
              9D5A3BAEF3E6DB25990089B928B80F28714C342F508E0698841903786ED962C6
              009E5BB62847034C5A08F30D40C93959B8FB03320E86D808C11F14BAA065DF11
              E32AA2FF9316C13C03600F31F147EA95B4E8D76424481B9B2244078052BABFF3
              484987419CE35CE9129B5F4A708DE161EA59605B347DE5A47716A8FA6664656C
              EBB9C8AEA1BEAB4CE8C694A2450CB4B265D96CC1E3ED9973CBCEEE8A666FF559
              BC22A90F9889CCDC25EB15AF287418728EC35B6B6F5FFA4246F436C1ADFA5EB3
              B6F157FBE9665DE8786450D4BBA0B779867DDF5C15FAED7A05976989E3B0B865
              FF9E69697D0DC7E18F9025DF005CD96FD59DBFF8996AD19E624A366204D4C09A
              346AE87DE194D153E4C068408DA9D3D3ABDC8C127A9F3864FD918EB76D564C1C
              465CBE0150CA7B2556D12C9819918A474CA557229EDEA7056DC5906831D3E016
              FD187A4F6AA17EEDE0586F2ADEBE116D59F89518B8A9A12B71D4DC5E1DD5E590
              010B8661C79097160C03503F75472B4D7836FCA3881B36F59AAC716060107A1F
              F856D8296AEAD111F8FAC114781751BD78C81DF88B9F12648EBF17BC8B7A9386
              4153449DE56C2A0AB6EAA8D668E311263360BD7E36843E308807D13782AE5BCC
              A43A6AA0010EB061F8C7D85FCC1C130DD4E279983A049C1F46529DF43989FB89
              59A9C0D7F45F43C0853B864A0BD3680ADACCFED0316300CF2D5BCC1800A4DB15
              BE21AA3DB794E16B74B4D33FBA5AE2EFF3E91BFB5287AF9134DF2403743B4117
              2B529DED95D80BD07A19ACC3CF03405A4853261EA39FFA57B8B10EBAC9003FB8
              7EE70BEA66A6F80637C80A7E501050385A7038206D7483C4FF0AFE344FC66361
              347559DE17E09CB539DD1C89E57B6384EECD34ED9BFECE10C6C8B1BAAE4420EF
              0CA53BDBC34AF1E9EF0CC53B381D86CAFBD618A5C053BEF706BD84712378FEF2
              BA39EA0309E37787D39DB19052A571771811671ABB0ADD1D66EC5F734DAC7DCE
              862CAD0000000049454E44AE426082}
          end>
      end
      item
        Name = 'add'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000004C049444154484B9D565B
              689C4514FE66FE7F37CD6537C9DAD4A40D693117F1F6102C943EB43E89B650F1
              A18828625B0BB520442A88508281E88BA23420459F145FC49207DF622F0FDA08
              52AC848AF6626E6D4869B066539326D9DDFF327E67F6FF77FF2DC5821F7C3BF3
              9F3973CECC9933675681581CECCFB1394E1E211BC890B463114CC424E2F17BF5
              34B9467E417EF8D0F0445ED1412B3FC6C81EF20439433A64645499200C75E019
              B7C61CE1B8CA77B4E6824CD261403E42BE4D4E917BC4C9C7EC1C900F7ABDC8B6
              06F4A431842E746243653F624AB3378F02DEC71C3FA3055541BBDBD9C8E2BF12
              27CBEC7C44071FB09F663F50C6572A9DC2E8F9BC3AFCDC7CCFC899E095EFFEC4
              2EADE073DC2234705FECC3F8C0B3CE375F9FDB3CB96F579B41A104A35D71E8D0
              5E89F606D97FD7E54F23394D0A020ECA762DFA00F7F02104E337D1F9C30D3C13
              892B686BC2F5818DBEFEE5D29C7AFDCC9C1789651751CF86AB410E490E595AB8
              A660636B8E29DB6E95257850F52E4A8E4248A9CFDD04511B8A5CC6B764CBA715
              CF8BED10D6BE351EE38ADF230EA13E3536C6677D2E80B1676834059A52877D47
              5A528B5CCC9F9AB4875D9977D97BD4DA89113BB1839B16CF355F3D80966B07C9
              37D072762F72584203A7C62B13585D8195AFA0FEC43EE4AE1E2ACF93F9EDF9D3
              2DB18AFC4840A4ABCC51E64F47F109A4B9AA9093154CDF168EE71064D3F0ED1A
              C555B5354D2906AB0DB9DDFDD4AA67528853C93AAFE8D0DEEF79F9A6AE645709
              61E9ADC63B7F4CEE1F53C76F2C9B6CDAB14615ED2957A3746B15EDF32BE8A5E9
              1A746630D9D188052F449A21313C11530AE07665D5F2E81E33BCD6FA642F54EA
              A4FA5B9C98E2402A7F79BAE74B75EAF6BA698E6CFC6FB4D5AB7FA60E9A97BCDC
              E3DD507523F64C64F79ADBAC7379B9A4CFECA12C4CB0720E49883CA917DF23B1
              C3BEB52BA86697C4AF0A1B2A69A3FE7D11C9639D58BF8A482199C2AC51B666C9
              6D16B99D78DFC955D4E844F310488ADB51F949A430135BD539F0521A850617AB
              BC6896ECDFE5A9DA30DE0B91CB78427755E6D76978E51B53DE8B6B9D19B79861
              35786F373EFFAB009DE26DB62B0CE0B466B0FEED6FD8717E162F94E79521F376
              6EC3E9979FC2853CEF8A72580968C9E36E1EDE8030A3B0B80477B3E8C93D616E
              BB05358D4B479E7756D0E01B7B7F25DF1791C263C8FC3A8CAEF1593A658A4A6C
              E4B4A5ED6DC1C29BAFE24756A83BD8C81213D096047CCDD1F8C99F45CE65F933
              AA7C19593BD5F7F00766B7CD8C5C9BAA94045E5B77E93374AF95E84C96240E64
              A0DCAA758F57F726D6F60E62662C40294B194BBA19EAEF748626AE7B8B83C61E
              47F2E031FC5AA3D81027969BE4016A4120C590DF927FF675924B27A43C401382
              A7BBCAFA742031088FED6FAE2C54204E8456E8152A2F9C059F4C9A8262B648E6
              485F0AA5E2A14A71B472D193B731096FBD624746B4844BDE63797A39DDD12C33
              8E0A3DA59AEACDC9D17907C5DB6E361DE88CD4B4F24AA3C04167525CA0AF9DAE
              ADAD3A7FB4C7512B7755A853768C147493AB0F7E7EDF41F6C202765ECCA38375
              CC2E51ACF82CA2DB73B8B5A31D3FAB4F20AF6B0D68B7E6F9FDAF3F12ACB592D2
              C5A6941BD449A8AC949EE44C3CCF2D7826BDCA6F098BF817CA6E6BFF48F0E741
              7F89ECBD8A2E570DE41D8C942ABAA4842AF1976822FF2F14BD0077F6A529C500
              00000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000623494441545847C5575B
              6C145518FECFCCECA5DD2D8B2D74CBA584169272B5DB2618125FD1071E883168
              42488C11A5D2474481102349031849F001A3829707A32F0A417D202668E28B4F
              1A5A211631E996D252DA42DBDD6ED9ED4E67E6F8FD6766BA9DEEB6F262F89A6F
              E7CCF9AFE73F979E11E3EFB6E9755DDD369EAB88E830B81FE4F6FF81FBE037E0
              39C4BCCFB105F7A2D18EC78FE01AB00FEC051D90E5129C0FBC2BB30A50AA0B85
              BE0F0DDC026E00EF817B90C475AE40122FBF838D6007F8150433789641769231
              FA8862E62C85B405616C882321B292717A243E22CBEB0E00B1A278BC025E0007
              C11D9CC069348E831D087C114F5654EE85744813262DEFBA25E5613DE658CE06
              AD961AA85AEAA84F30050DA3CC0BCB99A011CDD0FBC4392B9F39B14938224252
              F0E089E05F9508FE0FE2C1499CE104EEA25184B7ADB55DDD26DE352872F92973
              62B370A44D57D282F6D5FD93AC4AC854E7557AF1CF07B421A293E94837095443
              166D0AB7AEA4BE8F77D39599ACE8F96572EDC8CEE63819F0B4FCF42D3FB0F28D
              6718AF3CCD61EE94E0654F6141614BC87650A33C45BB5B6AE93A5ED961195926
              BB684FEE4D6ABE7A4854F4E5C7E0981CDBAD0D559EB3F9803BC9CB3262905A1F
              18B5853E87C96DEE8BB20C55419F6828CA4507E341D9F809B8A594B3943BDE54
              66F8D20125875B0C53BA3618B2C66D45CF8F3F252C141586943BD62438860737
              A66A7A98D5625473A69FCB19C0775F705C55E6C7C6985DAE5FF37EBF34B584F7
              E62290407CEA6F7DA4438F8C765214749F87283A7080A2185D187B2DA05F0198
              10D23053E1AD55AE6DC0D7413DB22C7353F774157C8752EE25AD4AE41A93717B
              737D356D03B7AB678CB6AD5B4EDB13515A0FED28CF826753093C41A178841AD7
              245CDB80AF65F696A83EBD4EEE5371959FD288EAA9CE96B275B840ED43796ABD
              97A794CFA102B50E1669A395A7382AB16815304FC22A500CBA4D6C13F001C277
              1B626CA3A7F0E781CF01095CAE9BED39767B543CBFEB923C9233A9062B1B879B
              B7A83CF04E989EA58469139F686508EB34130F51961763C010B9A14FAF0953EE
              DA5E71765383FC69DC487D80EDB2578D06B510A493663AA43F2C50326BD28AC9
              2225C1FAF99C98A1E462C1192C639DCC023B50F964DFB30E193C4D88A96297CA
              8994396D4323B54F787FF37C2FA4D25D02956CD817CBD8B72A8DBB5D4B6B80DF
              7CA86AB80DC1ED8554B22550D1C63B1F54DB031AAAED4FC11343A9026E7A5C32
              552E6F0A82744BB954BEAADC8BD8A945ACB45CA8B65F0155240BBF5848D5DCC7
              AB16FDEA989DA3BB05A1B928847F34CF27FB62A1695195CDA92011F42BF8DBF0
              52DD4CCFDB8359B1EBB56BF285471676949BB51B0CDA6C60E864DD1CA51456FA
              6A08D88992FBEDDA280D6F4F528F6593E10B3C481B89C50C2A7EF99CF8A13121
              7F1E8FA6CEF236540940E1DBDAB1EE372826DAA94EC6304EBE5E94C0F5B12844
              2B49B69DA4C33D63F42C97D5AB889A2E6EA792F45BF749FA9046A11F2213BF25
              2F9C8C83BF7151A082FC636245DB67E879593960880B34655BDA8DCC1DF157E6
              0EF566EF7A1CA0DE49E6100DE14A293012C3332903CA6BE0B6676487690436B7
              32BE0F907D660644AF6D6B37C42734E599B8230054B126AA5393F968CD40B159
              A48B4D9436D753BAB89AFAFB1C4AEB3AC287DDBBC092800EA66A64CCA0F44C83
              F2D1AF7CB1CF487CE041F533E39EA68A39570146C828D29AF353B2E1A894C9A3
              24EB8F914CBE47CE8ECFDDD51C286965B87249329B23B9EAA4F2E1B0AF247C36
              9CCF39517D6EF00A7E02CA90176BF6444B69E904E1F72F9AC47CC350052FEC7B
              DE0C2A3F7E02AA976FAF8953B7FF6B948B2518C84CBAFB2000F6EDDF90011593
              DFF87EDE8ADD10E66B339E731A7CAD1E3BD2224E75AE8537248F08DC60199424
              DF8615BDD810B02DF68C70F2911A1A796BAB985F51F6CD3126DC5BF1D3E02067
              F135C8DF05AF8217BD6BB33272240E848849EDD9CD148D0ECF60ED9AEFEC94DF
              A7A7E857FCEBE5ADA7F4F884C301A6352728433951081B623A34DB222355D350
              0ACDDD84FDEB3EB2E5581B41F55DF0585F46F2759420442B4412A74115D67AF9
              8789430532E5183D140EF86960461410ABFCCB083F2C78EC6F43E9D8218C5C0F
              48BC54706DB685A6CD5D7B3DF89A3C3D15BF0D9FE0D7719BFE2F97920768BB64
              41CD0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003D08060000001DD56F
              C1000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000BE4494441546843ED5B7D
              8C1C651DFEBD33B3B75F2D777B1FBDB6D7D2126C20810247D01035112284BF14
              4DFC005BF08308A8C10031410D2D8112E31F46234D9482881240312610AB8945
              8C9A1063A2692B94048208A52DEDD1BBBD6B7BDDBDDD9D99D7E77967A6DD8FD9
              BBD9DDABC9159ECB73EFCCBC5FBFAF793F666794D4616ACBB8F2B592910777EB
              C92DE359645E87CB9F003F0AAE0173E05240093C08BE08EE544A760D3EB0A77C
              F4DECB95A5B40C6DDBA35988386500286F21C30F8F3723B90FFC00CF43B092C9
              5F02B0C07AE7BE0EDE0FFD9EE249BDAEA6507461F2DEF114ACF5242E7D8ED781
              1A980A0E972CEA75F88DD6B279F8C13DB54867850385031D2AFF5714FA305805
              FB5803780B7C017C193CC90B1D0006C63D85B4DE1DF38161C6B2618C2241CC9E
              3A4D8C3CB811BC065CCF0B40A4D3DF6184AB422328C5FB82F73C4E7E8DCCCF83
              7360062C82DF564A3F31F8C0DE0A8E7B0235090F1704AD161EF684E92DE369C4
              F9CD38FC3E380846BA3D03A7DF40DD8D50507E1312867E64A5D7C0EB50683F52
              E6DB4CE7055B72459CF2AC4AA7A61DDB2DA52DCFCD89A5734A741A3A3961A985
              10785C294FFBAA82B4E45BA993AECA57AA76C173FBF2C84F661FC8EF3185FCEB
              90EC022F00231D3723FF2955DC3A9E4148BC840B1B40829EBF9CCAA322EF1D17
              C7893DA2EF14074350463C1980BA05D797FEAA2F398C4A0ECE934581160DCFB9
              7DB6941C2533B852447BC790CEA9ED384A8822421C823B909FE14E23EC061909
              C4EBC8BB8463C0F538790E8C068B5B51E1512ACF8A384F0CFD5928B852D23040
              3F38EAFB326AF5C932DC911694B213AA1F3858219E4AE2FB73326B59720457DE
              C5B5631885AAEA9184211022D205E95771FA0818E9FA291AE06738B80524DE44
              AC5F38B06D4F15D7CDE0185E4F04BD098A8E4816828E78BEACB5FB64E49F0765
              ECF9FDB23E65259F426927448D75ED3A79EB436BE4A05795495B615ED772542A
              52520F77361D47BA14B75E96D65ABD8A4BD1C0F8180DC00BBC37884751F0565C
              B391260EB508FA1E78B96246E095276BB23EBF4AF2DFFCAD5CB77DAFDC1694E8
              0C775C263B1EFA8C3C7FF2B094F229331B1D41FBB3EAA71C6D3A43A413524600
              2381788D0B86B560E4694E75DD83434B10E8168657B66D390C7E00E7F41A8F17
              6458564C5D5FE07C8C1F0C598D360798D313221DD9D75A0AC9E56D14529DCEF3
              8D88FC1277AFB3BB20676106650370E00C8D69FED258186C32E5BA45A42375E6
              E0DC80FAAE3B07C58A5A08D3BA063B11BAB9EC69C31C077B5B9534E8D86C80DE
              1189DE89BA4940B123D1175E9524C6E21BE00CA0C5960D3EEC0D8B6F8045142E
              424B938B185D8B6B80E04E3DF3E878126C8F780374A184BE19B5CA60349F6035
              1F1E2D1E381FF8E06878BE08E0428811C6450F8796AF60B1F0F8F4B72E760626
              F779B21C0672D1E132907BA8F996469C5C6CCCD7DA4CAB2B4B3559971B95DCDD
              CFCAC77FB45B6E8735B0E5403B091095BDEB72D9F1C34FCB5FCA1352C93A7200
              1987C0E3D8CEB8724E68E2B85B8E6EA5AC45E4FAA023FE4CFE22BBF083575CE8
              FB65E4FC3C2C61C74640DA99B4D1411F2A6631EF2EC3CAF91C28D88FCD647B0A
              9628BE116B3998C539D7DA8D737A3708D4E4422883E365109BFB8C7E445BC038
              594A6019B264204B0E7F1949A7EDA9D8B9A3D900C643A9B9131978B31F1D8EE0
              74153806E5C8356DA990CF72F03E5840431498EB42D366D7C0EA0F0D603B0D85
              04C1AF6435A41EC3F5783922521605D9B12F61DD9477826D100DF23419C03CBD
              C1C52A3D390AE7AD9973659DA19788E7563C590D0ED5B00546A03A88E5AE0D60
              6E194F6CB495419B057015B836A6DF669E1B1DA30D1A6B85E5D76840B6DADE00
              18616C7DA5384AF905545C8135F98A4C4196670625873409B3E901C980F639FD
              F0C3B0547329B3F5EC0A39077587A5B2BC5F3CB469817D6036A6DF66E60D0764
              3975802E23D0AD1F29A24937EA5C3F082AED7EADB0FFE5A7FC21FB524B7923E5
              9A0CFCEA35390F11E0B026CBB35212A0416B382B734FBF2A97FEEE0DECBB617A
              3490A87E54F693E7CB735FB850FE3D59960C6EE0687E49041F0D641C716FBC40
              FE9B4D49D1D7F6BBD651EFA5E9F336DEA495F3308A043AD71BC0D2B56F0C4CEC
              7BA696B5C65369BFF0C65119DDF8A47CAFEC62305982C0CC71E2E5CDF29DF347
              64A256B18AA993FEEE995517DFE8ABD44F901D370B98FBC3820B3862DA081F7A
              C3589E5E61BA1410C9CA143A30763918F3511D6693C65BA0C90040F4E0AAFEFF
              1205940F9C16CC44746B8BBEAD06609525ADF66940957A4D023334C571AB01CE
              12E5EB10789F68529E6835C0D98918D503BC570CD016EF1B204CDFB378DF0061
              7A1A6D878B258DB6735BAB01CEBE6990D0ED1C1B170141E1A0029792E608A9DF
              157B8829D68D6D3301C3FA4C83FEA9079F0E3539B8D900549E950CB1A352D87F
              9B17A3706C638B6675CC1E628A7563DB5C809495F5293B778500550FD8E490A6
              ED70EDEB8543FB9EF6FAADCB6CCB1F9A2AC9D06D2FC8B5B335C9DAA1559382C2
              A7B19F7F7D5ACE7D654AAE082E253686297BD190FC6BC380BC0D45F8FA4EDB30
              8E8307432C4B4979C735F2A7A1BC4C79AE35691FF7F74E8F6DDC84EDF0A9DD60
              9301BCDB0B7B5FFA85DE605F24DAE303917E1944B7DC1F26113E103028EBC20B
              6352BAEF31F9D803FF903B7011CE496680A8ECD62B65FBFDB7C8DFE410A2D031
              32B287D3BDCC8FC0E7451315C744D913EA4D6FDFF4C5977C492B7B07F25BB7C3
              B8E13CF57BA940E319B47F54FB32C527B2A577C42B1D16BF740464DACCE8FA11
              D1E52322A03D332169D92FF96315F33CB92B1CAFA2EEDB686342B26833052A50
              9BFE1692053243F62A949F822E93D0ED987A4EAA18CC1A22B9690CB04CA61667
              06FF2650F160D691B77329399073401BE4713399E7C84112E50F83C58C2D25E9
              939AD5E1AD530F08E74B4A3CDC4A65B43993B56502E9A1B0AF785928639887B2
              07A0C3213435A12DE80460580B222844EB2008B876BE6482C717D81B0D68F841
              8156535A4F313C00BE83F3221AE2CF2451D87685B0A20F2FF2F7E019B4C75765
              D8477B39A26BDA94E3DBA287C12957E7F8F62830BF010CE6F4307F7CE22B65B3
              50811D17E1CD29DCD501ADBAE3E81CB70B3A2DA22C2D3D8B5EF83656D7DEAF03
              DBE083D59269DB421F5ED867B31C1153207F1671651A329D400BE58A331C3D9C
              5DD8005E36ABD543984FB7A389223ADF0F6506E185D5E0AA188E8173A0678C46
              C55D74C31FB1BAF67E08CEDB6C8346609B6C9BFD548C3CEC374E9E95E071F04D
              A9A91F8B4B5D5C87AFD7B522D600E8F414D4D3181B9F05EF01EF02EF8E21AF3F
              0221839FABD851C4E05F8F081B3ABD447B17FD7D17BC33EC3F8E8F837F30E503
              C46BDAEE720F888C5767C445077F285B242CBE01FE1F588C9125C49230C0990C
              A666039CC9BEBA46CB38D29B940DB56900CE8F9121F892636F588C512F0E143B
              12BDB73744221D8DEEFCC70543D434DFB1EF1E6CA529A6706A4C52BF554D4253
              87FF501B29DB08A6558ABF8C195D23D291CD1FA0B8FCAE26C2B57C9F367CA534
              324A72504C0FFFB106C0EA8D02FB735E306677B29DAEDBCEF2B71C0FE7F43957
              953E96425AFDD2F49418D4853ACD6C19E7BBACFC8822C28B34C0CEE0D8ACB6D6
              6BADF88101D1F96483F919A29A454BCAC2A20537D70747E5E04756CB9FAF5E2B
              7FBC7A8DEC8A785513EBF3589675AE405D2CA835DAE2028BCB6117AD76A47C08
              A30B2CF84524E781D1AA70A79ADC329E81ABDB7E2F803C7730E15BE3FA06F87C
              0CBB40570A385A853DF94A3B8DA0E5BB26A1578185222BE80B9EE726D69B9312
              F6ACD8E3614DAFB1B4ADCA9C7A389911C2286EFBBD006EB54B8C30C8ECFD8B11
              E86557E6545A8EDAA9DA6C5E49AD60093615BE1EA87A924367F4C242CA1BE036
              3051D4674BD9B1D431DC4BD8CEA68AB554BE54F156B85E369DC8000C7BA6A1F2
              F15F8C2CF4CD10EE91270ADBF674F576AEBE09C3550EB44D7B29A89FC800F0AF
              8F3FAEFDCB90E624EEF9D930A72384DF07CCFFCD10143F035F8D9967A9B668CF
              B6B49FC2D8652BAD83E74A2D8F251B10E6F25120A3C0F27C65B9A26CDC4D0ADE
              6CDCCACE03CE15C9BE1A630E0ECEE0778349656E876441330FEA7568FD6E30CC
              386584F0986302BF1C8D0646829A98FC2500CE6EF596FB0FC82F47E9DC065D1B
              CC8B8C53DF0E17B78E6761ADB3E2DB61786ED7F0B6B86F8745FE07B624FD42AC
              4626840000000049454E44AE426082}
          end>
      end
      item
        Name = 'Connect'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000000F0806000000ED734F
              2F000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000001B549444154384F8D93CD
              4A5B511485F7C9F5071BA262A8523A71544107FE7410A3055F40A2E9C8B96FE0
              B00FE053E82B180D0ED5810E74D0A0202AC44907057F101135B6A0B9C76F25B9
              1A43ADAECB629FBDD7DEFBEC7BCFB9CE1A919B6A336FEDE6A0591CEB794A66FE
              1AFFDAB2F9BF95BC1A9E1B2C4F36990F7A587D31E7D2D811D82D099CC38279BF
              4DA363B3F0CCB2AB0F12AA0DF299C042D78B3B81370B47614C521D42B8438345
              26DAC4FE629A876A52E83E11FCC6EA071C836AAC827A2A86E694338ED5B41658
              2ED38633C8D873F843B00CD558058D9496243789DDB799BE33125D026998400A
              7AD8387A3DA4292755A9712EA1C0079AF4635B6AA2767A0DD29443AE1B601557
              8366D80185FF1547887254D34A03AFE3E09C2B50F7B710E5DCC27B4D50227484
              D5077AEF04E55ACD4D0CF786A63F71F69EC4D7116DB24B4D017B1BB3E9FC1F16
              453A2E604F61001BEF404469A7E42E628B965DB9D32B809042BF81308F730815
              FF17A591E3D7CDF913D675EF9C9BE43482CFAC06385F5DE9AF501746B880FA17
              B6B00716947F5B66F55EC2CB8FB69476E63EC60977E275415D32FD8DFAE297EC
              7A65E15DC9BEAFD54EC2EC11F903822C11261ADD0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000036049444154484BAD96C9
              4F544110C6ABDFC836B88CE216092A6A346E71097A32C69B89110C28D193897F
              80F1EFD18B1EF1A213C59337B968E2929868C410015704441818986179CFDFD7
              C35307060D4B25DF546F555F5777BFAA71F62FB9DF586696489A454973566591
              95A16513D29E42E7E8652D9A19B7E6F6696F53424A9378E7C15A5A5B400A5480
              6A965763B18A360E239CDB18FD1C7A98B101B847ACF9E13CB26292B6A3CE2AEA
              2A21D84AAF166C30E7EAD1C7C01EDF37A2311FC510E882E025BA1BD221BC7DB5
              28EAB3E9FE9CB53E8D18F7524C926E62B7014EA36D18D743D0C8E829B0CECF97
              9611D081F376BC756327A21E1BEBC9DAD5D79E28A11F2FE9262270BB58B413E7
              27C075464F02C6BDC8E06F48B449CDEF65FD61BAFDB4B9A780D154C6DA3AFDD1
              1548D28D9C7350EB09CC1DC7F406A33AAED0CF179C958224265D0F0E41A6A31B
              65366F57F68E59DBFB104A895BC33239DDC1E435F4262002CDC7CE1612CD6B9D
              D6CB4EF6DB0BFEFCE321927BE715451DED6DECE2225A7710132C464426BB1AFC
              4CA2DF81BCB5EE1E0ECC252A994E0145721A48FEB7FB8524B63B4D8B4DF36012
              6555905892D0F80EDC7E266B0A6B962DF87107D004E0923A127D687AFBFA1EF4
              107489CB8944F6F2A3975A8EAE1009034E9D7F7D0B4B115D3A0144E581E7B548
              3B58EAEE1712F9C3BFE3AB7136434769624C332B28F237692E9AD271E9B9E5C1
              47A027189FEB5224BE4FF9F9042618C989240B9449DFA23360252483BF376895
              82718E2BCCF9418B7AD1CFB402594E2412FCE0CFB98C853313815D20FF3BD502
              FBC9924768B515A1425E8CC459A2DFFB71D498301CB496F6690D321DE998FA60
              EF42DF068A2E26FA5F549A8F09647767D60FFE7C1998CDC2773B43BBBC2F6F41
              504E2DC810E620A30781D278FC10E692C57DCD0BDAE82DEC3BE87EA6DD6B2D0F
              443A4B2239979AB6AA6A4A6AA031917462AAF4BD19682C763617AA19AFC04D08
              B80B0812E1077303596B135761D11F4937388AA26AB9B2B24AF046A23A826E00
              4A3BCCC535DEBF4A6A873DC7F96BF40FECBE59107EB4CA2F593BFBE277E4C524
              92DBC7C89DB5E56467254BFD915803F8C7E2EBBD528FF2DCA43FD6429D1FC7CB
              28FA3B2F69C8C24CDE2E3D293ADAF924B1A4CF10D53A65E7D57CB52A6ABA1F45
              A13F45FA4BA44CA18F18022AE1CC04CE1FCFBD37C4EC170489133C5F2B83D800
              00000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000048C494441545847B597CB
              73544514C6CFB9F3C830897910019598940BAAA4340B754BA15516A0AE24A1CA
              25E59EB5FF48362ED8B0606109946E7C80CF2A77964AF92AB788068284846432
              EF99E6F7DD7B67221598A4A8B927F5A5FBF6749FEFF4E9D3DDA7DD7693A539B7
              99A39179A960211468193107C10A9451D2C93A7CB7289BE6A11197DD46DB16BE
              ECC4BF0E90C1065C792B675111321FA3EB8459788AD63228813CA37BE3BBA08D
              110D73DFA2DF06F50DDA2AD6AD376DF1F1863CDA808BAFB98D1E66C63ECED7D3
              E000507D2405C66090DB3EEA921AB88F87EE53D6696F6080EA77A9DFB5D0DDB4
              F59B2D7BFF7A50E7FFCB4E032EBD1E596E8219FA7EBE9E03074199991DA27C15
              BC029E077885654844EEAF809BE017C87F42F30A065529EFD0760BDCB34EA56E
              8B5FCB5B7D79D8808F8EB3BA93B838822C88641A65FB213F415D9852B73DC81A
              B88A015FC1700F9A55EAFFD0B662CDCDAABDF74DDF885C5A9A7D8CDB0B874AF1
              4C83BF40CB01EA47C039EAC741CFDD7B11F57D99B14721FF9BC934F956DC342D
              3F52B3B74B1DFB6445FDFA518C33597367B6B17BC334835FA2FE0138A29F9F50
              34161DB1AE2974CEC44B3B31D75BBAD480CBA72889F4C09A07059DCFD1AA99EF
              D5E583443ACE413EC732A03B3C1B73C59C3D03A26291FFD34001A7E83E9B7E0F
              4BA44B3AC799A038A62D1AD16E22062E9FE490296A8B29E814706F529ED28F43
              9683E82620ED06E05CF00D5B9869B0E54A791AC699357BDB26C149909548F724
              5C9AF09815CAB988885740684F6B07BC4849A064263329075C9A7454540C28FA
              CBAC8D3C31AF5E19CB3C5C4CDA75A4171203CC14840A8A5990B56887E94C105F
              6C008791337B57A362206B51ACC1C5CDCAD1C70E08CEFEE45E0B5A82FE0191A1
              88234FECE5580A05217FB0D3A8F379D7FB7B08220E710502B28B07BC033F0985
              D769DC548F8C050EB83C708386B662A00DB82C820CF8573D3296E5984BC94BB0
              A60CD04D554DCB3F41D6F2072073B22DD0C2802EAE70B95E16FD4EA9BB3C2B59
              4B381C2E710679A0C5120419400E1794BD7C1777CD46D00D878B0F841A31F0EE
              174464903B56E950C5C26B94ACD3D06539D6ED5EA35CB52EE9DAE96BEC0249A7
              DD8C1B4D88BD700128CF1B9648173AC37F20E1F196D2F7341F58FC8CBD192FC3
              6DA0ECF63AE579308C73413ACEA73A1503B7C0A62D7C1EEB4E0C906CADE38540
              1A4D0EE7BE4E5DB1B00494DF3FA968EC52A20B9DD2AD54BDBB16CF5EB29D945E
              214F3833DBB67C5EBB01EB5C97052EB35F890F9DDF4AD1073F64B64527EB8FE0
              43C87F4BC8C30D8BC26DF35AD516BEEDBF0F762AFCF404C7737914154A9D0E03
              25AAA3584F866BC780124CB56D7B2F111DAFCA78B4CF7F80F82F4A5E4964411E
              A7E477AC58D9B27706BD0B7A72F18DC8CAE378C09550CA10BD8E4681BCA2ECF6
              99B44D898C448F125E40CC30394774D0E870A30D620FAC7DBD6EA7AF3E442E79
              BC4B2FCCBB8DCDE62D97DF87123DC5B8AAFB6F43E50F5ABE643C970AE452AE68
              17B1D61EB753763A55AB2CB7EDECCF3B9E6592DDD7F4D231B7DC1457752452A5
              523C3A888F2023421243AEFBC4799CC62FE31ADFA0DBB4D646DBCE7CFF48E244
              CC1E00B7A682FEE6003E500000000049454E44AE426082}
          end>
      end
      item
        Name = 'Connecting'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000000F0806000000ED734F
              2F000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000014E49444154384F95D3CD
              2E035114C0F16955A43EBB222C242C9AB2118915E9CA23780456B656BC898D77
              B120AC4AE263212CC452A25542D08EFF7FCC944C3BC1497EB9CDCC3D676EEF3D
              3717A4220C836186526C14CE79C203EA68E67241C81845A70089FD0C53984315
              4B1887734C3EC13ECE70479157C6AF20B9803236514398E1063B5840314E8F0A
              4C6303B77062AB870FF8AE816DF8C1BCC94358C5219C904CEC2579E74AD650CA
              B380112CC2FFECE6F82C2BFAD0C60C9631E664FF4B056EA205BA4E2623E61115
              28C055187F4D363CEEA205DEF1E8937F46132F1678C639DEE00A3A4DF24BD80F
              750B58A98663186E5256B460CE150E50CFC71D758DBD7874A75D8585D27C6757
              EEC215F8F1A891ECC459ACE3086DA47B4097D8420503E6FEBC0B569F44192BB0
              2F26E092EF710A977D01EF827BD67D6C141A64F0167A1B3DAA64A3BD890D7F7F
              DFC620F8042E1BDDFAFB82A6FA0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000029F49444154484BAD963D
              4F14511486675711501435E2178AA228312452A885D11FA0858D9484C2C4CABF
              6369416CA8D4D2444B6B03A8440DD1C468FCE24344565D40599F679CB3595857
              02CB9B3CD91966E6BCF79C7BEFB9E4921A2A95129F35420B6C8366D80C7928C1
              2F9887EF3007C55C2E59E2B74A552659F02DB00BF6C30ED06027B482C61A7C83
              19D0A4001330059A3988B2969964065BE1101C84DDD00367E1386868368EF807
              BC851118064DE41DCC5666B5D2C420C740836EE883736066B564B071B80B8F41
              A35730154665130CCCE0041C81F3701DF68032FD28417CE3BDD7716F0987E03E
              98CD4B98B1744EA2060DFC38FA0360696E80068E2482F9AE44E0B8F6B9EF59C6
              01B80C7BE1303897E98BCA09D5E0285C03CBE68711E87F0AC3184C3F9C018DDA
              48209FCFB2680357CF2570D2C3602DD22032BA0AC6942603C5F26C870BA0561B
              7D2DC57727E134B8BF5AC2C4D5730ADC1BF54813CB6636BDE0624A4D34B0641D
              B009A2B6EB95DF2B2BB31D1A3531B0264EF646CA0A9949434CAEEE31828D541A
              531337D122CCFA07544FA92A65DB91454DECA40BF0067E83AA27AB18A4BBDE26
              5AD444B722BC00BB683D72709A58191BA7B10B9A68F0153EC02350EBCD24BE7B
              0ECFC023A090A781592233D0E821BC06CDDDBD6B910631E83B300D76E4B45CCA
              93ED23783E0C82A661B45A563EF73DCBE4806FC313D060BADC85B970857D82F7
              602D6F8213E7F3984803AD44039FFB9EF5BF050F2006ECA22A0748959D299D60
              93F424BC0217C173BE969C64EB7F0F9E82736BC93D1DD32A2C335118B9533D5B
              E2F8ED025BB7079AF771FCBA3C5DF6A330065FE03398C15C18A82A1395B57FCF
              987DD96F13D876C45E67795D391AFD04E774129CECF94A03F54F138591CF1C75
              DAAEC10CBDB7FE0671925D499AF91F4B55F0BF4A923F70B2C1ED2D676E230000
              000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000355494441545847BD97C9
              8F4C5114875F95D65A9BE759880421243662612161819548AC6D2C24FE1DFF80
              84C44258B1B0100BC186444C218618636EADE96ED5A5CBF73DF7BE54757545A5
              BDEB245F5EBD57C3F99D73CFAD736E25FB8B351A999FE9815E98017D01EFA781
              EFFF8231F809A3015FD72B956C9C6B47EB282038D6C14C9807F3616EB88FCEAB
              A03540117518816F3018F8016308F1336D36A9009CFBC346ABE3A5B00466838E
              15B12C3C9B037E56A79FE11D7C0133109F7D08CF4610A1C8166B13109CF7830E
              56C16230EA0DB01BB681A25C9689F6151EC375B80331136FE13D0C21C2A52AAC
              4540706EA42B600D98F6957008743E1DBAB547700EEE82CBA088D730D02CA210
              10D6DCC875B81E16C0763806463C1533E58AB80866E325BC80C1B81CCD025CF3
              E560AA4DFB4E380156FCBFDA25380B03F00C5EC1770B33AF629C5BD11697A937
              F24D701CCA70AE1D8403300BCCF042B0A08B6D64F48BC0C8157014FC70997604
              B68281BAA4FDD65C3544AF330558ED7BC06528DBDC3587C1AD6B06DCE23D66C0
              3754E503DFD80BA9CC0C6C0103D567AF02DC5AF14F66335888296D17B8E40AE8
              8B0254E45585A9CD02D7B93E73012E81CECDC06A486D16B94B9D3738055884DE
              C4FFFED416FB4921C03F2389D9F81FA69FDCA74E6D93B19DB6348A84A61F7D8E
              2BC01E2E0E1076B3D4A61F3BA43E6B51800FC56691DA9C119C0FF2094A01BE18
              0ED77B90DA1E829D519FA30AA8C19037600FB753A532D7FD06986D45E4022C3E
              05B82ED6C0654865B7C1208D5E7FB52A3DD9A9D5079FC2F51ADC87B2CD19F13C
              381D590766A06E063497C1C2F808BE712ADC976967E0099865FD0C170349C882
              CA9C6A55F71C4E4259DBD269E80A189CB3A19391BBAF6524F3B50DC2917B1D38
              1F6C04674267C4A9984B7A1AAE82C1B8CD1D4C9D8EF3034B21409B20622D3821
              29643FEC0387896ECC1FBF0517E02918B9CE8D5EE7C5F9A04580D62442E7CE6F
              9E0FBCF78CE0A0BA23BC768A6AFEBE5BCBB57D0037C1F3811930F237E0B9C041
              B470AEB509D08288D8B514A2887C82014777B3624B5584756485EBC8FA714B5B
              D4B1DA15E59A7B326A3B274E2A205A98179D8C4DBD0244A7B66E3B5ADC45FEB0
              C47F5553EE3E578CF71E52BB3F1B365BC8868E1C5A74AC20AFDEC7F66D5AF3E6
              02F174AC988E8EFF5896FD06DDA5EEFBBF4B227E0000000049454E44AE426082}
          end>
      end
      item
        Name = 'Disconnect'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000010000000110806000000D4AF2C
              C4000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000016849444154384F95D4BD
              2F83511480F1D74790D2F8987C6B180C160C22DD182D0C0616FE3B894D8C3589
              446A90462466915A484A5A511FD57A9EB6B79AA6869EE497FB3AEF3D27E9BDE7
              D515B544258A622CC31884CFC607DE90A7C0B5118D0614F6B08C63164B58C624
              DCF3841BDCE2018F244BACB5B018096CE30839545AE4718A3D2CA0B75E5E6D30
              851D9C231494F153E773C867B08FB9501C4312C770436B4160AE547F4E6103F1
              6E7A8C60055B3624FCCD8DB3690A73EEA72EDA4412A3263CF1350CA18C76C521
              7C67030F7C1DD5061626D069CC60CC06FD08F7DD49583360832F14CD74180ED7
              A70D0A70383A8D2C5E6CF08A2BBCC3BF3DA4FFC2771EA4879D462E34B8460A86
              9BDA3531176EE90297B0B6FA661ABB48A37970DA4DE21D0E318FDA95F310BE05
              9B9CA0805010147186032CA2CFDAC6D0907038FCFA9C71BFC4554CC03DCFC8D4
              DD234BF29BF5AF41081A39584E671CFE4F708FD7EC6DF99B0B24D86644D12F1B
              0CB01F0DFECAED0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001A0806000000427DF7
              CD000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000002CA49444154484BAD96CB
              6B14411087C72551A3262AF1FDC617F802110FDE0411C4B37741029EFC6FBC8A
              FE01DE040FDE044F8A288207513417DF51936CA2BBC6ACE6FB9AAE313B9BF8D8
              4DC1C7EC4E4FD7AFABAAA77A96158BD8AFA270AC1F066035AC82E5E07D868B59
              68C0347C831906BCDF611D22F39C0FC126589FFFAF0405FBA005CDCC0C4CC218
              4CC0F7AA589B4816D0D116D80183F9F71138081B6005FC807178094FE1354CC1
              3B780BD338FAC93559299205D6C06ED8069BE10C9C05858CA06A46F405EEC11D
              504CA15750C7618A2889CC8B602FEC820370114E409813D2A46CCE49F3B38DC2
              0D780C6FC028A7140A110BBA13F6C361B8020A569D562DC6BDD6C0145E8507A0
              E828931A35469DBC0EB6C356B8040A9853C782852CC614F07937C965D807FA1A
              C67FCD41A330FF0A9D8363E004C7FEC742C8FA5D0005FD3DE080C556C0DD6491
              B5C556FE378B79A7E028B83B8714F17DB0E827C12DAAF522627DCC8E42BEC083
              8AC41B7D08B42866B716F3AD8B8B4EE972FF1BCD46D07A15892CAC0545FA1511
              C3F24DD6BA4D55D5F46786FA14D0E95239AE5AF2AB88ADC16E6AA3D37A4D5798
              FEECCE2D456CD976D1CFB014168BACC3279855C428ECA0CF40F35E2F16A9B7AD
              28D2D4A15128F4103C0FB46E53E63C45CCCE7DF0409B54E42BE85CE5BBA0F522
              A23D8227604DEA8A58A00F6044B7E10578BF3C74FED1A2DFD9896FE6EB7B68D4
              884D758BE40D0F9DEBE0C113428EFF2932C742C0955F83E7E0C2C7F0DF4A45E2
              29AFBE90B678CF153BF1087878852D24A6E3B08FE002AD858B5468C220928896
              85ECC87BC0B345CEC3691886F2D98AB933757C0BACAB629E8AE34C48296F9B98
              856C059EF11E3AF61F233B0E46A5981DD6DDE366F12CB7C0E9A88548B9E77B59
              D38ED565211D79C6F849A4907DC874BA003F8FEC12E65FFC2C72AB5A033F2A9A
              38684B6B8748184F996F1DEAD8342AE27FEFEB24DA910246E1F756B9FADF5614
              73658CBA57663C8B6F0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000020000000210806000000B826A9
              51000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000379494441545847BDD8B9
              6B945114C6E1311A4DE2BEEF8A22165A2922828D2016F6B6366225E85F636321
              686B6B61A32208220A828A8560E1BE2F51638C89DBFB7C7E77989004C5CCCC81
              5F26DF9239EF39F7DC7BCFCD8CC65FEC57A3E19D99A137CC0E736A5CBBCF7E86
              EFE15B0B63EEE58FF31553DB94025A1CF785796141981F06EA7BB3827740C08F
              301A86C3E7F0A9FE1C09635309995440DEECC98768395D16968685F53D8EE706
              6208F11D221E0A5FEADF45EFFA5DCD6018C98B448EB30902E25CD4FD81D3D561
              79E06851D81E76844DF5B5A1F01D2217ED937027DC0EAF0331EFC38BF0260CE5
              6543D5B471026AE7A25B19D60622A47F6F3818D6857FB10FE172B81864E06378
              1A9E87CFAD99680AA8D36E7C45BD312C0E441C0E3BC3FFD8E37036DC0B44B81E
              27A21210E73EA559E4D22BED5BC2F1B02A4CC714E1A9702D10F1303C0BC371FA
              53D44C612932D12F09EBC389305DE74C60C7C2AEA0A8D7043E4CE3464F4BF4A2
              062147826CB4CB383B1A360443BB22CC55733220FA32DD54FFFEB02DB4DB383E
              14D4195F66512F01A6920BF39A32D5DE29DB13044704417D04487F596476070F
              3A69FB82A005DC4F80B49BFB5429944E9BC5AC0CF74019024562D151FD9D36F5
              669DE1B31220F55640334026BA6156543E6713E01753512176CBD419BFD52C00
              0132D12DE3AB0ADE8FAC0795D942BB657CF15B2DC5B6470D8506A25BA63FB019
              8D11602F7761FFB67174C3EC887C8E12A06920E26DB04B75DA744D8F82CC8F10
              F0B5BE895BA1D3763FBC0A95DF22C03E2D13D7835EAE937625186A355709907E
              02F47486E052E894E9174140153401C6821A35201B1782AEA5DDA65D3F176458
              A36A268CF66405321F29D23C7AE0F37468F7B4D41B3E0822570332DE6CC964C1
              03EDB38E56A19C0CED1021C033E16A50E87C087254F096E0CAF2163136A3D215
              DB1BB606EDD9E6F03F261891DF0852EFDC808F715C9D0F9A02584494738166D4
              D66CD3C0819A7FDDB0CC285DF0F9A0B039F769011A8CD3E6B23F4E006B11A169
              900D7D82E64193EA7CE064A4B97460D14F324BB92293DEBBE166B0D810220B2F
              4335EEADCED90401AC1E8ED2AA11020EED62E5BE6C10EA3BCA5A0242CA215551
              3B9211E11CD03C11159B54008B08CF44287AFD1BA7E574AC8B92A952C479BDCA
              82E8CAE9981845ECDAE9D8F30936A58062753638133DC73280F2FF01DF213245
              2572D930ADA5DFFF072675FCC71A8DDF4E3AE8746B18DAF30000000049454E44
              AE426082}
          end>
      end
      item
        Name = 'Save'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000045D49444154484BA5555D
              6C544514FE66F72EFBD3428B4B1BA96D1711B0121F2AF4A18869A9518C6D04A2
              09D1F8172B2455A2688C066D20A104AC8231A926E8033E6104890F1AD2F0E383
              35A446518B4A3405A20836B505D2ADADBBBDBB77E7FA9DBBF776EBF6C712BFE4
              DC99393373BE33E79C3BA3405CDB7E47319B564A0BA580A22902DB6DAF073E4A
              92B29FB23BBAAB27AE5C824ECA324A07E542C686CF4A6B03B62D1BAE0B7EC397
              32FC6A11BB2F50CE511A85E40D769A294D64FD862DEC6710C50ACCA74F06023C
              8D73DE3CC819459FA1A4DD150623D08F31F51A2E5DDBB1A2864E1EA3F68090FC
              C5CE3E12B47DF5585961EDE2C1D8D088AEDE72DCDE3090C00D624CF3644A6543
              C7CF78086959893EE083E5299FB80DDD8FD6043AD5CED469DADE4ED5CB063F92
              83F3B2A0363658A94D6BF97D87B0E9743FD688AE288801C3875446F34C8C86E8
              3C9080CB114E5898E7AA104F20F2C89DD629E993F8021D291012ADE993BD1141
              CBD455F51FA1C5238886D0F7E17A745C8AA3B06C1E12C1420CD3685AF65B16FC
              B112A4DFFA12AB0EFD80A7A4527862C3E6A9B946EC4A0845B42456599AA4F723
              D875D15E44823ACE38D515F023F5FB28C2DBBAB0B9EB3216DEB31A3D4D9538D1
              548BA3EB633856BD1267A341A79214BD768A84A7636CA5371E5695AD1E195ACE
              3C24348ECE457C0CC161130BAE2619D6249277EFC69F6A0B068ADB99E26198A9
              0CFCAE35A7F12C4F44AE44D913162E12AF3CD8290D1FC3E0676685DEBFF67684
              5EAD4660EB1284386699BB95350372249E6561C9757D75E5185C558ECF1B2A71
              91455DB46D136ED9D382AA9D4F63296228088560BAEBA72593044D82C7F3770A
              4547CEA2EAAE9BD0FB533F163EFF0E1EE6A9945F2193D630E606617EDB8F254C
              A05BE053634A12C289DC681AF3DFEDC16657E740D8A7B247BD77154D422E5C79
              F00CB152E49F46348CBE976AD1F1DE03D871EFCDF8945E64C470BE7171221FD3
              927890A4F38F4EB5D7E3837D0D3853CE749F68C1C7AB9927C999BB6C46CCB888
              DE3A075AC0533C5E87DEC6C358D77404EDC77F41E983B7E27B67D12C302D8913
              7B376671FE27A77A51D2BC125F372FC7C1B54B71A5BB0F95D9D97F63AA7CE548
              1859CFE8044801E8A485B9CF7E86272B22183BB011275B3B5173F43CD6796BDC
              D6C17FE6442C7A21F2C081DC12F6B92154D71FC49EE2D7B1F7CD6E3C37466277
              3EDFEE24578544944A8A997798926B9D63A9184768415A5BAAC9CC20CC2BA694
              8F9A5CF113AB4B732CAD53289CF7200E382F9F6CD018818E46909CC34B913A1F
              D7C9B52E6D56B899630FCED89B93318D3BFF5C38804464CEF8FD27C44A26D201
              9F5DA1B66244BF62FCBAB7C1EA38731537924C1CCA0FC5B420297DE58BB10C3F
              6234300498B2B99C53697919DF67A7512B5F5D49DB77BFD9FB5186527AC75B59
              F652664724B994A7FA67A4542BAEF0F95D4CE62ECE740A49193B5F50825CD966
              66D41F7C05FDF44C086689AC2F7CA355C0B03386D21554C8D36B52D6385E9248
              946F531EA22444F73F11A17C427931BAABE7F23FE4B999468BE4026A00000000
              49454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000005A4494441545847B5576B
              6C1455183DF3D85DB66C775BE8232D2E58B605D2565212494C888886108CC400
              09FA03821889F25012425088298914FD8131C400C1C41FA844490C0812A35120
              56E3230D518AD08A50A0502C2D7DAD5BA0FB9A1DCF379D5DFAD895AD84933D73
              EFDCD777BEEF7E736756E9A99DA54DAC3B6DB02C06B0915C414E221F04DAC903
              E42EDAEC14DB8AB4B252C3E218E9272F934D6482241413E0EFFEA192D5E454B2
              8D7C96221A250285BC39454E21D7D1D8FE89758D61D6D1BE12EE50146E97CAC9
              269431EBA07B2667854D18A51E0CA845954A4C75BDC09E7DE45572B608D8C1CA
              9BE45A2AFA8025CCCDE31CFFDC8A94F8C6535411DC4898BA2CF63F615285812E
              84E211B3C5B107DDB4B986ED22E26D11204AE21C5749CF23E69609CEAE9EBED2
              C222B3FCEC0D54BCF13D16C612D0B959F696DCC5C8802435B25D31E542EFE309
              6825E3D1F7DE3C1C2FCE519B43FD89B3D1A2470D5531FEE4505DF6DF240F5B13
              377B1C7DAF2893CDAD987F6D3D56FBBD904162E7BEF9F24C7C68EEC4DCF32B35
              D972B17B586CEB7243300240F0D69DFC3C9F19B81EC294C70F60635B0833E885
              A13121174CC5577E1FBA645BEFC4E0A2679254B2780AF45A753B113D711973AE
              71AECAB9D29C30A107C3F07286AE68C36D266F2C789D6601035D3CFF20D65F0D
              A15216E0648DB14D6C9F8B1F6EF6C3FD531B26D5CD4163811F37B9FC6DF6C6AC
              C992A411E4A014EA9C6D2813015427896BED8CB58514C83593B06AE285052F1B
              54379C977BE0BBDE8F80B4D1A3E470F56604FAA67A2C79A701AFEE6E647F3F6E
              B734E1CA9573686A6D42736B339ADB5BD1816B70441370D8F3521816AA214809
              784A2E54A8B3455710B51AEFC2746830C769F49170EB0C9F0B614D47F7D44FD0
              59F6313A34073A19FE20DB63B24DD6AC2C901260AD6C3FE956E846427A469E04
              43EE0C393986F766859400BB32DAB08D38B7231CC738A90FC4993B3138F978FA
              2EAC427ECB8B98C04CCD67BF87ED925719D7198994807BC0CCD761ACAC46FDC2
              00BE581CC0751E4F9E69E5085454E0914039AA03D3505552C2142C4442530733
              3C1B0C7B0AD2C0F244B6E4C01954D514A36371399AEBAF60D2C94B7888192D8F
              98505E1872F8A83E37C23D039860CDCE624BEE25C082C1E7786F2356DBB75983
              F6E5A91B75820E45B65B20A1E07BC5A2B5A0C781BE8A3CFCC197CC25DE5ABE4A
              9F8C91FA48B03D2DB2162021B64B75FA44FCD6B00ADB2EBC8E9D7F6FC2F60DB3
              B18F8F6F44FAD25A17645030A60888089F13DDDF2DC3FE4A2FC2871AF0F0AF17
              51F4FE0AFCF80C8F6A7BDC9890B500AE6C395796870B93A7A3E7DDD3285FF625
              76BCF42D9EC700F4451568E271CB74B1348C0E4486D0642FC046D4E031CB2CC8
              E549E075A237DF85109B4D391BF83424D7CB3A10D9E780FD5EB81444D5B15F50
              B6E6499CEF5E87AD3F2FC76722E9D3263C26DE7350DAACCF10801102328D1A84
              2C6E460CE4ACFE1A6BF79C40D5D501384E75C0BB60379637B4275F27E99D92C9
              E9901A6CD9BE47E06C0FCDAE01F8379CC496D91FA1F6898378EB782B16D94332
              4232381D52025C72B1078991C1DA68244548198CA0987B9FCB7B097BC639824C
              BEA504B4C8851F0D92C664F27D2E8B8EA25CA4B4855A62069B468F658F94E08B
              CBFAB031E4B36408920294B332388CA83F0FFDC5E3F9B2B1DBFF8B5C296DFB50
              529D26EF8C1905FC2F10418C2A92DF1AD20FF92AEE64D9E544B806BDE70B3C1E
              54FF7EC3AC38D48200DF6AC3D48E1562819EABFE5C84D6CDC43923AA5E344CED
              AF50EEACB8AAC6CEB0BB5004EC61653DB994FF0B8E845FD327BB7212A5F05969
              9136A3C704D982288C78AF125455BD4DDB1509D2E652F6C897F85E1150C64A23
              29C69EA3886F580A943C52BE94AC588D118309007EA502BD43CE06DA7B9AC5E7
              A4B4D5586BDB8D4748F1BA9E94FF0349DCD736503E6D584B88AD19E43C52FC5A
              22CE4A045456122CE58F631DB9987C90384AD6D2E6B99EDA59EABFAE383004C8
              D7D18F0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003D08060000001DD56F
              C1000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000E13494441546843D55B0B
              7015D519FE76F7BEF32637243C0C8C9587A0426A71EA542CCC68E9747C74B0B6
              9D5A19A95607DAF1D1E20395474170B0A01D3AEA98D65A19ED54AB68B50F181D
              ABA833D6024910C5825A8810C8FB7573DF77B7DF7F7637DC488809E406F8327F
              CE63CFEE9EEF3FFFF9CF7FEEEE6AC842EBB22A967594AEDE61B52C9BE1D3A0CF
              63F59594D994B328799433013D94CF296F535EB5606E0DAFAE4BB62DBB50639E
              FC6A2C6924E85500C9EB3C603AF91F3059413957CA0EE42475FC0C804EC91EDC
              3D945F91DF7352C8E6AA1AB915ED77CF304C9FBE89553F927A2245F1DAD93316
              D91CFEA499E682516BEA322E678D198D19ABEDBE1986A5EBAFB3D11C4A92E293
              33887A8AD4EFA244A4C201956769CA2E346876E6D4C0BEB31A4BA7139A4CD5F3
              2997512AA5867039BDA927CDCB4AD62925689ACC8B519CF32C3CC383D751E294
              00A58372AF65997F0C3F5017637E40F0CEAEC9659BDE48409196D150A52CB42E
              3D3F088FE70666D7528A292EB76739E83F6E2577D559929739FF678AABA54F2C
              58F3C2AB6B3F631EAD2BAA0C2D6AC293EED6BD46B76198519F6EA6831ACC10EF
              2B17F430A51D8C38791BEC2C6DD0E47FF65F8B5B30A2A6EE8D79F77747B5CDA0
              439F7936BBB6952DCFA1B81C7F48253CA739DEBE9615AEC3EBE0F52E14F2548C
              D7F268E9F08A9D96B5988EC503836A0E3257C876C5BC6161328310BD8997CC85
              FCC8ABC01E77F96F7A74243C1A222C74B21FE4E189447DE3CD8287F6C71D25EC
              603BB104C11EAE0833C5075CC1C2AB14D7592CA6661E17F24CA50ED62DA41C20
              791321E64A78F152DEB23469A2D09FCF9287C2315032F236E09ABEC5C54F4BA6
              91F019686365336B5A68175D5DA129285AF7DF04392D62BBC7282ED72B45014F
              3073334550CF393F55E67CCBAA2A2DBCBCC6B2163923AF91BCA6C88FB62C8453
              268AFDB483BFEF46654304F95E1DA6DB939186DCD7C7FBCF9F8443A17C445251
              2468924DAC3FCC85BF396DE545BDBFED49B7DC3F23A869FAC76CEE3AC66A51C0
              47CCB8E6FF2447FDA6D6E55546E9AA9A8C7523E9E693BE851015609307CA6229
              94E48D457AC98BB8F4911ADC42E6B2EE9E72948750BF691E1EFBD6641C4846D1
              ED3570907D6ED012E8EC0C4D358BD77F9C26DF27D9F427F619D8231D176DB883
              274B1D9061C57C9BBC98FD31E4C7207DE7665CBA61271639E4DDF3D98CDE90DE
              71D825EB1EFD81C7CDC6282A6F7B13DFA78BD3D938404B0D3274F3593A74DD4A
              3B2D51E7A472BD4AE93C3D796F84A7D6792399D018F81ABC0067BE721A65D9E4
              EF7A09B3D7EF80CC2775633BB1C1761ACFD3875DB2EE31109A621893EE44D0EF
              81CEC1F1F22C830AD43533E39EEFC632D2EF904C01D104C79C54691A9C024F45
              EEAAF486E2F55E8EAD90AF20ABF2681AA52EF95FEFC062D64B8FD8B7BE1D9B5A
              82DA223FBA325C8B58946BF7421AF6A938A6D807BDD7A567CFB42550BCB71D33
              9CAA63E0F6251CC4A1C33763255784EE7406470C0DF59A81A6887F42B2E0C103
              29F25DC8E67FA028CEFD2A20FE8B70C0976E91E5AE9C75E3B8D495F999BBE765
              5CB26E3B7EC6BA7EC90BFE7A15965F3517FBD00E3FBD876B592E5559292467AA
              DC400A901545DA67D8AF3012CFFC13D3AFDF8265F6C163E1F6A73480062A6005
              E77F840A68340CEC278FA668A03299BFA6FE1805F4EBBC344FCAE01503EC443E
              C91770A9D365E4BF8CBCA039C6F31A11EA6E41A8A711F9AEC49B9197684130DE
              0A7FBC051E96AD5833329454ACE90BD28C34DB9814A3AB9533FA08826D72DDA1
              C2EE213D884AFB45FF0A4867A4DE473396B9E44DF52058BD1BD7AA63BCDCF1C8
              2BC89896224607796E4535D64C7812F79757E3C19FFF0B17FB4BD143CDA5FC06
              BA284D0103872807FDDEA312F05058CFE38D940E2E6F09DA4046E73267DF6078
              D1BF027415D6CA9410D1133443361493714DF3B850364DD36F8B2318A1D36C8D
              636C4F0A452D71AE295E6444016CD1CDAB34313D44A967B052AF65EC94F522B2
              7C35523A793CC154C2DC9CA05F05D0C085A4881CD79C460312EF032A894E488D
              189D905A7FC491B15E68A47925D95C75334869674D1B9D54ABE6A5782819B4B1
              AEDD211F55EDE93372C4FF380A708D6DF094FB82E7899310305157C94AE58828
              23C59AA496E4E644FE98E77D931CEF24959050C7D98E8D7362FA2EFA57C04840
              274583B29D81D3A3940D94DFB07C9022707F6038D1411824465601D964849EC8
              38553A0A3FABA59D4D3FE71859051C2525E32BD1A98E894C6FA05CCFC87321CB
              E58CDAEC7E898D68F41339B581DC288044B95C2AC8B22929592917A8C8D921AA
              84D941EE35F2AC124A19F71CC54C3D4C75159E07D846B6ACD2C79C2921370A20
              452E9D1EC9664C4502F134535D119172884A28613A9A4A9068B39C653B35187A
              4BBD4413E0D269B7D75C850E37865D01AAA31178BF568EC3175560DBEC71787D
              5639DEBE641C3E63BD9F96E065405144F75E4EE59C459990C96062AF58A8A448
              FD18D344098D26401B928D594E5430EC0A60E4268B98B17026FEF7EF5B51BD6D
              319E7EFF763C71F737B11B7178033EC60806021E0F8A29614A994A19F12BF13A
              651E373C8C440DDA8407961B570C0643F19FC3AE00467F5EF4C0D7D08650C367
              18D5B01F250D9F625413F702AD31F85A7A10A0E4510A284522CD3D286E893A12
              A1D8F585947CEEF18362398C26D554FA52D0D70C8554BFBBC1D41DA122C38A86
              698A13A8F9D1D1240AC7FF1EABDA1328A71D4A8C735C73CCF3A2C389FE86D364
              AD341D679421B5533E066EBF4AB91D3EF2536E876537687237A8E3000F374643
              43D80D9E0C3852C55D498429A5C328E181C8F7017DC55042C7E17782ECC24042
              27283FCDF499A62C9B6EFD40E2341F560CBB02C40C8F238A017735F26C410B79
              D055E24763D0836E96E5E72BA9576DE4787FC2435F0AAE4243F201C3AE80E380
              FD5704B4E9A5D8FEF0A5585F731D567CBA10AB982E7F68361E9E3A0A356E1BA7
              FD0943055D83C44829408DDE4DE761D3EEDBB1F10E2E8993CB102909213585E9
              9D73B16BCFED7864C1B97856B576DA9F28E803067D7ECE15C09EA8D1B87612FE
              F2BB05D8126F445EAC1DC144029E640ABAA4B13696B94C3EBD10FFB8FA2B7829
              FBBC5C23A70A101264A18D0EE2F3E7AFC46B684001D71D2B1840DA5F88B8AF00
              4949A5ACCCF630F2375F812DF2C3A69C37124AC8AD0538739161F0FB8CFCE35C
              CE3CDE22C457BE830B266CC4D2298FE336A6F7AC7B0FD3BC854874D11AF43062
              178FC17FB2CFCF2572AB00277EAF2AC3418646F6BDFCC8EC6D47597D3726CBEF
              FC4CA7ECEBE0C687F5EA7806DACC32F57E4FEFF943C610D4965305B8FD087848
              DF2EA827F98C2E155959FB25757E2F14A8E3AAFD0821E73E405235C206430019
              51D6781D05304DA894C7A45E1D67FED30E84A59EB0D532540CC16E72ED0314DE
              3E840B4851F309D10E04565D8CED6F5C83A5AFCDC7AA37BE87A5F7CD422D3A11
              E0CECF94A9F2EE61F57ECF094194289E77B0C8ED14B0ECEBEF69C3571FDD8669
              C172F474724B3C8E9E7FEE2434CD3E1BCD73CF4153450112521FA840E4E13771
              9EF806757EAE0788C8F90DDC6970EFBBB871DB2E8C2D1A8F4E8BD610EDE61697
              DB5C49C53AA4FEB59DA85CF99EFDECDE3D6FA890507828BF1EE55C0164A1D673
              D9D17DE7652C5DF2026667483814464F5E392292C633D06F7B1E73AE7E05F774
              27314ADACB79CE25868CA1282FE70A10B84A9047641B76E296F26AACA87A0C8B
              E654E3FA994CC75663E5C65ADC144BA3E064C93B18F4F923A20081AB0491B638
              C6D436E3EB6F1DC4E5754CDD1F5A444E963C2FA0C9E3A4C162C414201072BD8A
              90D75E5C71889F2C791743B948FF0A18966E1C1F8AEC09BCFE72C218E0EAFD2B
              C05067D8CF72CF3464EF1F8481FC094BB1BB7EF04505D8ADECC05444BDCA92B3
              67D3B9007D80EAAF7C18E0A8404B718AF5F42AA08F26BEA80045D5B2381D2DF5
              1B5D9A9731F3FD48316E57BF35F699BBA797A8F09AC69BF1B3BF5482D4C9BB08
              C2C1B2F45EAA7D86536A251E77B5E2977F96C7E0CA4CD28CD5B934A55188D865
              95784B8EA9DFEEB2E7EF6922EC977A14376F22FB998F78228334C9C9DBE129B5
              0FF1785DE28A23219C13F25C603F33135415B0A17475CD92F85DE1802FD1220F
              282B78D6388E7E29BCF02DDE8AD912D7BBBFB9F551E529823B72EC8B36673C6A
              37CEC33B5602492AA595167090C71B91447747D179287970B7BC29BA9ECD7F69
              9F8503A2801798B9C62EA38E0A9899BE3568E85A22C0F12EE1052A68FBF2B0B2
              402FE17D74FEC9AEED7483F42A03D394976B804E926F624D2327737B26134C44
              A293CDE2A7EAE4BB087933DE7DDFF04551807C50F01445F6E06246DFA612B646
              97940783A9462FA313798A1BA6468BE369F5D1948F17B79FF31E1D805307F156
              92D84E2F19F020C2FEB5332FEF1BC9471FD18E82E95AC9DA0FE5A9907C04B685
              E2725D4805CCE4E86AF2C2B43C8E167C90CA24AB2AD67E98892D090703C916AF
              A5ABC7D405BC95BC31EE632A8FD184FEE960098E0A38FE9AF2675196BB35535E
              9E47AC2B380945EBF6A58E2C9B6E7016CB4FEFEE56BB95A74E5304A8997B99AC
              A1B89F946CA615A869115B521630AC9847B7923ECD32BDBCB897271EB581D301
              A2008BE3CD91B5343D696946326DE4A7535A9159F8D027EA9B07727C91C97C8A
              CBF13E725CEB2860868F93E87D66656E8816C553BEC3AB2E2E5D5DFB01F3672C
              485C46FC71CA37282EB73A58998B4A1FD895141FA03E1F6BBDBF6A22C7549450
              4671B524F36A3335FC0A83D78FE850A2AEE7E73C23DCD229846CA12451FF052C
              CBC71DC034CA5514197559EE5D4EF22509C9D7EC17EE8E05541954827C463699
              C5BF512651EC48CA7E6CEEE234603C28D85AB1215343CAA2847D647005C9EF75
              39ABF0C8212F157BE94E67B14A3EA311B8E4559445C885CE0411B87D76399093
              352B9BBC54BA8D15B20F302FFE6001E5BB94B32967CAE8BB106EF2D9DFCB944D
              E4A5BE14C9E60800FF0705C2CA9E7C0EBCD30000000049454E44AE426082}
          end>
      end
      item
        Name = 'Edit2'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
              61000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000020B49444154384F8D9251
              48935118869FB35596DADADCA66D3A56DA2A32C27911985DD845C8B01C64B488
              340CCC42A8B020A1F0A2A4202226060A755751209109C1AEF2A22B4D57226184
              CBCA1C5B0CB1A868919CCEBF4D6FDC66CFCDE1FDBFF73DDFF79F7304FF8F4E3E
              C43EF08CDAEF71D6343530289A984DD55644C85B94F479682F5847C498C37C77
              2D1DD28F539F326443C82E1C5FA2ECB917A4E65598AADF0BAC1D0D53B1D74650
              97326542277B287E3281A7B20FFF5C9C1C6F39F7B542B9993795266209570684
              BC8B6DE0182D965CC24A4B7560725F294F3BABF17F6DA35EF662485A97235467
              FBF3469AADB9CC282DF53AE2DA5A616558DEA466BA1553C2990621BBB1054ED0
              5C98C767A5A54EF0475BDD850CFFB8C481487BB6702F45432769B4E5F35169AD
              7322BCD3C2E8DC4535F6652C9A51F6B3EC09087903DBCB168E17AF27A4F4D2D8
              3BCCBC8E5EC02BAF634E38D3A10ECC32D2CA518781294D2E86B71730FEE93C87
              E4B564E7B4A89D8BC64EE3736EE09D2617C32E1313A1B334A8BA35614C87DA39
              3F788AC365C6A570E29F4B8D4CBE6DC3276F67096BC8008E3A178FF6BBE8EFA9
              A353FBB4494D327E4685BBD898746546B730C2E69979B6EC2E612A10629BD3C0
              87C73EAEEE72F3425C2192F265446F3770707012EF740C7BDE6A7EFA3DDCA9DE
              CA90384734E5C98A7850BFEAC8ECAFBF653E37416795BA81F7C44407DF52F515
              807FC284AD304AACA4900000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000019000000190806000000C4E985
              63000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000045349444154484BAD96FF
              4FD4751CC71F9F3BEE0E383A1C203218DFEE509449CC9635732502018AE12253
              B720851986344CC24A67981A686A6B9AAD8C66FE505BA2647F80CB69932D37B3
              5A06C20C38EEF08090AF05C7717C7A7D4E64C50F7668CF1FEEFDB9F7FBF57A3F
              DFCFE7EBFD79BF3F0AFF031C5B30C79849249418FB5F58E24270DD76D21A5D87
              4B1BD7FBA21E021D2504C5866225026B613DEBF77DC726F71893B9CB18298A41
              3D96CFD04391B494600CD2617D2498E40DDF5050DF44D1809B88C62E1607B9E9
              CD5BC680CBCEC40393DCD946508897A48847893E779DD40397A99C049D5EC133
              EE25B8D149AA790257D6129CBAA99C59A1A39840B30E5B683CD6F22F7871D44D
              E086344E6905F6AA1834A2110F732E76B0088BFCBF9BE63F6E6F253048212924
              81B8E27AF2EB7EA6F452270BAB7368707BE86DEE214D14E953C2B8762A8733E1
              5E3A6745D2B315935E2C0A5F48EC2B5FB3F6F44F94AAA08C4E1072A199B4DA35
              9CE91D6168D283FED2464EC44773D3DECDEF7E6FE181324C78C5221BF165F5AC
              F9EC1A65B262452698941F7552451F1648D797CF717C55224E49E9B4F7D112B7
              04975F35E92BC7E4F1F808E2CACE9257F7235B7D040A32373A4D8D1667D4E151
              BC8CCB726E5D77D014B7906EE53564F83FD05F8ED155CC22F528D9154F724C8A
              3A2EDDAACCEAD55A9DC284D6469969BFF212156A2D4FDF28244ACBBD87FB2A19
              AFC030368A6D5E0AB1550DE47E7C95726DF76816690A448957B329321847FD5A
              3E7C2A995F5A9B694B7986EEA929EE0F8DA0770BC9EAFBE4BCB59C0F02A614C8
              CA7D0A3402AD9D1B84E3C24676A835ACF8AD9038F5A3FB2F7C1AEEED181DC542
              7098ECB7977344BC1E95EE696BEEB51142F0ED0B54A9EF91DE542404B57E1E53
              EA0E0CF64D2C901A64ED4BE7A0698A60660DC24C749F2F60A7285879EB65E225
              DE3F056A15015DC5CC178BB26A33A831E9FFADE09E45738CF49E7B9E37D583A4
              B7169120047E2A7883005190A41EF2111C08D433A275CFB448087ABECA6797C4
              AD6C291482FDFE12EC22A0733336A941C6F11CF69A0DF46BDD33092C46FA3E5F
              CD1E5190291625AA7BFC253889E22C2656BCCD3C91CB5E29F298D63D9320C4C0
              40DD6ADE110599F6CD58D577677117B5ACC7AC56F3C4F975546A13C9D1E0B448
              5165689AC01CC0E027B9548B524D814DE2037CC97E42A718E4308EC47CF407B2
              838D0CDCDEC9EE23197C1A6AA2577BD134E2FDE91C7B752557DA7FA5C31A8B5D
              D9EF23F71BBAC4182CFD6D44B5DD2139D7CA45E3E3F495AEE0A66CDD313942BC
              07D2395E99C5F75D4DD813A269576AF04CE5FA0D9D7E1E96D3375820D766B8CD
              42FFCE5AB2636BA81E1E275C080EBF9EC36547331DD191B4298766A7601AB2C7
              33F36C34688FF25EFC191E882B752E8D275749916B79B6AB84F9939518EE463F
              1894D6ED146C3E4B85DB8B3EC3CAD5758B695ABA0807C30CCB47405754240EE5
              E0EC2DFA27948E6D21A9DDEED1C79626787BE4BB69903F18723819F28C3298B8
              9861653772753C0CE06F09C9B3C2EC0F0C830000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
              F4000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000696494441545847B5970B
              705C5519C77F77DFCF6437C9E66152ECB4260DB515A1526BE535A153494D6929
              D80A5370E2A898406D226A67181D66E8088CCDA30D56033AC260012D3030B5D0
              E121A2602DA64D532BC536691AD2244DF3DA6493DDEC6EB27BFDCE6EA851124A
              9AF8DF99DDBBF7DC3DBFFFF9BEF39D7356E3FFA0C81D68962C6CD171B2E5EB65
              726DC72457DD04872334BB73E9D17E4C5C3D3BE706C29BD1ACE95847E37CCA6E
              E033B8F196EDA7C83F8AEBA935BC6631D11308D292E2A44DDBC1D89C1BD02BB0
              4462E4588DE4938677CD93DC71A095F5AAED0A1F7F6B2AE517C4E80B8669755A
              689F330391AF4BD83331477432A2310ADD0EB24B5E64C3CBA7B9559A7583463C
              AE63FCBC8F83474BF9A598E8198D70D290FCF9EC14D994C8B935AA932D795FE4
              5E806BD751164FC0559E7505D7C444532F2B57EEA114335E99163E63A2875928
              5222F0CB24EC7109BBE4DCEA20ABE68F2CAF5C414B633763A706583CF1A832A2
              22AE758D30FFCB391CCCCFE3DCAC0C4436087C3E1635F2788C7C730E9E8D7B59
              57DBC8771B3A30ECDFC6D3EF9EC0DAE2A730916B0D5DBD5F95C95F1FB99EB762
              21FA2FD940647D123E16276B7C9C02472EA9B7EF61DDDE7FB159B5370FB2E8F0
              7BD85ED9C69E83FFC47E5ABECB6DEDB3E93434DDC5E362A63F3CC6D94B32102D
              16F802CC639025392F70E6E2B9F319D63E7382BB54BB8C3651E362A2B0E90496
              977FC2536F36E2911405DF2FE5518C0C8C846877DAE84C4466268AAE45330B7C
              5CE0E12805AE3C524B7FC7579F3CCE3755BB74A84B9C65BE253FD5BD9205BCF4
              878DEC0B85C061A137389A80B78D0F3332E32A50F09846A6C0F315FCDB7B29FE
              5FB8BA569F527A3175DD789EA543010C0E23E70321A97F2B67C6A38C981F273E
              23036A91911E33431181CF23B5EC7956FFFA18DF526D93E14AAAE454E9E53A69
              7DFB76AA53DD7407C2B4A5D8F8201614F8A3C9347D6203FA5619791C9FC00BDC
              7978B6BCC0AAFAA3DCADDAA682CB0D43B62CB7AF6FA26641161DC3013A05DE21
              333F647A2C510D097D2203FA16CC710D5F5072EE969157BE44D1EE2394A9B6E9
              E0990EDA5FBB8DEACB7338EBEFA3CB6D979C4BD84DF5FF812B5DD4807E0F66DD
              886F384C41CA3C3C3FDAC70D750D942BE874709F9D8E03B752BD741EED0AEE75
              D13A1E2360DE9D0CFB647DAC013572DD4286E42E3F55E0F7EFE7DAEABF738FF4
              22F34B6053C0D36D74EDDB40D555F3694BC0DD9C8E8D097CD747E14AD31A5070
              A9D78CC0280502F73EF00AD7FCEC105B126B7A127EE1B71FC2D36C74BF780B55
              2B1672C6DFC339AF330937D525AB612A4D69402F17B889F4C15119791EDEEDAF
              F2A5870EF2BD988E693AB8D74ACF733753756D01A7FDE7E94EC025ECA65DD3C3
              953E6240BF57E056D20643E47B64E48FBCC117B7BF43C5B88E793A78AA85BE67
              D7B2A3E8729AFDDD13701832EDFC78B8D27F1990096752DBA43F094FAB7E93AB
              1FF80B15B2DE5B12B029E02916FA7F5BC28EAF2C49C0CF4F8C7CD0547371B8D2
              850EF532815B4853706F1EE9756FB1ECFE3FF3FD681CDB87B089472FC0DD66FC
              4F1453B5F60A4EFACF09DC3101BF48D8272BD169AC5CA69B0DAFCAB937978CFA
              77B872DB9F041EC33E1DDC6966E8573751B56119EFFBBBE811784B3C8E7F2670
              2583BE51D66C2B2E39ADCEF7E490F19B437CAEF20DEE0BC770AAB57C2AB8C344
              A07E35D59BAEE63D7F27BD12F616A9B141E30CE14A0639389B02117C6E0FBEDF
              1F6671F9AB6C13B8CB6220AC4A6EE2B90B70BB89919FAFA27AF30AFE21F03E19
              79B3C0FDC65A64839CB90C5190032CE9B8B03D74889BA5D4CCB537F2F0D3B7F0
              E0422FC7120F4D44C26624B8B3889AD26B38E6EFA05F56B86631E937D65C1A5C
              C91019C3E974E0FCA00DDFC901962ECFE1ED8A628EDFB69873BB57F1AC4422A2
              2221F0D08E1BA8FDCE7534FACF0ADCC1293DC68071E7A5C3950C52621E79D91E
              3B4EA19CE79DEBF2394244429F42A4379C387259CD6242CE70B5F7167158E003
              5E3BCDBAC6806196702583C4DF2B2BBAFDF5332C93D18EAE5F48E7F30D7CBAA4
              9EAFDD7D80FB54F81FBE8E9AAD37D2E06F67C0A3E0D06F9845D8274BD37F4051
              5790854B9EE0417F986CB72C2CC351D2D52E93E7E664E51778A1B28886A14E06
              643F3F25B7FB65E4721C9C1B69FA4F59FDC37DACA97A97AD6AE667BB685B99CB
              916F2CA1E9A6423A64F70E0507E8936354AB44AA5FAB993BB892A66FD7AE2F7B
              4EBFB32388B7FC4A0E152F12A88B117945C7028CCABCE87759E57F6D8C21AD6E
              6EC23E595A6F455676863DB01C8FFC530BA0C7860907A20CC9EAD36F353362D1
              084B3AA286BAA9F7F3D909FE0DF9B3D1634EDEDCFB0000000049454E44AE4260
              82}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003F0806000000501DCE
              CA000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB00000FD549444154785ED59B79
              7055F515C7BFF7BE352FE191BCB00504949DB02B22A220C82A7BD8656B6B3B63
              17B18EED38D3CEB4B67F74BA00DAA9334C370B8425542D5A16ADFB82FD4764C0
              2A9BAC024181ECC97BC95BEEBBFD9EDFBD377921610949201CE7725FEEBBBF7B
              7F9F73CEEF9CF3FBBD9F1A6E2331F3A0A1177454C3637A1180890C5E6ECFABED
              780E2492F09A26E0D691D03454F1FBF33C2E22816A7D1D3F3522B78D02CC85EC
              6B77C2C7E085070182B6E7E52CCD44A60164C40DA4F9FDBC478799A881960462
              5E0D615217F1BE4BFCA648FF23C2EA6129725B28C09CC97EF61434C2FB94E5DB
              5301D9B47216AD1E74E9F06BED619C3C83D0C5087CA37B11D840B22602C3EF46
              259550C6C714515917D8B642FB13A81F4BDABC02CC69ECE360C2D7D0EE2EA4F3
              93050F8468F5F61E17FCFC4FCB7B19B3DEFA0A9312267CBD82385C301DF9C3EF
              C4C530D1D33D28A3124AF9B8122AA198CFA8D09EA72F51DABE027E02DD3408CF
              314EEB65F22C960FC50C647A053E1D18BB1E2B3F3E8F89AA812D213FBE79330F
              AB47F6C2370D94201E91408519478DCBBABD6D8AF9B4B2BC5B73218D7F067928
              785A3ED3ABF35A064C1B7E12A1928E35750DC94802C1578E63D8E41C7CD63307
              E170047E2A4C5737981C023AEF77C168931E603E48CFBC8F47146E93E39B9F82
              3CC4ED3BD0C5B3DC1AE169F9711BB0624F2126F3BA04FF7A2CA284A4095D3CE1
              ED79F8C3DD321CCA61DA9E50CCBB8B18274ADB9C07A8683F90F63198D2045457
              292E8B5743C924325D1AD23526BF091BB1ECA3424C690C5E44AED99ED0EE9563
              183A859ED0A30BC23535F07A249C826F60A668530A306711E42EE5F61E5A3EC0
              BFC4ED430A9EE33F9E443B4F10A6C07F700ED3381C78D976EB46244509412A61
              C8B46EF8AC5B0891580C3A1519E70DD12B36BED962CE25663FC24499EA24B431
              DAF3B28CF90E46122176349D11DFC3E0E51ED919A7153C5D5C3CC07A42E322C3
              803719C535E8BA6017BEC34B6EA64D2998D2F8465F9BF0007334BB22A92E6E15
              394472E0B369F54C8F1B69FCEC65F0E347E85346E0A45E8D427AC128B1329520
              79BDC13070C4F192B2283A0C0B615F6E3714D30B0C2A227CCB3DC09CC78E8F66
              07138477139EA52DC77E88542ACF33E00524DA3FB00DCB73F3F12451359420F0
              8BA9D8F7EC68BC208F10405B098D8AE325720E880F393EC3F32DF580DA0A4FE0
              C5F202CF31CF62252496674D9FA6B5E3985F8FE57BCE637269149D0A8EA0E78F
              8661AFC60C317E30CE325E9CFB909EC0B68E121A78029529C8DA035DF1DE6F26
              634FAC0A6020ACE48D15B74C01E614767410E1A34497F25643662ABC94B77A10
              C9873760395D7DAA584F025A510D72B61D45CF27EA94704694F091351C1A2881
              F02A560CCEC6277B97622363BFC1BFAB796305BF2EBB250A30A7B383B98497DA
              5EA23D084F70E5F6167C9A0DBFEC7D89F66C222614405B095D0ABE448F278653
              092C944409C9FA9EA02C9E02BFF7F395F82BFD3D1E4B2046EB97B30765BCABFC
              A62B40B9BDE479B17C2ABCD4F649B477E0276EC0D2F7CFE211079EA2ACCACF0A
              ACB81A390547D163159560520913A804B39A4A286409C57BA805B1B46B50363E
              FD6205E1DD88476348F8380F608C29E3D34A357EBEA90A30A5BA1B4AEC38E1ED
              684F20ABBCA5E5D9E9802B13C9491BF0E87B6731FD72F81451F9BD884AE070E8
              BE6A043E554A184A4F607660753892ED5CB921C2AFC45F343762D128E15D8497
              F9808451A09C0AA8BE690A3067F3B5C353E0AD80573BABB3E18DC9847FF7EAF0
              4AF85D432554C3FDF0089C2E2B45493881C48165F89BCB8328AB3F991657F081
              0E7C99964498F120D6E8C35B5AD494D609784EAAAB0F9F26969FB2014BDE3E83
              19D7824F15679C0FC8C2FEC38F619D6AC16B7C0FF1908CC710670125F0B226A0
              E0190BAAB418432715D3EA0A3027B33BE2F6329FB796B1EAE6F31CF30EFCD48D
              58C2F97C93E01D7194D037139F7FBC087FEE144094D3E5049F1D612A95051199
              06CB21C1AF4AA357E014E15F6666514F682531A7F27552E189E51DB7AF0FAFC6
              FCB48D582CF0D2A4A9F022A23439B3D2CBAC609D2F6FE4B508EBFD323EB088DF
              16F328658AAD623C88A2D0829736ADA6007312FB358CCF4FA4B8BD1DED1384A7
              D502AE2C2408BFE8CDAF30539AA8864D849738C07ADFD52580D3FB96E2F77D72
              50128DDBA94E5C5E5353DF52717B0E8C283F19DA96DA77B58E02CC117C657F3E
              5B56725CB563DE82973A9F6EEFCE82319D9627FC2C69A21ADE18BC2EF0FF5D8C
              E7BA7742594D25CCDA686FAAD59F72CD40980A8FE11BC2FFBD0E5EA4492FBC1E
              516E6F5BDE34D498CFE4955ACBF37380F009C22F7AE334664B13ABE58DC1770E
              E02BC2AFEDDD05A511C207DCF68287B51A5CCA8786A506C05124B59DF5E1455A
              D40354792B454E8C96BF0AFC8C7C2CB4E11DB971F84584CFA9852FE73093682F
              E3BD9C2E5FCD3EC471B17178911653801AF3436CCB9B08F06D32A5B5E0650808
              7C088999847FFD14E658AD54A76E189E117F6DEFAE84AFA88597485F4CF0321E
              11E6FA18A34052CB6F1C5EA44514A0F2BCC03B795EB3E1697DB1BC28C443F859
              1BB160770BC0774AC3993D0BF15C9F86F0257C6A19FB10662FA22ACF6FBA32BC
              48B315603E64C34B8567477B1EB56ECFB7073C74FBD9F998BFEB14E6AA46CD84
              FF8896EFDB0D25367C5D91234A7033D5C972EA898601AF316956296C8E21C408
              C2CB989722A77EB497E96DC0938DC49C4D98BFF324F2A40DBF6B0EFC5981EF6F
              C1734CD9E5AD15F44AD9132BCF1F41427BEDDAF02237EC01CAEDC7B07D92F0CE
              C4A62ECFCB0C4FC1CFCDC7BC1D29F0ECD50DC17724FC870BB12605BE9CCFB2E0
              759EA5BC4D23FC05C2EFBA3E78912675C6117322DB39B3BA942287E79021F0B6
              E5F33621EFB513982F6D5A007EEDC0EE288AB098BD0C5EDC5F5677A2F8B269F0
              224DF60015ED9D595DDDC446053C836E9FB4E1E76DC2DC16823FF7C102C2DF81
              62C25B9617B7B77EE393D95D25535E94A9CE682ABC48936280CAF3B292236E7F
              7985C780C70EA77B093F7F33E6BE7A020BA44D73E03B58F06B06F5A0E51B1BF3
              E2F6025F44CB6F6E3ABCC8757B40BDC50CE6745EB2C63C0FBABD05DF01F1059B
              3167FBF11680F7A3F0FDF9582BF061CBF275F072167871FBAFAF9DEAAE26D7D5
              39F55B9D447BB1BC35A50DF28DD90A9EC18F87825F48F8578E6191B4692EFC7B
              B4FC909EB824F0E997C34BB4F7DB637EFB8DC38B5CD30354C093686F12DE8AF6
              02AFDCBE163E1BF1452D08FFEEFC2BC08BDB4B9E97687FBEF9F02257EDA42A72
              EE26BC4C69AD311F6467D41A9EB83D737DBA8F965FBC19B35F3A86C5D2A639F0
              D97E9C27FCEA6177E2921DF052E16525A7527311FE1CE10B9A0F2F72450F30C7
              136214BF97316FFF3ECF37AAC58C54F8255B5A0EFE1D5A7ED85DCAF292EAEABB
              BD447B19F312ED5B085EA4D1CEAA652C296FA5C2732BF8DA682F79DE817F740B
              666DFB124BA44D73E1DF9E8735237AA92D2D1ADDBE6E622365AEC74E759768F9
              6604BCC6A4810798430921D1FE1AF04BB762664BC087FCF8FAADC6E19D05CC4A
              55DB4B85D7C2F022F53AADF2FC00C2CB4A8EA70E9E67B53981B93EDDD711F165
              5B3163EB512C9536CD86CFC39A7B7AE342A39677C6BCACE1153007B582D47A80
              8297652C6B6253CFF2A9F0CB0B5A08DEA736315D0EEFCCEA644A5BA9C904BBB8
              F5E045EA86405F8268709B5EF8D991BA549702BFA200D3B71C6919F8FFCCC3EA
              910DE19D22A7522D5D8BE5D7B71EBC885280F95D82E870996EF878567B72EAC1
              77427C25E1371FC132B9BF39F059847F8396BFB731786756E7C06F6B5D7811DD
              1C44103F5FADD1F11348A705642F5E163B1B742CFFAD023CB2A965E02F08FCA8
              3E6AEF5EFD312F458EA43A176AD4EAEDE6D68717D1314E9D5DA6AEAC9FC14E48
              B113A4F515FCB7B7615AFE612C57376B0C8F144665E91CF5706D49857F7D2E56
              DFD797F04425BCE4F9BA951C296F1DCBE7DF1C7811D96EA8D3F5DDEC849F4706
              8F76F124A7B4418E8C973065E361ACB0EF950D472EB13E3B2E43877AB8BA121C
              F84CC2EF26FCE87E842F819EEE492972EC1F2D342F2D7F515578370D5E44B69E
              5B75BEECC9E32C8F793ECD475F3872162106BC85F67DE0D4B430AF0FFEF5BDC1
              C81FD9191F138EB75E590929F01769F935F78BE54B68790FDDDE72F712823B96
              B7E0D75F5DA1AD219AF9147CE2F2EC5027BEBE4B8D818E691DA13DFD1A1E7A7E
              3F1E979BEE0CE2C8A9C7F03C3A20C2382183C578E14D0CFDE91EAC8A1948BB3C
              2EA4C2EF9E83D563FAE3EB14B7B7E025E0C94A8EFC6C7A946EBFF3E65ADE11B1
              BE2C8A7879F6F3EC67E7E58765D73B67315CDD4199DB1B7BD01191B24204A3C5
              08549E4570D50C1C58D417AFDAB7D48A03DFDE8B4BBB1A83B7029E547952DED6
              F0D32D8317D14D4DB9BF8F9FFD8CFA3E1FD570F834B24F96B326948B9C7E2E1D
              C09977197CEDBC307C2E24792D8922A4F1FA21973D14D4C352E07712FE018117
              B7AF0F6FB9BD44FB32C2FFE3D6C18BE89AA1AC2F959F9F245E2642E3C52F3020
              1C57EBFBB82B8863CCD945F128DC045463949044553B34E46F758D9F8D54F8B1
              0370DE1EF38EDBD72D66B86DB76FE522E77A4457E98F01909EE0A719655FBE9E
              EAFEE3EFC07E5E35E206748E7775F864907447E53F8F6280C1002A5E407817E1
              8B765C0E2F16AF9FEA6AA88A84B6E3D6C38BC8660219FB69CCFB7E3F3F1D3D85
              ECE36596FBCB9C9C51FF302AE00FF811F76523E20DA1FA543902CF6CC404CE06
              D52F3D54823B48F87FCFC6EA71035158CFF226E1ADA067C1CBACEE45CB6BDA82
              481054C18FE3DFCB2AC0717FA906E5FFB228BFBB33CA9923A2072FA2DDCF76E3
              BEE1EBF083A19BF0ECEA7DF87E754295CD70E01FCAC5B9300BDA5A78C7F2B0DD
              5E7EAEDAD876E045B4E48F710F2D94133590E50FC11CB10E3F3C7009F73B014D
              361F65781139588CA10E70AAB4F7E1D2F69958FB702ECE56D1C93352039EE3F6
              92EA6467461B18F3978B967C0A63E8FE5DDC0C7FC78B9039620B7E5D15579321
              6529FE539BDF1DF112A87B3B1C1F9D83FF3D33129F0C95757B59C3B3C6BCECC0
              747EA894595D8D2A6F6F526DDF54110F18CFE2A7735A07E83FDF8D31BFDD8B27
              24A2D38A4CD3B49F2D5E17AA097DE2C1AED8BF7C000E4EEACF298BFC045D0E57
              34AAD26325DBC82EACFA014FE0B7B44D7811F1808935097462F5877B39BE3FBD
              80B1F677CAD23D9806C7127AC5401C9CC05A9E0933CE7A504FF06046303CCCE7
              1E0D55CC22B2F958B6A48812C2CC1C12ED0D06BC360B2FA2C59EC4248F1FA1CF
              0AD165D436FC2E9984BB57260E11FAC0CA5C1C1AC71A9E61324E243DCE7903D3
              A1E17621E6D610556B75A03A18E4788802AAD40E4C5957AA20FC2D2E72AE47B4
              F02A776E2023D16FC741F4DB7E0CB98F0FC1E7F7F7E1D4C4CFAA3F0C579C968E
              9B481038E696FD771A2D0B75087C0D11AB6971514244B93CA8ACF3486A5BDB3E
              BC8856FEAB915E5FF9A17B7C7AA43B939F415BFAC4D24C8B4916380EB4052B87
              496039CB7A9D2C55CB3E1C1E4C7371B63670FACA1B92DAA2A8085FFCCB91214F
              F4C218442EC47C881984263B3D40F6D6399616CB0BBCB3E7CEE42749121EE2C7
              796410FCB7B70FB825C0FF016E5024806A29F5830000000049454E44AE426082}
          end>
      end
      item
        Name = 'Pass'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000000F0806000000ED734F
              2F000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000031D49444154384F45525D
              685457109E397B7F76EF6E9A989B5551F3C36234D2404C5259E8932FA6C4D807
              4BDB07A98A3E484D34416A9F5484565084A2795A1B5F14D4A7822954A44869C5
              2A1A4B50EA0F9AA0B10ABABB59B3D9DDBB77F7EEDE339D73C5F6C0DC7BE69B99
              EFCC7CE760EE486F3300A4D8BAD81C020C81F42B8D0649CDD07400825AD5AF15
              6A8C8B9089403EE745D99EB0ED15FCF9916D5613947C2BAD013B3DBDD1EEE919
              1B7FD376EBABDB8DCE8E3B4DC5D47CC775BBAF77D89E99DE58C0D8808632C935
              33AA5675F037B3269BBFBF57660072133B0787275F9C799D2FC7D7C6A3530420
              1EA74BC9F616EB9FF35FB4EED1775EF85DE5BD3DB23EC2DD4EA90E1C5F188602
              E9E69E5507AFBE3A9E2BB9FAB56FFBB74E4C6E193A3B39B4F9D268FF972F738E
              3D7625738C1EEC8BAB5C297453D52A8250C94785C1AD87D03DF37AB1E7F30DAD
              13E6D6D4AF88DF3888074BEDDBCEFCFC697FDBB947AF16363C9E2EAD53B96519
              D484140154423A770A10A9D634C1D03243CC2B9F0842CAD4BED9D4B3829751C9
              077E550435A4296745F919654F0E7EFC4741FF64A1E8FAF773F54D3F8C7C9638
              B4AB6233018DEF8FCCCFE6BDEEBCE3D61FE6E34399130345337BFF69DD5A8190
              39DC7B976E2C8B9E3BB47DBCB373B562F523D11859B106D6480B4CED23563488
              ADEBEAA24BDFED3E4697C1CA1EEEBB1B8C00AB5AA1E856BD4C3A13B8AE5392E5
              5291962F6D96F19626B5976ED9911CC274FA0D385ECD83A58DEC12BC23F03C56
              0351D38289D4126B3B13B5B307361F4D8D6C39DED1DE16606CA472428808CCF1
              1EE4C618F87F0582020A4C44716165541490C5FB0F7FFF93EF4AD55702C7A524
              F4FD7A00329B7CF274563FF56776F4F48D175F3F7F3E07825F1B87C8AFFB2059
              59405D1D2A55CF1624E66AE1F08768DB36F8EAEA98A2C6635DFCE5FA1AE26433
              1C01C33084BA57BBA5054CDD40E8CA7BF01B5AFC94FB7E12547F5468485CFBAB
              1849665DCF2C7BB2A1E456630B6EE50304A42596B9180B9B4E4417C5E551B3FA
              51AC7CD32A3E1B24D4BA91DFB4CD27A690644718691105B19EDC318B1A122250
              D597B24EDCB7249E54A25F256C22147300B0F75F4C065E593A7B6CC800000000
              49454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000064549444154484B8D566B
              6C5455109E731FBBDD4777DBDD4A4BED1B5AA0A03CAB681141401022624C4014
              1234C440784A54A0A0C8C3042D7F6A0CCA23C8E307C4802F120A18404150205A
              8416E4590A96B62CDBEEF3EEEDBDF7DCE39CBB5B42A311273B77E69E73F69B33
              3367E65C0248C1F70767A2A8429E83EC423691AD3924064400D364C04CC364CC
              648408F8930441E0B3AC6B1D2786CC47E3C89B903FF2AFADEB206820035F6A91
              4B916B906F20F385F8149866A08884249FCFF448FE9E1E905C32E8514D0FB484
              DBC37214BC19541611DB34BB8CF10D96202F42BE86FC0237528DCA2CE48968F5
              2CCA6EC4AAA0278C5A53B9FD6C60F4898BB7CAA28AE1CC48B7C5C60C28BA346D
              A8E708EC5E7D9A6C85BBA9E5F709712B501C40DEC18D4450A946036B831F0CB1
              115535A313273365E97A57DF6915158749E5FC355F9D7CB1B1A9454C4F7781CB
              6187685C85785C81F2D282CE55539FD83B2254BBA9A1F6725D8FAA2509E9F821
              C2649B80781A62AF40EC653C2C3C07D791811986E9FBE4A2B175CC7AA1EF943E
              7DBEA123DF9DFDE9FE29A150545FFEE6840347AA26ADF8EDBDF1730EAD98B46A
              F18CE78F5CBD79479A5553FBFAD18CC90BFA3F9B55F4C68C5DE05BDF60304C1C
              C7436A447672B774E4997C24B6ACAFC425EB0FBE5B7B96AF2E2B2F6743060E88
              B57DBBFE13F6794E79D00F9EAB000E2507BC6CD7E3832EEC59B7B1B8A458ABA8
              1866C4F62D7D5B718087FF3FF24EA985C371393EF784278C9F0A7096E7714160
              E5909C5DA79BC7DD0BB4C392D7C6FCD0A371DD3632B7F5B23F08113C1D09672B
              84C9CCF30D03E8F75B17BE3AF6C4F5C6DBE2EEFAE8384775969F03A417F8B8E0
              C471F16C3E40F11E0549A5E7787F7D63EBA35ECCC1537969E7D4E5B1661CA56C
              3E086C8E87B08FADD3A7C3F633379F2CF69D773B1DF0FBD5DBF9503A8AA3135A
              9CCB51EE5337235AD948960D2082D2E9362813B98F02A3C6556A1D4B209F0123
              5F4418599AF41CE7296340B184C0A0A6048AE9C67A100D577E723E45DD8C980D
              BBC929803450EE61B9818915075976D1786C2C64B20DF9B9ACC65BC0367B4B2C
              B9362F17B221C363039D100222AE07A5851D049069E4D283050A568290ACC1CC
              53F5FD94EA972AA39E813D3508D8545565A7A3EEA7C3C367958523695EB55377
              AA9A6677D86D09BB2C277AF4D3427AC259A0E99DA011BB23EC9F3832AFFA91B2
              B4933F1F47B82B5DB8C9D3944A8D5032A4644B43F687FB767C99DDDADCCC42A1
              3099BE7CE364C33441D334E8D474A08601922481CD2683DD6EC77032680F0660
              FFE1138567EA6FAC9D3E61C4F5AADE83B06B1CBD62A51C4F732A5CA910A67BD8
              B51B4DEC527D3D843A3AB02D9910686B313B026D341EEEA034113398AEEA064A
              FEDE7EB795DE0BB461376310080448FD1FE7E0E65F7718787D1620763B0B3665
              2419424229EED096D4312996B4BA21115115D163C9E172CBD8317904443E8E4C
              7037D8E6888568B7CB780AB0E13D40DD128FB608566B524F090EC0C71C4E17CC
              7C65D2ED750BA71E7B79D2B856D966E7E39C52EB923B45B7F8CEACA12EEA6EE4
              5F08FDB050C68FAEECD839AFCF9A25E16D8BBE5E50595D397C58C29A4ECD2375
              C97FD0438D7491246384A271F3E25EC056AF504CFEFFFEEF4317E265C57D37BF
              3BF85366556D6C51F9DE25CFCDDDDBB8F8D8895FEDD67472FE3F296524B510C3
              CFF3C809A5A573164581E86A1C8E9DA9CF6D34863D73EC97BA2C8AB5218AC9BC
              63C8AC75A9FF21CEFDC8F141C68D7085F21186F7A9A6EBD66A8AB5914AAC49AD
              C601E6853F2F678C9DBD72425353531A7FA714BB0ACEA3370CD75BC89DBA4140
              E287D1228E6BDDD20ADAE1D72510252617E7E58885458550DAAB48C8CFCF23D9
              393982CFE717BC9E740171A4A6A65B364194A40C8F47F0F9FD420ECE17E4E793
              DE25456271AF1228CCC9122012B18A1C775B8422C16FC60DA8CC420FC7F9C375
              2DF1A1F3C6364BDEF476D5700415961EEBA42E45D59CC158C2155235B74E99DD
              261235D3618BFADC4EC599262B6EBB18F33B482CCB694BE426DA428E1FB71C0E
              160D2E442387117B2737C2BF54F887442FCC490DC4E23705D065413499281912
              E64312247CD864191F6920CA02183A3569A76A6878957295329D5291524320A6
              60D389DB811E10FE21C16FC60956FCD110BF07F87DFC1656B50325AFC0640124
              1F4896480DE0DF5287C27A49BE72D59A24CC54516E46C64FA2BAE0DF7FE9D586
              290AA36E0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000008DA49444154584795570D
              7054D5153EEFBEF7F67F97CD2E9BCDEF26841090440B081404094AC1C20CA280
              5510B41D40C830A5E51FA4583B542AAD626152451C1845053BFC76125163418A
              94091509C5405C20219B3F4802D990DDECBEF7F6ED7B3DF7ED6EC84269CDD9FD
              E6DCDF73CE3DE7DCFBEE656E6D1CCE3A37554591A701C072C4F3884CC4FF2046
              FBAB776AF14AA2E5BED48CD88BD88A3A6F50DDDA5C2C8C407604918DA8455C42
              DC2D4D0586288A0AAC228B3C89CA84A8516DBEC2B0AACAF15186D34508564155
              586D4632D1B1431103114D88A7D188B3D403A958F906E14194203EC08E30F224
              3AF7F775AC65CDEBD64119E08069433220F3113770D956D4A742A4FE365C3B79
              03CA7DD72F85C06FFDB222E8B14C51E2537B08751990BD88D88168448CA2066C
              C6C27A44092AA61D742043200A914027A4FEB9416D5FEFB6F7AF69F5C0F4C985
              B5D6893F29FBAE6DD4B7DEFAACD65B9D668610C874A504463F90E77BAAD05E99
              D672E4985071F6B2387290CFFECA95C0CD35F90CD19BD17D0450BEE65594FF12
              B277115B68C587B88AD0C73BD18B009D6B7334F7DE5CE54851E7C258F5D0EA57
              37BDBCA221D3934B85A89CD1AA6660392DCBA3129D09DB18357FF01075DBEFD7
              7BD5FD8B562BB36174C7EF06A38700BA36E42542ADC946AE435C4634520F5081
              87D0BA595866125652BABEB9D09876EE62A134FFB7B3161EB8BAFCC30F3FD667
              6465C32F7E36BD7ECA505755BE9934A19F494D209AF3D9F996E1BBF71DCABCED
              EF8015CB9676BE59CCFC51DE535ADEF1D3A7BDEE92C3525C2455AEE9407E10AB
              33B958F39D84EB7C793063DFECD5EABA63175DB0F88591EB8FB52FA1CA8B8B27
              C83B573E7BB0A063FF7E3873A21EDAA00B538BC94A07FBE4094FE53F3371D3BC
              859B764CDDBAFD2F76B7635DC99A194FF8E44F0EB7A3A81B549E7FC350A65762
              683A3497F4260E048D7FF52263701441DA8970D18CB7777F64CFCD1B08BB56CF
              395050BEF4ED8B7B4E9CA9308DA9FEE59C3DB52B67EDBA7A9C145EF0961E393D
              B67AED5B3B7FB3A4C296E2806DBBF665D758274DCB7081ABFC9589BC265BB927
              B7930D60D028558A686557956A84B1D373CBCE787F2404BB60C17333EA07B67F
              72B0BA16EA8A8E43D3136F568AA5B35F50B6CE59A04CDA7651707DAD36D47E19
              AC1DC757FE75DEACE9B75A1A7D70B4BAED6128FE71A6EDF31334FB314BA8EC1E
              676B94EC01150D10634D392160C152E8FEFE5AA383F00618919B7205BEFB87CF
              9767A32E0565AD514B2C4AD17566C6C9304A632AB482F7EBBA514372EA687BF5
              D5865448CDEF9F760B1D8BA44A8AB6C8DE7457083042F17E9313F4A0EA8D6151
              62399E073317ED0611A43A2888D27EB225DC23897DBD5B2B778640065114F53A
              560486059CCB4194333BD3C0A80DA4C27191BD29C900A2CA602B6D8A8D70E224
              45C6D8315A9D610883EB204ABA835DF0FE736CE92A0FBF7DAE897F67BE992F5D
              33809F52F1161133D06B1C4765C6178A73F18C646C310F846FF2D8917C3E2576
              8146AD6113A81B5D5C4B7DBB255003664B28A0A86831C360AA2B11195AC0FCAB
              F68A7C3C48A360021E72703E5514B8262FDDB75C8220E8E07AA31E2CD1084E42
              DDA82CD8A184DAC0D2361FACAE1C25D4108A265990644041AA9F44EADBF33386
              8D7F108A5D56281CE7E0F84B4C341201C59EE56E7D66F58C86A0C11196894E8A
              28E6405834A371AAD5A30BEA383664E424A9A03FEF27371D0E406FEA747A0223
              1E736596E8C7407B5D41C45775C133687C3DAAEA89439201E72BEB0CC346E466
              7F6A7B72D5FB5F540E958E7C0055DF5671B2148645EBB78E272C373E2C8441C4
              9D224A120882408F0130180CA0D7F3A0D7E9C0643482188E6DB7AF4EFED332B3
              3BB4D268B1702F4D9D77AAB8BDE6D5B3DF9F6AC1AED85E474A32E07A1330C3A6
              A6930B571BED07F61FB2C49B35BA72D94B597200E3140EC40B7788D0B0353737
              33879B9B6DC0EAE0B161F9B662573AD3E2BDD6B37B282525214B3FA25159D5F3
              AC0C2C4FA5285410252D0F6826C61123ADA055EEB46B1CE31FCB1D2AD1683400
              CF3151941DD3D18B920C880506B5E25CBA5D3003354194284F8092823703FC33
              C829B446DA478B89317162683262135A83FFA4AEBB0CF82F94E42E4A89D53D50
              58C42C5BF2F3EB4B16CC6FF3E40E40253D2BEE13FD3F0392087DAB292F7AE821
              28DB52B26FDBC3752BDE793CB062EF6BBFFE2C3B2797F6A97D35A24F06D0C050
              3665C2981B035B777FEADD7BB2BA61FB91EA71FC99B2471F194D531FF5C70EAE
              1F4A7D33201E912BBEE61418F46CDE2037F4F7148223E21C5350E76B4A1CB77D
              72419F0CA009874C2D2B3BAA5FFCD1E5D5CAE4B9C5378A973EF9FCCE534B2B4F
              9FC6E5E37534968F3F981206C4ACBE77EE3D2D749F61B352FEF9712B5730C9D9
              661A9079F48BE3F47B8F1FA9BE6761C2004D516C3A2652BC42EB34A91288F56A
              434938E0870D7FFBF78CF78ED53C2A0B41DA16DFE177C627E6E0F170DF15260C
              D078CC0A02B22CAB80DF13D445139B7E903460AFC67137A87EBF5FD9FCC6764F
              E98E5D699220E081151B8B527AC653A273443CB2655AC41B742FD26CA22DF47E
              FE60FB9F66EBD0890A1EF2ACC3D99F4FCB1908EEF42CD6E14A2536BB83182C36
              C2E94D040847503A9DDC230D0D27F418C0D39370061331E2585B8A93385D6EE2
              4ACFE43C79F9D0CFDA8F054124782751DA5E9B4643568468A6B7E23F60611D1A
              B4D8B9E9DC4E75193BB66BC4C2698D4C4A6A574436064462BE2D8039282A0649
              928DC1B060F40705E36D41D20705D1846E562D7A5DC86ED2092966936036E9C3
              7894872D7A22D80C6AB74D0FDD361D1FF6884D4DE66FF69433EFC279D4B90875
              EE446CA106B8B1405F46F459B6D810AE3F643AE367C18637222BAEAA1FC28E65
              B31D3F75561DD095182D06E0AC26D0A178F435485D2244BB42D01D1420D81585
              509704016CEB840804D0415DD4B3208546B923822E6326EA790F419F67A3B438
              A01123911D4664A127BC2A432EA15B6954E99586863556C6F063157F0A8B1582
              A0D371E76337831F1B4230D05AF26140083D9B3156A842E338448DD2B7E16004
              7DA4CEC4F7C1BFA80712AFE3746C5C819887A02FE5FB9066738C12C5981D714A
              AADC4DF47DF03182BE8E5B6E6D1CCEFE0792BDE25DA4554BC20000000049454E
              44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003D08060000001DD56F
              C1000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000015B3494441546843E55B09
              9815D5953EB7B657AFDEDA0BDD345BB30A022A982089F11B9D6422318966D101
              132351346E44348BDB7C3122A8DF478C4610158D4B304A1414494482131493B8
              92448880802CCDBE74D3DBEBB7D6ABAA3BFFA9F75ED3F4D0403B43C7CCFCDDE7
              55D5DDCFB9E79CBBD42D411DD078FB5841AAA48AE96BE4C19F8C0D09415F40F0
              57406781068042A0C3F27C02214169D00ED05BA0A552CAD72BEF5A936C9A3E4E
              48D7A18A99AB398D8F7666C0BC8208AF78FF6D5C6E059DC2CF4570A6F68C9F70
              305F1D3B6A1D6816F87B861F3AF2EA272A0534DE3EC642D023089ACCE18003D2
              0AB7FFB470416AE1969E05C3D794CF5C9D2CF12C702370238BCC2F43A2B34179
              90CE3980ADA0D7402CC50C07741382A4A70AE91982984887697183205859EC25
              C1BDE148492E54CC96A4D852A87912821BFF7110048D02B1090FE500A0C4139B
              C597C0B32F04D1347DAC289FCE02183B1F11DCF3395000540FBA138D7CA662E6
              9A04EEBB0D790A181D4F618A5094148AB9190A392DA4B94912324B8A220B1AE8
              A92495202E11F2B418D98A4949B2A9959A29219EA6945FD8C700FC5804C26673
              061F540D2AF1B60002B82431FD0C4403609E133D0B2A496923E80224DA8CAB6F
              22B8147BAB33D82D08FC39A4BB6D8A916BD1143713128A1717BA59E9DAD932FB
              403E60A449D3FBAB268D1817A5DAD36354312C4C5AD800FB92722D393AB02E41
              756B5A69C3DAB6EC41CA79E5E4062AAD344A6E928EDD285535E19195CE8972C7
              A1A0941614C8B7E22E00BDAB98D1EED386E0F23BD048900D42BD7419F89B2F20
              A530C4F036024A0E8F7BFE2C661E1959180EEE8FE9FCE4CD42952E54CF9131D2
              035560AB2AB733675A169974E175FD69F8F96376678223D6EF69E9BB63E7DEF2
              BDFBF76BADC994A22A0A95C5A25EBFBE35B941FD6A1A46D78477952B0D6BE9DD
              27D779AF2CDB9FB3281FA88120F2B903E4B9076135ADE889AC98238FC6BE0FB4
              9F3B4D43FBF34521BC09EACD71C006F4DD78F6015FC3C31250C9E14D45868799
              79CE88E76342DE4C9ACC618894D44B04437D738DA9322D41BA7ACDF4916DFDCE
              3BF7E5551F8D7979F91FACB7DF7A8BF6EDDD43F95CB698F370985688060F1D46
              E79C73367D6DC2E79BCE1D55F10EBD35674576E1C2DD5A2D399A6136483BBB47
              68D4083D4D8B59BE833B264ABCE07A151E1F059578BD9055FBAB2006076C2529
              FDA102E044C784BC1E769E819D4BEA2382E121E9EDA95E81A1A3AAD4FB565D39
              7FE7A0DBCFB9E486332FF9CEA5D673CF3CEDEDACDBEA8179EEB92352369DF23E
              FC608DF7F09CD9F2BC0B2E2CFFF2F53FFFCA6B9597CD307FBEFC022D47E15C73
              B64698D660E9501528282F8167393E147891B400BF6CD6CC2BE3ABAC011FE2E6
              E4C2333D06495DDDF8530C1145FB391ABC1B4985F984A0FA603E3228F9515B28
              FC9D2B876E3FE9EA6B7F38E3BE012F2D7ACE4FA6A9AA705C76F0A468BA41FD6B
              0752DF7EFD291A8B91EBBAD4D2DC4C3B776CA77DBB77727A4E271545119EE749
              0123B9F9D6DB68E67513DFD3E74F7A2ABB694393596335CA4C7A1B29A25E2464
              463CE9E7392A9AE0C730FC61A81FFB101EAF2B84D2669604CFF00A9E8C683D88
              9FBA707887206F634F2E4CE94AA87D78406A3398BFF6E6916B6217FCE0E28997
              C5376D58EFEABAA6E6F30E332F860E3F594CFCF78BE873678C3D386640795D85
              9AADD745AE0D55293605637BB25A9FBF6DDE3370E59FDF8DBCB06891686C3800
              BFA70A0F829B75CF5D72DDFA0FC7FFEAFE85E5952F5EFE4076FD5FA5591DCCCB
              5C264F9670E504698B578F2E04449678DA50BC7207F7670160FC6F17C0F18FF3
              19A89127A350C93E995DC948E8A24B07AFABF8E68D5FBBF05BF19DDBEB5CD334
              D56C36EB456371E596DB6EA329179CFD41EFFCC6D7E8BD399B69F91BCDB0621B
              6AEC428745D0207568DF5070E8A7BF5C3169DAE453A74DB9F80B0F3EF57CEDBC
              871EE49AA46118CA2BBF5DEC4E4CA7872D79E2E9A9D17967DF673737B8BA65A4
              A4B433E214A8F8ABC7E70F001E0A4B303B0F6FC7EC7986BC15BD2FE0DD35BD22
              9F4C97056B2BA38D9FBDE5CAC9574F2B63E6038180CFFCE853C7282B96FDB6E5
              3FBE3E686EEF399F9995FAE9657FCEBCFBC62E5BA746A77FB0C11D123EE00C09
              EF77FA9807ED6CAA21FDCAA2BACC4DE7BF3272D9B7EE7CE496492F3CFB9BDF78
              F17899B06D5B72992BFFB0DCFDD13D0F8DA4A9CB268A83A44B21AA6006717205
              0F6BC78BC3783C5E27723830A693272252D37BB9BB717FD5A20933E6CE1FB6FA
              AFAB3C6E682E97F3469D72AAF2F26F9EDC376EDFD37727A64D7C231F10296B44
              B8DE2C0B6CD5156DA39ACF82929B541BE4D81B755DDF14AC36B70746859BB37B
              77B5A6AE38EBF96F8FB17FB170D173B950382250269B84F2F8BC87E8D7AF6F9C
              A0DF78DF69D96DB90005AC5E58EC04E58FDAA7BBDD42B70520BF87DEE789841E
              28B3EBD321F382F3FABCB3CB9BF0E8437339DA6F682C5EA63CF3C4BC96811B1E
              79A0F5E92776443E15CB6A42D94699E41672EC9D700AFB854A4D6207667BF518
              D755795038CE5E72B2752293FC286019BB82A787DDD6EBBEFBEE1707B43C3667
              CE1CBFEC2279B3EEBD8F9AAAFFF57CAB37669699541CAE354A790C8E1F03DDD7
              00C3CF634A1593D683E8FD736E3CE3D9175E8EE7B2190FBDE8ABD7CDB7DE4A63
              CA1A16B63DFACBADD1D1F10CA55BEBB026D92D14309D9669F1A0CC8BFBA52B16
              93A72C909E7FFF201C99A024A47B903C7B87C8A577863F6D79F60F27BD39E5CB
              635FFBFA451379C4401D9A58FFC11A5AF2E73523E9E2BB87D97B3023D003310C
              DF869C767C26DC11DD1700BA9254DD72D249CB1CA259F54EF998E5CB97FB51F9
              7CDE1B3C6CB8B8F2C27337D2C317BD658E8063CAB4ED42B3F66359D38639A623
              7ED9B5B716BF40DC5AB22184162CA0F62824F7399812D3EBF72C9B76CD943645
              C52CDBF17D9DF7FB575F53A9FF5963032E69987546A4224C2CB3BACD4FF705A0
              4A1640C06D45EF9F3EA162CDB6FD03B66FDB8A958DBFAE105F3AEF3CAA120DEF
              653ECAB7A956A499A45B2F7430BF0BAE6AC1D1872A865889344928B410AD6467
              0F1855468A962DDCF3D9C1E56BCFF8CC991878B06604FEB2EA3DDA9F090ED106
              852C37930AA04D0644D5031AE080514DF1577434F0CCB26DDB77865D8757AE7E
              5162CCE8935DDABDAACEC5AA4090DB8288240629472C3936F325882790D69336
              BC4D42D102895C0BE54CAF69CBA9A79DEA4733D51FD84F3B9A5295347078C84B
              830F7848A43FF11A002E14CC5D547FDD18AD0935B6B4FADE57626DC242A82C8F
              E768EFDF1358F7796022870C8EAFDADD85C1F9858D455D0EF3588F726D4DBD2A
              2B3846B0B2D9B91C35362782545663425460DE1F0A4FAC00E414485F48158CF1
              C686465A40CFE57875C9028075681A9966D046631D348999F63057EC3EF30CDE
              7D2C96E1B7D24E3966E0D070CF9600A7284831C03CC425BD203A4595A3BB6706
              DD93580485CB426518C674F2309BEC541D3A078DC6BFAFA8B881272BC474132C
              D78EAD3B025BF013F8F5F882B6481D5DA2D2A442DCF1A27B02E03582C279A486
              3BA87E694BEB0860B6397D0A3A732FE877A0BB859037836E138AF77DA1B83728
              8A3B4D28722AE8C7A09B10371BB404F9E0567C332BD5D095184BE1BC27A3E3B1
              6FF1F938D13D01187E73380F5AC90147E4BF140805C6D82C8525778990FC13AE
              F532246D19A134D6102AC53072809418C419978E8CCA9C0CCB3A69C937913E27
              788D6271193E7347AAEA90503856C0172862ED11537689630A405E8382A79126
              6FC0FADBF3D7FD219F31BF495D748B006B3A05E199ABC90C0E240B6B783D34C4
              0B46877A46749813080FCFEBC111F05D236C451BE118D670D7880C47FC30CF8C
              0C955A683085ACC1143007A0AC0A941540A15D31C62D81A149DEEB0B61280CA1
              BD01792DFCC1578F2D8C2E0450600CF36BACF64500FEA65C1AC101D2600642B5
              9E6A94A15FE00BFC8AFDB425F01A9E92AD32DB44467A6FAA22B52DDD3FB33155
              6BAF4BF677D727FAD2A6441F6D4BB2B7BE235D6534DABD8DFA5CB55E97AAD236
              B755CB0D893EEEFAB67EB90F9303D29B52B5A9ED99BE99036DB16C33B429972E
              4D01DA217D1354140FBED7D3CC5E5E203CC8B3A283A566F48556C568B8D079D9
              5E4C7E4474317F2EE6915871B9324E9ADA9F1A33E56E63C65060696A9014BD0E
              0B6299CF2A187E3BC2B22C41A77D26183703E5D4679445E1DE0699E5066931CC
              D40C0B4385E57A9AE548D5CAB8AA85F23C5371D29A6072D3E43829AC0932946F
              CD51A62147C9FD796BF3DB09AA1D12308C64B19602B036F228539FD177524E49
              240C374B95980944D51AB850536920DBDB8D31A415499DCE1D5542970B087983
              22A407B552B54A4AE6ABC5999346EAE3BE39880CC3F45C25ECE45CC31874FA80
              6C7A9E9F1EAE58B8AE436B3E581FB1879F73D30175A491AA4B1B2D8936AD25B1
              5349B42545329DA1542A43C96492926D6D9448B4FAF397683446E14884C2E110
              0418A448C8A2582422E3B1B01B8F8C718215E3730336AAB26EEB16BF2EAECC73
              31CBCEE62DFACA83139D713B9B359DB2188553D4DA9CF6563EF2A1D8B14A484B
              4F919B4FCBF18ADB04491F09BC25C6A2E1DD113687AB2B66AE7EACF12763D5F2
              CCDFA57429EE19C1E1CA9654959CF5C76BEF7D65ED8437DF781D6A2E29C10CB4
              34D1F62D9BFDFB1298218287739DC2FCA0134ADD70E4EE6857BDCE6A8BC9A7AE
              A14CEEC84359ABABABA9DFC0C1105E14428CF871974EBE9426F64F3C909D3179
              45605474B748B76D8539A49AAD31FC26C8EDB031EAF3DCB51374790C9302333C
              15133C0512F75E59F2122D5DB2D85DF6BB97BC3757AEF03E58FDBEECC83C83F7
              F8C03CB752A2A3786F8FD7F1BE6040708F0A5357109CA6901695222F9781A2A4
              93CF83BFC3E576E0C001FADB7BEF787F5CF1AAF7F2E217BCA52FBD2857BDFD36
              EC3028B166827FF2141E43C4B948DCC50E671702F06733857E28D6C9B7614899
              6F354D2B349757409D9C333F1703213CC91B9B300D08A548783E2A1D4AEB3FFB
              65148AFDEFA3000715DBA16029EEF31284092123E2FC1485F6B7F0FD91D1A506
              F8F93B0A1C01DC4046C70677EE157EEE1CF6BF812395C9611DDB02B0C058327E
              7C3B8EB257D4B509FC5FC251FAE3FF87008E827F880060B2BE93830D4B7811DF
              491EC1C47B043D2E00661EF6CA830ADBB0C0F48E9D246E258F18C5543D871EAD
              917B19BCCBE1278F526EBAE5569AF7F0DCEC9CD90FE4AEB8FA5AD1ABAAB7FF2A
              ACF3CCF244A3C704C0CCB387BE76EAF7C5DB4B9F59F7B38B4FBAFFEABE1FFCF4
              FA6175D31FFFE184C7FEF8FBC57BCFFA9773FC57613DA9093D521333C42A7ED1
              A48BE9E1BBA6FDA9FC17637F96BC63CA7BA9458FD5A59E99BD3579FDD7579CFC
              B7E9F72C7C7CF6F693468C2C68420F09E184D752527B55D3C5D4AB2E4FD0921B
              16B735503E343A9EB27A07765B3581BDD6B872B779E17F36D464DF7FF1AAEF5D
              E167F333F7007A4CD77A61DE3EA4A67C0FAD7B3761F6C6C89C4E34906BEF26C7
              DE23326D4DC15A4C5756BFB477D8A0DA14EFB9B2D07A6264E831016478259873
              C3640554CF41BD9A11845DF08E4F908CA0E9F04AB7D7E060229532A4E7B6FB8C
              138D132E006602F62C5A9B1BE9E5D7DEEA4FDF7BFC53D9F7B152B7B3BDA0E983
              B1B0186C372422611B5A31FEAACFBFB864299F4B621FD02366D0231A50EC4979
              D7CC99B4F4EFEE65B1677F7F9E6A44E208EEED649D5E81119FAAA247D74EB973
              EEA2CF2F797111F7BEBF80EA09F49800B84713AD2DF21BDFB8C89CBE60CD15F9
              A9AF4FA64629B5FE2745769DFFE46D136F9CF5C5E977DC71E275BE137ACC07C0
              A9F9FB018E93F7E6CE7E800E66A85C09C2DBF71B1E58B3A92EBE6841E16C564F
              D97E093D2600060B81118BC7493AB91C6DA614EDDB90D614E11801D38FEB69F4
              A8008A10FC3235525D5B41B39F3F9BBEFBE478336819BCDDF58F408F0AA0A8DA
              A27EDF5EFAEE753FA8BDE4FEE55327DF3A7FF28CBBEF09F2862AC7F5A4FA3358
              001D6BEC91DA33D92CBDF4E20BB460FE53F2D74F3D21DF58B9B21873A270D888
              7A188F2C00FEBAA294828F997789D2CC8CAF85FB8F3F54F31E80A2163641FF27
              F3FE525B4A6DC34DE1DA11FE69FC76743C5196E59A77814AB9F83435437AA4F1
              2BA7127CD7ECD8FED161595ABFE396772C316911523D6CF7D7DFD13D8C3A3694
              891DA2E7F22668615FB1737CE7FC9DCAF63752B82D25388EC35C7A6E9EDB58EA
              645CD1402713826DB507964EC532EFBBF9873F2028E10B7CC6BEE2AEF73DC708
              430AC88D8A200D4FE8A6515E55CD2751D448342E02A62584A2712BB07A93C23D
              6CF7D7933C9707B5036D2C513B501FA8F870087EBA4EF0855E2C9B85E76FA420
              3F9AA00B331812D17819D4495762E5986092C6270BF810AA140EC9ECBE0A517E
              CF6AAFF12763F8D4C1BF814A7893DF0C2D05F1128CBDD05008FF125CE765D55E
              AA4E2D2E4AB2F9B082B267F5967B7F7C65D58F2FFFA6C8B83298CCDAC154326D
              A65299405B5B526F6D4B6A20A5359912E94C56A479EE9F4C0A7E0BC46F8012AD
              09AC075294C5E8E7A09798F2791BF255483774D2349D745D2733680A2B14A658
              344691689442E170E18D51304821CBA468382CE3D1B0876B3E1C09E543212B1B
              0E05B3E1809E096A225B5B5D61D3EAF907831504F5726C99C7CAE26084F9E4CA
              BE85EBF022AF3EEF02528920E21D3CF027268C03A0CF55CC5CBD35F7A3784C77
              5AD1ED622025BCA830A08B65D50645C23A85431A85621A85AB758AF533C9AA32
              C98807480B07C05188142DC8EF00F352B57252B3D2AE6226B2AE99C8B981A49D
              3793691BC24B9BF003120C64C241231BD6F56CCC54B39180920B2A6E26205CCC
              119C8CC2EF0CDD7C9AEC5C869CD62CD92DFCCE304BAD7BB2946A702895702899
              72A82D695363BDE3A9E48AA072109A5467EB958DC17B1B528DB78F1D04BE58DB
              6B98496023E2C7FB568EC84B71791AC406C48B113E41CE5F8C6C95D328EE09A5
              8634BDDC71EDA0674B9D5CE28F2308AB3A181F94980F33B8F0691E948E090AC3
              7B9EA0C29EBC097BB37017444F58718D2221DDA75085864224259BF2D4960625
              1DCA3483320E5CB34B59A8312C9BAD9BABF3A0D6FC790D2C132E8A3C052DE5E3
              9182F75435A405E3AAA1E655A122B7D3A0B8DE3E31974ACCF31723A341A52F46
              2E077FBF128D778E131577FC85BF19E2B928AB7FE9BB9AFDA03B542FF35CFCEE
              8D09791A8A1F838C2604049F845F7E2BCFAE84850897EE8730BB4C7C945663CF
              83960B084AB05785D074084C87C0149F233485A5E533C162D7D0732AE5158DF2
              0877115E381FC405091635BFE5454EE95FF9196A5E105231D481D01C5A4C3991
              24AFF93F4E8E78AA3911B13341DCF3FCA5064F391782F9492D33C78A0E5F8D8D
              0D23824F3C7E0E549212E323D00A106B45C793D60C5F837C140604B81084493E
              AE563CB2C621FC1E1FFD831F2616193BA943790BF0BD3882F9AD249FF8E3E792
              EF46109C71613C4388FFB95521A6808EF70CEE40F6F6ECF0D8E619259EDE45E2
              0995335727C07361CDCD3710027F4CC042E037A7FC1115A3E42CFE99C1EBEAD2
              56F3F360FEAA12F3CC737B2F94028AF7FCF9DC2DA0D2BC80C152EE2CE94F2A98
              AF8E1AC61F49F097A3FC69E061BC1EA6861CA1A9BA8C4D5F251B311F402CAB10
              7F53C4DF0EF7071D75A6F80902DB3A4FF0F82B31FE767845E55D6B12CD334E17
              5E5EB2C9FBCC1311FD175A0D6866F9FCC9870000000049454E44AE426082}
          end>
      end
      item
        Name = 'Update'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000000F0806000000ED734F
              2F000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000032849444154384F65537B
              6C4B511CFECEBDB7AB75AC5B6B8A49378FB56BCDDA86CCC4632259482C986012
              CB62118F4558268210F126FE43C2B07F3C4222FC81651631F18AC750EC614C37
              CF62619D35CB86B6E71EBF33221237F96ECEEBFBCEEF713E16DAEA4B06504970
              117A05A0709DE99A82589C422BF44574B0980E555584C2009D9612082F096552
              E03C0D024683D8F5B28329E3D34922E74B7CEBD5B03DF0960F65101893AE7538
              6799DFE35ECA777F5045A64DD77F46D956E239A440539CA64F1CB4ADA14F9C50
              4D9F9BF984B53528F17FC6D4F04F58E910128DE8CC198E3B47E7E0547296E667
              C5B1BE9E1D1E5324A6D483041EDE599E9D24AA55E3AD5236CF69450B71288CFF
              417BCF6F94B242719FC53595FBCC92DB9FE5948ACC1F68E78EF25AB1B9350417
              251A1B6DC1E3452E1C2F72E3F8180B9AE335C468CFBDBE566C449D709A06A8B2
              164CE35C4F38B7BF7ADAED364C79F1053E29E81D8A7B870B713A771AAEA1085D
              CF2B9075F6193C6949483431185A83D02DC33401CEA10C8C03BB501F2DADBA8F
              0D1181FE88DE7523F36A13EC78831EC6D09375000FF61C412D5DE238F914139D
              6E185252624C084AAD8BF2F8B16560EE743BAE1057A80C7C69362AC541380A9D
              D0364D8726F6C135DF81D3D4C2FE5A4C4A455D705DC264C94527FDC47E5FA238
              046F4106CEAFC9C141D18EB42AEBEF68C40E0CD936197BADF1E8A0A94E1171A3
              8ADEC52EED4CDF764F8B7C182CCC4D7A4323F8EC0CB4A45B102A2FC602F742E4
              8936583002E699D9786B37E31509307A5CBC220FBB57E4192B7B23E09ABCA5B3
              3BC23C23115B56837CEAFF2403DD7DB1058171D7F150E6D9F815BE60186E79D6
              6343FDBE425C42EA8C375D4F83DF6598224A2F02F96A5BD55CB6870E3C895283
              DE87915113C0922B6D2826F25819A9D706FFB1396C2F8628017FDD3BA3149402
              F1A94922CA7278D4E7556F3C2A431915F190C38A465B023E4A382C6828A1B5BB
              2BB1DA3B4EBBC98AF4A8D3C62292FBAF1776B677AAAADDAC23A92064FC76AD6B
              78FD6B6EA5B28BDCD15A2879A6E553F7E5E4C8876E86518305FFE305A714B0D0
              40BA3193F0C78DD055C6B841ED771EA21C2A1782DC086AC25F37B60258F50BED
              E852AC6BAADD8A0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000190000001808060000000FB556
              C6000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB0000069549444154484B65560D
              5054D715FEDECFEEC2C24208C4F013909F08ACC6A202D1E8389924EA9488ADA3
              89A49D34AD74DAA449A658A6B533C5D4748C4D4326D3A9B6939F76AC3A9599C6
              6434468DF931496506900608441058694014B080B8849FFD7BEFF53BCFC5517B
              76BEBDEFBD7BEEF9EE3DE7DE73AE02CAF80B4BEF60F31BE219229E3009BB2F2A
              5614B78BE8DCAEA71253C49BC4EF9377B54D285182134421B187F0111A611B36
              2CC50A472C0D96A939144B53606A1614336CAA11A8AAE1D0154353AC39328141
              DC4B5411BDC4A34252CB874A623D59CFB2BD45AC67E1C64A2420480C11D370F2
              4B1819F0B3F5E30CBE515EC74C54FD86D0EEFD6C4E12FB8564920FAF91E07763
              3B8A9C6EB76E0E0C7F8384C0404A7A6124E3E2A095BFBFC52AF97C104523D348
              0B47E072EA08CE8BC3F04399F8F2C7254A4B4686E2BBDCAD5F9A8DCF1E4B4BF6
              20100CAB292FB58768FB05DADEAEF32F8EB84020C6A599674EB618DE45C848CF
              C582978F61DDEB6DD83438897CE9BF59BA46B1F0F37E3CB2AFDDEA79AE18EFFE
              6AAD71FAE2D73DBEA61E5C5AB9BA742E7EFF21DC1224F92031C0F86800DE42DC
              9D958982270FE1A9DFD6A35A08540511415457C452A2DF062651B0E30C7E51F9
              4F7C3F2B17F98B32913A3016D58AC6564844ECC12313FDF1595E64571DC5A6BA
              4EFC3062C2C948474C0BBAC0A522EC7162D2A9216445BF91CC081988DDDF81CA
              EA23D8985A80F953A39D1EDB6AD4AE4D627207497B7F5628F570134A0F7C852D
              34A270A68641431E07AE6DF6E2E0818DF8F5A715A8AE63BBB11075492E8CEBDC
              4F2E0D013177B0038FBFDD80E292A59139125B743116AB0513AC6348C5A499B6
              AF0E0FFB8348911508C13D09E8A97B027F595D823E0CF2A761BCC48598CD8FA0
              E9ED4FD070E63232DD1A54DD010423702401B3FCC939BB21BA4B57226D83FE15
              B575587057A2E53E3B8CE5D24157687485599004DFA13678BB0710FB9362742A
              BB30C4DDA2FEAB1CE35BCA30B0C54422FD317FB817399E5884E239A996569D5B
              3A641388A88609252B419BFE6A044BF67D819F4E04B822FA92AB57C489A70750
              FE910F0F2E998771B8ECE0CB9FB9EA38FCBBFFCA533386D8FA06DCBBF84DEC5C
              F606B65D1E4556F1E260BAE8298A62670E955155133D31177C3FC74BCBD3D064
              7FE40A24A0D450F3EF44EBE91FA0B6D48BB31F3693282AC7CAE0A9A9405E431F
              563EF11E7E391E409AEF1ABEB5EE20B65FBE66155B3B911A0A9972444C95C6AC
              403876540FE1FC874F297FE68C1BC5555C8A46822F4F7D0F7B73EE40C7E926F4
              7FFB04034CF97803E236AC417643271E78FC28AA87A6902393928DD2358EA5EB
              FF61555FF26389DB359B626F208E519D0ED5505EC550A25369AFDF8A3F2E4CC6
              BFE727E0FCC90AECC98943FBEEE3F0AD3966273D1165CD0AA49C68C0831547B1
              9D04B9625C26259363BFD9318AA2D57F43CD987F365F5715D33E8C147B2B9FBB
              E01C8A77E34A6715F6F457A136AF0057908970CDD348EAA840F2F37190E52BE6
              55382666E17E7605EACAF37084C6C973FD4CDCE5C660CDC3A85D93878FAFCE30
              85D25332E886DCB7CC8839520FEFFB17511AC303279B22C89C5A9A8EFEE7CAD0
              B8F7015CD93BCB541941C293DF45D7FE4F705F73034A3854E2686FF955F7A069
              D78F941348B6CE4D35273E1632ACCA5B48C05C6EB880F7BA517E3580BB3595A7
              DD847EB80BD3EF74E3B3EFE4A3799E1B53C353F09CBC80E2C641AC0DF0B4CF9D
              A994580CFD6C393E43973AA2FCC1BC3ABA439FF9BF9534363AA61F5B15FCE2DC
              300EBCDC80AA900997CC7026823826C3F2FA019491D820B116B9EE7F1EA6EB04
              4C3581E78B7168DD12B4D4B7C68C48DDE258A92FD7D30AC57EC92E5834DDDF8E
              C117CB716A5B29DE723B98036880CAB273C498C23CE52081ED1E0EB6D38EE855
              95E0AD9DEB71BCA71D1717E52E9CB6AD46ED0A893C4835439C1A56220E8CF6F5
              C2F7CA261C7E6D2D5EF126A35574848CED9CBE2AEFDCB68A3705ADD4ABADDD84
              77BA7BD05B7810FF756821DB3845EC2A325058F3E44B2462AAF3329661762638
              D273BE2FF0CC43117F659179FEEF6D56D147FD58CCB49F1E3658B4E81AE6B4A1
              75D9E8D8BA4CE97026A95FF776E94349E9F913FE17753D443B628F9243CC4A65
              7C950F5B8947591D9BA5E766B13630996C868711F0B0D8C6726F29886102BC93
              25374CC7D7B1FC9EBA29514585764BD97C40D8E5572E12F2B280F813D147CC5D
              24A40C9861C3522DC394D8301FD9C9939DBC3DA88AA1F31611BD4888482B2ECA
              25B6115271CBEC4E123143A386789A90727CFB9548E496F44D91FEDB756462E2
              2AB958BC41EC4EDED536F13F3027BD86290F3BBB0000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000200000001F08060000008656CF
              8C000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000009A6494441545847B5577B
              7454C51DFEEEDDF76E9EBB9B64C926590884870805445311EC51D4AAD516AC87
              5ADBAA60E558A4166D3D8895D31E239CB65A1FB588542B3E5BB5B515EBFB51D4
              565A51096828AF9098259BE7EE66B3C9BEF7DEDB6F66B381A8ED3F3DFD92EFCE
              DD997BE7FBCD6F7E33F3BB4A64E37C93A7A555635903601DF96DB28EFC7FA09B
              7C92BC879A7D425B11B5BC99C76207D94076926DA44E7E1A06A018BCF01F0A0C
              43BE0F4511BFC50FFECBBA42FD44A8E46CB2913C462EA3117B8407AAF9633719
              20D7B283873D2D7B53BCFF0C5A97C19C33C1E1B5C31A70C1AA5A6115F57A06B9
              6012D9BE24D2A634D2A7BD8CBC7CE153A09683C54A720B298C385518B08937B7
              906B69916840E4D6798AAAE4901DCAA3BAB45F890D8F38D219DDEBAB84877F25
              748213232849246117EE2871218352D64049208CD1BE18A24E9B1A2E2B2B4DF5
              9BEA0C9BA1C3502D70B7EC139E12867C8FC5FDE4CF84015DBCA1C5C66C8E3C1D
              D9384F35216154B41C318C0D5673389AF3BA6D46BD3A0995DDC7E0BF6F0FE6EE
              EAC6EC9E047CA91C5CA2438705895A17FA16D561FFF50BF091BF1E3DF91E0C0D
              6795A0C7630987A2B3349727035DB52BD4D023B7CEB77192C434DB8501C2AAE7
              38FAE514E7C8D3A8BCED20C561198CA0B6CA2DE7CC77D58B38E72FED383F9A42
              AD10FD4FF038105A3E1D2F3D782176328AFAC243E8F45621A46C424EB40B0D1A
              6150F74FFCB95C0486800C3855CF7322F3306E8679304CF11A4CDBDD8B594DDB
              B0FED18FB16A4CDC5014E89F47D11649C1FFD03E5C336B1B7EB877103329DE14
              1E441D0764961AC7C3434E47D100093DADA1DA1152078750555585C6773A31EB
              8267B0A17D085F9022425C3CC85739F7EA8994EB834DF2193E7B308A53CE7D0A
              EBDF0B61BAD783C67014D5C62D4E55CB4F909C6880D96E209ACDB8AA9C082452
              A8FFD6F358CB51D7A90A342942081D925530EC2624ED6624C4BDA8933670718A
              E7B8C073E12402973F876BE91B9FD785FA702CED722A72E18C638201B964B749
              D78C6A54C17DE90E2CEB8E630647A3E986E80F2CA0D8287A56035EFCC5526C7A
              E952DCF21A79E739B8FDCC7ABC6255912E7A443360117D76C470F2D94FE19B70
              A30279A3A27DB457386A1C725E08A563391CD168C2D75465F85FDB8BE96F0571
              9E6C6167C511BA1DE8D9721EB65EF6451C4016430CAB618E4E59320BCE1BBF8C
              F77EF306FEB16D2FCE919E90CE8292D761D67498FA42A8F095436DED140E3B8E
              82017ABE6CCA42EE522ABCF041DDBA03A7A7F370C9C032A4CB158A873EBC1AB7
              4F9E8370BA0DD6541603231974A634E89C06679915D5AB9B31BCFA6CBCCB38B3
              D2C032FAC0CC85AA716F5073A3E8A5C12367CC2865B0C6A4AC00A740A17F75E7
              D71FC1D5676D35D67D751356BE7D0C67CA568ACB92A8B0217AE36B386B490B56
              3FDB017FE524181DA3C8CD7C1CA9C9DB1171DAD0DE750C6DE1761C1CECA4640A
              F9F70FA17AEB8B984B152D934586CECA8ECDCC385431B136939AE3861CDA15C2
              D95CEB970EA5E907428C5C504C01E772CE9F0F6345220FFBC58DE811CEAF2D2D
              2C5F01FBAF900B546124C317AA3C7045B837AE781E577FFF4DDCF48B7730AFA4
              019503097DB2231314DBF138549512A339E46E5D8E9D8F5D88DB5C16CE2D21DD
              5F00BB2C6009036DCF75B8AFCC86602C8D8119DB4F58D43FE23C47E1F37BD0C4
              014C6E7E14377C328CD90C46F3C6BF63DD9DAFE04BBE46D40FC4B5A9C61A19FC
              B25FB90A549379B86B1F42DF68565AB79C8B7BB8B5C6452433FAC4DA979E58E4
              C7EBEFACC4A374EE603481F60A6FC1500121DE1F438DCF8369F10C02CD8F61DD
              D118E68A41F07D3DABC1FE631A71F7AB58E29B82FAE0883C75E5F41697A11170
              23D81744F0CA33F0C1AF97E22E8719714E8F5CDBA7FBF1E6BBABF030E2E88F66
              71C85D8941A5A5E021632394481CDE9A1A4CA550C3698FE1FA23631B975C92D4
              281AB1E16FF8C1FD6F188B1B16C0AF6BF972F17ED10045B917BAAFC27CB4F713
              04572DC1EE7B97E26EAEF9D18593F0D6AE55F8AD11C7407F0A07DD6518503633
              B2C7702408ABA71C351FF760C6CC07B1FE50140B44CC505C8E50401821CA8C06
              E7BA9D587FF39338BFC40A8BCE7DB5688044C2A84F4D2A51BB1221C4AE391587
              FEB80C9B5F598E6790E42E9D43D263822D14863BBE86C7F04D05818C3862EC50
              0E0CC27D4A0DDA6E6AC67DD3DD6865AD0C5E41F15C8D0B9FAC39050FAC9889DF
              8D6461C9E60DB370CD0403921A07A61856854907CF7ADB4573D1CDD1A53533AC
              F672F8CD1ECCF137E0648B82995D61F8DAAF4059A51DCE703FCC2B9AD0FD870D
              78FA2B5311EC1995C94D01635BF3D2C9787BCB5AEC78E23BCAF62D57E071CD50
              47856DC59D50E2859E51656500CE480255173F8D6BA23C99CDAA3C46C568E588
              2E3F09AFB75C887703266EAE19A4659B85DB0D0FD1CD8F60D1A65DF86E32878A
              E2C8451CD0DD43372CC47BF80889B641A5635FAB3170C125261A707C2B965850
              E731FA22D17C7D23C2817274EF1BC0A2B1A671DCBE0B27733F3863E914BC3FC3
              834106AA72388CEA9D412CD81FC669425088535D914B99ED174DC30B0B67A273
              A043094DF595F4CDD91FD7229714FA9B6040A0B209FA68FB30FA8DD88ECBF0EC
              9CAD08B485D1CC1EF33290781125859A05592F83511C56B203A2282EDA44FD6C
              2F76FFFE6B7849EB45D86E53FA735A35574F7CECE94FC5403ED903B7D7958E66
              983072A37979051E9A528E3676649651CDDE85801C194B2130265E4852A47D05
              8AFAC60AB4BDBA02DB383D3DB10CBACA1C25A9BCDDCEE6E39860809989686FB6
              C1707B10191A41475D29BA3EB8127735D7E2AF6C16F978E1CC17175EA5688186
              A813D5A4E85311EF7C78057EE92F45476418473D1E44953BE23A13CE09281A20
              4B5DE1B166C983F99B565981DE688CEBDE8A23FF5C8D2D3F5D8C3B026538205C
              2B44A431279275A26D7239FEF593C5B853BC5361A1780C873DB5E8137BC7F086
              2645688C810EE3E578560C66C5AD322B66E01BC96103B5CE0E353A9C29B7A9A8
              774D32BC4CBCAB1ED887E96F3255EB18869FD12EB3629E1FA39CAA1003F3C0B5
              F37098897B38D1AB4478F41DAB2CB7C606E375BA85C7A9AEDA9890B69E98153B
              84019B79B381BC8E8D22579799AB494B6344A9843FC570C8F5D9A229CDED73C2
              6BF2B27BBBE1E0E2B4F3CC2F38D4C601587800A794941646A2975F079525A621
              97C997E929F1C1697027638A20B2E142FFF3AF65B195FCB930407C19BD4F8A03
              620DB95D7882E567B0E73C26164ED86C56D86BEC30F1549411174FC308259117
              673ECDC82E7E63FC249D006A8908BC8A14E2E23B71A19C07362C6021BE0DC547
              E951723F29ADFD1CB07EFCFB701CC50552B8FD5C88FA93C869A41017DF861F0A
              0F14BF8E4512720329BE8EFFEBC7C7FF805EF209F22E6AF2EB78BEE9DFB5913C
              35AA628A870000000049454E44AE426082}
          end
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000400000003E08060000009B411D
              6F000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
              000970485973000017100000171001186111DB000019C3494441546843D55B07
              985D55B5FEF7ED657ACD642024840E9A800AA108529422044B9E48AF82140DE5
              812D01639466413A0911049526A14BE7E1138480A421351002816492E99972FB
              3DE7FDFFBEF70C33C9DC9989F8DEF758F3AD39E7ECB3CBFAD75E7BEDB5CE39D7
              601075CCDED5C007D4CE59EAB6CFDA35620CF667F1E1E42F922792CBC843DAFC
              3F2497DC47FE80FC1CF91117EEB3757397253B2FF99C711D07B57397AA8EA501
              3004EFE30DA778FE751E7E4CFEBCAE8BA4461E6F0E7D5285FD2BE379ECD112F2
              A5C4B7501783B1DA4A5E41FBECA9010373358BCE523929470E144E3FB53418C3
              3C02FE7ECDDCA5190FB3E189E189DB46F03E98FB58E908F2E046ADE4BF92FF49
              96697D522ACC8CEB0E9E21961A6FA63777C687232DD55DC85F2237AA80E4617A
              8C7C24316785DD745C424DCC59EAF0E21ADEF81E39430E9113E45F529E9B6AE7
              2E5BC7F37F0BB95F801FE3C911B24F1E4785FCEB471EEBC92F234FCDFC3B9480
              8E59BB3652DDA7F3F422B294922687C937520167D127F8BC25309D8707C99E96
              D692BFC94A8B7884940467C89AFA98549A057C6ED6F8FD09E3CFA64C00C9802F
              9F09C0CD878C71C270DC30673CC4AA411837E8BA3C027EA2B40A280216F02C2F
              D89BC9B83014D6A4607C190781AC1308661D7FC4C9F9E34E3E17711D5FD0A50A
              4B930FAE2656A7C4F7051E64DD5B903D8CDF20BEFB4DFBACA94163CCDF58308D
              2CD2CC1FC09B2FB1A104CDF3DC76548ADCE329768D051370F3B41ECDAF418CB0
              623A3A2E227987EC22C4F380DF5896F6A53E8B3EE780FE19391666792FEDF721
              C50E93BC9564CF094E808E292E940CE731C785E99885235B0AE5974C7ECA2F73
              97437F962C4B10BDC2D6FBC8077C85174F903DCDFC940DE608BC1AF2BA24B987
              13C0048A15266407214A23D0652C2DE30A2FCBE5C90E62613F827EA924CABB52
              A980673896AC4A10FCFC1FA2F983251A3101934FC349E7910DF891A0734A1078
              1F6BF7F26E9F9132825483A1CC41B8E632DB4B49F2B0F0F8135EFE9CEC613D4C
              0AF82D4F669245EB096B0AD7FC7A960F6C15C3917B2C876FA6196710E434C668
              D6E52CAE606965368F724E673C12A772CA295C12A19756A3F6A9D518FF662B9A
              3FEA436D4F0665195A0B25375450BA328CBEE6383A7668C09A832760EDEE13D0
              4175A6D1035F8AF34FCB48047D56011B2C5319544482B696451B97CFADA59540
              2CD6D1D327D4B3DD32168D2FDCC1F552C0529E4C2D5CE34E563CA6E36282FFD9
              08E08F6337F57605462C7007552CA9A6895BF0D172028F012FAD40E3754BB0DB
              A2B598B2B60F939239548C385524AD8958003D4DE558B5D7782C3B732A964EDB
              9E13C3F94FD05186FCE8E51291123A59B99BC73E5A479AEACA993F9656422727
              94DB9F9CFD1F78795CA114AF698D4C227B0DA51D5DD9B5391CB967135C9D35DF
              A82BE040036B37A5F2680A04501DA5DF7DEA3D34EF371F271E7017E6FCF10D9C
              F06E37A6248AE0D9B1C308B3C03ADFE85A75FA59F7DD2E4CB9FD759C78D0DD98
              73C0021CFFF25A34C49A60B81C6AB834C6B17E13E5D41657C536518CA3FF9949
              D94A10EB78980A18B5DC18DDAA814CD753404FF1382CB927B113AD77AE66D767
              67BD9EC58D9CD9FA6825421B72887DED36CC98BE1073FEF6110E21E8CA0190C5
              31F8CF47AB29B0CE37BA561DD5F5DA511995CFAEC66107DE8D9F1EF5071CD947
              871AA9402491A5E20B7BBCB89A931193FB757F5C5A0945EA2F1E4571551EAD81
              25F748CA554EF0396BF65544D2C063433A87DA1867FDAEE598BCE3EFF0A30757
              6206AD215E9C51561900CACBB191EA7AEDAC32D8575F1655F7BC8DA377BA0517
              3EB902CD31DA5D2A873A0E2005346819BA592A2143251C35E6B1CCD8C01FC30E
              B765C70182A79363511D9D5C03D77B6DA401EE790F619F131FC5AC967E6C3D00
              BC30A363065D8AAC32D897A7880F7BB1FDD71FC0EC1F3D8669D171703239CE3E
              AC25D6B37225F7920855E277CF18DBD8A32AC0DD821DD5B19EF677393C835A0A
              5447F05561EAFDF8BB71C86F5FC1D98C56C212F0DF057C631A5004C7E0D22ABF
              7C11669EF300F68D8C478E3EA19A55E4E16511159436C4CD784C933B7AA5232C
              98003B8EF35843AEA3E9D544A8FD53EFC5817FA4A3523556B2E075BE19445C96
              C74C9E12747EFD629C39F37EEC1BAD8793CC5A25D4B0B76A5A699C1316B00E7B
              141AB1827B327105694E743CBC94E9D770A09A581DF08BA7B0DBADAFE254D593
              7912C5A883A99E14C5530FB4942B16798E6F5485582514FAC1758B71C60DCF61
              A7582D5C3AE36A2AA79A77148FC85DFB6D943A029510BA2803633AAEFB006B95
              B1A82ACB016271045F5989C62B17E154D662146DB7AE110729829292AC735311
              F7F25C34803EEDF9DCDA9480798E8F5D5A65A84D49525D8DCDC1FD173F8F53DE
              5AC3898920C8E04A1355C90E622E276F64C94A29807B9C732ABB57078CE15952
              CE012B5912A75ECD898FE3184672B516FC2866CFF13D05998628561FB8151EF9
              C1345C7DC76198F3D83730E799199873EFE198336B2F5C7500EFD547F191EA8B
              D5B6D0CBF0A4B1690AF98E14C67FFB611CADE08B14675BC59F312E8360314721
              B174181A56F8103A7DA6C2F5B939EBF8E214BF82DB5D45B016CE0F9EC01E6FB4
              637756B39EBED06253F26690FF7C4D71ACFAE11EB8F69DD331F7E9EFE04F971F
              8217BF3515EFEC3709ABA74DC09A2377C6CAB95FC14BCFF0DE5BA7E167A74FC1
              CD7551AC515BDB59A1AF6199DA551D77792BF6FEE57FE333A13AE4E9A3949344
              C8019E156DA078D8883606606B85D3EDDAEBA54F054995CCE42AA341847BBB50
              76DBEBF681C900C0E148F778D3F6F5E5897878D519B8F4B243F1520553A0440B
              4CB20DE9540F7AD20974913BD3BDE851597F0B9C1A3FFAE7CDC0336F9F8A39D3
              C6E319DB61A1AFD118572FC68CBE4EC46241F8988405693F3E86C8C63D9C7662
              6B6C4ACA050444A6E6336EFEBCEA95AFCECF37051B99DF33A3B69AAC51A4C760
              C73FF341EC770D3D2FFB1A00380CA93FC3219DB3A7E2966BBE85BFBAEB106370
              A438BE8FE58ADFC5FDAC59C836B5D8985790A38C2FCA385E795994B3C70CF2DA
              17B1437B8AE941216FF4806879888B85F6E86699529FB4235E9F548535B92CD6
              3259693141264DBF863241A5C5791EBFCBEA37920B98072BC09F4FFEB4A2FDAD
              BBB3115F23E59702C2BC19E7B12CC44D709B79B86065373EC301B5AE4B9ABFE8
              D45D70DB8263F074EF472867B697578E5F04CF8C13AD94BE877D64ACF032D582
              12A2E4729655104C25C78D06AB289B1257CD6661CC00CB9588E95CCD3D520D65
              8F69278F368EB596F53A5833617E433F514201834018EE19F90A538D8650040D
              C130EA821154858288876A915BF816B6F8600376504D0A3E78E001926274DCAB
              194F2F381E4F324D8D96C790657F397F94292BE78F6D15D165583365D359837E
              C6A33DECB49B37DBD97C1D15B2963BC3477E1FD624BBD09568456FB21DFDC90E
              2E9D0EB8E94E04D35D08273B1125C774E47528DD0E3FC1F7B3FF0DEC43317F86
              7F1C52543C6C44030A903D65F2B9B2856F62DB175ADCF17F6FC1F8E75B30EED9
              16D47DD0868ADBDEC0D49C6B737FF5B4890254CE1BBE8A103AFE73773CFBCA9B
              68F85B2B2A5E588F8A17D7A1F2D1F7D0C0783E4C9507E853B4BB38ECC9315751
              315731954D58A5248D9FCA70AC225AD8E787113F3EA0FFF93012440BCFBB684D
              8970005C9F34172A97A9773A1A4156E3B33C471C59F69BA140593B8AEC6804F2
              9600853726EE76DFF4C59BDFABFE67BBF966D0E72A33D4BE6CC129C1A163D1C3
              D2112948338C04D0AFFD59EDD8D8E10E52B6CF1678FCBF8EC21FF219B4B1CFD5
              9CE1568C27E00B29E420722F628B3E4E4C80E2EB4F0F4D8CBC818552478075CC
              046B980C6517BC80ED7FF9328EFCD361B8FDF313D19AE8864307D84630EB5857
              4FB37B28439A1EC9E9AC98EAAB9DBBA4E412B05A624A89178FC19FB7AFC512CE
              568D32B07E328FD563012FE2DA0DF76650C376956ADFC7F31D6AF1CA1347E13E
              82D1B695A743A34BE498AB8B8D0691B992E58B299C8F79A7839CAB592CACFB28
              C1C7FB33883312CDDCB31893CE7F1667AFE8C267A73F80B3190855C72AE05239
              8A57B4FB57537D650CE442883B3E7F2E455D6C4A1F2F0172C631F9003DF3F2D3
              CC8D531AF07795D3996CF6636AD5573B9D4F6DC4F3AF9E8E79C13C72CCDCD2B4
              907E7696A6CB6349897EF5C04A2A5002C65D811DD610542DC1D7C4EBE0DEBB0C
              134F7B0CE74BD18A2899854E3AE0CF3877450B2DA302012AA18E32304F050364
              0671298442F9AE01AC836948A1CFF8FA73193AA614DC6527E3E6CFD4E3459932
              05D82C05A8BEDA7DB6012F2C3D050BD8A39BCE2219F2A19BE6D9C3FB7ADA9B37
              376EDAAFABE46B4B2B5798B3AF985E665F4F8BAA277873FFAB9874CA63B8A097
              56C97227CF1D44472961FF3FE3BC95EB514B2504A984FA0125706709B87DC35A
              F02005C82305FA699E6D14364117927FF564CCDFA50E8B28F44006361AA99EEA
              4B79CB4FC1CD54A67C4082CEAB834B8C610936B0273DD8B6163298DC438BE0B9
              8CB8EE957A17C0675017A7513FF44F4C3CE95182E7CC7BE3D87645F9D6F663EB
              FDEEC1B9EFB75A4B080DB6049F93F61E870FA121164005F451ACD650001D5609
              39E45E3D05F376AAC3CB63518227D42EF558C476F309334FF0490B1EDC147934
              749086C66FAE1E3AFBEEC1843B91F2F80766BEDE824F5BF0FEBFBC8E0927FC05
              1794CA413CF9D6F461F217EFC6B9ABDB50152B47B8A8847AE33875EE74C51A4C
              7406D1D04E7CFE14C39476D7F85A2974BBCC56C2D2126EDAB116FF1849099E50
              3BD7E125D69F270B1A045E1E993BB87DB79831D76D3AFBD8B908DE37C8EC35F3
              B5F03FF606B63C8EE037F07A38F01E79F27DD4876DF6BE0BE7AEE9282A21837A
              9A553D9AD9DECD2BE21CA08D3A328EB91F592A804A409B55420649BF43C77832
              6E94371F4E099E50B4947FB0DE3C43F396F206C01B0BBE97F5D2E657C398FE29
              94432F56FC36F7D00C3758F0F4E34FBC892D8E79041774A7AD459404EFD12025
              6CBBE75D98D9D289CAA225E8417E83CFC90D590AC376E698B066AA5DC27B4A08
              6A773809376E5F83C58395E00925E52CE37D3F2D6600BCB1E0DB59B3D784089E
              418FDA0C2682D70EAF274E0A83E5D8EAACD913FCD32BD07CF4C3167CC358C07B
              E4C9F7612FB6DBF34ECC6CED4245AC0C6166890D4C71A9002E8A220DDB612E50
              A6484AE1882CC12A2195A617A7F92E3D09376C5783251A845B5D4E472945E083
              8E9DF9D4C0CC538916BC62F4DEA15633407A7FAB5C80390785AED4E3B67803F0
              DC4A347DFB219CDF9546A3C6619D8FA51E9DF4BE995A40EE835E6C3FED4E7CAF
              A7CF8D47AA11CA3B793DDA1BA061159071ABF5684A51B42CA18320DB18DD7550
              09E9283B5D72226E9412B8D50538F38BA9949BC2341C82CF127C37C7EE24DC6E
              2E8504E3FD1C4DCFE56E303C695F282443E14C1E65913802772FC1E4AF2EC44F
              3A526852158DC33E374701F6E992DAE962550F76DAF9365CB47815EAA31C89F7
              06685805E44311A6123E873397A1D1EAA5641795D04525F4723938F120727F99
              815B0EDF06F73D3A03B7B2D33CCB41F029D6135459909E6B85E8D4C29CFF30AA
              08E24286D67AB9329812AC47291869FAB8FBA03F81D075AF60FFCA103AB7ADC2
              AB932BF1DAD695787DBB6A2CD7E3B362AB5264B1B16DBBEAAB9DDAAB1F0DFA83
              E7B02FADCC237B36241D269FC994F1A68ED953993A2ECBBBE7D84A41DE29A390
              DA4F9BB546296C59404F0A2B09AD1BE11C573663FB343B5206D6CD7A7A89E929
              429CA22215FCA4D93ECBD1F20A8EDC951460172A45AFD2D93FEF6DA9576C4C7C
              222C512D05C47A07957E6A199AA7DF87D9CA49D88F641EAA48120BA87F987376
              C3BC6B8FC55F9911E8A982DE04332C635AB3C1E9DD10DBFAE07CA8EA2C1659CC
              C35AC000E905748802FA6DAEAE6703C1640E41CD5632037FEF3A94259973D9EB
              1C427A14A5A7C6891C9AE875B7246FC5CC6F8214C79EB4DAAB2961992B806508
              99DDD86F90919C945F707239667C19970ACDF5D069F5724CBDE9E942E48C2770
              827DE35498AC92E0652547EF88156861BA9C443EDB8F4CA60FC9748F9D80769F
              CFAFC919A0120A28F6AF1CCC610AECDA8F1C2A7C7EC4A2E390893422116D407F
              F978F4461BD16FAF1B9124E762E360E24D08C59B11898F473CE0473DE3012940
              3C9E2336B2CF5A0A5B45892B390F95B42E6D7F51DED723782B13956AB8E41C53
              8DD49E77E068AD638167BBE1652E86EBF449CBF7DA16EBD2B4B910FD11738556
              5AE79A80CF7C48DBFBD0F10537140CA840C32F8159BBFA6B7FBE34EFCEE6BAED
              45399398A6701CE317ADC6E48B5FC4A114448FBC06BA91BAA4FEE2352D9A0008
              44EFFC6F3A08CFD6D7A1B7BF037E4E757FD06FE301BB1CD840DBA21E73C959E9
              1B830A2EA74AB68D3294B59E7FDAED38F6A5B53840C3B17F755D9254E79A0371
              E9397BE1B56417D3723FC33A6DC35C9A8E6198F150667DE7D153CEA4F4D7B2CC
              622EE1030A8F8F1C2A802E50423551F80934D7EAADE7E327EF733658774CB445
              19DEB9EC4BB8FDB86978971EC297EB874B6F9FA3B05A9B1A57A4EF85829CB160
              402B3C0EF7C125D8EAFC6770CC7B1BB0F368E0A9D04220C658E4F5B3F0DBCC06
              9B72EBB19BBE756AD31725995015C2BFEA4E947A1E30948A4319B933E5EF3E64
              B9C6732686F42FF6C51DBAE66DFBB252C29560FBCE5F11D9C98F62F69E37E0B4
              BB5FC744020CC69AE0E3720945EB1089D6931B59C6A51388C27F0FEBEC3F1FC7
              7EEB41CC2A8297D9F35092ECE3799A7AF6A2DDF13061E51D87DBAF5EF533F364
              289FE0D4A6D3FE3ABD7CD98446B400F72C9685C13D1175ACD14C27D4CCB51F38
              F8161CFDE4FB98EE695E1D952229C303A0A745CD65786F7235DE9D548D750D11
              243274A0DCEF63EF77A3E9BD2E6CBD86191DD7BF4D5D8BE047EEBF28C3C113F1
              D0E3A7E0CEE47AB8F41DEBD8782D656EA5FFEA47CAE43B1BA7FAB4AC37CB02B4
              55717825AE5AB37D04D0872EF81EFE061E9850813735307D8167C6C35211BCB5
              083D2DE2F2D9F1990F70C48265F8CEA58B30F3572FE37B7AC7A88F2018B5ED20
              F0AAAB36A381D7D89261CB72BCBDF06B7888E1978F3E46CF1BBAC93D461F5231
              CB3037AB56B1D146347C31471699DFF38C292D4FA500BDC3EB4EE9C14608A9DB
              0FC5EFCA83E8E4146D921C0D433632B3274565F054A358F6CA74549D625D5E96
              268DA9B12B18F4DCF955CC8F4791E036AC2FCABAD88116AF9E69E4F076A1CFE2
              FF4D68440D5B4A51B01083191F7AD987A2C1CE442FF2FB6D87B5D71D84ABB5EF
              8EC5123C621F9E3204D0B257A6A3EA8C46DECC6BECEB0FC2357B6F8BB5891EC6
              10948DE59D1CA4C7643975DC0ACDE3A5A0176854059805EC204D07288D5201EC
              AD23164417B73573C21E78874AB88AA1F186315AC227266FE6CB28C30D5FC66F
              8EDB032B288B4B9994B374B04AB7F1D362B974CDFC91C18B46B700915E91FA91
              E5E00A75AD12E28CD5136D30277F012BEE39029735C5B1D25B69FF1B8AA069D8
              3E35C6B83856DD3F1D979DC8B1FB997053967696531A7472CBEBB3B25E3B3619
              C6A400F36B6B05F2C8695A82B6173BA0B49E60DE77D80E58FDDAA9B87C9F663C
              A5FA1292027B6BFD139194A9BE38B695756F8EC1D4FBF283B6C79A4407F2B43E
              BD0768E3AD76026700CD50BA65ECE3AAD3315536D71190BEE68E7053A133A4B6
              5B29D43A2A617DB207E99A0012CF9D86DFFFFA4BB87C6205DEE03D6FADDBD92B
              328B4634CBC10E7160C6D5D78472BC7525FB7EFE3BB8B5318CFE14C7E4D87AC9
              A2E70E6D0CD27A4C0557FD3BC8FBFE34E218834989A8CDDC389EA58AE2715832
              77B0633A1BFE695790B7B54A8806B12E9BC38674079CF3F7C5F255DFC595E77D
              1ED74B117A6ECF3A02E13939F110A03A5799EEA94EB1AE829B1C53DAD718E05C
              F3C17771C585EC3BCDC0369B450F1DDE7AD6D18BD636B6EFB10F5D96B1AF0747
              055FF88CA2400929E07D32FBB054F8647684F700F6597E920E26484B50EACB60
              83B3D4C2A4A72518406BB213692785CC6F8EC073ABCEC415F30FC1DC232663E1
              44E6E6F100360894BAE100034075AE32DD937363DDD7A64FC6BD37B3EDCA3371
              E51587E1056685E914FB0E1138B7BAB5D45E0B2569E5F8FA6E38CDB0276FEE1F
              11BC776F4AF168B12B12D44F64BE6F8B389BAC368511532BCBED07C6C5F24DC8
              FD2687DD92EC63C2A485A1085E1F521954D2595430812A636C1FF217F23C3D21
              882C6B41D50BEB51F35E37AABB9863F433851672AEE374551CBDDB54A1739F26
              74EC328EA0CA68CE49987C2F0C7387B4FDB6E0E38FA515ECF4B1AD7E00A1EF58
              1C734569F01E162679756CA74F659B0B7770831470304F1E277B9F905FCCCA73
              593EEAE7F2227D90E896C1CF98DBBEDFA7354811F693792A229ECDDB2C2F1C66
              A2E3D36F35C21454BB8ABE3EF0EC4EA2E779A59F4BA4B82632F665AC7E3B9062
              6497E4511F53E8C994B89FB32EEBD34E9F3737D9D623928785C71FF1F252B287
              F5AB54C054C6DDE6395EE8BB1F919E03EA0713FF50439E8FFE8389CFD157EF49
              A3D447552E823C0B5348E5F79AFB28AFF5C94D84494A38EF20C0CE64F64348BA
              20D03C39E3E77A668FDA71520595D016045AA1ADBE2A5174FAB671CDD3EC7504
              A2FCEA365004BF1BCFF58309CFCF2D6616B58F9D03DEFC1A0FF7933DCD7C44FE
              3A1BBEC223BA66EFEAA3D0DE7C0D2595520CC320DEEFA68C3F97F47143F0F99C
              0C33D25CC0B8792AD8E59CEB27333CEAE7115A386C67C5E751CEC0F6E2DAAD96
              766098B919BD9FC832C6D44F66728E2F94CFFBA34E3E1F73F286FA0CD90D6624
              72BD892B8217BE09640FE30CDE5F683A2EF99CA99DB3D865A5EB59A89FCB793F
              9A92255C419ECF8ADA6A3E75444CFA86F834F20FC99A79EF4753C27446C725BB
              19F900EB203A69EED4BE7E387528D9D392A8852CD3798DACEDEFD34072CAFAD9
              9C7EF9EAFD3A44FE4C4BFA49E29C5E3777695AD8BD25607F1EC3A3665E3F9F3B
              43E5A4C18AF8B4D2600C0B08FE9C22F8C20F278B370694503CFF0F1EF4D359EF
              A73422CF111656ECE6D1C0389B499F64ACC14E6239593F9DBD471783B10E118C
              378CE1665B239F306B577D6379008BF5E3E9FDC85B91655AFF2A98FF2B92D2B4
              73E8031CFD1CF0117AFBA7EB7EBE2CA1352F374BF045C502FF039E9BE471C925
              74010000000049454E44AE426082}
          end>
      end>
    Left = 32
    Top = 328
  end
  object VirtualImageList1: TVirtualImageList
    Images = <
      item
        CollectionIndex = 4
        CollectionName = 'Connect'
        Name = 'Connect'
      end
      item
        CollectionIndex = 5
        CollectionName = 'Connecting'
        Name = 'Connecting'
      end
      item
        CollectionIndex = 6
        CollectionName = 'Disconnect'
        Name = 'Disconnect'
      end>
    ImageCollection = ImageCollection1
    Left = 72
    Top = 392
  end
  object VirtualImageList2: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'Edit'
        Name = 'Edit'
      end
      item
        CollectionIndex = 1
        CollectionName = 'Load'
        Name = 'Load'
      end
      item
        CollectionIndex = 2
        CollectionName = 'Delete'
        Name = 'Delete'
      end
      item
        CollectionIndex = 3
        CollectionName = 'add'
        Name = 'add'
      end
      item
        CollectionIndex = 7
        CollectionName = 'Save'
        Name = 'Save'
      end
      item
        CollectionIndex = 8
        CollectionName = 'Edit2'
        Name = 'Edit2'
      end>
    ImageCollection = ImageCollection1
    Width = 25
    Height = 25
    Left = 24
    Top = 424
  end
  object PPLVListServer: TPopupMenu
    OnPopup = PPLVListServerPopup
    Left = 40
    Top = 104
    object N10: TMenuItem
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100
      OnClick = N10Click
    end
    object N5: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1099#1081' '#1089#1077#1088#1074#1077#1088' '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      OnClick = N5Click
    end
    object N6: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1073#1088#1072#1085#1085#1099#1081' '#1089#1077#1088#1074#1077#1088' '#1080#1079' '#1089#1087#1080#1089#1082#1072
      OnClick = N6Click
    end
    object N7: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077' '#1082' '#1089#1077#1088#1074#1077#1088#1091
      OnClick = N7Click
    end
    object N8: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1090#1077#1082#1091#1097#1080#1081' '#1089#1087#1080#1089#1086#1082' '#1089#1077#1088#1074#1077#1088#1086#1074
      OnClick = N8Click
    end
    object N9: TMenuItem
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
      Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1088#1072#1085#1077#1077' '#1089#1086#1093#1088#1072#1085#1077#1085#1085#1099#1093' '#1089#1077#1088#1074#1077#1088#1086#1074
      OnClick = N9Click
    end
    object N11: TMenuItem
      Caption = #1051#1080#1094#1077#1085#1079#1080#1103
      Hint = #1059#1089#1090#1072#1085#1086#1074#1082#1072'/'#1087#1088#1086#1089#1084#1086#1090#1088' '#1083#1080#1094#1077#1085#1079#1080#1080' '#1085#1072' '#1090#1077#1082#1091#1097#1077#1084' '#1089#1077#1088#1074#1077#1088#1077
      OnClick = N11Click
    end
  end
  object TimerClasterStatus: TTimer
    Enabled = False
    OnTimer = TimerClasterStatusTimer
    Left = 988
    Top = 319
  end
  object TimerRuViewerStatus: TTimer
    Enabled = False
    OnTimer = TimerRuViewerStatusTimer
    Left = 908
    Top = 335
  end
  object VM23: TVirtualImageList
    Images = <
      item
        CollectionIndex = 9
        CollectionName = 'Pass'
        Name = 'Pass'
      end
      item
        CollectionIndex = 10
        CollectionName = 'Update'
        Name = 'Update'
      end>
    ImageCollection = ImageCollection1
    Width = 19
    Height = 19
    Left = 96
    Top = 304
  end
  object PPpassword: TPopupMenu
    Left = 93
    Top = 174
    object N12: TMenuItem
      Caption = #1043#1077#1085#1077#1088#1072#1094#1080#1103
      OnClick = N12Click
    end
  end
end
