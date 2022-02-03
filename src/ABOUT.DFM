object AboutBox: TAboutBox
  Left = 504
  Top = 236
  Width = 539
  Height = 83
  Caption = 'About'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    523
    45)
  PixelsPerInch = 96
  TextHeight = 13
  object versionString: TEdit
    Left = 8
    Top = 8
    Width = 422
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 437
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
end
