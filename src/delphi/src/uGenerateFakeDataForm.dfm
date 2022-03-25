object GenerateFakeDataForm: TGenerateFakeDataForm
  Left = 0
  Top = 0
  Caption = #49892#54665
  ClientHeight = 503
  ClientWidth = 645
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    645
    503)
  PixelsPerInch = 96
  TextHeight = 13
  object lblResultFolderPath: TLabel
    Left = 8
    Top = 395
    Width = 72
    Height = 13
    Caption = #44208#44284' '#54260#45908' '#44221#47196
  end
  object lblRows: TLabel
    Left = 8
    Top = 96
    Width = 34
    Height = 13
    Caption = '#Rows'
  end
  object lblFormat: TLabel
    Left = 192
    Top = 96
    Width = 34
    Height = 13
    Caption = 'Format'
  end
  object lblType: TLabel
    Left = 440
    Top = 96
    Width = 22
    Height = 13
    Caption = 'type'
  end
  object btnExecute: TButton
    Left = 8
    Top = 432
    Width = 629
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = #49373#49457
    TabOrder = 0
    OnClick = btnExecuteClick
  end
  object edtresultfolderpath: TEdit
    Left = 100
    Top = 392
    Width = 537
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object btnFileSelect: TButton
    Left = 8
    Top = 8
    Width = 629
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = 'dataset '#54028#51068' '#49440#53469
    TabOrder = 2
    OnClick = btnFileSelectClick
  end
  object cbFormat: TComboBox
    Left = 248
    Top = 93
    Width = 145
    Height = 21
    ItemIndex = 0
    TabOrder = 3
    Text = 'json'
    OnKeyPress = cbFormatKeyPress
    Items.Strings = (
      'json')
  end
  object edtrows: TEdit
    Left = 60
    Top = 93
    Width = 101
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    OnKeyPress = edtrowsKeyPress
  end
  object cbType: TComboBox
    Left = 492
    Top = 93
    Width = 145
    Height = 21
    ItemIndex = 0
    TabOrder = 5
    Text = 'line'
    OnKeyPress = cbTypeKeyPress
    Items.Strings = (
      'line'
      'json array')
  end
end
