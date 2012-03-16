object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 546
  ClientWidth = 711
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object NextInspector1: TNextInspector
    Left = 466
    Top = 0
    Width = 245
    Height = 511
    Align = alRight
    TabOrder = 0
    OnChange = NextInspector1Change
    object NxTextItem1: TNxTextItem
      Caption = #1052#1086#1090#1086#1088
      ReadOnly = True
      ParentIndex = -1
      object txtRpm: TNxTextItem
        Caption = 'RPM'
        ReadOnly = True
        Value = '1000'
        ParentIndex = 0
      end
      object NxProgressItem1: TNxProgressItem
        Caption = 'RPM'
        Value = '0'
        ShowText = True
        ParentIndex = 0
      end
      object txtWheelRpm: TNxTextItem
        Caption = 'Wheels Rpm'
        ParentIndex = 0
      end
    end
    object NxTextItem2: TNxTextItem
      Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
      ReadOnly = True
      ParentIndex = -1
      object trbThrottle: TNxTrackBarItem
        Caption = #1044#1088#1086#1089#1077#1083#1100
        Value = '30'
        Margin = 6
        Position = 30
        ParentIndex = 4
      end
      object trbClutch: TNxTrackBarItem
        Caption = #1057#1094#1077#1087#1083#1077#1085#1080#1077
        Value = '100'
        Margin = 6
        Position = 100
        ParentIndex = 4
      end
      object cbxStarter: TNxCheckBoxItem
        Caption = #1057#1090#1072#1088#1090#1077#1088
        Value = 'false'
        AllowAllUp = True
        Buttons = <
          item
            Glyph.Data = {
              F6000000424DF600000000000000760000002800000010000000100000000100
              0400000000008000000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00AAAAAAAAAAAA
              AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
              AAAAAAAAAA0AAAAAAAAAAAAAA000AAAAAAAAAAAA00000AAAAAAAAAAA00A000AA
              AAAAAAAA0AAA000AAAAAAAAAAAAAA00AAAAAAAAAAAAAAA0AAAAAAAAAAAAAAAAA
              AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA}
            Text = 'true'
          end>
        ParentIndex = 4
      end
      object spnGear: TNxSpinItem
        Caption = #1055#1077#1088#1077#1076#1072#1095#1072
        DefaultValue = '1'
        Value = '1'
        Max = 6.000000000000000000
        Increment = 1.000000000000000000
        ParentIndex = 4
      end
    end
    object NxTextItem3: TNxTextItem
      Caption = #1044#1074#1080#1078#1077#1085#1080#1077
      ReadOnly = True
      ParentIndex = -1
      object txtFlong: TNxTextItem
        Caption = 'Flong'
        ParentIndex = 9
      end
      object txtFtraction: TNxTextItem
        Caption = 'Ftraction'
        ParentIndex = 9
      end
      object txtA: TNxTextItem
        Caption = 'a'
        ParentIndex = 9
      end
      object txtSpeed: TNxTextItem
        Caption = 'Speed'
        ParentIndex = 9
      end
    end
    object txt: TNxTextItem
      Caption = #1054#1073#1088#1090#1072#1085#1072#1103' '#1089#1074#1103#1079#1100
      ReadOnly = True
      ParentIndex = -1
      object txtBaseTorque: TNxTextItem
        Caption = 'Base Torque'
        Value = '0'
        ParentIndex = 14
      end
      object txtEngineTorque: TNxTextItem
        Caption = 'Engine Torque'
        Value = '0'
        ParentIndex = 14
      end
      object txtEngineClutchTorque: TNxTextItem
        Caption = 'd Engine Torque'
        Value = '0'
        ParentIndex = 14
      end
      object txtWhellsTorque: TNxTextItem
        Caption = 'Whells Torque'
        Value = '0'
        ParentIndex = 14
      end
      object txtWheelsClutchTorque: TNxTextItem
        Caption = 'd Wheels Torque'
        Value = '0'
        ParentIndex = 14
      end
      object txtFWheels: TNxTextItem
        Caption = 'F Wheels'
        Value = '0'
        ParentIndex = 14
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 511
    Width = 711
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    object btnStart: TBitBtn
      Left = 538
      Top = 6
      Width = 75
      Height = 25
      Caption = 'START'
      DoubleBuffered = True
      Kind = bkOK
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnStrop: TBitBtn
      Left = 619
      Top = 6
      Width = 75
      Height = 25
      Caption = 'ST&OP'
      DoubleBuffered = True
      Kind = bkNo
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = btnStropClick
    end
    object BitBtn1: TBitBtn
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Draw1'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = BitBtn1Click
    end
    object btnDraw2: TButton
      Left = 97
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Draw2'
      TabOrder = 3
      OnClick = btnDraw2Click
    end
  end
  object chartTorque: TChart
    Left = 0
    Top = 0
    Width = 466
    Height = 511
    Title.Text.Strings = (
      'TChart')
    DepthAxis.Automatic = False
    DepthAxis.AutomaticMaximum = False
    DepthAxis.AutomaticMinimum = False
    DepthAxis.Maximum = 0.169999999999999800
    DepthAxis.Minimum = -0.830000000000000300
    DepthTopAxis.Automatic = False
    DepthTopAxis.AutomaticMaximum = False
    DepthTopAxis.AutomaticMinimum = False
    DepthTopAxis.Maximum = 0.169999999999999800
    DepthTopAxis.Minimum = -0.830000000000000300
    RightAxis.Automatic = False
    RightAxis.AutomaticMaximum = False
    RightAxis.AutomaticMinimum = False
    View3D = False
    Align = alClient
    TabOrder = 2
    ColorPaletteIndex = 13
    object Torque: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      Title = 'Torque'
      LinePen.Color = 10708548
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object brakingTorque: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 3513587
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Torque03: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 1330417
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Torque05: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 11048782
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Torque07: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 7028779
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object toMotor: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 6519581
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object toWheels: TLineSeries
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Visible = False
      LinePen.Color = 919731
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
end
