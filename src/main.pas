unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, DB, TUtil32, BDE, DBTables, Menus, FileCtrl,
  Grids, DBCtrls, DBGrids, ActnList, Buttons;

type

  TBDEUtil = class;

  TMainForm = class(TForm)
    OpenDialog1: TOpenDialog;
    Session1: TSession;
    dbHelixDoctor: TDatabase;
    menuMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    Open2: TMenuItem;
    tblDiskDoctor: TTable;
    memuAliasses: TPopupMenu;
    menuVerifyTable: TMenuItem;
    menuRebuildTable: TMenuItem;
    Table1: TMenuItem;
    DataBase2: TMenuItem;
    Verify2: TMenuItem;
    Rebuild2: TMenuItem;
    StatusBar1: TStatusBar;
    pcTable: TPageControl;
    tsStatus: TTabSheet;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    TableLocEdit: TEdit;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    FieldsLB: TLabel;
    RecSizeLB: TLabel;
    IndexLB: TLabel;
    ValidLB: TLabel;
    RefLB: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    RestructLB: TLabel;
    AuxPassLB: TLabel;
    CodePageLB: TLabel;
    BlockSizeLB: TLabel;
    TabLvlLB: TLabel;
    GroupBox3: TGroupBox;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    MessageLB: TLabel;
    PBHeader: TProgressBar;
    PBIndexes: TProgressBar;
    PBData: TProgressBar;
    PBRebuild: TProgressBar;
    tsIndex: TTabSheet;
    IndexGrid: TStringGrid;
    tsFields: TTabSheet;
    Grid1: TStringGrid;
    tsData: TTabSheet;
    panelq: TPanel;
    GroupBox4: TGroupBox;
    Panel1: TPanel;
    lbTables: TListBox;
    AliasCombo: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    tblTemp: TTable;
    ActionList1: TActionList;
    grdData: TDBGrid;
    navTemp: TDBNavigator;
    dsTemp: TDataSource;
    tsSQL: TTabSheet;
    qrySql: TQuery;
    dsSql: TDataSource;
    grdSQL: TDBGrid;
    Panel3: TPanel;
    Panel2: TPanel;
    btnGo: TSpeedButton;
    btnClear: TBitBtn;
    memoSql: TMemo;
    Splitter1: TSplitter;
    actVerifyTable: TAction;
    actRebuildTable: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    tsLog: TTabSheet;
    DBGrid1: TDBGrid;
    tblLog: TTable;
    dsLog: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure AliasComboChange(Sender: TObject);
    procedure ByDirectBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure lbTablesClick(Sender: TObject);
    procedure tsDataEnter(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure actVerifyTableExecute(Sender: TObject);
    procedure actRebuildTableExecute(Sender: TObject);
  private
    { Private declarations }
    BDEUtil: TBDEUtil;
    procedure OpenDatabaseList;
    procedure SetTableAndDir(ByDirectory: Boolean);
    procedure ClearBars;
    procedure ClearLabels;
    procedure SetTableInfo;
    procedure ClearTable;
    procedure SetTable(TableName: String);
    procedure FillGrids( strFile : String );
    function TableVerify(Table:string;var sResultString:string):integer;
    function TableRebuild(szTable:string;var sResultString:string):integer;

  public
    { Public declarations }
  end;

  TBDEUtil = class
    CbInfo: TUVerifyCallback;
    TUProps: CURProps;
    hDb: hDBIDb;
    vhTSes: hTUSes;
    constructor Create;
    destructor Destroy; override;
    function GetTCursorProps(szTable: String): Boolean;
    procedure RegisterCallBack;
    procedure UnRegisterCallBack;
  end;

var
  MainForm: TMainForm;

implementation

uses about;

{$R *.DFM}

function GenProgressCallBack(ecbType: CBType; Data: LongInt; pcbInfo: Pointer):
  CBRType; stdcall;
var
  CBInfo: TUVerifyCallBack;
begin
  CBInfo := TUVerifyCallBack(pcbInfo^);
  if ecbType = cbGENPROGRESS then
    case CBInfo.Process of
     TUVerifyHeader: begin
       MainForm.PBHeader.Position := CBInfo.percentdone;
     end;
     TUVerifyIndex: begin
       MainForm.PBIndexes.Position := CBInfo.percentdone;
     end;
     TUVerifyData: begin
       MainForm.PBData.Position := CBInfo.percentdone;
     end;
     TURebuild: begin
       MainForm.PBRebuild.Position := CBInfo.percentdone;
     end;
    end;

  Result := cbrUSEDEF;
end;


constructor TBDEUtil.Create;
begin
  Check(TUInit(vhtSes));
end;

destructor TBDEUtil.Destroy;
begin
  Check(TUExit(vhtSes));
  inherited Destroy;
end;

function TBDEUtil.GetTCursorProps(szTable: String): Boolean;
begin
  if TUFillCURProps(vHtSes, PChar(szTable), TUProps) = DBIERR_NONE then
    Result := True
  else Result := False;
end;

procedure TBDEUtil.RegisterCallback;
begin
 Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
            sizeof(TUVerifyCallBack), @CbInfo, GenProgressCallback));
end;

procedure TBDEUtil.UnRegisterCallback;
begin
  Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
           sizeof(TUVerifyCallBack), @CbInfo, nil));
end;

procedure TMainForm.OpenDataBaseList;
var
  TmpCursor: hDbiCur;
  vDBDesc: DBDesc;
  iI:integer;
begin
  AliasCombo.Items.Clear;
  Check(DbiOpenDatabaseList(TmpCursor));
  while (DbiGetNextRecord(TmpCursor, dbiNOLOCK, @vDBDesc, nil)
                                      = DBIERR_NONE) do begin
    if vDBDesc.szDBType = 'STANDARD' then
      AliasCombo.Items.Add(vDBDesc.szName);
  end;


  Check(DbiCloseCursor(TmpCursor));
  // scan aliases for our batabase
  	for iI := 0 to AliasCombo.Items.Count - 1 do
	begin
		if UpperCase(AliasCombo.Items[iI]) = 'MERCHANTMAGIC' then
      begin
      	AliasCombo.ItemIndex:=iI;
		   AliasCombo.text:=AliasCombo.Items[iI];
   		AliasComboChange(Self);
         break;
      end;
	end;

end;

procedure TMainForm.ClearBars;
begin
  MessageLB.Caption := '';
  PBHeader.Position := 0;
  PBIndexes.Position := 0;
  PBData.Position := 0;
  PBRebuild.Position := 0;
end;

procedure TMainForm.ClearLabels;
begin
  FieldsLB.Caption := '0';
  RecSizeLB.Caption := '0';
  IndexLB.Caption := '0';
  ValidLB.Caption := '0';
  RefLB.Caption := '0';
  RestructLB.Caption := '0';
  AuxPassLB.Caption := '0';
  CodePageLB.Caption := '0';
  BlockSizeLB.Caption := '0';
  TabLvlLB.Caption := '0';
end;

procedure TMainForm.ClearTable;
begin
  TableLocEdit.Text := '';
  actVerifyTable.Enabled := False;
  actRebuildTable.Enabled := False;
end;

procedure TMainForm.SetTable(TableName: String);
begin
  TableLocEdit.Text := TableName;
  actVerifyTable.Enabled := True;
  actRebuildTable.Enabled := True;
end;

procedure TMainForm.SetTableAndDir;
var
  vDBDesc: DBDesc;
  Alias: String;
  Table: String;
begin
  Alias := AliasCombo.Items[AliasCombo.ItemIndex];
//  Table := TableCombo.Items[TableCombo.ItemIndex];
  Table := lbTables.Items[lbTables.ItemIndex];
  Check(DbiGetDatabaseDesc(PChar(Alias), @vDBDesc));
  SetTable(Format('%s\%s', [vDBDesc.szPhyName, Table]));
  ClearBars;
  SetTableInfo();
  FillGrids( TableLocEdit.text);
  if tsData.visible then
		tblTemp.open;
end;

procedure TMainForm.SetTableInfo;
var
  Table: String;
  
begin
  Table := TableLocEdit.Text;
  if BDEUtil.GetTCursorProps(Table) then
  with BDEUtil.TUProps do begin
    FieldsLB.Caption := IntToStr(iFields);
    RecSizeLB.Caption := IntToStr(iRecBufSize);
    IndexLB.Caption := IntToStr(iIndexes);
    ValidLB.Caption := InttoStr(iValChecks);
    RefLB.Caption := IntToStr(iRefIntChecks);
    RestructLB.Caption := IntToStr(iRestrVersion);
    AuxPassLB.Caption := IntToStr(iPasswords);
    CodePageLB.Caption := IntToStr(iCodePage);
    BlockSizeLB.Caption := IntToStr(iBlockSize);
    TabLvlLB.Caption := IntToStr(iTblLevel);
  end;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  Session1.Active := True;
  OpenDatabaseList;
  BDEUtil := TBDEUtil.Create;

end;

procedure TMainForm.AliasComboChange(Sender: TObject);
begin
  Session1.GetTableNames(AliasCombo.Items[AliasCombo.ItemIndex], '*.*',
    True, False, lbTables.Items);
  ClearBars;
  ClearLabels;
  ClearTable;
  dbHelixDoctor.Connected := False;
  dbHelixDoctor.AliasName := AliasCombo.Items[AliasCombo.ItemIndex];
  dbHelixDoctor.Connected := True;
// Check for log table of asci type

  if lbTables.Items.IndexOf('HelixDoctorLog.db')= 0 then
  begin
   tblLog.close;
  	tblLog.TableName:='HelixDoctorLog.db';
   tblLog.TableType:=ttParadox;
   with tblLog.FieldDefs do
   begin
   	Clear;
    	Add('Time',ftDateTime, 0, False);
    	Add('TableName',ftString, 50 ,True);
    	Add('Action',ftString,10, True);
    	Add('Result',ftString,100, True);
   end;
   tblLog.CreateTable;
   tblLog.open;
  end
///  Session1.GetTableNames(AliasCombo.Items[AliasCombo.ItemIndex], '*.*',
//    True, False, TableCombo.Items);

end;

procedure TMainForm.ByDirectBtnClick(Sender: TObject);
begin
 if OpenDialog1.Execute then begin
   SetTable(OpenDialog1.FileName);
   AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo;
 end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  BDEUtil.Free;
end;

procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AboutBtnClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
 if OpenDialog1.Execute then
 begin
   SetTable(OpenDialog1.FileName);
   AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo;
 end;

end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
if OpenDialog1.Execute then
 begin
   SetTable(OpenDialog1.FileName);
   AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo;
 end;

end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
	close;
end;

procedure TMainForm.lbTablesClick(Sender: TObject);
begin
	SetTableAndDir(FALSE);

end;

procedure TMainForm.FillGrids( strFile : String );

   procedure ClearGrid(var Grid: TStringGrid; iStartCol, iStartRow :integer);
   var i:integer;
     j:integer;
   begin
      for i:=iStartRow to Grid.RowCount do
      begin
        for j:=iStartCol to Grid.ColCount do
           Grid.Cells[j,i]:='';
      end;
   end;

var strDT : String;
	strTemp: String;
    iPos : Integer;
    i : Integer;
    iNumKeys : Integer;

begin

   tblTemp.close;
   tblTemp.TableName := TableLocEdit.text;
   tblTemp.IndexDefs.Update;  {Make the index values available}
   tblTemp.FieldDefs.Update;

   Grid1.RowCount := tblTemp.FieldDefs.Count + 1;
   if tblTemp.IndexDefs.Count > 0 then
      IndexGrid.RowCount := tblTemp.IndexDefs.Count + 1
   else
      IndexGrid.RowCount := 2;

   iNumKeys := 0;
   for i:= 1 to tblTemp.IndexDefs.Count do
   begin
        IndexGrid.Cells[0, i] := tblTemp.IndexDefs.Items[i-1].Name;
        IndexGrid.Cells[1, i] := tblTemp.IndexDefs.Items[i-1].Fields;
   end;

   IndexGrid.Cells[0, 1]:= 'PrimaryIndex'; {By Default}
   ClearGrid(IndexGrid,0,tblTemp.IndexDefs.Count+1);

   if Length(IndexGrid.Cells[1,1]) > 0 then
   begin
     iNumKeys := 1;
     strTemp := IndexGrid.Cells[1,1];
     iPos := Pos(';', strTemp);
     while iPos <> 0 do
     begin
        Inc(iNumKeys);
        strTemp[iPos] := ' ';
        iPos := Pos(';', strTemp);
     end;
   end;

   for i:= 1 to tblTemp.FieldDefs.Count do
   begin
		Grid1.Cells[0, i] := tblTemp.FieldDefs.Items[i-1].Name;
      case tblTemp.FieldDefs.Items[i-1].DataType of
        ftUnknown : strDT := 'Unknown';
        ftString : strDT := 'String';
        ftSmallint : strDT := 'Small Int';
        ftInteger : strDT := 'Integer';
        ftWord : strDT := 'Word';
        ftBoolean : strDT := 'Boolean';
        ftFloat : strDT := 'Float';
        ftCurrency : strDT := 'Currency';
        ftBCD : strDT := 'BCD';
        ftDate : strDT := 'Date';
        ftTime : strDT := 'Time';
        ftDateTime : strDT := 'DateTime';
        ftBytes : strDT := 'Bytes';
        ftVarBytes : strDT := 'VarBytes';
        ftBlob : strDT := 'Blob';
        ftMemo : strDT := 'Memo';
        ftGraphic : strDT := 'Graphic';
     end;
     Grid1.Cells[1, i] := strDT;

     if tblTemp.FieldDefs.Items[i-1].Size > 0 then
        Grid1.Cells[2, i] := IntToStr(tblTemp.FieldDefs.Items[i-1].Size)
     else
        Grid1.Cells[2, i] := ' ';

     if (i - 1) < iNumKeys then
        Grid1.Cells[3, i] := '*'
     else
        Grid1.Cells[3, i] := ' ';
   end;
end;
//   ClearGrid(Grid1,0,tblTemp.FieldDefs.Count+1);
procedure TMainForm.tsDataEnter(Sender: TObject);
begin
 If not tblTemp.Active then
 	tblTemp.Open;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
begin
	qrySql.close;
	qrySql.Sql.clear;
	qrySql.Sql:=memoSql.Lines;
	qrySql.open;
end;

procedure TMainForm.actVerifyTableExecute(Sender: TObject);
var sTemp:string;
begin
	ClearBars;
	TableVerify(TableLocEdit.Text,sTemp);
	MessageLB.Caption:=sTemp;
end;

function TMainForm.TableVerify(Table:string;var sResultString:string):integer;
var
  Msg: Integer;

begin
  Screen.Cursor := crHourGlass;
  try
    Check(TUExit(BDEUtil.vHtSes));
    Check(TUInit(BDEUtil.vHtSes));
    BDEUtil.RegisterCallBack;
    try
      if TUVerifyTable(BDEUtil.vHtSes, PChar(Table), szPARADOX, 'VERIFY.DB',
           nil, 0, Result) = DBIERR_NONE then begin
      case Msg of
        0: sResultString := 'Verification Successful. Table has no errors.';
        1: sResultString := 'Verification Successful. Verification completed.';
        2: sResultString := 'Verification Successful. Verification could not be completed.';
        3: sResultString := 'Verification Successful. Table must be rebuild manually.';
        4: sResultString := 'Verification Successful. Table cannot be rebuilt.';
      else
        sResultString := 'Verification unsuccessful.';
      end;
      end;
    finally
      BDEUtil.UnRegisterCallBack;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.actRebuildTableExecute(Sender: TObject);
var sTemp:string;
begin
  	qrySql.close;
   tblTemp.close;
   ClearBars;
   TableRebuild(TableLocEdit.Text,sTemp);
	MessageLB.Caption:=sTemp;
end;

function MainForm.TableRebuild(szTable:string;var sResultString:string):integer;
var
  iFld, iIdx, iSec, iVal, iRI, iOptP, iOptD: word;
  szTable: String;
  rslt: DBIResult;
  Msg: Integer;
  TblDesc: CRTBlDesc;
  Backup: String;
begin
  Screen.Cursor := crHourGlass;
  try
    Check(TUExit(BDEUtil.vHtSes));
    Check(TUInit(BDEUtil.vHtSes));
    BDEUtil.RegisterCallBack;
    try
      Check(TUVerifyTable(BDEUtil.vHtSes, PChar(szTable), szPARADOX, 'VERIFY.DB',
           nil, 0, Msg));
      rslt := TUGetCRTblDescCount(BDEUtil.vhTSes, PChar(szTable), iFld,
            iIdx, iSec, iVal, iRI, iOptP, iOptD);
      if rslt = DBIERR_NONE then begin
        FillChar(TblDesc, SizeOf(CRTBlDesc), 0);
        StrPCopy(TblDesc.szTblName, szTable);
        TblDesc.szTblType := szParadox;
        TblDesc.szErrTblName := 'Rebuild.DB';

        TblDesc.iFldCount := iFld;
        GetMem(TblDesc.pFldDesc, (iFld * SizeOf(FldDesc)));

        TblDesc.iIdxCount := iIdx;
        GetMem(TblDesc.pIdxDesc, (iIdx * SizeOf(IdxDesc)));

        TblDesc.iSecRecCount := iSec;
        GetMem(TblDesc.pSecDesc, (iSec * SizeOf(SecDesc)));

        TblDesc.iValChkCount := iVal;
        GetMem(TblDesc.pvchkDesc, (iVal * SizeOf(VCHKDesc)));

        TblDesc.iRintCount := iRI;
        GetMem(TblDesc.printDesc, (iRI * SizeOf(RINTDesc)));

        TblDesc.iOptParams := iOptP;
        GetMem(TblDesc.pfldOptParams, (iOptP * sizeOf(FLDDesc)));

        GetMem(TblDesc.pOptData, (iOptD * DBIMAXSCFLDLEN));
        try
           result := TUFillCRTblDesc(BDEUtil.vhTSes, @TblDesc, PChar(szTable), nil);
           if result = DBIERR_NONE then begin
             Backup := 'Backup.Db';
             if TURebuildTable(BDEUtil.vhTSes, PChar(szTable), szPARADOX,
                 PChar(Backup), 'KEYVIOL.DB', 'PROBLEM.DB', @TblDesc) = DBIERR_NONE
             then sResultString := 'Rebuild was successful.'
             else sResultString := 'Rebuild was not successful.';
           end
           else
           begin
           		sResultString  := 'Error Filling table structure';
           end
        finally
          FreeMem(TblDesc.pFldDesc, (iFld * SizeOf(FldDesc)));
          FreeMem(TblDesc.pIdxDesc, (iIdx * SizeOf(IdxDesc)));
          FreeMem(TblDesc.pSecDesc, (iSec * SizeOf(SecDesc)));
          FreeMem(TblDesc.pvchkDesc, (iVal * SizeOf(VCHKDesc)));
          FreeMem(TblDesc.printDesc, (iRI * SizeOf(RINTDesc)));
          FreeMem(TblDesc.pfldOptParams, (iOptP * sizeOf(FLDDesc)));
          FreeMem(TblDesc.pOptData, (iOptD * DBIMAXSCFLDLEN));
        end;
      end;
    finally
      BDEUtil.UnRegisterCallBack;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

end;

end.
