object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  Caption = #1051#1086#1075#1080#1085
  ClientHeight = 286
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 340
    Height = 286
    Align = alClient
    TabOrder = 0
    object pnlLogin: TPanel
      Left = 5
      Top = 4
      Width = 329
      Height = 140
      TabOrder = 0
      object lblLogin: TLabel
        Left = 9
        Top = 16
        Width = 30
        Height = 13
        Caption = #1051#1086#1075#1080#1085
      end
      object lblPass: TLabel
        Left = 9
        Top = 47
        Width = 37
        Height = 13
        Caption = #1055#1072#1088#1086#1083#1100
      end
      object lblAgent: TLabel
        Left = 9
        Top = 77
        Width = 30
        Height = 13
        Caption = #1040#1075#1077#1085#1090
      end
      object lblServer: TLabel
        Left = 9
        Top = 108
        Width = 63
        Height = 13
        Caption = #1048#1084#1103' '#1089#1077#1088#1074#1077#1088#1072
      end
      object edtLogin: TEdit
        Left = 89
        Top = 8
        Width = 233
        Height = 21
        TabOrder = 0
        Text = 'edtLogin'
      end
      object edtPass: TEdit
        Left = 89
        Top = 39
        Width = 233
        Height = 21
        TabOrder = 1
        Text = 'edtPass'
      end
      object cbbAgetn: TComboBox
        Left = 89
        Top = 69
        Width = 233
        Height = 21
        TabOrder = 2
        Text = 'cbbAgetn'
      end
      object edtServer: TEdit
        Left = 89
        Top = 100
        Width = 233
        Height = 21
        TabOrder = 3
        Text = 'http://'
      end
    end
    object grpProxy: TGroupBox
      Left = 0
      Top = 150
      Width = 329
      Height = 83
      Caption = #1055#1088#1086#1082#1089#1080
      TabOrder = 1
    end
    object btnOk: TButton
      Left = 252
      Top = 248
      Width = 75
      Height = 25
      Caption = #1087#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 2
      OnClick = btnOkClick
    end
  end
end
