object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 756
  ClientWidth = 778
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object splMainPnlAndWebBrous: TSplitter
    Left = 0
    Top = 153
    Width = 778
    Height = 3
    Cursor = crSizeNS
    Align = alTop
    AutoSnap = False
    Beveled = True
    Color = clRed
    ParentColor = False
    ExplicitTop = 0
    ExplicitWidth = 756
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 778
    Height = 153
    Align = alTop
    Caption = 'MainPanel'
    TabOrder = 0
    ExplicitWidth = 777
  end
  object pnlWeb: TPanel
    Left = 0
    Top = 156
    Width = 778
    Height = 600
    Align = alClient
    Caption = 'pnlWeb'
    TabOrder = 1
    ExplicitLeft = 304
    ExplicitTop = 368
    ExplicitWidth = 185
    ExplicitHeight = 41
    object wbMain: TWebBrowser
      Left = 1
      Top = 1
      Width = 776
      Height = 598
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 216
      ExplicitTop = 216
      ExplicitWidth = 300
      ExplicitHeight = 150
      ControlData = {
        4C00000034500000CE3D00000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object MainMenu: TMainMenu
    Left = 744
    Top = 8
    object MenuMain: TMenuItem
      Caption = #1043#1083#1072#1074#1085#1086#1077
      object MenuLogin: TMenuItem
        Caption = #1042#1093#1086#1076
      end
      object MenuQuit: TMenuItem
        Caption = #1042#1099#1093#1086#1076
      end
    end
    object MenuPreference: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object LoginPreference: TMenuItem
        Caption = #1044#1083#1103' '#1074#1093#1086#1076#1072' '#1074' '#1080#1075#1088#1091
        OnClick = LoginPreferenceClick
      end
    end
    object N5: TMenuItem
      Caption = #1055#1088#1086' '#1085#1072#1089
      object MenuAbout: TMenuItem
        Caption = #1058#1080#1087#1072' '#1093#1077#1083#1087
      end
    end
  end
end
