object Add_New_User: TAdd_New_User
  Left = 0
  Top = 0
  Caption = 'Add_New_User'
  ClientHeight = 164
  ClientWidth = 274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object RzPanel3: TRzPanel
    Left = 0
    Top = 0
    Width = 274
    Height = 161
    Align = alTop
    TabOrder = 0
    object Server_Name: TLabeledEdit
      Left = 88
      Top = 16
      Width = 169
      Height = 21
      Hint = 'Server name.'#13'For example: speed.travian.com '
      AutoSize = False
      EditLabel.Width = 32
      EditLabel.Height = 13
      EditLabel.Hint = 'Server name.'#13'For example: speed.travian.com '
      EditLabel.Caption = 'Server'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = False
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      LabelSpacing = 12
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object User_Name: TLabeledEdit
      Left = 88
      Top = 43
      Width = 169
      Height = 21
      AutoSize = False
      EditLabel.Width = 58
      EditLabel.Height = 13
      EditLabel.Caption = 'Login_Name'
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      LabelSpacing = 10
      TabOrder = 1
    end
    object Password_Name: TLabeledEdit
      Left = 88
      Top = 70
      Width = 169
      Height = 21
      AutoSize = False
      EditLabel.Width = 46
      EditLabel.Height = 13
      EditLabel.Caption = 'Password'
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      LabelSpacing = 22
      TabOrder = 2
    end
    object Button1: TButton
      Left = 88
      Top = 120
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object Button2: TButton
      Left = 182
      Top = 120
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
  end
end
