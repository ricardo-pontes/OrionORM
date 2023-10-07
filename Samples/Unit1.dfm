object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Button1: TButton
    Left = 545
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object EditID: TLabeledEdit
    Left = 24
    Top = 48
    Width = 73
    Height = 23
    EditLabel.Width = 11
    EditLabel.Height = 15
    EditLabel.Caption = 'ID'
    TabOrder = 1
    Text = ''
  end
  object EditName: TLabeledEdit
    Left = 112
    Top = 48
    Width = 369
    Height = 23
    EditLabel.Width = 32
    EditLabel.Height = 15
    EditLabel.Caption = 'Name'
    TabOrder = 2
    Text = ''
  end
  object EditSalary: TLabeledEdit
    Left = 24
    Top = 96
    Width = 73
    Height = 23
    EditLabel.Width = 31
    EditLabel.Height = 15
    EditLabel.Caption = 'Salary'
    TabOrder = 3
    Text = ''
  end
  object SwitchActive: TToggleSwitch
    Left = 112
    Top = 96
    Width = 73
    Height = 20
    TabOrder = 4
  end
  object EditStreet: TLabeledEdit
    Left = 24
    Top = 144
    Width = 281
    Height = 23
    EditLabel.Width = 30
    EditLabel.Height = 15
    EditLabel.Caption = 'Street'
    TabOrder = 5
    Text = ''
  end
  object EditNumber: TLabeledEdit
    Left = 320
    Top = 144
    Width = 161
    Height = 23
    EditLabel.Width = 44
    EditLabel.Height = 15
    EditLabel.Caption = 'Number'
    TabOrder = 6
    Text = ''
  end
  object EditNeighborhood: TLabeledEdit
    Left = 24
    Top = 200
    Width = 281
    Height = 23
    EditLabel.Width = 78
    EditLabel.Height = 15
    EditLabel.Caption = 'Neighborhood'
    TabOrder = 7
    Text = ''
  end
  object EditCity: TLabeledEdit
    Left = 320
    Top = 200
    Width = 161
    Height = 23
    EditLabel.Width = 21
    EditLabel.Height = 15
    EditLabel.Caption = 'City'
    TabOrder = 8
    Text = ''
  end
  object EditPostalCode: TLabeledEdit
    Left = 492
    Top = 200
    Width = 117
    Height = 23
    EditLabel.Width = 63
    EditLabel.Height = 15
    EditLabel.Caption = 'Postal Code'
    TabOrder = 9
    Text = ''
  end
  object Memo1: TMemo
    Left = 24
    Top = 240
    Width = 585
    Height = 185
    TabOrder = 10
  end
end
