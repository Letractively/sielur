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
    ExplicitLeft = 40
    ExplicitTop = 88
    ExplicitWidth = 378
    ExplicitHeight = 169
    object pnlLogin: TPanel
      Left = 5
      Top = 4
      Width = 329
      Height = 108
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
    end
    object grpProxy: TGroupBox
      Left = 5
      Top = 118
      Width = 329
      Height = 83
      Caption = #1055#1088#1086#1082#1089#1080
      TabOrder = 1
    end
  end
end