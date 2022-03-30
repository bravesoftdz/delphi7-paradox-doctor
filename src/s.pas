unit s;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, DB, BDE, TUtil32, DBTables, Menus, FileCtrl,
  Grids, DBCtrls, DBGrids, ActnList, Buttons, CheckLst,BatchMove,xautils,
  FieldUpdate,JclFileUtils, ValEdit, bdeutil, jpeg, Log4D, CommCtrl;

type

  ChangeRec = packed record
    szName: DBINAME;
    iType: Word;
    iSubType: Word;
    iLength: Word;
    iPrecision: Byte;
    end;

  TMainForm = class(TForm)
    OpenDialog1: TOpenDialog;
    doctorSession: TSession;
    dbHelixDoctor: TDatabase;
    menuMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    tblDiskDoctor: TTable;
    memuAliasses: TPopupMenu;
    Table1: TMenuItem;
    DataBase2: TMenuItem;
    Rebuild2: TMenuItem;
    pcTable: TPageControl;
    tsStatus: TTabSheet;
    GroupBox3: TGroupBox;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    PBIndexes: TProgressBar;
    PBData: TProgressBar;
    PBRebuild: TProgressBar;
    tsIndex: TTabSheet;
    tsFields: TTabSheet;
    tsData: TTabSheet;
    panelq: TPanel;
    grLeft: TGroupBox;
    Panel1: TPanel;
    tblTemp: TTable;
    ActionList1: TActionList;
    grdData: TDBGrid;
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
    tsLog: TTabSheet;
    DBGrid1: TDBGrid;
    tblLog: TTable;
    dsLog: TDataSource;
    lbTables: TCheckListBox;
    actVerifyChecked: TAction;
    actRebuildChecked: TAction;
    RebuildChecked1: TMenuItem;
    actRebuildLevel2: TAction;
    pbFiles: TProgressBar;
    Label2: TLabel;
    BatchMove1: TBatchMove;
    Table2: TTable;
    Panel4: TPanel;
    navTemp: TDBNavigator;
    Button2: TButton;
    actClearLog: TAction;
    actUpgrade: TAction;
    actCheckAll: TAction;
    actUnCheckAll: TAction;
    CheckAll1: TMenuItem;
    UnCheckAll1: TMenuItem;
    Panel5: TPanel;
    Label1: TLabel;
    AliasCombo: TComboBox;
    Splitter2: TSplitter;
    actVerifyRebuildDatabase: TAction;
    ActionGroup: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    edtTableName: TEdit;
    pbCancel: TButton;
    UpgradeButton: TButton;
    PBUpgrade: TProgressBar;
    Label11: TLabel;
    FromSrc: TDataSource;
    ToSrc: TDataSource;
    FromTbl: TTable;
    ToTbl: TTable;
    OpenDialog: TOpenDialog;
    N3: TMenuItem;
    UpgradeCheckedTables1: TMenuItem;       
    Upgrade2: TMenuItem;
    actUpgradeChecked: TAction;
    actUpgradeDatabase: TAction;
    actVerifyDatabase: TAction;
    actRebuildDatabase: TAction;
    actSynchDatabase: TAction;
    actClearMasterDb: TAction;
    infoPanel: TPanel;
    InfoGroup: TGroupBox;
    tableLocation: TEdit;
    TableInfo: TValueListEditor;
    UpgradeInfoGroup: TGroupBox;
    edtMaster: TEdit;
    UpgradeTAbleInfo: TValueListEditor;
    tsDataRecordCount: TEdit;
    tsPumper: TTabSheet;
    pumperPanel: TPanel;
    pumpDestinationGroup: TGroupBox;
    pumpSourceGroup: TGroupBox;
    pumpDiffGroup: TGroupBox;
    GroupBox1: TGroupBox;
    pbGetDiff: TBitBtn;
    pbRecover: TBitBtn;
    pumperTable: TEdit;
    pbCancelPumper: TButton;
    pbAppendDiff: TButton;
    diffTbl: TTable;
    dsDiff: TDataSource;
    sourceGrid: TDBGrid;
    diffgrid: TDBGrid;
    DBGrid4: TDBGrid;
    actPumperInit: TAction;
    Panel6: TPanel;
    UpgradeIndexGroup: TGroupBox;
    UpgradeIndexGrid: TStringGrid;
    IndexGroup: TGroupBox;
    IndexGrid: TStringGrid;
    Panel7: TPanel;
    UpgradefieldsGroup: TGroupBox;
    FieldsGroup: TGroupBox;
    FieldsGrid: TStringGrid;
    UpgradeFieldsGrid: TStringGrid;
    btnValidate: TBitBtn;
    actValidateTable: TAction;
    actValidateDatabase: TAction;
    actValidateChecked: TAction;
    actPumperGetDiff: TAction;
    About1: TMenuItem;
    actAbout: TAction;
    actClearLocks: TAction;
    UpgradeStatus: TLabel;
    Panel8: TPanel;
    Image1: TImage;
    btnClearLog: TBitBtn;
    Tools3: TMenuItem;
    ClearLogFile1: TMenuItem;
    CkearLocks1: TMenuItem;
    CopyNewTables1: TMenuItem;
    Button1: TButton;
    Button3: TButton;
    pbNewTables: TBitBtn;
    Image3: TImage;
    PBHeader: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure AliasComboChange(Sender: TObject);
    procedure ByDirectBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure btnFromFileClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure tsDataEnter(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure actVerifyTableExecute(Sender: TObject);
    procedure actRebuildTableExecute(Sender: TObject);
    procedure tblLogNewRecord(DataSet: TDataSet);
    procedure lbTablesClick(Sender: TObject);
    procedure actVerifyCheckedExecute(Sender: TObject);
    procedure Batch1Click(Sender: TObject);
    procedure pbCancelClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RebuildChecked1Click(Sender: TObject);
    procedure actRebuildCheckedExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure actUpgradeExecute(Sender: TObject);
    procedure actCheckAllExecute(Sender: TObject);
    procedure actUnCheckAllExecute(Sender: TObject);
    procedure Splitter2CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure actVerifyRebuildDatabaseExecute(Sender: TObject);
    procedure actVerifyDatabaseExecute(Sender: TObject);
    procedure actUpgradeCheckedExecute(Sender: TObject);
    procedure actUpgradeDatabaseExecute(Sender: TObject);
    procedure actRebuildDatabaseExecute(Sender: TObject);
    procedure actClearMasterDbExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure infoPanelResize(Sender: TObject);
    procedure pcTableChange(Sender: TObject);
    procedure dsTempDataChange(Sender: TObject; Field: TField);
    procedure pumperPanelResize(Sender: TObject);
    procedure actPumperInitExecute(Sender: TObject);
    procedure Panel6Resize(Sender: TObject);
    procedure ToSrcDataChange(Sender: TObject; Field: TField);
    procedure FromSrcDataChange(Sender: TObject; Field: TField);
    procedure Panel7Resize(Sender: TObject);
    procedure actValidateTableExecute(Sender: TObject);
    procedure actValidateCheckedExecute(Sender: TObject);
    procedure Validate1Click(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actClearLocksExecute(Sender: TObject);
    procedure actNewTables(Sender: TObject);
  private
    sDoctorLog: String ;
    sVerifyTbl: String ;
    sRebuildTbl: String ;
    sProblemTbl: String ;
    sKeyViolationTbl: String ;

    { Private declarations }
    FieldUpdate: TFieldUpdate;

    procedure OpenDatabaseList;
    procedure SetTableAndDir(ByDirectory: Boolean);
    procedure ClearBars;
    procedure CompleteBars;
    procedure ClearLabels;
    procedure SetTableInfo; Overload;
    procedure SetTableInfo( TableInfo: TValueListEditor;  tableName: string); Overload;
    procedure ClearTable;
    procedure SetTable(TableName: String);
    procedure FillGrids( strFile : String ; indexGrid : TStringGrid; fieldGrid : TStringGrid);
    function TableVerify(szTable:string;var sResultString:string):integer;
    function TableValidate(szTable:string;var sResultString:string):integer;
    function TableRebuild(szTable:string;var sResultString:string):integer;
    function TableUpgrade(szTable:string; szMaster:string ; var sResultString:string):integer;
	  procedure Log(sTable,sAction,sResult:string);
	  function CopyTable(sFromTable:string;sToTable:string;iMode:TBatchMode):integer;
   // procedure ChangeField(Table: TTable; Field: TField; Rec: ChangeRec);
	  function TableRebuildDuplicate(szTableMaster,szTable:string;var sResultString:string):integer;
 		procedure FieldUpdateProgress(sender: TComponent;Percent: Integer; FieldName: String);
    procedure FieldUpdateError(sender: TComponent;Error: TFieldUpdateError);
    procedure SetToPerformAction;
    procedure CopyNewTables(SrcDir, DstDir: String);
    function CopyDbTable(DB:TDatabase; SrcTbl, DstTbl: String; Overwrite: Boolean):integer;
  	function TableRebuildIndexes(szTable:string):integer;
    function AliasLocation(const Alias: string): string;

  public
    { Public declarations }
    gCountPre : String;
    gCountPost : String;
  end;

 
var
  MainForm: TMainForm;
  Logger: TLogLogger;

implementation

uses globals, about;

{$R *.DFM}
  const
    sBadData: String = '?';

{
"Insufficient memory for this operation" ($2501)
Problem: Your application (or another BDE application) has exhausted the memory available to the BDE.
Solution:
1) Close all BDE applications.
2) Find the program BDEADMIN.EXE. This is usually in a directory somewhere under "\Program Files\Borland...".
3) Run BDEADMIN.EXE and click on the Configuration tab.
4) There should be an item in the treeview on the left side called "Configuration". If it's not expanded, expand it.
5) Next, expand the System entry below it. Under System, select INIT.
6) In the right-side window, find the entry called "SHAREDMEMSIZE". Change this value to 4096.
7) Next, click on the word "Object" in the main window's menu bar, and select Apply.
8) Answer "OK" to the confirmation to "Save all edits...".

You can now try to start your application again. If you still have trouble running the application and you are running Windows NT or Windows 2000, follow the same instructions above, but this time leave the SHAREDMEMSIZE property at 4096, and change the SHAREDMEMLOCATION property to "0x5BDE". Then apply the changes as before, and retry your application. If you still receive the same error, try changing SHAREDMEMSIZE to 8192. If the error continues to persist, you can also try "0x6BDE" for SHAREDMEMLOCATION. If the error still continues to persist, you can also try other values for SHAREDMEMLOCATION. (See solution for error $210D below.)
}

procedure TMainForm.FieldUpdateProgress(sender: TComponent;Percent: Integer; FieldName: String);
begin
  PBUpgrade.Position := Percent;
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

procedure TMainForm.CompleteBars;
begin
  pbFiles.Position := 100;
  PBHeader.Position := 100;
  PBIndexes.Position := 100;
  PBData.Position := 100;
  PBRebuild.Position := 100;
  PBUpgrade.Position := 1000;
  SendMessage (pbFiles.Handle, PBM_SETBARCOLOR, 0, clGreen);
  SendMessage (PBHeader.Handle, PBM_SETBARCOLOR, 0, clGreen);
  SendMessage (PBIndexes.Handle, PBM_SETBARCOLOR, 0, clGreen);
  SendMessage (PBData.Handle, PBM_SETBARCOLOR, 0, clGreen);
  SendMessage (PBRebuild.Handle, PBM_SETBARCOLOR, 0, clGreen);
  SendMessage (PBUpgrade.Handle, PBM_SETBARCOLOR, 0, clGreen);
end;

procedure TMainForm.ClearBars;
begin
	PBFiles.Position :=0;
  PBHeader.Position := 0;
  PBIndexes.Position := 0;
  PBData.Position := 0;
  PBRebuild.Position := 0;
  PBUpgrade.Position := 0;
  SendMessage (pbFiles.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
  SendMessage (PBHeader.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
  SendMessage (PBIndexes.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
  SendMessage (PBData.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
  SendMessage (PBRebuild.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
  SendMessage (PBUpgrade.Handle, PBM_SETBARCOLOR, 0, CLR_DEFAULT);
end;

procedure TMainForm.ClearLabels;
begin
tableinfo.Strings.Clear;
UpgradeTableInfo.Strings.Clear;
tablelocation.Text := '';
pumperTable.Text:= '';
edtmaster.Text:= '';
end;

procedure TMainForm.ClearTable;
begin
  tablelocation.Text := '';
  pumperTable.Text:= '';

  actVerifyTable.Enabled := False;
  actRebuildTable.Enabled := False;
  actUpgrade.Enabled := False;
  actValidateTable.Enabled := False;

  pbGetDiff.Enabled := False;
  pbAppendDiff.Enabled := False;
  pbRecover.Enabled := False;
  pbCancel.Enabled := False;
  pbCancelPumper.Enabled := False;
  pbNewTables.Enabled := False;
end;

procedure TMainForm.SetTable(TableName: String);
begin
  globals.sActiveDbName:=TableName;
  pumperTable.Text:= lbTables.Items[lbTables.ItemIndex];
  tablelocation.Text := TableName;

  actVerifyTable.Enabled := True;
  actRebuildTable.Enabled := True;
  actUpgrade.Enabled := True;
  actValidateTable.Enabled := True;

  pbGetDiff.Enabled := True;
  pbAppendDiff.Enabled := True;
  pbRecover.Enabled := True;
  pbCancel.Enabled := True;
  pbCancelPumper.Enabled := True;
  pbNewTables.Enabled := True;
end;

procedure TMainForm.SetToPerformAction;
begin
	if tblTemp.Active then
  	tblTemp.Close;
  pcTable.ActivePage := tsStatus ;
  ClearBars;
end;


procedure TMainForm.SetTableAndDir;
var
  vDBDesc: DBDesc;
  Alias: String;

begin
	tblTemp.Close;
  Alias := AliasCombo.Items[AliasCombo.ItemIndex];
  sActiveTableName := lbTables.Items[lbTables.ItemIndex];
  edtTableName.Text:= sActiveTableName;
  Check(DbiGetDatabaseDesc(PChar(Alias), @vDBDesc));
  SetTable(Format('%s\%s', [vDBDesc.szPhyName, sActiveTableName]));
  ClearBars;

  if tsData.visible then
  begin
    if  sActiveTableName <> ''  then
    begin
      tblTemp.TableName :=  sActiveTableName;
      tblTemp.open;
    end;
  end;

  SetTableInfo();

end;

procedure TMainForm.SetTableInfo;
  begin
    SetTableInfo(tableinfo,sActiveDbName);
    sMasterDbName := 	sMasterPath + sActiveTableName ;

    if (FileExists(sMasterDbName)) then
    begin
      edtMaster.Text := sMasterDbName;
      actUpgrade.Enabled := True;
      pbCancel.Enabled := True;
      SetTableInfo(upgradetableinfo,sMasterDbName);
      FillGrids( sMasterDbName, upgradeindexgrid, UpgradeFieldsGrid);
      upgradeindexGroup.Caption:='MasterDB Table Index Count: '+ inttostr(upgradeindexgrid.RowCount-1);
      UpgradeFieldsGroup.Caption:='MasterDB Table Field Count: '+inttostr(UpgradeFieldsGrid.RowCount-1);

      upgradeindexgroup.Visible :=true;
      UpgradeFieldsGroup.Visible :=true;
      UpgradeInfoGroup.Visible :=true;
    end
    else
    begin
      sMasterDbName := '';
      edtMaster.Text := '';
	    actUpgrade.Enabled := False;
      upgradeindexgroup.Visible :=false;
      UpgradeFieldsGroup.Visible :=false;
      UpgradeInfoGroup.Visible :=false;
    end;
      FillGrids( sActiveDbName, indexgrid, fieldsGrid);
      indexGroup.Caption:='Table Index Count: '+inttostr(indexgrid.RowCount-1);
      FieldsGroup.Caption:='Table Field Count: '+inttostr(FieldsGrid.RowCount-1);
 end;


procedure TMainForm.SetTableInfo( TableInfo: TValueListEditor;  tableName: string);
var
   CursorProp: CURProps;
   	tblTemp:TTable;
begin
  if  tableName <> '' then
  begin
  try

      tblTemp:=TTable.create(self);;
      tblTemp.TableName := tableName;
      tblTemp.open;
      Check(DbiGetCursorProps(tblTemp.Handle, CursorProp));
      with CursorProp do begin
        TableInfo.Strings.Clear;
        TableInfo.InsertRow('Record Count:', IntToStr(tblTemp.recordcount),true);
        TableInfo.InsertRow(' ',' ',true);
        TableInfo.InsertRow('Fields',IntToStr(iFields),true);
        TableInfo.InsertRow('Indexes:', IntToStr(iIndexes),true);
        TableInfo.InsertRow('Table Level:', IntToStr(iTblLevel),true);
        TableInfo.InsertRow(' ',' ',true);
        TableInfo.InsertRow('References:', IntToStr(iRefIntChecks),true);
        TableInfo.InsertRow('Validations:', InttoStr(iValChecks),true);
        TableInfo.InsertRow('Aux Password:', IntToStr(iPasswords),true);
        TableInfo.InsertRow('Block Size:', IntToStr(iBlockSize),true);
        TableInfo.InsertRow('Table Size:',IntToStr(iRecBufSize),true);
        TableInfo.InsertRow('Code Page:', IntToStr(iCodePage),true);
        TableInfo.InsertRow('Restructured Versions:',IntToStr(iRestrVersion),true);
      end;
    except
      on EDBEngineError do
        begin
            TableInfo.Strings.Clear;
            TableInfo.InsertRow(' ',' ',true);
            TableInfo.InsertRow('Fields',sBadData,true);
        raise;
    end;
  end;
  tblTemp.Close;
  tblTemp.Free;
  end;

end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  sMasterPath :=  ExtractFilePath(ParamStr(0)) + 'MasterDb\' ;
  sPumperPath := ExtractFilePath(ParamStr(0)) + 'PumpDB\' ;
  sDoctorDb:= ExtractFilePath(Application.EXEName) +'DoctorDB\' ;

  sMasterDbName:='';
  sActiveDbName:='';

  if not DirectoryExists(sDoctorDb) then
  	ForceDirectories(sDoctorDb) ;

  if not DirectoryExists(sMasterPath) then
  	ForceDirectories(sMasterPath) ;

  if not DirectoryExists(sPumperPath) then
  	ForceDirectories(sPumperPath) ;

  TLogBasicConfigurator.Configure;
  TLogLogger.GetRootLogger.Level := All;
  Logger := TLogLogger.GetLogger('myLogger');
  Logger.addAppender(TLogFileAppender.Create('filelogger','DoctorDB/DoctorLog.log'));

  Logger.Info('Cervelle Software - Database Doctor');
  Logger.Info('-----------------------------------');
  Logger.Info('------ BEGINNING LOG SESSION ------');
  Logger.Info('-----------------------------------');

  sDoctorLog:= sDoctorDb + 'DoctorLog.Db';
  doctorsession.Active := True;

  OpenDatabaseList;
  globals.BDEUtil := TBDEUtil.Create;
  globals.BDEUtil.PBHeader := PBHeader;
  globals.BDEUtil.PBIndexes:= PBIndexes;
  globals.BDEUtil.PBData:= PBData;
  globals.BDEUtil.PBRebuild:= PBRebuild;

  FieldUpdate:= TFieldUpdate.Create(self);
  pcTable.ActivePage:=tsStatus;
end;

procedure TMainForm.AliasComboChange(Sender: TObject);
begin
  doctorsession.GetTableNames(AliasCombo.Items[AliasCombo.ItemIndex], '*.*',True, False, lbTables.Items);

  ClearBars;
  ClearLabels;
  ClearTable;

  dbHelixDoctor.Connected := False;
  dbHelixDoctor.AliasName := AliasCombo.Items[AliasCombo.ItemIndex];
  dbHelixDoctor.Connected := True;

  tblLog.close;
  tblLog.TableName:=sDoctorLog;
  tblLog.TableType:=ttParadox;

  if not FileExists(sDoctorLog) then
  begin
   with tblLog.FieldDefs do
   begin
   	Clear;
    	Add('Date',ftDateTime, 0, False);
      Add('Action',ftString,20, FALSE);
    	Add('Result',ftString,100, FALSE);
      Add('Table',ftString, 255 ,FALSE);
      Add('Duration',ftString, 10, False);
   end;
   tblLog.CreateTable;
  end;
  tblLog.open;
end;

procedure TMainForm.ByDirectBtnClick(Sender: TObject);
begin
 if OpenDialog1.Execute then begin
   SetTable(OpenDialog1.FileName);
   AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo(tableinfo,OpenDialog1.FileName);
 end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  globals.BDEUtil.Free;
end;

procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AboutBtnClick(Sender: TObject);
begin
  //AboutForm.ShowModal;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
   OpenDialog1.InitialDir:= globals.sMasterPath;
   //OpenDialog1.Options := [fdoPickFolders];
 if OpenDialog1.Execute then
 begin
  globals.sMasterPath := ExtractFileDir(OpenDialog1.FileName) ;

   //SetTable(OpenDialog1.FileName);
   //AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo;

 end;

end;

procedure TMainForm.btnFromFileClick(Sender: TObject);
begin
  if DirectoryExists(ExtractFilePath(edtMaster.Text)) then
    OpenDialog.InitialDir := ExtractFilePath(edtMaster.Text);
  if OpenDialog.Execute then
    edtMaster.Text := OpenDialog.FileName;

(*

if OpenDialog1.Execute then
 begin
   SetTable(OpenDialog1.FileName);
   AliasCombo.ItemIndex := -1;
   lbTables.Items.Clear;
   ClearBars;
   SetTableInfo;
 end;
*)
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
	close;
end;

procedure TMainForm.FillGrids( strFile : String ; indexGrid : TStringGrid; fieldGrid : TStringGrid);

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
    if strFile = '' then
      exit;
    
   tblTemp.close;
   tblTemp.TableName := strFile;
   //tblTemp.open;

   try
      tblTemp.IndexDefs.Update;  {Make the index values available}
     if tblTemp.IndexDefs.Count > 0 then
        IndexGrid.RowCount := tblTemp.IndexDefs.Count + 1
     else
        IndexGrid.RowCount := 1;
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

   except on E: EDBEngineError do
      begin
        IndexGrid.RowCount := 2;
        iNumKeys := 0;
        IndexGrid.Cells[0, 1]:= 'Error'; {By Default}
        IndexGrid.Cells[1, 1]:= E.Message+ ' : ' + inttostr(E.HelpContext);

        TableInfo.Values['Indexes:']:=sBadData;

        fieldGrid.RowCount := 2;
        fieldGrid.Cells[0, 1]:= 'Error'; {By Default}
        fieldGrid.Cells[1, 1]:= E.Message+ ' : ' + inttostr(E.HelpContext);
        TableInfo.Values['Fields:']:=sBadData;

        Log(sActiveDbName,'Verify',E.Message);

        raise;
      end;
   end;

   try
      tblTemp.FieldDefs.Update;
      fieldGrid.ColCount := 4;
      fieldGrid.RowCount := tblTemp.FieldDefs.Count + 1;
     for i:= 1 to tblTemp.FieldDefs.Count do
     begin
      fieldGrid.Cells[0, i] := tblTemp.FieldDefs.Items[i-1].Name;
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
          ftAutoInc : strDT := 'Auto+';
       end;
       fieldGrid.Cells[1, i] := strDT;

       if tblTemp.FieldDefs.Items[i-1].Size > 0 then
          fieldGrid.Cells[2, i] := IntToStr(tblTemp.FieldDefs.Items[i-1].Size)
       else
          fieldGrid.Cells[2, i] := ' ';

       if (i - 1) < iNumKeys then
          fieldGrid.Cells[3, i] := '*'
       else
          fieldGrid.Cells[3, i] := ' ' ;

  // if tblTemp.FieldCount > i then
  //     fieldGrid.Cells[4, i] := tblTemp.Fields[i].ImportedConstraint;
  
    end;
   except on E: EDBEngineError do
    begin
        fieldGrid.RowCount := 2;
        fieldGrid.Cells[0, 1]:= 'Error'; {By Default}
        fieldGrid.Cells[1, 1]:= E.Message+ ' : ' + inttostr(E.HelpContext);
        TableInfo.Values['Fields:']:=sBadData;
        Log(sActiveDbName,'Verify',E.Message);
        raise;
    end;
   end;
   tblTemp.close;
end;
//   ClearGrid(Grid1,0,tblTemp.FieldDefs.Count+1);

procedure TMainForm.tsDataEnter(Sender: TObject);
begin
  try
 		If not tblTemp.Active then
      tblTemp.Open;
  except
    on EDatabaseError do
    begin
    end;
  end;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
begin
	qrySql.close;
	qrySql.Sql.clear;
	qrySql.Sql:=memoSql.Lines;
	qrySql.open;
  ShowMessage('SQL Query posted!');
end;

procedure TMainForm.actVerifyTableExecute(Sender: TObject);
var sTemp:string;
begin
	ClearBars;
  timerStart();
	TableVerify(sActiveDbName,sTemp);
	//sbInfo.SimpleText:=sTemp;
   Log(sActiveDbName,'Verify',sTemp);
end;



function TMainForm.TableValidate(szTable:string;var sResultString:string):integer;
begin
  FieldUpdate.ValidateFields(szTable);
  result := 1;
  sResultString := 'Validation Completed.' ;
end;


function TMainForm.TableVerify(szTable:string;var sResultString:string):integer;

begin
  Screen.Cursor := crHourGlass;
  try
    Check(TUExit(globals.BDEUtil.vHtSes));
    Check(TUInit(globals.BDEUtil.vHtSes));
    globals.BDEUtil.RegisterCallBack;
    sResultString := 'Verification unsuccessful.';
      if TUVerifyTable(globals.BDEUtil.vHtSes, PChar(szTable), szPARADOX, PChar(sVerifyTbl), nil, 0, Result) = DBIERR_NONE then
      begin
      case Result of
        0: sResultString := 'Verification Successful. Table has no errors.';
        1: sResultString := 'Verification Successful. Verification completed.';
        2: sResultString := 'Verification Successful. Verification could not be completed.';
        3: sResultString := 'Verification Successful. Table must be rebuild manually.';
        4: sResultString := 'Verification Successful. Table cannot be rebuilt.';
      end;
      end;
  except
    on E : Exception do
    sResultString := 'Verification unsuccessful.' + E.ClassName +' error raised: '+E.Message;
    end;
    
    globals.BDEUtil.UnRegisterCallBack;
    Screen.Cursor := crDefault;
end;

procedure TMainForm.actRebuildTableExecute(Sender: TObject);
var sTemp:string;
begin
    qrySql.close;
    tblTemp.close;
    fromtbl.Close;

    ToTbl.Close;
    ClearBars;
    FieldUpdate.RestructureTable(sActiveDbName, 'LEVEL', '7');
    TableRebuildIndexes( sActiveDbName);
    TableRebuild(sActiveDbName,sTemp);
    ToTbl.Close;

    CompleteBars;
    Showmessage('Rebuild Complete!');
    ClearBars;
end;

function TMainForm.TableUpgrade(szTable:string;szMaster: String;var sResultString:string):integer;
begin
  Screen.Cursor := crHourGlass;
  sResultString := 'Update was not successful.';
  TableUpgrade:=0;
  PBUpgrade.Max := 100;
  try
  	begin
      FromTbl.Active := False;
      ToTbl.TableName := szTable;
      FromTbl.TableName := szMaster;
      try
        FieldUpdate.QuickProgress := PBUpgrade;
        FieldUpdate.QuickLabel := UpgradeStatus;
        FieldUpdate.QuickStatus := true;
        FieldUpdate.ReadFromFile(szMaster);
        FieldUpdate.ApplyToFile(szTable);
        PBUpgrade.Position := PBUpgrade.Max;
        TableUpgrade:=1;
        sResultString := 'Upgrade was successful.' ;
      except
        sResultString := 'Upgrade was NOT successful.' ;
      end;
      end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TMainForm.TableRebuildIndexes(szTable:string):integer;
  var
    aExclusive, aActive: Boolean;
  begin
    with tblTemp Do
    Begin
      aActive := Active;
      Close;
      aExclusive := Exclusive;
      Exclusive := True;
      Open;
      DbiRegenIndexes(tblTemp.Handle);
      Close;
      Exclusive := aExclusive;
      Active := aActive;
      DbiSaveChanges(tblTemp.Handle);
    end;
  end;



function TMainForm.TableRebuild(szTable:string;var sResultString:string):integer;
var
  iFld, iIdx, iSec, iVal, iRI, iOptP, iOptD: word;
  rslt: DBIResult;
  Msg: Integer;
  TblDesc: CRTBlDesc;
  Backup: String;
begin
  Screen.Cursor := crHourGlass;
  result:=0;
  try
    Check(TUExit(globals.BDEUtil.vHtSes));
    Check(TUInit(globals.BDEUtil.vHtSes));
    globals.BDEUtil.RegisterCallBack;
    try
      Check(TUVerifyTable(globals.BDEUtil.vHtSes, PChar(szTable), szPARADOX,PChar(sVerifyTbl),nil, 0, Msg));
      rslt := TUGetCRTblDescCount(globals.BDEUtil.vhTSes, PChar(szTable), iFld,
            iIdx, iSec, iVal, iRI, iOptP, iOptD);
      if rslt = DBIERR_NONE then begin
        FillChar(TblDesc, SizeOf(CRTBlDesc), 0);
        StrPCopy(TblDesc.szTblName, szTable);
        TblDesc.szTblType := szParadox;
        StrPCopy(TblDesc.szErrTblName,sVerifyTbl);

//        TblDesc.bPack := True;    pack tables

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
           result := TUFillCRTblDesc(globals.BDEUtil.vhTSes, @TblDesc, PChar(szTable), nil);
           if result = DBIERR_NONE then begin
             Backup := sDoctorDb +'Backup.Db';
             if TURebuildTable(globals.BDEUtil.vhTSes, PChar(szTable), szPARADOX,
                 PChar(Backup), PChar(sKeyViolationTbl), PChar(sProblemTbl), @TblDesc) = DBIERR_NONE
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
      globals.BDEUtil.UnRegisterCallBack;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TMainForm.TableRebuildDuplicate(szTableMaster,szTable:string;var sResultString:string):integer;
var
  iFld, iIdx, iSec, iVal, iRI, iOptP, iOptD: word;
  rslt: DBIResult;
  Msg: Integer;
  TblDesc: CRTBlDesc;
  pFields: pFLDDesc;
  pOp: pCROpType;
  Backup: String;
begin
  Screen.Cursor := crHourGlass;
  result:=0;
  try
    Check(TUExit(globals.BDEUtil.vHtSes));
    Check(TUInit(globals.BDEUtil.vHtSes));
    globals.BDEUtil.RegisterCallBack;
    try
      Check(TUVerifyTable(globals.BDEUtil.vHtSes, PChar(szTable), szPARADOX, PChar(sVerifyTbl),
           nil, 0, Msg));
     rslt := TUGetCRTblDescCount(globals.BDEUtil.vhTSes, PChar(szTable), iFld,
            iIdx, iSec, iVal, iRI, iOptP, iOptD);
      if rslt = DBIERR_NONE then begin
        FillChar(TblDesc, SizeOf(CRTBlDesc), 0);
        StrPCopy(TblDesc.szTblName, szTableMaster);
        TblDesc.szTblType := szParadox;
        StrPCopy(TblDesc.szErrTblName,sRebuildTbl);
        TblDesc.bPack := True;    //pack tables

        TblDesc.iFldCount := iFld;
        GetMem(TblDesc.pFldDesc, (iFld * SizeOf(FldDesc)));
        pFields:=TblDesc.pFldDesc;

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
        pOp:=TblDesc.pOptData;
        try
           result := TUFillCRTblDesc(globals.BDEUtil.vhTSes, @TblDesc, PChar(szTable), nil);
           if result = DBIERR_NONE then
           begin
             Backup := sDoctorDb +'Backup.Db';
             inc(pFields,0);
             //pFields^.iFldType:=fldINT32;
             //pFields^.iSubType := fldstAUTOINC;
             pFields^.iFldType := fldPDXAUTOINC;
             inc(pOP,0);
             pOp^ := crMODIFY;
             rslt:=TURebuildTable(globals.BDEUtil.vhTSes, PChar(szTable), szPARADOX,PChar(Backup), PChar(sKeyViolationTbl), PChar(sProblemTbl), @TblDesc);
             if  rslt = DBIERR_NONE then
             	sResultString := 'Rebuild was successful.'
             else
//             	sResultString := 'Rebuild was not successful.';
						sResultString :=xaGetDdbError(rslt);

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
      globals.BDEUtil.UnRegisterCallBack;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.Log(sTable,sAction,sResult:string);
begin

	with tblLog do
   begin
    if not active then
    active:=true;
   	append;
    Fieldbyname('Duration').asString:=TimerStop();;
    Fieldbyname('Table').asString:=sTable;
    Fieldbyname('Action').asString:=sAction;
    Fieldbyname('Result').asString:=sResult;
    post;
  end ;
end;

procedure TMainForm.tblLogNewRecord(DataSet: TDataSet);
begin
	with tblLog do
   begin
		FieldByName('Date').asDateTime:=NOW();
   end
end;

procedure TMainForm.lbTablesClick(Sender: TObject);
begin
	SetTableAndDir(FALSE);
  actPumperInit.Execute;
end;

procedure TMainForm.actVerifyCheckedExecute(Sender: TObject);
var
	iI:Integer;
   sTemp:string;
begin
	for iI:=0 to lbTables.Items.count-1 do
   if lbTables.Checked[iI] then
		pbFiles.max:=pbFiles.max+1;
		pbFiles.position:=0;

   pbCancel.tag:=0;
	for iI:=0 to lbTables.Items.count-1 do
   begin
   try
   	if lbTables.Checked[iI] then
      begin
      	lbTables.ItemIndex:=iI;
        ClearBars;
        SetTableAndDir(FALSE);
      	if TableVerify(sActiveDbName,sTemp)= 0 then
        	lbTables.Checked[iI]:= False;
				//sbInfo.SimpleText:=sTemp;
   			Log(sActiveDbName,'Verify Checked',sTemp);
      	pbFiles.Position:=pbFiles.Position+1;
	      application.processmessages;
      	if pbCancel.tag=1 then
      		break;
      end;
   except
      on EDBEngineError do continue;
   end;
   end;
   pbFiles.Position:=pbFiles.Max;

end;

{    Copy Table: will copy a table if exist.
      	0: Mode := batAppend;
      	1: Mode := batUpdate;
      	2: Mode := batAppendUpdate;
      	3: Mode := batCopy;
      	4: Mode := batDelete;
   }

procedure TMainForm.CopyNewTables(SrcDir, DstDir: String);
var
	DB : TDatabase;

  dstFile: string;
	tableList:Tstrings;
  paramsx:Tstrings;
  i:integer;
begin
	try
    if DirectoryExists(SrcDir) then
    begin
      tableList:= TstringList.Create;
     paramsx:= TstringList.Create;
      DB := TDatabase.Create(nil);

      paramsx.add('PATH='+ SrcDir);
			paramsx.add('DEFAULT DRIVER=PARADOX');
			paramsx.add('ENABLE BCD=FALSE');


      with DB do begin
        Connected := False;
        DatabaseName := 'MMUG' ;
        Directory := SrcDir ;
        params:=paramsx;
        DriverName := 'STANDARD';

        Connected := True;
      end;

      DB.GetTableNames(tableList, False);

      pbUpgrade.max:=tableList.count;
      pbUpgrade.position:=0;
      

      for i:=0 to tableList.count-1 do
   		begin
      	dstFile := DstDir+tableList[i]+'.db' ;
        if (not FileExists(dstFile)) then
        TimerStart;
        begin
 					if CopyDbTable(DB, SrcDir+tableList[i]+'.db', dstFile, FALSE) = 0 then
					begin
        		//sbInfo.SimpleText:=tableList[i];
   					Log(dstFile,'Table Creation','Table Added');
					end
          else
          begin
            //sbInfo.SimpleText:=tableList[i];
   					Log(dstFile,'Table Creation','Table Not Added');
          end;

        end;
      	pbUpgrade.Position:=pbUpgrade.Position+1;

      end ;
    end;
    finally
    	DB.Free;
      tableList.Free;
      paramsx.Free;

    end;
end;

function TMainForm.CopyDbTable(DB:TDatabase; SrcTbl, DstTbl: String; Overwrite: Boolean):integer;
begin
     result := DBICopyTable(DB.Handle, Overwrite, PChar(SrcTbl), nil, PChar(DstTbl));
end;

function TMainForm.CopyTable(sFromTable:string;sToTable:string;iMode:TBatchMode):integer;
var
	sTemp:string;
   iIndexToModify:integer;
   psFromTable:DBITBLNAME;
   psToTable:DBITBLNAME;
   sDataBaseDir:String;
   dbDataBase:TDatabase;
    stChangeRec:ChangeRec;
	tblFrom:TTable;
	tblTo:TTable;
   bmFix:TBatchMove;
   bTableWasOpen:boolean;
	i:integer;
const
	bOverwrite = True;
begin
try
  Screen.Cursor := crHourGlass;
  zeroMemory(@stChangeRec,sizeof(stChangeRec));
	dbDatabase:=TDatabase.create(self);
   tblFrom:=TTable.create(self);
   tblTo:=TTable.create(self);
   bmFix:=TBatchMove.Create(self);
   //check if file exist. somewhere

   with dbDatabase do
   begin
   	DriverName:='STANDARD';
   	Databasename:='LukasNikoloff';
   	//get the directory
      sDataBaseDir:=ExtractFileDir(sFromTable);
      if sDataBaseDir = '' then
	   	sDataBaseDir:=ExtractFileDir(expandFilename(sFromTable));
      params.Add('PATH='+sDataBaseDir);
      open;
   end;
   tblTo.DatabaseName:=dbDatabase.name;
   tblFrom.DatabaseName:=dbDatabase.name;

   AnsiToNative(dbDatabase.Locale,sFromTable,psFromTable,DBIMAXPATHLEN);
   AnsiToNative(dbDatabase.Locale,sToTable+'A',psToTable,DBIMAXPATHLEN);

	Check(DbiCopyTable(dbDatabase.handle,bOverwrite,psFromTable,nil,psToTable));


	with tblFrom do
   begin
   	bTableWasOpen:=active;
   	close;
   	TableName := sFromTable;
   	FieldDefs.Update;
   	IndexDefs.Update;
    tblTo.close;
    tblTo.TableName := sToTable;
		tblTo.TableType:=TableType;
  	//make sure that the auto increment is off
		//find the auto + fields
    tblTo.FieldDefs.clear;
    iIndexToModify:=-1;
   	for i:= 0 to FieldDefs.Count-1 do
      begin
         tblTo.FieldDefs.AddFieldDef;
         tblTo.FieldDefs.items[i]:=FieldDefs.items[i];
      	//if FieldDefs.Items[i].DataType = ftAutoInc then //	Auto-incrementing 32-bit integer counter field
      	//begin
          // HERE
         	//tblTo.FieldDefs.Items[i].DataType :=ftInteger;   //change it to and integer
          //iIndexToModify:=i;
         //end;
      end;
//	with tblFrom do
   begin
   	IndexDefs.Update;
      tblTo.IndexDefs.BeginUpdate;
   	for i:= 0 to IndexDefs.Count-1 do
      begin
      	tblTo.IndexDefs.AddIndexDef;
         tblTo.IndexDefs.items[i]:=IndexDefs.items[i];
      	if i = iIndexToModify then
         begin
            tblTo.IndexDefs.items[i].options:= [ixPrimary, ixUnique];
         end
      end;
      tblTo.IndexDefs.EndUpdate;
      tblTo.StoreDefs:=True;
   end;

   	tblTo.CreateTable;
      tblTo.Close;
  	end;

	with bmFix do
  	begin
   	Destination :=tblTo;
    Source:= tblFrom;
    ChangedTableName := '';			// ChangedTableName
    KeyViolTableName := '';
    ProblemTableName := '';
   	ChangedTableName := '';		// ChangedTableName
   	mode:=iMode;
    AbortOnKeyViol := False;		// AbortOnKeyViol
   	AbortOnProblem := True;	 		// AbortOnProblem
   	Transliterate := False;			// Transliterate
   	RecordCount := 0; 				// RecordCount
   	CommitCount := 0;					// CommitCount
	end;

   try
     bmFix.Execute;										// Perform BatchMove
     result:=1;
     TableRebuildDuplicate(sFromTable,sToTable,sTemp);
     //sbInfo.SimpleText:=sTemp;
//		tblTo.close;
//   	tblFrom.close;
//	PutBack the autoincrement
//      tblFrom.FieldDefs.updated:=FALSE;
//      tblFrom.FieldDefs.update;
//      tblTo.FieldDefs.updated:=FALSE;
//      tblTo.FieldDefs.update;
//      tblTo.LockTable(ltWriteLock);
//      tblTo.open;
//      tblTo.FieldDefs.BeginUpdate;
//   	for i:= 0 to tblFrom.FieldDefs.Count-1 do
//   	begin
//      	if tblFrom.FieldDefs.Items[i].DataType = ftAutoInc then //	Auto-incrementing 32-bit integer counter field
//         begin
//				stChangeRec.iType:=word(ftAutoInc);
//      		tblTo.FieldDefs.Items[i].DataType :=ftAutoInc;   //change it to and integer
//            iIndexToModify:=i;
//         	break;
//         end;
//    	end;
//      tblTo.FieldDefs.EndUpdate;
//      tblTo.StoreDefs:=True;
      if iIndexToModify>-1 then
		Begin
      	tblTo.exclusive:=True;
      	tblTo.open;
//         stChangeRec.iType:=word(ftAutoInc);
//	      ChangeField(tblTo, tblTo.fields[iIndexToModify], stChangeRec);
      	tblTo.close;
      end;


 	except
  	on EDatabaseError do
     begin
     	result:=0;
     end;
  	end;

   if bTableWasOpen then
   	tblFrom.open;

finally
  Screen.Cursor := crDefault;
  tblFrom.Destroy;
  tblTo.Destroy;
  bmFix.Destroy;
  dbDatabase.Destroy;
end;
end;


procedure TMainForm.Batch1Click(Sender: TObject);
begin
  frmBatchMove.showmodal;
end;

procedure TMainForm.pbCancelClick(Sender: TObject);
begin
  ClearBars;
  ShowMessage('Program has been terminated!');
  Application.Terminate;
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
	memoSql.lines.clear;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if Tag = 0 then
  begin
    Button2.tag:=1;
    Button2.Caption:='Hide Delete';
    xaShowDeletedRecords(tblTemp, true);
  end
  else
  begin
    Button2.tag:=0;
    Button2.Caption:='Show Delete';
    xaShowDeletedRecords(tblTemp, true);

  end;

 end;

procedure TMainForm.RebuildChecked1Click(Sender: TObject);
var iI:integer;
begin
	for iI:=0 to lbTables.Items.count-1 do
   	lbTables.Checked[iI] :=true;
  actRebuildTableExecute(Sender);
end;

procedure TMainForm.actRebuildCheckedExecute(Sender: TObject);
var
	iI:Integer;
   sTemp:string;
begin
  qrySql.close;
  tblTemp.close;
  fromtbl.Close;
  totbl.Close;
	for iI:=0 to lbTables.Items.count-1 do
   if lbTables.Checked[iI] then
		pbFiles.max:=pbFiles.max+1;

   pbCancel.tag:=0;
	for iI:=0 to lbTables.Items.count-1 do
   begin
   try
   	if lbTables.Checked[iI] then
      begin
      	lbTables.ItemIndex:=iI;
         ClearBars;
         try
          SetTableAndDir(FALSE);
         finally
          FieldUpdate.RestructureTable(sActiveDbName, 'LEVEL', '7');
          TableRebuildINdexes(sActiveDbName);
          TableRebuild(sActiveDbName,sTemp);
         end;

         SetTableAndDir(FALSE);
         if TableVerify(sActiveDbName,sTemp)= 0 then
             lbTables.Checked[iI]:= False;
			//sbInfo.SimpleText:=sTemp;
   		Log(sActiveDbName,'Rebuild Checked',sTemp);
      	pbFiles.Position:=pbFiles.Position+1;
	      application.processmessages;
      	if pbCancel.tag=1 then
      		break;
      end;
   except
     on EDBEngineError do continue;
   end;
   end;
   pbFiles.Position:=pbFiles.Max;
   CompleteBars;
   Showmessage('Rebuild Complete!');
   ClearBars;
end;

procedure TMainForm.actClearLogExecute(Sender: TObject);
begin
  with tblLog do
  begin
    active:=false;
    EmptyTable;
    active:=true;
  end;
end;

procedure TMainForm.FieldUpdateError(sender: TComponent;Error: TFieldUpdateError);
begin
  case Error of
    fuFileNotFound  :  MessageDlg('File not found.', mtError, [mbOK], 0);
    fuApply         :  MessageDlg('Error applying field definitions.' , mtError, [mbOK], 0);
    fuRead          :  MessageDlg('Error reading field definitions.', mtError, [mbOK], 0);
  end;
end;


procedure TMainForm.actUpgradeExecute(Sender: TObject);
var sToTable:string;
	sFromTable:string;
   sTemp:string;
   iError:integer;
begin
    TimerStart;
		SetToPerformAction;
  	ClearBars;
    TimerStart;
		TableUpgrade(sActiveDbName, sMAsterDbName,sTemp);
    SetTableInfo;
    CompleteBars;
    Showmessage('Update Complete!');
    ClearBars;
end;

procedure TMainForm.actCheckAllExecute(Sender: TObject);
var iI:integer;
begin
	for iI:=0 to lbTables.Items.count-1 do
   	lbTables.Checked[iI] :=true;

end;

procedure TMainForm.actUnCheckAllExecute(Sender: TObject);
var iI:integer;
begin
	for iI:=0 to lbTables.Items.count-1 do
   	lbTables.Checked[iI] :=False;
end;

procedure TMainForm.Splitter2CanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin

 //  MainForm.Width:=MainForm.Width + NewSize - grLeft.Width;
   Accept:=true;
end;

procedure TMainForm.actVerifyRebuildDatabaseExecute(Sender: TObject);
begin
  actCheckAllExecute(Sender);
  actVerifyCheckedExecute(Sender);
  Application.ProcessMessages;
  actRebuildCheckedExecute(Sender);
end;

procedure TMainForm.actVerifyDatabaseExecute(Sender: TObject);
begin
  actCheckAllExecute(Sender);
  actVerifyCheckedExecute(Sender);
end;

procedure TMainForm.actUpgradeCheckedExecute(Sender: TObject);
var
	iI:Integer;
   sTemp:string;
begin
	for iI:=0 to lbTables.Items.count-1 do
   if lbTables.Checked[iI] then
		pbFiles.max:=pbFiles.max+1;

   pbCancel.tag:=0;
	for iI:=0 to lbTables.Items.count-1 do
   begin
   try
   	if lbTables.Checked[iI] then
      begin
      	lbTables.ItemIndex:=iI;
         ClearBars;
         SetTableAndDir(FALSE);
         if (FileExists(edtMaster.Text)) then
         begin
            TimerStart;
      	    if TableUpgrade(sActiveDbName, sMasterDbName,sTemp) = 1 then
              lbTables.Checked[iI]:= False;
            //sbInfo.SimpleText:=sTemp;
            Log(sActiveDbName,'Upgrade Checked',sTemp);
         end
         else
         begin
         		  //sbInfo.SimpleText:='Upgrade Skipped; Not in master Db';
   		        Log(sActiveDbName,'Upgrade Skipped',edtMaster.Text);
         end ;

      pbFiles.Position:=pbFiles.Position+1;
      application.processmessages;
      if pbCancel.tag=1 then
      	break;
      end;
   except
      continue;
   end;
   end;
   pbFiles.Position:=pbFiles.Max;
   CompleteBars;
   Showmessage('Update Complete!');
   ClearBars;
end;

procedure TMainForm.actUpgradeDatabaseExecute(Sender: TObject);
begin
	CopyNewTables(sMasterPath, dbHelixDoctor.Directory);
  actCheckAllExecute(self);
  actUpgradeCheckedExecute(self);
  AliasComboChange(Sender);
  ClearBars;
  end;

procedure TMainForm.actRebuildDatabaseExecute(Sender: TObject);
begin
  actCheckAllExecute(self);
  actRebuildCheckedExecute(self);
  ClearBars;
end;

procedure TMainForm.actClearMasterDbExecute(Sender: TObject);
var
	DB : TDatabase;
  table: TTable;
  dstFile: string;
	tableList:Tstrings;
  paramsx:Tstrings;
  i:integer;
begin
	try
    if DirectoryExists(sMasterPath) then
    begin
      tableList:= TstringList.Create;
     	paramsx:= TstringList.Create;
      DB := TDatabase.Create(nil);
      paramsx.add('PATH='+ sMasterPath);
			paramsx.add('DEFAULT DRIVER=PARADOX');
			paramsx.add('ENABLE BCD=FALSE');

      table := TTable.Create(nil);
      table.TableType:=ttParadox;

      with DB do begin
        Connected := False;
        DatabaseName := 'MMUGCM' ;
        Directory := sMasterPath ;
        params:=paramsx;
        DriverName := 'STANDARD';

        Connected := True;
      end;

      DB.GetTableNames(tableList, False);

      pbFiles.max:=tableList.count;

      for i:=0 to tableList.count-1 do
   		begin
        table.active:=false;
        table.TableName := sMasterPath+tableList[i]+'.db';
        //    exclusive:=true;
        table.EmptyTable;

        //table.active:=true;
        	//sbInfo.SimpleText:=tableList[i];
          Log(sActiveDbName,'Table Cleared','Succesfully Cleared');
     			pbFiles.Position:=pbFiles.Position+1;
      end ;
    end;
    finally
    	DB.Free;
      table.Free;
      tableList.Free;
      paramsx.Free;

    end;

end;

procedure TMainForm.FormShow(Sender: TObject);
var i:integer;
begin
end;


procedure TMainForm.FormActivate(Sender: TObject);
begin
if ParamCount > 0 then
begin
  if FindCmdLineSwitch('UPGRADE') then
  begin
    self.Enabled := false ;
    self.actUpgradeDatabaseExecute(self) ;
    self.Close;
  end;
end;
end;

procedure TMainForm.infoPanelResize(Sender: TObject);
begin
 UpgradeInfoGroup.Width := infoPanel.Width div 2;
end;

procedure TMainForm.pcTableChange(Sender: TObject);
begin
  if pcTable.ActivePage =  tsPumper then
      actPumperInit.Execute;
end;

procedure TMainForm.dsTempDataChange(Sender: TObject; Field: TField);
begin
     tsDataRecordCount.text := 'Record Count: ' + inttostr(tblTemp.RecordCount);
end;

procedure TMainForm.pumperPanelResize(Sender: TObject);

begin
  if  actPumperGetDiff.enabled then
  begin
      pumpDiffGroup.Visible :=true;
     pumpDiffGroup.Width := (Sender as tPanel).Width div 3;
     pumpDestinationGroup.Width := (Sender as tPanel).Width div 3;
  end
  else
    pumpDiffGroup.Visible :=false;
    pumpSourceGroup.Width := (Sender as tPanel).Width div 2;
  begin
  end;
end;

procedure TMainForm.actPumperInitExecute(Sender: TObject);
begin

    if globals.sMasterDbName <> '' then
    begin
     FromTbl.Close;
     FromTbl.tablename:= globals.sMasterDbName;
     FromTBl.Open;
     pumpSourceGroup.Visible:= true;
    end
    else
    begin
             pumpSourceGroup.Visible:= false;
    end;

    if globals.sActiveDbName <> '' then
    Begin
      ToTbl.Close;
      ToTbl.tablename:= globals.sActiveDbName;
      ToTbl.open;
    end;
end;

procedure TMainForm.Panel6Resize(Sender: TObject);
begin
        upgradeIndexGroup.Width := (Sender as tPanel).Width div 2;
end;

procedure TMainForm.ToSrcDataChange(Sender: TObject; Field: TField);
begin
       pumpDestinationGroup.Caption := 'Table Record Count: ' + inttostr(toTbl.RecordCount);
end;

procedure TMainForm.FromSrcDataChange(Sender: TObject; Field: TField);
begin
      pumpSourceGroup.Caption := 'PumpDB Table Record Count: ' + inttostr(fromTbl.RecordCount);
end;

procedure TMainForm.Panel7Resize(Sender: TObject);
begin
         upgradeFieldsGroup.Width := (Sender as tPanel).Width div 2;
end;

procedure TMainForm.actValidateTableExecute(Sender: TObject);
var
sTemp :string;
begin
 ClearBars;
  timerStart();
  TableValidate(globals.sActiveDbName,sTemp);
	//sbInfo.SimpleText:=sTemp;
  Log(sActiveDbName,'Validate',sTemp);
end;

procedure TMainForm.actValidateCheckedExecute(Sender: TObject);
var
	iI:Integer;
   sTemp:string;
begin
	for iI:=0 to lbTables.Items.count-1 do
   if lbTables.Checked[iI] then
		pbFiles.max:=pbFiles.max+1;

   pbCancel.tag:=0;
	for iI:=0 to lbTables.Items.count-1 do
   begin
   try
   	if lbTables.Checked[iI] then
      begin
      	lbTables.ItemIndex:=iI;
         ClearBars;
         SetTableAndDir(FALSE);
         TimerStart;
         if TableValidate(sActiveDbName,sTemp) = 1 then
         begin
            lbTables.Checked[iI]:= False;
            //sbInfo.SimpleText:=sTemp;
            Log(sActiveDbName,'Validate Checked',sTemp);
         end;
      pbFiles.Position:=pbFiles.Position+1;
      application.processmessages;
      if pbCancel.tag=1 then
      	break;
      end;
   except
      continue;
   end;
   end;
   pbFiles.Position:=pbFiles.Max;
end;

procedure TMainForm.Validate1Click(Sender: TObject);
begin
  actCheckAllExecute(self);
  actValidateCheckedExecute(self);
  AliasComboChange(Sender);
end;

procedure TMainForm.actAboutExecute(Sender: TObject);
begin
  aboutBox.ShowModal;
end;

function TMainForm.AliasLocation(const Alias: string): string;
var
  AliasParams: TStringList;
begin
  AliasParams := TStringList.Create;
  try
    Session.GetAliasParams(Alias, AliasParams);
    Result := AliasParams.Values['Path'];
  finally
    AliasParams.Free;
  end;
end;

procedure TMainForm.actClearLocksExecute(Sender: TObject);
var
  stemp:string;
  AliasParams: TStringList;
begin
    //sTemp := dbHelixDoctor.Directory;
    //Log(sActiveDbName,'Deleting Locks:',sTemp);
    //FileDelete(sTemp + '\*.lck');
      //sTemp:= doctorSession.NetFileDir;
     // FileDelete(sTemp + '\*.lck');
      //sbInfo.SimpleText:=sTemp;
      //Log(sActiveDbName,'Deleting Netdir:',sTemp);
      //DeleteDirectory(stemp, false);
      //sTemp:= doctorSession.PrivateDir;
      //sbInfo.SimpleText:=sTemp;
      //Log(sActiveDbName,'Deleting PrivateDir:',sTemp);
end;

procedure TMainForm.actNewTables(Sender: TObject);
begin
    ClearBars;
    CopyNewTables(sMasterPath, dbHelixDoctor.Directory);
    SetTableInfo;
    CompleteBars;
    Showmessage('New Tables Complete!');
    ClearBars;
end;
end.

