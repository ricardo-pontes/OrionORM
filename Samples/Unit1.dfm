object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 552
  ClientWidth = 801
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    801
    552)
  TextHeight = 15
  object Button1: TButton
    Left = 533
    Top = 24
    Width = 75
    Height = 25
    Caption = 'FindByKeys'
    TabOrder = 0
    OnClick = Button1Click
  end
  object EditID: TLabeledEdit
    Left = 23
    Top = 81
    Width = 73
    Height = 23
    EditLabel.Width = 11
    EditLabel.Height = 15
    EditLabel.Caption = 'ID'
    TabOrder = 1
    Text = ''
  end
  object EditName: TLabeledEdit
    Left = 111
    Top = 81
    Width = 369
    Height = 23
    EditLabel.Width = 32
    EditLabel.Height = 15
    EditLabel.Caption = 'Name'
    TabOrder = 2
    Text = ''
  end
  object EditSalary: TLabeledEdit
    Left = 23
    Top = 129
    Width = 73
    Height = 23
    EditLabel.Width = 31
    EditLabel.Height = 15
    EditLabel.Caption = 'Salary'
    TabOrder = 3
    Text = ''
  end
  object SwitchActive: TToggleSwitch
    Left = 111
    Top = 129
    Width = 73
    Height = 20
    TabOrder = 4
  end
  object EditStreet: TLabeledEdit
    Left = 23
    Top = 177
    Width = 281
    Height = 23
    EditLabel.Width = 30
    EditLabel.Height = 15
    EditLabel.Caption = 'Street'
    TabOrder = 5
    Text = ''
  end
  object EditNumber: TLabeledEdit
    Left = 319
    Top = 177
    Width = 161
    Height = 23
    EditLabel.Width = 44
    EditLabel.Height = 15
    EditLabel.Caption = 'Number'
    TabOrder = 6
    Text = ''
  end
  object EditNeighborhood: TLabeledEdit
    Left = 23
    Top = 233
    Width = 281
    Height = 23
    EditLabel.Width = 78
    EditLabel.Height = 15
    EditLabel.Caption = 'Neighborhood'
    TabOrder = 7
    Text = ''
  end
  object EditCity: TLabeledEdit
    Left = 319
    Top = 233
    Width = 161
    Height = 23
    EditLabel.Width = 21
    EditLabel.Height = 15
    EditLabel.Caption = 'City'
    TabOrder = 8
    Text = ''
  end
  object EditPostalCode: TLabeledEdit
    Left = 491
    Top = 233
    Width = 117
    Height = 23
    EditLabel.Width = 63
    EditLabel.Height = 15
    EditLabel.Caption = 'Postal Code'
    TabOrder = 9
    Text = ''
  end
  object Memo1: TMemo
    Left = 23
    Top = 273
    Width = 758
    Height = 72
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 10
    ExplicitWidth = 754
    ExplicitHeight = 71
  end
  object Button2: TButton
    Left = 452
    Top = 24
    Width = 75
    Height = 25
    Caption = 'FindAll'
    TabOrder = 11
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 319
    Top = 24
    Width = 127
    Height = 25
    Caption = 'FindManyWithWhere'
    TabOrder = 12
    OnClick = Button3Click
  end
  object LabeledEdit1: TLabeledEdit
    Left = 23
    Top = 24
    Width = 154
    Height = 23
    EditLabel.Width = 67
    EditLabel.Height = 15
    EditLabel.Caption = 'LabeledEdit1'
    TabOrder = 13
    Text = ''
  end
  object Button4: TButton
    Left = 186
    Top = 24
    Width = 127
    Height = 25
    Caption = 'FindOneWithWhere'
    TabOrder = 14
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 675
    Top = 24
    Width = 47
    Height = 25
    Caption = 'Delete'
    TabOrder = 15
    OnClick = Button5Click
  end
  object LabeledEdit2: TLabeledEdit
    Left = 614
    Top = 24
    Width = 55
    Height = 23
    EditLabel.Width = 67
    EditLabel.Height = 15
    EditLabel.Caption = 'LabeledEdit2'
    TabOrder = 16
    Text = ''
  end
  object Button6: TButton
    Left = 728
    Top = 24
    Width = 47
    Height = 25
    Caption = 'Save'
    TabOrder = 17
    OnClick = Button6Click
  end
  object StringGridContacts: TStringGrid
    Left = 23
    Top = 400
    Width = 758
    Height = 129
    Anchors = [akLeft, akRight, akBottom]
    ColCount = 3
    FixedCols = 0
    FixedRows = 0
    TabOrder = 18
    ExplicitTop = 399
    ExplicitWidth = 754
  end
  object EditPhoneNumber: TLabeledEdit
    Left = 23
    Top = 369
    Width = 281
    Height = 23
    EditLabel.Width = 81
    EditLabel.Height = 15
    EditLabel.Caption = 'Phone Number'
    TabOrder = 19
    Text = ''
  end
  object Button7: TButton
    Left = 310
    Top = 369
    Width = 75
    Height = 23
    Caption = 'Save'
    TabOrder = 20
    OnClick = Button7Click
  end
  object EditFinancialStatus: TLabeledEdit
    Left = 491
    Top = 177
    Width = 117
    Height = 23
    EditLabel.Width = 63
    EditLabel.Height = 15
    EditLabel.Caption = 'Postal Code'
    ImeName = 'Portuguese (Brazilian ABNT)'
    TabOrder = 21
    Text = ''
  end
end
