object DataModule2: TDataModule2
  OnCreate = DataModuleCreate
  Height = 385
  Width = 984
  PixelsPerInch = 96
  object ConnectionDB: TFDConnection
    Params.Strings = (
      'CharacterSet=UTF8'
      'User_Name=postgres'
      'Password=tq6jg7'
      'OidAsBlob=Yes'
      'UnknownFormat=BYTEA'
      'ApplicationName=AllBooks'
      'MetaDefSchema=MySchema'
      'ExtendedMetadata=True'
      'Database=RVDB'
      'Server=172.16.0.95'
      'DriverID=PG')
    LoginPrompt = False
    Left = 216
    Top = 40
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    DriverID = 'PG'
    VendorLib = 
      'G:\'#1055#1088#1086#1077#1082#1090#1099' '#1076#1083#1103' '#1088#1072#1073#1086#1090#1099'\'#1055#1088#1086#1077#1082#1090#1099' WMI\REMOTE MANAGEMENT\18\Bin\64\li' +
      'bpq.dll'
    Left = 336
    Top = 40
  end
  object FDTransaction1: TFDTransaction
    Connection = ConnectionDB
    Left = 208
    Top = 120
  end
  object FDQuery1: TFDQuery
    Connection = ConnectionDB
    Transaction = FDTransaction1
    Left = 208
    Top = 176
  end
  object FDTable1: TFDTable
    Connection = ConnectionDB
    Left = 392
    Top = 112
  end
  object FDGUIxScriptDialog1: TFDGUIxScriptDialog
    Provider = 'Forms'
    Left = 459
    Top = 33
  end
end
