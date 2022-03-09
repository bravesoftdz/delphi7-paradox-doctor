{
TFieldUpdate v1.1
by Nathanial Woolls
natew@mobiletoys.com

This component is complete freeware.  Use it anywhere you want, for any
price.  Charge $1,000,000 for a commercial product that uses TFieldUpdate,     
and do so without feeling dirty.  If you like the component, have any
suggestions, wish to donate any code, etc, email natew@mobiletoys.com

TFieldUpdate allows you to update the fields of a Paradox or DBase database
at runtime to match a set a field definitions supplied either at runtime
or design time.  The TFieldUpdate component allows you to add new field
definitions to TFieldUpdate.FieldItems, and modify those field definitions by
setting values for TFieldUpdate.FieldItems.Items[I].Name, .FieldType, .Length,
and .Precision.  You can also populate TFieldUpdate.FieldItems using the
procedure ReadFromFile(), specifying the path to a database from which to read
the field definitions.  This procedure is available at design time using the
property TFieldUpdate.ReadFrom, which allows you to browse for a database.
You can then apply these field definitions to a database at runtime using the
ApplyToFile() procedure, specifying the path to a database to which you want
to apply the field definitions contained in TFieldUpdate.FieldItems.
TFieldUpdate.LoadFromStream(), .SaveToStream(), .LoadFromFile(), .SaveToFile(),
.LoadFromIni(), .SaveToIni(), .LoadFromWinSock(), and .SaveToWinSock() are
available for saving and loading the field definitions to and from various
sources.

TFieldUpdate has two events, OnProgress, which passes an integer percentage
representing the progress of applying field definitions to a database and the
current field name begin updated, and OnError, which passes fuFileNotFound,
fuApply, fuRead, fuLoad, or fuSave to indicate where the problem was encountered
If an error occurs while applying field definitions (i.e. fuApply is passed),
then you can read TFieldUpdate.CurrentField to find what field was being
updated when the error occurred.

QuickStatus, QuickLabel, and QuickProgress are ease-of-use properties.
QuickLabel can be set to any TLabel on your form, and QuickProgress can be set
to any TProgressBar on your form. Then, if QuickStatus is set to True,
QuickLabel's caption will be updated to reflect the name of the current field
being updated, and QuickProgress will be automatically updated with the progress
of the field update progress.

One Use of TFieldUpdate (or at least how I use it) follows:
You have a customer base with a database whose fields need to be regularly
updated to match new or altered fields in your master database.  With
TFieldUpdate, simply place the component on your database update application
form, click on the ReadFrom property, browse to and select your master database.
Then, all you need is one line of code, calling:

FieldUpdate1.ApplyToFile('\path\to\customers\database');

And TFieldUpdate will properly update the customer's database to match yours.
}

unit FieldUpdate;

interface

{$R FieldUpdate.res}

uses
  SysUtils, Classes, bde, Dialogs, db, TypInfo, dbtables, inifiles,
  scktcomp, stdctrls, comctrls,TUtil32,JclFileUtils,Forms,jclStrings;

type

  ChangeRec = packed record
    szName: DBINAME;
    iType: Word;
    iSubType: Word;
    iLength: Word;
    iPrecision: Byte;
  end;

  TFieldUpdateError = (fuFileNotFound, fuApply, fuRead, fuLoad, fuSave);
  TOnProgress = procedure (sender : TComponent; Percent : Integer; FieldName : String) of object;
  TOnError = procedure (sender : TComponent; Error : TFieldUpdateError) of object;
  TFieldItems = class;
  TFieldItem = class;
  TTableItem = class;

  TFieldUpdate = class(TComponent)
  private

      TblDesc:   CRTblDesc;
      fromTableItem :TTableItem;
      toTableItem :TTableItem;

    FReadFrom: String;
    FOnProgress: TOnProgress;
    FOnError: TOnError;
    FQuickStatus: Boolean;
    FQuickLabel: TLabel;
    FQuickProgress: TProgressBar;
    procedure SetFieldItems(const Value: TFieldItems);
    procedure SetReadFrom(const Value: String);
    procedure SetOnProgress(const Value: TOnProgress);
    procedure SetOnError(const Value: TOnError);
    procedure AddField(Table: TTable; NewFieldItem: TFieldItem);
    procedure ChangeField(Table: TTable; NewFieldItem: TFieldItem  ;OldFieldItem: TFieldItem);
    function CompareField(OldField: TFieldItem ; NewFieldItem: TFieldItem) : boolean ;
    function FieldTypeToBDEFieldInt(TableType : TTableType; FieldType: TFieldType): Word;
    function GetTableType(Table: TTable): TTableType;
    function FieldTypeToString(FieldType : TFieldType) : String;
    function StringToFieldType(FieldType : String) : TFieldType;
    procedure SetQuickStatus(const Value: Boolean);
    procedure SetQuickLabel(const Value: TLabel);
    procedure SetQuickProgress(const Value: TProgressBar);
    procedure CopyNewTables(SrcDB, DsDB: String; Overwrite: Boolean);
    procedure CopyNewTable(SrcTbl, DstTbl: String; Overwrite: Boolean);
    { Private declarations }
  protected
    { Protected declarations }
    procedure DoOnProgress(Percent : Integer; FieldName : String); virtual;
    procedure DoOnError(Error : TFieldUpdateError); virtual;
  public
    { Public declarations }
    CurrentField : String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadFromFile(Path : String) ; Overload;
    procedure ReadFromFile(var FTableItem : TTableItem; Path: String); Overload;
    procedure ValidateFields(Path : String); Overload;
    procedure ValidateFields(dbItem: TTableItem); Overload;
    procedure ApplyToFile(Path : String);
    procedure DupTableStruct(SrceTbl: TTable; DestTblName: String);
    procedure RestructureTable(sTableName: string; Option, OptData: string);

    procedure LoadFromFile(Path : String);
    procedure SaveToFile(Path : String);
    procedure LoadFromStream(Stream : TStream);
    procedure SaveToStream(Stream : TStream);
    procedure LoadFromIni(IniFile : TIniFile);
    procedure SaveToIni(IniFile : TIniFile);
    procedure SaveToWinSock(Socket: TCustomWinSocket; TimeOut: Longint);
    procedure LoadFromWinSock(Socket: TCustomWinSocket; TimeOut: Longint);
  published
    { Published declarations }
    //property Items : TFieldItems read FFieldItems write SetFieldItems;
    property ReadFrom : String read FReadFrom write SetReadFrom;
    property OnProgress : TOnProgress read FOnProgress write SetOnProgress;
    property OnError : TOnError read FOnError write SetOnError;
    property QuickStatus : Boolean read FQuickStatus write SetQuickStatus default False;
    property QuickProgress : TProgressBar read FQuickProgress write SetQuickProgress;
    property QuickLabel : TLabel read FQuickLabel write SetQuickLabel;
  end;

  TFieldItems = class(TCollection)
  private

    { Private declarations }
    FOwner: TPersistent;
    function GetItem(Idx: Integer): TFieldItem;
    procedure SetItem(Idx: Integer; Item: TFieldItem);


  protected
    { Protected declarations }
    function GetOwner: TPersistent; override;
    property Owner: TPersistent read FOwner write FOwner;
  public
    { Public declarations }
    constructor Create;
    property Items[Idx: Integer]: TFieldItem read GetItem write SetItem; default;
  published
    { Published declarations }
  end;

  TTableItem = class
  private
    { Private declarations }
    FName: String;
    CursorProp: CURProps;
    FVCHKDesc: VCHKDesc;
    FFldDesc: FldDesc;
    FHasValidation: boolean;
    FFieldItems: TFieldItems;

    aVChkDesc: Array of VCHKDesc;
    aFldDesc: Array of FldDesc;
    aIdxDesc: Array of IdxDesc;
    aRIntDesc : Array of RIntDesc;
 end;



  TFieldItem = class(TCollectionItem)
  private
    { Private declarations }
    FPrecision: Byte;
    FName: String;
    FType: TFieldType;
    FSubType: Word;
    FLength: Word;
    FVCHKDesc: VCHKDesc;
    FFldDesc: FldDesc;
    FHasValidation: boolean;

    procedure SetLength(const Value: Word);
    procedure SetName(const Value: String);
    procedure SetPrecision(const Value: Byte);
    procedure SetSubType(const Value: Word);
    procedure SetType(const Value: TFieldType);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property SubType : Word read FSubType write SetSubType;
  published
    { Published declarations }
    property Name : String read FName write SetName;
    property FieldType : TFieldType read FType write SetType;
    property Length : Word read FLength write SetLength;
    property Precision : Byte read FPrecision write SetPrecision;
  end;


implementation

{ TFieldItem }

constructor TFieldItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

destructor TFieldItem.Destroy;
begin
  inherited Destroy;
end;

procedure TFieldItem.SetLength(const Value: Word);
begin
  FLength := Value;
end;

procedure TFieldItem.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TFieldItem.SetPrecision(const Value: Byte);
begin
  FPrecision := Value;
end;

procedure TFieldItem.SetSubType(const Value: Word);
begin
  FSubType := Value;
end;

procedure TFieldItem.SetType(const Value: TFieldType);
begin
  FType := Value;
end;

{ TFieldItems }

constructor TFieldItems.Create;
begin
  FOwner:= nil;
  inherited Create(TFieldItem);
end;

function TFieldItems.GetItem(Idx: Integer): TFieldItem;
begin
  Result:= TFieldItem(inherited Items[Idx]);
end;

function TFieldItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TFieldItems.SetItem(Idx: Integer; Item: TFieldItem);
begin
  inherited Items[Idx]:= Item;
end;

procedure  TFieldUpdate.ReadFromFile(var FTableItem : TTableItem; Path: String);
var
  Table : TTable;
  I : Integer;
  hMaster:  hDBICur ;
  ItrVChk, ItrRInt: Integer;

      TblDesc:   CRTblDesc;
      PtrIdxDesc: Pointer;
      PtrRIntDesc: Pointer;
      FFieldItems: TFieldItems;

begin
  if FileExists(Path) then
  begin
    try
      FTableItem.FName:= Path;
      if FTableItem.FFieldItems = nil then
            FTableItem.FFieldItems:= TFieldItems.create;

      FFieldItems:= FTableItem.FFieldItems;
      FTableItem.FName:= Path;
      FFieldItems.Clear;
      Table := TTable.Create(Self);
      Table.TableName := Path;
      Table.Active := True;

        hMaster :=   Table.Handle;

       Check(DbiGetCursorProps(hMaster, FTableItem.CursorProp));

       if  FTableItem.CursorProp.iFields > 0 then
       begin
        SetLength(FTableItem.aFldDesc, FTableItem.CursorProp.iFields);
        Check(DbiGetFieldDescs(hMaster, @FTableItem.aFldDesc[0]));
        for I := 0 to length(FTableItem.aFldDesc) - 1 do
        begin
          if FTableItem.aFldDesc[i].iFldNum <> (i+1) then
              FTableItem.aFldDesc[i].iFldNum := (i+1);
        end
      end;

       if  FTableItem.CursorProp.iIndexes > 0 then
       begin
          SetLength(FTableItem.aIdxDesc, FTableItem.CursorProp.iFields);
          Check(DbiGetIndexDescs(hMaster, @FTableItem.aIdxDesc[0]));
       //   PtrIdxDesc := AllocMem(SizeOf(IDXDesc) * CursorProp.iIndexes);
       //   Check(DbiGetIndexDescs(hMaster, PtrIdxDesc));
       end;


       if  FTableItem.CursorProp.iValChecks > 0 then
       begin
          SetLength(FTableItem.aVChkDesc, FTableItem.CursorProp.iValChecks);
          for ItrVChk := 0 to FTableItem.CursorProp.iValChecks-1 do
            Check(DbiGetVChkDesc(hMaster, ItrVChk+1,@FTableItem.aVChkDesc[ItrVChk]));
        end;

      if  FTableItem.CursorProp.iRefIntChecks > 0 then
       begin
          SetLength(FTableItem.aRIntDesc, FTableItem.CursorProp.iRefIntChecks);
          for ItrRInt := 0 to FTableItem.CursorProp.iRefIntChecks-1 do
            Check(DbiGetRIntDesc(hMaster, ItrVChk+1,@FTableItem.aRIntDesc[ItrVChk]));

      //  PtrRIntDesc := AllocMem(SizeOf(RINTDesc) * CursorProp.iRefIntChecks);
      //  for ItrRInt := 1 to CursorProp.iRefIntChecks do
      //    Check(DbiGetRIntDesc(hMaster, ItrRInt,Pointer(Integer(PtrRIntDesc)+(ItrRInt-1)*SizeOf(RINTDesc))));
      end;

      for I := 0 to Table.FieldDefs.Count - 1 do
      begin
        FFieldItems.Add;
        FFieldItems.Items[I].FFldDesc :=  FTableItem.aFldDesc[I];
        FFieldItems.Items[I].FName := Table.FieldDefs.Items[I].Name;
        FFieldItems.Items[I].FType := Table.FieldDefs.Items[I].DataType;

        FFieldItems.Items[I].FPrecision := Table.FieldDefs.Items[I].Precision;
        FFieldItems.Items[I].FLength := Table.FieldDefs.Items[I].Size;
        FFieldItems.Items[I].FHasValidation := false;

            
        if  FTableItem.CursorProp.iValChecks > 0 then
        begin
        // find default
              for ItrVChk := 0 to FTableItem.CursorProp.iValChecks-1 do
              begin
                  if FTableItem.aVChkDesc[ItrVChk].iFldNum = FFieldItems.Items[I].FFldDesc.iFldNum then
                  begin
                    FFieldItems.Items[I].FVCHKDesc :=   FTableItem.aVChkDesc[ItrVChk];
                    FFieldItems.Items[I].FHasValidation := true;
                    break;
                  end;
              end;
        end;
      end;
      finally

  Table.Free;

  end;
end;
end;


{ TFieldUpdate }
 procedure TFieldUpdate.DupTableStruct(SrceTbl: TTable; DestTblName: String);
 var
  TblDesc: CRTblDesc;
  PtrFldDesc, PtrIdxDesc, PtrVChkDesc, PtrRIntDesc: Pointer;
  CursorProp: CURProps;
  ItrVChk, ItrRInt: Integer;
 begin
  SrceTbl.Open;
  Check(DbiGetCursorProps(SrceTbl.Handle, CursorProp));
  // Allocate memory for field descriptors
  PtrFldDesc := AllocMem(SizeOf(FLDDesc) * CursorProp.iFields);
  PtrIdxDesc := AllocMem(SizeOf(IDXDesc) * CursorProp.iIndexes);
  PtrVChkDesc := AllocMem(SizeOf(VCHKDesc) * CursorProp.iValChecks);
  PtrRIntDesc :=AllocMem(SizeOf(RINTDesc) * CursorProp.iRefIntChecks);
  try
   Check(DbiGetFieldDescs(SrceTbl.Handle, PtrFldDesc));
   Check(DbiGetIndexDescs(SrceTbl.Handle, PtrIdxDesc));
   for ItrVChk := 1 to CursorProp.iValChecks do
    Check(DbiGetVChkDesc(SrceTbl.Handle, ItrVChk,
Pointer(Integer(PtrVChkDesc)+(ItrVChk-1)*SizeOf(VCHKDesc))));
   for ItrRInt := 1 to CursorProp.iRefIntChecks do
    Check(DbiGetRIntDesc(SrceTbl.Handle, ItrRInt,
Pointer(Integer(PtrRIntDesc)+(ItrRInt-1)*SizeOf(RINTDesc))));
   FillChar(TblDesc, SizeOf(TblDesc), #0);
   with TblDesc do
   begin
    StrPCopy(szTblName, DestTblName);
    StrCopy(szTblType, CursorProp.szTableType);
    iFldCount := CursorProp.iFields;
    pfldDesc := PtrFldDesc;
    iIdxCount := CursorProp.iIndexes;
    pIdxDesc := PtrIdxDesc;
    iValChkCount := CursorProp.iValChecks;
    pVChkDesc := PtrVChkDesc;
    iRIntCount := CursorProp.iRefIntChecks;
    pRIntDesc := PtrRIntDesc;
   end;
   Check(DbiCreateTable(SrceTbl.Database.Handle, True, TblDesc));
  finally
   FreeMem(PtrFldDesc);
   FreeMem(PtrIdxDesc);
   FreeMem(PtrVChkDesc);
   FreeMem(PtrRIntDesc);
  end;
 end;



procedure TFieldUpdate.ApplyToFile(Path: String);
var
  NewIndex: IDXDesc;
   hDb: hDBIDb;
  Table : TTable;
  I : Integer;
  J : Integer;
  FieldFound : Boolean;
  FieldDiff : Boolean;
  MyChangeRec : ChangeRec;
  TblDesc: CRTblDesc;
  pOp: pCROpType;
  fromFieldItems: TFieldItems;
  toFieldItems: TFieldItems;
begin
  if FileExists(Path) then
  begin
    try
      Table := TTable.Create(Self);
      Table.TableName := Path;
      Table.Exclusive := True;
      Table.Active := True;
      if (GetTableType(Table) = ttParadox) or
         (GetTableType(Table) = ttDBase) then
      begin

        ReadFromFile( toTableItem , Path);
        fromFieldItems:=fromTableItem.FFieldItems;
        toFieldItems:=toTableItem.FFieldItems;

         for J := 0 to fromFieldItems.Count - 1 do
        begin
          if fromFieldItems.Items[J].FName <> '' then
          begin
            CurrentField := fromFieldItems.Items[J].FName;
            FieldFound := False;
            FieldDiff := True;
            for I := 0 to toFieldItems.Count - 1 do
            begin
              FieldFound := StrCompare(toFieldItems.Items[I].FName,fromFieldItems.Items[J].FName,false) = 0;
              if FieldFound then
              begin
                if  CompareField(fromFieldItems.Items[J], toFieldItems.Items[I] ) then
                  FieldDiff := false ;
                break;
              end;
            end;
            if (FieldFound) and (FieldDiff) then
            begin
              ChangeField(Table, fromFieldItems.Items[J],toFieldItems.Items[I] );
            end else if not FieldFound then
            begin
              AddField(Table, fromFieldItems.Items[J]);
            end;
          end;
            DoOnProgress(Trunc((J / (fromFieldItems.Count)) * 100), fromFieldItems.Items[J].FName);
          end;

        CurrentField := '';
        if (Assigned(FQuickLabel)) and (FQuickStatus) then
          TLabel(FQuickLabel).Caption := '';
      end else
        DoOnError(fuApply);

        if  fromTableItem.CursorProp.iIndexes > 0 then
        begin
        try
          Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
          pOp := AllocMem(fromTableItem.CursorProp.iIndexes * sizeof(CROpType));
          for i :=0 to fromTableItem.CursorProp.iIndexes -1  do
          begin
            Inc(pOp, i);
            pOp^ := crADD;
            Dec(pOp, i);
          end ;

          FillChar(TblDesc, SizeOf(TblDesc), #0);
          with TblDesc do
          begin
            StrPCopy(szTblName, table.tablename);
            StrCopy(szTblType, szPARADOX);
            pecrIdxOp:= pOp;
            iIdxCount := fromTableItem.CursorProp.iIndexes;
            pIdxDesc :=  @fromTableItem.aIdxDesc[0];
          end;
        Table.Active := False;
        if not Table.Exclusive then
            raise EDatabaseError.Create('TTable.Exclusive must be set to true in order to add an index to the table');
             (*
                 i:=1;
           with NewIndex do
           begin
              szName := fromTableItem.aIdxDesc[i].szName;
              iIndexId:= fromTableItem.aIdxDesc[i].iIndexId;
              bPrimary:= fromTableItem.aIdxDesc[i].bPrimary;
              bUnique:= fromTableItem.aIdxDesc[i].bUnique;
              bDescending:= fromTableItem.aIdxDesc[i].bDescending;
              bMaintained:= fromTableItem.aIdxDesc[i].bMaintained;
              bSubset:= fromTableItem.aIdxDesc[i].bSubset;
              bExpIdx:= fromTableItem.aIdxDesc[i].bExpIdx;
              iFldsInKey:= fromTableItem.aIdxDesc[i].iFldsInKey;
              aiKeyFld[0]:= fromTableItem.aIdxDesc[i].aiKeyFld[0];
              bCaseInsensitive:= fromTableItem.aIdxDesc[i].bCaseInsensitive;
            end;

            Check(DbiAddIndex(hDb, Table.handle,TblDesc.szTblName, szParadox, NewIndex,
        *);
        Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));

        finally
            Table.Exclusive := false;
          if pOp <> nil then
            FreeMem(pOp);
        end;
        end;

       Table.Active := False;
      Table.Free;
    except
      DoOnError(fuApply);
    end;
  end else
    DoOnError(fuFileNotFound);
end;


procedure TFieldUpdate.ReadFromFile(Path: String);
var
  Table : TTable;
  I : Integer;
  hMaster:  hDBICur ;
  ItrVChk, ItrRInt: Integer;
begin
  if FileExists(Path) then
  begin
    ReadFromFile(fromTableItem, Path);
  end;
end;

constructor TFieldUpdate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fromTableItem := TTableItem.Create;
  fromTableItem.FFieldItems:=TFieldItems.Create;
  fromTableItem.FFieldItems.Owner:= Self;

  toTableItem :=TTableItem.Create;;
  toTableItem.FFieldItems:= TFieldItems.Create;
  toTableItem.FFieldItems.Owner:= Self;
end;

destructor TFieldUpdate.Destroy;
begin
  fromTableItem.Free;
  toTableItem.Free;
  inherited Destroy;
end;

procedure TFieldUpdate.SetFieldItems(const Value: TFieldItems);
begin
  //FFieldItems := Value;
end;

procedure TFieldUpdate.SetReadFrom(const Value: String);
begin
  FReadFrom := Value;
end;

procedure TFieldUpdate.SetOnProgress(const Value: TOnProgress);
begin
  FOnProgress := Value;
end;

procedure TFieldUpdate.DoOnProgress(Percent: Integer; FieldName : String);
begin
  if (Assigned(FQuickProgress)) and (FQuickStatus) then
  begin
    TProgressBar(FQuickProgress).Min := 0;
    TProgressBar(FQuickProgress).Max := 100;
    TProgressBar(FQuickProgress).Position := Percent;
  end;
  if (Assigned(FQuickLabel)) and (FQuickStatus) then
  Begin
    TLabel(FQuickLabel).Caption := FieldName;
    Application.ProcessMessages;
  end;
  if Assigned(FOnProgress) then
    FOnProgress(Self, Percent, FieldName);
end;

procedure TFieldUpdate.DoOnError(Error: TFieldUpdateError);
begin
  if Assigned(FOnError) then
    FOnError(Self, Error);
end;

procedure TFieldUpdate.SetOnError(const Value: TOnError);
begin
  FOnError := Value;
end;

procedure TFieldUpdate.ValidateFields(dbItem: TTableItem);
var

  I : Integer;
  J : Integer;
  value: string;

  fieldItems: TFieldItems;
  ff: TFieldItem;
  qrySql : Tquery;

begin
   qrySql:= Tquery.Create(self);
  fieldItems:=dbItem.FFieldItems;
  try

    for J := 0 to fieldItems.Count - 1 do
    begin
      value:='';
      ff := fieldItems.Items[J];
      if ff.FName <> '' then
      begin
        if ff.FHasValidation then
        begin
                   case TFieldType(ff.FFldDesc.iFldType) of
                    ftUnknown     :  value := '';
                    ftString      :  value := PChar(@ff.FVCHKDesc.aDefVal);
                    ftSmallint    :  value := '';
                    ftInteger     :  value := '';
                    ftWord        :  value := '';
                    ftBoolean     :  value := '';
                    ftFloat       :  value := ''; //value := floatTostr(PDouble(@ff.FVCHKDesc.aDefVal));
                    ftCurrency    :  value := '';
                    ftBCD         :  value := '';
                    ftDate        :  value := '';
                    ftTime        :  value := '';
                    ftDateTime    :  value := '';
                    ftBytes       :  value := '';
                    ftVarBytes    :  value := '';
                    ftAutoInc     :  value := '';
                    ftBlob        :  value := '';
                    ftMemo        :  value := '';
                    ftGraphic     :  value := '';
                    ftFmtMemo     :  value := '';
                    ftParadoxOle  :  value := '';
                    ftTypedBinary :  value := '';
                    ftCursor      :  value := '';
                    ftFixedChar   :  value := '';
                    ftWideString  :  value := '';
                    ftLargeInt    :  value := '';
                    ftADT         :  value := '';
                    ftArray       :  value := '';
                    ftReference   :  value := '';
                    ftVariant     :  value := '';
                  end;

            if value <> '' then
            begin

               	qrySql.close;
                qrySql.DatabaseName :=  extractFileDir(dbItem.FName);
	              qrySql.Sql.clear;
	              qrySql.Sql.Add('update ' +   ChangeFileExt(extractFileName(dbItem.FName) , '') ) ;
	              qrySql.Sql.Add('set ' + ff.FName + '=''' + value + '''') ;
	              qrySql.Sql.Add('where ' + ff.FName + ' is null' ) ;
                //qrySql.open;
	              qrySql.ExecSQL;
                //value:= qrySql.sql.text;
            end ;
        end;
            end;
            end;
             finally
            qrySql.Free
  end;
end;

procedure TFieldUpdate.ValidateFields(Path : String);
var
  dbItem :TTableItem;
begin
  dbItem := TTableItem.Create;
  ReadFromFile(dbItem, Path);
  ValidateFields(dbItem);
  dbItem.Free;
end;

procedure TFieldUpdate.ChangeField(Table: TTable; NewFieldItem: TFieldItem ;OldFieldItem: TFieldItem);
 var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  pFields: pFLDDesc;
  pOp: pCROpType;
  B: byte;
  MyChangeRec : ChangeRec;
  newINdex: integer;
  opTYpe : CROpType;
  Field: TField;
begin
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to restructure');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to restructure');

  Field := table.FindField(NewFieldItem.FName);
  Fillchar(MyChangeRec, sizeof(MyChangeRec), 0);
  if NewFieldItem.FName <> '' then
    StrCopy(MyChangeRec.szName, PChar(NewFieldItem.FName));
  //MyChangeRec.iType := FieldTypeToBDEFieldInt(GetTableType(Table), NewFieldItem.FType);

  MyChangeRec.iType := NewFieldItem.FFldDesc.iFldType;
  MyChangeRec.iSubType := NewFieldItem.FFldDesc.iSubType;
  if NewFieldItem.FLength <> 0 then
    MyChangeRec.iLength := NewFieldItem.FLength;
  if NewFieldItem.FPrecision <> 0 then
    MyChangeRec.iPrecision := NewFieldItem.FPrecision;

  Check(DbiSetProp(hDBIObj(Table.Handle), curxltMODE, integer(xltNONE)));
  Check(DbiGetCursorProps(Table.Handle, Props));
  if (Props.szTableType <> szPARADOX) and (Props.szTableType <> szDBASE) then
    raise EDatabaseError.Create('Field altering can only occur on Paradox' + ' or dBASE tables');
  pFields := AllocMem(Table.FieldCount * sizeof(FLDDesc));
  pOp := AllocMem(Table.FieldCount * sizeof(CROpType));

   newIndex :=  Field.Index;
  try
    Inc(pOp, newIndex);
    pOp^ := crMODIFY;
    Dec(pOp, newIndex);
    Check(DbiGetFieldDescs(Table.Handle, pFields));
    Inc(pFields, newIndex);
    if StrLen(MyChangeRec.szName) > 0 then
      pFields^.szName := MyChangeRec.szName;
    if MyChangeRec.iType > 0 then
      pFields^.iFldType := MyChangeRec.iType;
    if MyChangeRec.iSubType > 0 then
      pFields^.iSubType := MyChangeRec.iSubType;
    if MyChangeRec.iLength > 0 then
      pFields^.iUnits1 := MyChangeRec.iLength;
    if MyChangeRec.iPrecision > 0 then
      pFields^.iUnits2 := MyChangeRec.iPrecision;
    Dec(pFields, newIndex);
    for B := 1 to Table.FieldCount do begin
      pFields^.iFldNum := B;
      Inc(pFields, 1);
    end;
    Dec(pFields, Table.FieldCount);
    FillChar(TableDesc, sizeof(TableDesc), 0);
    Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
    StrPCopy(TableDesc.szTblName, Table.TableName);
    StrPCopy(TableDesc.szTblType, Props.szTableType);
    TableDesc.iFldCount := Table.FieldCount;
    TableDesc.pecrFldOp := pOp;
    TableDesc.pFldDesc := pFields;
    Table.Close;
    try
      Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));

      if NewFieldItem.FHasValidation = true  then
      begin
        if OldFieldItem.FHasValidation then
          OPTYpe := crModify
        else
          OPTYpe := crADD;
        FillChar(TableDesc, sizeof(TableDesc), 0);
        StrPCopy(TableDesc.szTblName, Table.TableName);
        StrPCopy(TableDesc.szTblType, Props.szTableType);

        NewFieldItem.FVChkDesc.iFldNum :=  newIndex+1;
        TableDesc.pecrValChkOp:= @OPTYpe;
        TableDesc.iValChkCount := 1;
        TableDesc.pVChkDesc := @NewFieldItem.FVChkDesc;
        Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
    end
    else
    begin
      begin
        if OldFieldItem.FHasValidation then
        begin
          OPTYpe := crDrop;
          FillChar(TableDesc, sizeof(TableDesc), 0);
          StrPCopy(TableDesc.szTblName, Table.TableName);
          StrPCopy(TableDesc.szTblType, Props.szTableType);

          //NewFieldItem.FVChkDesc.iFldNum :=  newIndex+1;
          TableDesc.pecrValChkOp:= @OPTYpe;
          TableDesc.iValChkCount := 1;
          TableDesc.pVChkDesc := @OldFieldItem.FVChkDesc;
          Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
        end;
    end;

    end;


    finally
      Table.Open;
    end;
  finally
    if pFields <> nil then
      FreeMem(pFields);
    if pOp <> nil then
      FreeMem(pOp);
  end;
end;

//returns true if they are the same
function TFieldUpdate.CompareField(OldField: TFieldItem ; NewFieldItem: TFieldItem) : boolean ;
begin
  result := false;
  if (OldField.FType = NewFieldItem.FType) and
    (OldField.FPrecision = NewFieldItem.FPrecision) and
    (OldField.FLength = NewFieldItem.FLength)  and
    (OldField.FHasValidation = NewFieldItem.FHasValidation) then
    begin
      //check if the default has changed.
      if(OldField.FHasValidation ) and ( NewFieldItem.FHasValidation  ) then
      begin
        if OldField.FVCHKDesc.bRequired = NewFieldItem.FVCHKDesc.bRequired and
          OldField.FVCHKDesc.bHasDefVal = NewFieldItem.FVCHKDesc.bHasDefVal  then
          //OldField.FVCHKDesc.aDefVal = NewFieldItem.FVCHKDesc.aDefVal and then
            result:=true;
      end
      else
      begin
        if NewFieldItem.FHasValidation = true then
          result :=true;
      end
    end;
end;


procedure TFieldUpdate.AddField(Table: TTable; NewFieldItem: TFieldItem) ;
 var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  pFlds: pFLDDesc;
  pOp: pCROpType;
  B: byte;
  MyChangeRec : ChangeRec;
  newINdex: integer;
  opTYpe : CROpType;

 begin

  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to restructure');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to restructure');

    Fillchar(MyChangeRec, sizeof(MyChangeRec), 0);
    if NewFieldItem.FName <> '' then
      StrCopy(MyChangeRec.szName, PChar(NewFieldItem.FName));
    MyChangeRec.iType := FieldTypeToBDEFieldInt(GetTableType(Table), NewFieldItem.FType);
    if NewFieldItem.FLength <> 0 then
                MyChangeRec.iLength := NewFieldItem.FLength;
    if NewFieldItem.FPrecision <> 0 then
                MyChangeRec.iPrecision := NewFieldItem.FPrecision;

  Check(DbiSetProp(hDBIObj(Table.Handle), curxltMODE, integer(xltNONE)));
  Check(DbiGetCursorProps(Table.Handle, Props));
  pFlds := AllocMem((Table.FieldCount + 1) * sizeof(FLDDesc));
  FillChar(pFlds^, (Table.FieldCount + 1) * sizeof(FLDDesc), 0);
  Check(DbiGetFieldDescs(Table.handle, pFlds));
  for B := 1 to Table.FieldCount do begin
    pFlds^.iFldNum := B;
    Inc(pFlds, 1);
  end;

  newIndex :=  Table.FieldCount + 1;

  try
    StrCopy(pFlds^.szName, MyChangeRec.szName);
    pFlds^.iFldType := MyChangeRec.iType;
    pFlds^.iSubType := MyChangeRec.iSubType;
    pFlds^.iUnits1  := MyChangeRec.iLength;
    pFlds^.iUnits2  := MyChangeRec.iPrecision;
    pFlds^.iFldNum  := newIndex;
  finally
    Dec(pFlds, Table.FieldCount);
  end;
  pOp := AllocMem((newIndex) * sizeof(CROpType));
  Inc(pOp, Table.FieldCount);
  pOp^ := crADD;
  Dec(pOp, Table.FieldCount);
   Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));

  FillChar(TableDesc, sizeof(TableDesc), 0);
  StrPCopy(TableDesc.szTblName, Table.TableName);
  StrPCopy(TableDesc.szTblType, Props.szTableType);
  TableDesc.iFldCount := newIndex;
  Tabledesc.pfldDesc := pFlds;
  TableDesc.pecrFldOp := pOp;
  Table.Close;

  try
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));

    if NewFieldItem.FHasValidation = true  then
    begin
      OPTYpe := crAdd;
      FillChar(TableDesc, sizeof(TableDesc), 0);
      StrPCopy(TableDesc.szTblName, Table.TableName);
      StrPCopy(TableDesc.szTblType, Props.szTableType);

      NewFieldItem.FVChkDesc.iFldNum :=  newIndex;
      TableDesc.pecrValChkOp:= @OPTYpe;
      TableDesc.iValChkCount := 1;
      TableDesc.pVChkDesc := @NewFieldItem.FVChkDesc;

      Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
    end;

  finally
    FreeMem(pFlds);
    FreeMem(pOp);
    Table.Open;
  end;
end;

function TFieldUpdate.GetTableType(Table : TTable) : TTableType;
begin
  if Table.TableType <> ttDefault then
    Result := Table.TableType
  else
  begin
    if (UpperCase(ExtractFileExt(Table.TableName)) = '.DB') or
       (UpperCase(ExtractFileExt(Table.TableName)) = '') then
      Result := ttParadox
    else if UpperCase(ExtractFileExt(Table.TableName)) = '.DBF' then
      Result := ttDBase
    else if UpperCase(ExtractFileExt(Table.TableName)) = '.TXT' then
      Result := ttASCII
    else
      Result := ttParadox;
  end;
end;

function TFieldUpdate.FieldTypeToBDEFieldInt(TableType : TTableType; FieldType: TFieldType): Word;
begin
  Result := fldUNKNOWN;
  case TableType of
    ttParadox : begin
                  case FieldType of
                    ftUnknown     :  result := fldUNKNOWN;
                    ftString      :  result := fldZSTRING;
                    ftSmallint    :  result := fldPDXSHORT;
                    ftInteger     :  result := fldINT32;
                    ftWord        :  result := fldUINT16;
                    ftBoolean     :  result := fldBOOL;
                    ftFloat       :  result := fldFLOAT;
                    ftCurrency    :  result := fldPDXMONEY;
                    ftBCD         :  result := fldBCD;
                    ftDate        :  result := fldDATE;
                    ftTime        :  result := fldTIME;
                    ftDateTime    :  result := fldPDXDATETIME;
                    ftBytes       :  result := fldBYTES;
                    ftVarBytes    :  result := fldVARBYTES;
                    ftAutoInc     :  result := fldPDXAUTOINC;
                    ftBlob        :  result := fldBLOB;
                    ftMemo        :  result := fldPDXMEMO;
                    ftGraphic     :  result := fldPDXGRAPHIC;
                    ftFmtMemo     :  result := fldPDXFMTMEMO;
                    ftParadoxOle  :  result := fldPDXOLEBLOB;
                    ftTypedBinary :  result := fldPDXBINARYBLOB;
                    ftCursor      :  result := fldCURSOR;
                    ftFixedChar   :  result := fldPDXCHAR;
                    ftWideString  :  result := fldZSTRING;
                    ftLargeInt    :  result := fldINT64;
                    ftADT         :  result := fldADT;
                    ftArray       :  result := fldARRAY;
                    ftReference   :  result := fldREF;
                    ftVariant     :  result := fldUNKNOWN;
                  end;
                end;
    ttDBase   : begin
                  case FieldType of
                    ftUnknown     :  result := fldUNKNOWN;
                    ftString      :  result := fldZSTRING;
                    ftSmallint    :  result := fldDBNUM;
                    ftInteger     :  result := fldINT16;
                    ftWord        :  result := fldUINT16;
                    ftBoolean     :  result := fldBOOL;
                    ftFloat       :  result := fldFLOAT;
                    ftCurrency    :  result := fldUNKNOWN;
                    ftBCD         :  result := fldBCD;
                    ftDate        :  result := fldDATE;
                    ftTime        :  result := fldTIME;
                    ftDateTime    :  result := fldDBDATETIME;
                    ftBytes       :  result := fldBYTES;
                    ftVarBytes    :  result := fldVARBYTES;
                    ftAutoInc     :  result := fldDBAUTOINC;
                    ftBlob        :  result := fldBLOB;
                    ftMemo        :  result := fldDBMEMO;
                    ftDBaseOle    :  result := fldDBOLEBLOB;
                    ftTypedBinary :  result := fldDBBINARY;
                    ftCursor      :  result := fldCURSOR;
                    ftFixedChar   :  result := fldDBCHAR;
                    ftWideString  :  result := fldZSTRING;
                    ftLargeInt    :  result := fldINT32;
                    ftADT         :  result := fldADT;
                    ftArray       :  result := fldARRAY;
                    ftReference   :  result := fldREF;
                    ftVariant     :  result := fldUNKNOWN;
                  end;
                end;
  end;
end;


procedure TFieldUpdate.LoadFromFile(Path: String);
var
  Stream : TFileStream;
  BinStream : TMemoryStream;
begin
  try
    Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
    try
      BinStream := TMemoryStream.Create;
      try
        ObjectTextToBinary(Stream, BinStream);
        BinStream.Seek(0, soFromBeginning);
        RegisterClass(TFieldUpdate);
        //Self.FFieldItems := TFieldUpdate(BinStream.ReadComponent(nil)).FFieldItems;
      finally
        BinStream.Free;
      end;
    finally
      Stream.Free;
    end;
  except
    DoOnError(fuLoad);
  end;
end;

procedure TFieldUpdate.SaveToFile(Path: String);
var
  BinStream :TMemoryStream;
  Stream : TFileStream;
begin
  try
    BinStream := TMemoryStream.Create;
    if FileExists(Path) then
      DeleteFile(Path);
    try
      Stream := TFileStream.Create(Path, fmCreate or fmShareDenyNone);
      try
        BinStream.WriteComponent(Self);
        BinStream.Seek(0, soFromBeginning);
        ObjectBinaryToText(BinStream, Stream);
      finally
        Stream.Free;
      end;
    finally
      BinStream.Free;
    end;
  except
    DoOnError(fuSave);
  end;
end;

procedure TFieldUpdate.LoadFromStream(Stream: TStream);
var
  BinStream: TMemoryStream;
begin
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(Stream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      RegisterClass(TFieldUpdate);
      //Self.FFieldItems := TFieldUpdate(BinStream.ReadComponent(nil)).FFieldItems;
    finally
      BinStream.Free;
    end;
  except
    DoOnError(fuLoad);
  end;
end;

procedure TFieldUpdate.SaveToStream(Stream: TStream);
var
  BinStream: TMemoryStream;
begin
  try
    BinStream := TMemoryStream.Create;
    try
      BinStream.WriteComponent(Self);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, Stream);
    finally
      BinStream.Free;
    end;
  except
    DoOnError(fuSave);
  end;
end;

function TFieldUpdate.FieldTypeToString(FieldType: TFieldType): String;
begin
  result := 'ftUnknown';
  case FieldType of
    ftUnknown     :  result := 'ftUnknown';
    ftString      :  result := 'ftString';
    ftSmallint    :  result := 'ftSmallint';
    ftInteger     :  result := 'ftInteger';
    ftWord        :  result := 'ftWord';
    ftBoolean     :  result := 'ftBoolean';
    ftFloat       :  result := 'ftFloat';
    ftCurrency    :  result := 'ftCurrency';
    ftBCD         :  result := 'ftBCD';
    ftDate        :  result := 'ftDate';
    ftTime        :  result := 'ftTime';
    ftDateTime    :  result := 'ftDateTime';
    ftBytes       :  result := 'ftBytes';
    ftVarBytes    :  result := 'ftVarBytes';
    ftAutoInc     :  result := 'ftAutoInc';
    ftBlob        :  result := 'ftBlob';
    ftMemo        :  result := 'ftMemo';
    ftGraphic     :  result := 'ftGraphic';
    ftFmtMemo     :  result := 'ftFmtMemo';
    ftParadoxOle  :  result := 'ftParadoxOle';
    ftTypedBinary :  result := 'ftTypedBinary';
    ftCursor      :  result := 'ftCursor';
    ftFixedChar   :  result := 'ftFixedChar';
    ftWideString  :  result := 'ftWideString';
    ftLargeInt    :  result := 'ftLargeInt';
    ftADT         :  result := 'ftADT';
    ftArray       :  result := 'ftArray';
    ftReference   :  result := 'ftReference';
    ftVariant     :  result := 'ftVariant';
  end;
end;

function TFieldUpdate.StringToFieldType(FieldType: String): TFieldType;
begin
  result := ftUnknown;
  if FieldType = 'ftUnknown' then result := ftUnknown
  else if FieldType = 'ftString' then result := ftString
  else if FieldType = 'ftSmallint' then result := ftSmallint
  else if FieldType = 'ftInteger' then result := ftInteger
  else if FieldType = 'ftWord' then result := ftWord
  else if FieldType = 'ftBoolean' then result := ftBoolean
  else if FieldType = 'ftFloat' then result := ftFloat
  else if FieldType = 'ftCurrency' then result := ftCurrency
  else if FieldType = 'ftBCD' then result := ftBCD
  else if FieldType = 'ftDate' then result := ftDate
  else if FieldType = 'ftTime' then result := ftTime
  else if FieldType = 'ftDateTime' then result := ftDateTime
  else if FieldType = 'ftBytes' then result := ftBytes
  else if FieldType = 'ftVarBytes' then result := ftVarBytes
  else if FieldType = 'ftAutoInc' then result := ftAutoInc
  else if FieldType = 'ftBlob' then result := ftBlob
  else if FieldType = 'ftMemo' then result := ftMemo
  else if FieldType = 'ftGraphic' then result := ftGraphic
  else if FieldType = 'ftFmtMemo' then result := ftFmtMemo
  else if FieldType = 'ftParadoxOle' then result := ftParadoxOle
  else if FieldType = 'ftTypedBinary' then result := ftTypedBinary
  else if FieldType = 'ftCursor' then result := ftCursor
  else if FieldType = 'ftFixedChar' then result := ftFixedChar
  else if FieldType = 'ftWideString' then result := ftWideString
  else if FieldType = 'ftLargeInt' then result := ftLargeInt
  else if FieldType = 'ftADT' then result := ftADT
  else if FieldType = 'ftArray' then result := ftArray
  else if FieldType = 'ftReference' then result := ftReference
  else if FieldType = 'ftVariant' then result := ftVariant;
end;

procedure TFieldUpdate.LoadFromIni(IniFile: TIniFile);
var
  I : Integer;
begin
(*
  try
    FFieldItems.Clear;
    for I := 0 to IniFile.ReadInteger('Total', 'Count', 0) - 1 do
    begin
      FFieldItems.Items[I].Name := IniFile.ReadString(IntToStr(I), 'Name', '');
      FFieldItems.Items[I].FieldType := StringToFieldType(IniFile.ReadString(IntToStr(I), 'FieldType', ''));
      FFieldItems.Items[I].Length := IniFile.ReadInteger(IntToStr(I), 'Length', 0);
      FFieldItems.Items[I].Precision := IniFile.ReadInteger(IntToStr(I), 'Precision', 0);
    end;
  except
    DoOnError(fuLoad);
  end;
  *)
end;

procedure TFieldUpdate.SaveToIni(IniFile: TIniFile);
var
  I : Integer;
begin
(*
  try
    IniFile.WriteInteger('Total', 'Count', FFieldItems.Count);
    for I := 0 to FFieldItems.Count - 1 do
    begin
      IniFile.WriteString(IntToStr(I), 'Name', FFieldItems.Items[I].Name);
      IniFile.WriteString(IntToStr(I), 'FieldType', FieldTypeToString(FFieldItems.Items[I].FieldType));
      IniFile.WriteInteger(IntToStr(I), 'Length', FFieldItems.Items[I].Length);
      IniFile.WriteInteger(IntToStr(I), 'Precision', FFieldItems.Items[I].Precision);
    end;
  except
    DoOnError(fuSave);
  end;
  *)
end;

procedure TFieldUpdate.LoadFromWinSock(Socket: TCustomWinSocket;
  TimeOut: Integer);
var
  Stream : TWinSocketStream;
  BinStream: TMemoryStream;
begin
  try
    Stream := TWinSocketStream.Create(Socket, TimeOut);
    try
      BinStream := TMemoryStream.Create;
      try
        ObjectTextToBinary(Stream, BinStream);
        BinStream.Seek(0, soFromBeginning);
        RegisterClass(TFieldUpdate);
        //Self.FFieldItems := TFieldUpdate(BinStream.ReadComponent(nil)).FFieldItems;
      finally
        BinStream.Free;
      end;
    finally
      Stream.Free;
    end;
  except
    DoOnError(fuLoad);
  end;
end;

procedure TFieldUpdate.SaveToWinSock(Socket: TCustomWinSocket;
  TimeOut: Integer);
var
  BinStream: TMemoryStream;
  Stream : TWinSocketStream;
begin
  try
    BinStream := TMemoryStream.Create;
    try
      Stream := TWinSocketStream.Create(Socket, TimeOut);
      try
        BinStream.WriteComponent(Self);
        BinStream.Seek(0, soFromBeginning);
        ObjectBinaryToText(BinStream, Stream);
      finally
        Stream.Free;
      end;
    finally
      BinStream.Free;
    end;
  except
    DoOnError(fuSave);
  end;
end;

procedure TFieldUpdate.SetQuickStatus(const Value: Boolean);
begin
  FQuickStatus := Value;
end;

procedure TFieldUpdate.SetQuickLabel(const Value: TLabel);
begin
  FQuickLabel := Value;
end;

procedure TFieldUpdate.SetQuickProgress(const Value: TProgressBar);
begin
  FQuickProgress := Value;
end;

procedure TFieldUpdate.CopyNewTables(SrcDB, DsDB: String; Overwrite: Boolean);
var
  i: integer;
  List: TStrings;
  srcFilename: string ;
   dstFilename: string;
begin
  if BuildFileList(SrcDB + '\*.db', faAnyFile  ,List,False) = true then
  begin
      For i := 0 to List.Count - 1 do
      begin
        srcFilename :=  SrcDB + '\' + List[i] ;
        dstFilename :=  DsDB + '\' + List[i] ;
        if not FileExists(dstFilename) then
        begin
          CopyNewTable(srcFilename, dstFilename, false);
        end;
     end
  end;

end;

procedure TFieldUpdate.CopyNewTable(SrcTbl, DstTbl: String; Overwrite: Boolean);
var
  DB      : TDatabase;
  STbl,
  DTbl    : String;
begin
  {Since we're using path names and not BDE aliases, we have to do
   some checking of the paths to see if they're blank; that is, the
   user passed just the file name to the procedure, and not the
   FULLY QUALIFIED file name. In that case, we merely set the source
   and destination to the application's EXEName directory}
  if (ExtractFilePath(SrcTbl) = '') then
    STbl := ExtractFilePath(Application.EXEName) + SrcTbl
  else
    STbl := SrcTbl;

  if (ExtractFilePath(DstTbl) = '') then
    DTbl := ExtractFilePath(Application.EXEName) + DstTbl
  else
    DTbl := DstTbl;

  {First, check to see if the source file actually exists. If it does
  create a TDatabase that points to the source file's directory.
  This can actually point anywhere using the method we're using because
  we're specifying fully qualified file names as entries as opposed to. The important thing though, is to
  set it to a valid directory}
  if FileExists(STbl) then
    begin
      DB := TDatabase.Create(nil);
      with DB do begin
        Connected := False;
        DatabaseName := ExtractFilePath(SrcTbl);
        DriverName := 'STANDARD';
        Connected := True;
      end;

    {Do the table copy from source to dest. Notice the PChar typecast of STbl
     and DTbl. The BDE function actually calls for a DBITBLNAME type. But this
     is just a null-terminated string - a PChar - so we can save ourselves a
     lot of time by just typecasting the strings.}
      Check(DBICopyTable(DB.Handle, Overwrite, PChar(STbl), nil, PChar(DTbl)));

      //Get rid of the database component.
      DB.Free;
    end
  else
    ShowMessage('Could not copy the table. It is not in the location specified.');
end;

// Purpose: Use the pOptData portion of DbiDoRestructure.
// Remarks: This function calls DbiDoRestructure with the Option to change
//          and the OptData which is the new value of the option. Since a
//          database handle is needed and the table cannot be opened when
//          restructuring is done, a new database handle is created and set
//          to the directory where the table resides.
// Example: RestructureTable(Table1, 'LEVEL', '7')
//             Change table level to 7
//          RestructureTable(Table1, 'BLOCK SIZE', '4096')
//             Change table block size to 4096
//
procedure TFieldUpdate.RestructureTable(sTableName: string; Option, OptData: string);
var
  hDb: hDBIDb;
  TblDesc: CRTblDesc;
  Props: CurProps;
  pFDesc: FLDDesc;
  table : TTable;
begin
table:= TTable.create(self);
  //table.exclusive:=true;
  table.tablename:= sTableName;
  table.exclusive:=true;
   table.open;

  // If the table is not opened, raise an error.  Need the table open to get
  //   the table directory.
  if Table.Active <> True then
    raise EDatabaseError.Create('Table is not opened');
  // If the table is not opened exclusively, raise an error. DbiDoRestructure
  //   will need exclusive access to the table.
  if Table.Exclusive <> True then
    raise EDatabaseError.Create('Table must be opened exclusively');
  // Get the table properties.
  Check(DbiGetCursorProps(Table.Handle, Props));
  // If the table is not a Paradox type, raise an error.  These options only
  //   work with Paradox tables.
  if StrComp(Props.szTableType, szPARADOX) <> 0 then
    raise EDatabaseError.Create('Table must be of type PARADOX');
  // Get the database handle.
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  // Close the table.
  Table.Close;
  // Setup the Table descriptor for DbiDoRestructure
  FillChar(TblDesc, SizeOf(TblDesc), #0);
  StrPCopy(TblDesc.szTblName, Table.Tablename);
  StrCopy(TblDesc.szTblType, szParadox);
  // The optional parameters are passed in through the FLDDesc structure.
  //   It is possible to change many Options at one time by using a pointer
  //   to a FLDDesc (pFLDDesc) and allocating memory for the structure.
  pFDesc.iOffset := 0;
  pFDesc.iLen := Length(OptData) + 1;
  StrPCopy(pFDesc.szName, Option);
  // The changed values of the optional parameters are in a contiguous memory
  //   space.  Sonce only one parameter is being used, the OptData variable
  //   can be used as a contiguous memory space.
  TblDesc.iOptParams := 1;  // Only one optional parameter
  TblDesc.pFldOptParams := @pFDesc;
  TblDesc.pOptData := @OptData[1];
  try
    // Restructure the table with the new parameter.
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    Table.close;
    table.free;
  end;
end;

 (*
extern Word __stdcall DbiPackTable(hDBIDb hDb, hDBICur hCursor, char *pszTableName,
        char * pszDriverType , DWord bRegenIdxs);



ifndef PackTableH

#define PackTableH

#include <vcl\dbtables.hpp>

bool PackTable(TTable *table);

#endif

Listing D: The PackTable function


#include <vcl.h>

#pragma hdrstop

#include "PackTable.h"

bool PackTable(TTable *table)

{

bool active = table->Active;

bool exclusive = table->Exclusive;

bool retval = true;

try

{

if (!exclusive)

{

table->Active = false;

table->Exclusive = true;

}

table->Active = true;

CURProps props;

Check(DbiGetCursorProps(table->Handle, props));

String tableType = props.szTableType;

if (tableType == szPARADOX)

{

CRTblDesc tableDesc;

memset(&tableDesc, 0, sizeof(tableDesc));

lstrcpy(tableDesc.szTblName,

table->TableName.c_str());

lstrcpy(tableDesc.szTblType, szPARADOX);

tableDesc.bPack = true;

hDBIDb hDb = table->DBHandle;

table->Close();

Check(DbiDoRestructure(hDb, 1, &tableDesc,

0, 0, 0, false));

table->Open();

}

else if (tableType == szDBASE)

Check(DbiPackTable(table->DBHandle,

table->Handle, 0, szDBASE, true));

else

retval = false;

}

catch(...)

{

retval = false;

}

table->Active = false;

table->Exclusive = exclusive;

table->Active = active;

return(retval);

}

*)


end.
