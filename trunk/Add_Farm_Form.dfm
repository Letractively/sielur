object AddFarmForm: TAddFarmForm
  Left = 0
  Top = 0
  BiDiMode = bdLeftToRight
  BorderStyle = bsNone
  Caption = 'AddFarmForm'
  ClientHeight = 540
  ClientWidth = 509
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  PixelsPerInch = 96
  TextHeight = 13
  object Mainpnl: TPanel
    Left = 0
    Top = 0
    Width = 509
    Height = 540
    Align = alClient
    TabOrder = 0
    object pnlTroops: TPanel
      Left = 8
      Top = 7
      Width = 491
      Height = 99
      TabOrder = 0
      object img1: TImage
        Left = 7
        Top = 11
        Width = 18
        Height = 18
      end
      object img2: TImage
        Left = 7
        Top = 40
        Width = 18
        Height = 18
      end
      object img3: TImage
        Left = 7
        Top = 69
        Width = 18
        Height = 18
      end
      object img4: TImage
        Left = 144
        Top = 11
        Width = 18
        Height = 18
      end
      object img5: TImage
        Left = 144
        Top = 40
        Width = 18
        Height = 18
      end
      object img6: TImage
        Left = 144
        Top = 69
        Width = 18
        Height = 18
      end
      object img7: TImage
        Left = 264
        Top = 11
        Width = 18
        Height = 18
      end
      object img8: TImage
        Left = 264
        Top = 40
        Width = 18
        Height = 18
      end
      object img9: TImage
        Left = 392
        Top = 11
        Width = 18
        Height = 18
      end
      object img10: TImage
        Left = 392
        Top = 40
        Width = 18
        Height = 18
      end
      object img11: TImage
        Left = 392
        Top = 69
        Width = 18
        Height = 18
      end
      object edtT1: TEdit
        Left = 30
        Top = 8
        Width = 65
        Height = 21
        TabOrder = 0
      end
      object edtT2: TEdit
        Left = 30
        Top = 37
        Width = 65
        Height = 21
        TabOrder = 1
      end
      object edtT3: TEdit
        Left = 30
        Top = 66
        Width = 65
        Height = 21
        TabOrder = 2
      end
      object edtT4: TEdit
        Left = 168
        Top = 8
        Width = 65
        Height = 21
        TabOrder = 3
      end
      object edtT5: TEdit
        Left = 168
        Top = 37
        Width = 65
        Height = 21
        TabOrder = 4
      end
      object edtT6: TEdit
        Left = 168
        Top = 66
        Width = 65
        Height = 21
        TabOrder = 5
      end
      object edtT7: TEdit
        Left = 288
        Top = 8
        Width = 65
        Height = 21
        TabOrder = 6
      end
      object edtT9: TEdit
        Left = 288
        Top = 37
        Width = 65
        Height = 21
        TabOrder = 7
      end
      object edtT10: TEdit
        Left = 416
        Top = 8
        Width = 65
        Height = 21
        TabOrder = 8
      end
      object edtT11: TEdit
        Left = 416
        Top = 37
        Width = 65
        Height = 21
        TabOrder = 9
      end
      object edtT12: TEdit
        Left = 416
        Top = 66
        Width = 65
        Height = 21
        TabOrder = 10
      end
    end
    object rgAtaks: TRadioGroup
      Left = 215
      Top = 112
      Width = 120
      Height = 73
      Caption = #1058#1080#1087' '#1072#1090#1072#1082#1080
      ItemIndex = 2
      Items.Strings = (
        #1055#1086#1076#1082#1088#1077#1087#1083#1077#1085#1080#1077
        #1053#1072#1087#1072#1076#1077#1085#1080#1077
        #1053#1072#1073#1077#1075)
      TabOrder = 1
    end
    object rgScan: TRadioGroup
      Left = 341
      Top = 112
      Width = 158
      Height = 73
      Caption = #1056#1072#1079#1074#1077#1076#1082#1072
      Items.Strings = (
        #1056#1077#1089#1091#1088#1089#1099' '#1080' '#1074#1086#1081#1089#1082#1072
        #1042#1086#1081#1089#1082#1072' '#1080'  '#1089#1086#1086#1088#1091#1078#1077#1085#1080#1103)
      TabOrder = 2
    end
    object pnlCoords: TPanel
      Left = 8
      Top = 112
      Width = 193
      Height = 73
      TabOrder = 3
      object lblVillage: TLabel
        Left = 7
        Top = 13
        Width = 48
        Height = 13
        Caption = #1044#1077#1088#1077#1074#1085#1103':'
      end
      object lblOrXY: TLabel
        Left = 7
        Top = 48
        Width = 115
        Height = 13
        Caption = #1048#1083#1080'  '#1061'                          Y'
      end
      object edtVillage: TEdit
        Left = 62
        Top = 5
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object edtX: TEdit
        Left = 46
        Top = 40
        Width = 59
        Height = 21
        TabOrder = 1
      end
      object edtY: TEdit
        Left = 128
        Top = 40
        Width = 55
        Height = 21
        TabOrder = 2
      end
    end
    object grpOptions: TGroupBox
      Left = 8
      Top = 191
      Width = 491
      Height = 130
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1085#1072#1073#1077#1075#1072
      TabOrder = 4
      object lblPeriods: TLabel
        Left = 10
        Top = 24
        Width = 64
        Height = 13
        Caption = #1055#1077#1088#1080#1086#1076'('#1084#1080#1085')'
      end
      object lbl1Dispersion: TLabel
        Left = 153
        Top = 24
        Width = 66
        Height = 13
        Caption = #1056#1072#1079#1073#1088#1086#1089'('#1084#1080#1085')'
      end
      object edtPeriod: TEdit
        Left = 80
        Top = 16
        Width = 60
        Height = 21
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        TabOrder = 0
        Text = '60'
      end
      object edtDispersion: TEdit
        Left = 225
        Top = 16
        Width = 51
        Height = 21
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        TabOrder = 1
        Text = '10'
      end
    end
    object btnAdd: TButton
      Left = 424
      Top = 504
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 5
    end
    object btnCansel: TButton
      Left = 8
      Top = 504
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      TabOrder = 6
    end
  end
end
