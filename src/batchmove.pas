unit batchmove;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DBTables, DB, Buttons, Mask, Spin, ComCtrls;

type
  TfrmBatchMove = class(TForm)
    BatchMove1: TBatchMove;
    Bevel1: TBevel;
    Label1: TLabel;
    Bevel2: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbSourceAlias: TComboBox;
    cbSourceTable: TComboBox;
    cbDestAlias: TComboBox;
    cbDestTable: TComboBox;
    dbSource: TDatabase;
    tblSource: TTable;
    dbDest: TDatabase;
    tblDest: TTable;
    Label7: TLabel;
    cbMode: TComboBox;
    Bevel3: TBevel;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label8: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ckAbortOnKeyViol: TCheckBox;
    txtKeyViolTableName: TLabel;
    edKeyViolTableName: TEdit;
    ckAbortOnProblem: TCheckBox;
    txtProblemTableName: TLabel;
    edProblemTableName: TEdit;
    edRecordCount: TSpinEdit;
    Label11: TLabel;
    Label12: TLabel;
    edChangedTableName: TEdit;
    Label13: TLabel;
    Bevel4: TBevel;
    OpenDialog1: TOpenDialog;
    sbKeyViolTbl: TSpeedButton;
    sbProbTbl: TSpeedButton;
    edCommitCount: TSpinEdit;
    sbChangeTbl: TSpeedButton;
    ckTransliterate: TCheckBox;
    Label9: TLabel;
    cbSourceIndex: TComboBox;
    Label10: TLabel;
    cbDestIndex: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
    procedure cbSourceAliasChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ckAbortOnKeyViolClick(Sender: TObject);
    procedure ckAbortOnProblemClick(Sender: TObject);
    procedure sbKeyViolTblClick(Sender: TObject);
    procedure cbSourceTableChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBatchMove: TfrmBatchMove;

const
	sNONE = 5;		// '<NONE>'
  sSOURCE = 6;			// 'Source'
	sDESTINATION = 7;		// 'Destination'
  sTBLNAMEREQ = 8;		// 'table name is required.'
  sKEYVIOLTBLREQ = 9;	// 'Key Violation'
  sPROBTBLREQ = 10;		// 'Problem'
  sALIASREQ = 11;		// 'alias is required.'

implementation

{$R *.DFM}

procedure TfrmBatchMove.FormCreate(Sender: TObject);
begin
	Application.HintPause := 0;
  
	// Retreive aliases and store them in the Source/Destination comboboxes
 	with Session do
 	begin
 		if (not Active) then Active := TRUE;
   	GetAliasNames(cbSourceAlias.Items);
   	GetAliasNames(cbDestAlias.Items);
 	end;

	// Begin and set alias combobox entries to <NONE>
  with cbSourceAlias do
 	begin
 		Items.Insert(0, LoadStr(sNONE));
  	ItemIndex := 0;
 	end;

 	with cbDestAlias do
 	begin
 		Items.Insert(0, LoadStr(sNONE));
  	ItemIndex := 0;
 	end;


 	cbMode.ItemIndex := 0; // BatchMove mode is set to batAppend
 	cbModeChange(cbMode);  // Fill memo with information on BatchMove mode

	// Set options to TBatchMove's default property values
	with BatchMove1 do
 	begin
		ckAbortOnKeyViol.Checked := AbortOnKeyViol;
 		ckAbortOnProblem.Checked := AbortOnProblem;
     ckTransliterate.Checked := Transliterate;
  end;

	// Set possible maximum values dynamically
  edRecordCount.MaxValue := High(LongInt);	// Maximum records to move
  edCommitCount.MaxValue := High(Integer);  // Records moved before commit

end;

procedure TfrmBatchMove.cbModeChange(Sender: TObject);
begin
	// Display help information about the TBatchMode
	with Memo1 do
 	begin
 		Clear;
     Lines.Add(LoadStr(TComboBox(Sender).ItemIndex));
   	SendMessage(Handle, EM_LINESCROLL, 0, -1 * Lines.Count);
 	end;
end;

procedure TfrmBatchMove.cbSourceAliasChange(Sender: TObject);
var
	cbTableList: TComboBox;
 	db: TDatabase;
begin
	if (TComboBox(Sender).ItemIndex = 0) then Exit;
  if (Sender = cbSourceAlias) then
  	begin
     	cbTableList := cbSourceTable;
      	db := dbSource;
    	end
  else if (Sender = cbDestAlias) then
  	begin
     	cbTableList := cbDestTable;
      	db := dbDest;
    	end
  else Exit;

	cbTableList.Clear;
  with db do
  begin
  	if (Connected) then Connected := FALSE;
    	AliasName := TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex];
    	Connected := TRUE;
  end;

	with cbTableList do
  begin
    	Session.GetTableNames(db.DatabaseName, '', TRUE, FALSE, Items);
    	ItemIndex := 0;
  end;

  cbSourceTableChange(cbTableList);
end;

procedure TfrmBatchMove.BitBtn1Click(Sender: TObject);
var
	strName: String[80];
begin
	strName := SysUtils.EmptyStr;

	// Source and Destination alias must be specified.
  if (cbSourceAlias.ItemIndex = 0) then
  	begin
  		strName := LoadStr(sSOURCE);
        cbSourceAlias.SetFocus;
     end
  else if (cbDestAlias.ItemIndex = 0) then
  	begin
  		strName := LoadStr(sDESTINATION);
        cbDestAlias.SetFocus;
     end;
  if (Length(strName) <> 0) then
  	begin
     	strName := Format('%s %s', [strName, LoadStr(sALIASREQ)]);
        MessageDlg(strName, mtError, [mbOk], 0);
        Exit;
     end;
  with dbSource do if (not Connected) then Connected := TRUE;
  with dbDest do if (not Connected) then Connected := TRUE;


	// Source and Destination table names must be specified.
  if (Length(cbSourceTable.Text) = 0) then strName := LoadStr(sSOURCE)
  else if (Length(cbDestTable.Text) = 0) then strName := LoadStr(sDESTINATION);

  if (Length(strName) <> 0) then
  	begin
     	MessageDlg(Format('%s %s', [strName, LoadStr(sTBLNAMEREQ)]), mtError,
        	[mbOk], 0);
        Exit;
     end;

  with tblSource, cbSourceIndex do
  begin
  	TableName := cbSourceTable.Text;
     if (ItemIndex <> 0) then IndexName := Text;
  end;

  with tblDest, cbDestIndex do
  begin
  	TableName := cbDestTable.Text;
     if (ItemIndex <> 0) then IndexName := Text;
  end;


  // if AbortOnKeyViol or AbortOnProblem turned off, table must be specified
  if ((not ckAbortOnKeyViol.Checked)
  	and (Length(edKeyViolTableName.Text) = 0)) then
  	begin
        edKeyViolTableName.SetFocus;
     	MessageDlg(Format('%s %s', [LoadStr(sKEYVIOLTBLREQ),
        	LoadStr(sTBLNAMEREQ)]), mtError, [mbOk], 0);
        Exit;
     end
  else
  	BatchMove1.KeyViolTableName := edKeyViolTableName.Text;

  if ((not ckAbortOnProblem.Checked)
  	and (Length(edProblemTableName.Text) = 0)) then
  	begin
        edProblemTableName.SetFocus;
     	MessageDlg(Format('%s %s', [LoadStr(sPROBTBLREQ),
        	LoadStr(sTBLNAMEREQ)]), mtError, [mbOk], 0);
        Exit;
     end
  else
  	BatchMove1.ProblemTableName := edProblemTableName.Text;

  // Set BatchMove properties as specified by user
  with BatchMove1 do
  begin
		// Mode
  	case cbMode.ItemIndex of
     	0: Mode := batAppend;
        1: Mode := batUpdate;
        2: Mode := batAppendUpdate;
        3: Mode := batCopy;
        4: Mode := batDelete;
     end;
  	AbortOnKeyViol := ckAbortOnKeyViol.Checked;		// AbortOnKeyViol
     AbortOnProblem := ckAbortOnProblem.Checked;		// AbortOnProblem
     Transliterate := ckTransliterate.Checked;			// Transliterate
     RecordCount := edRecordCount.Value; 				// RecordCount
     CommitCount := edCommitCount.Value;					// CommitCount
     ChangedTableName := edChangedTableName.Text;		// ChangedTableName
  end;

  try
  	with dbDest do if (IsSQLBased) then StartTransaction;
     BatchMove1.Execute;										// Perform BatchMove
     with dbDest do if (InTransaction) then Commit;
  except
  	on EDatabaseError do
     begin
     	with dbDest do if (InTransaction) then Rollback;
        raise;
     end;
  end;
end;

procedure TfrmBatchMove.ckAbortOnKeyViolClick(Sender: TObject);
var
	bEnable: Boolean;
begin
	bEnable := (not TCheckBox(Sender).Checked);
  edKeyViolTableName.Enabled := bEnable;
  sbKeyViolTbl.Enabled := bEnable;

	if (bEnable) then
  	begin
  		txtKeyViolTableName.Font.Style := [];
        edKeyViolTableName.SetFocus;
     end
  else
  	txtKeyViolTableName.Font.Style := [fsItalic]
end;

procedure TfrmBatchMove.ckAbortOnProblemClick(Sender: TObject);
var
	bEnable: Boolean;
begin
	bEnable := (not TCheckBox(Sender).Checked);
	edProblemTableName.Enabled := bEnable;
  sbProbTbl.Enabled := bEnable;

	if (bEnable) then
  	begin
  		txtProblemTableName.Font.Style := [];
        edProblemTableName.SetFocus;
     end
  else
  	txtProblemTableName.Font.Style := [fsItalic];
end;

// This method is shared by sbKeyViolTbl, sbProbTbl, and sbChangeTbl
// components. It allows client to designate a filename.
procedure TfrmBatchMove.sbKeyViolTblClick(Sender: TObject);
begin
	with OpenDialog1 do
  begin
		if (not Execute) then Exit;
     if (Sender = sbKeyViolTbl) then
     	edKeyViolTableName.Text := FileName
     else if (Sender = sbProbTbl) then
     	edProblemTableName.Text := FileName
     else if (Sender = sbChangeTbl) then
     	edChangedTableName.Text := FileName;
  end;
end;

(*	This method is shared by cbSourceTable and cbDestTable components.
		When client designates a table, associated indexes are retreived into
     appropriate comboboxes (e.g., cbSourceIndex or cbDestIndex. *)
procedure TfrmBatchMove.cbSourceTableChange(Sender: TObject);
var
	cbIndexList: TComboBox;
  Table: TTable;
  db: TDatabase;
	List: TStringList;
begin
	if (Length(TComboBox(Sender).Text) = 0) then Exit;

	// Update index list based on who is the caller.
  if (Sender = cbSourceTable) then
     begin
        db := dbSource;
        Table := tblSource;
        cbIndexList := cbSourceIndex;
     end
  else if (Sender = cbDestTable) then
     begin
        db := dbDest;

        Table := tblDest;
        cbIndexList := cbDestIndex;
     end;
  cbIndexList.Clear;

  // Because destination table may not exist, we'll first check for its
  // existence before calling GetIndexNames to avoid exception.
  Table.TableName := (TComboBox(Sender).Text);
  List := nil;
  try
     List := TStringList.Create;
     Session.GetTableNames(db.DatabaseName, '*.*', TRUE, FALSE, List);
     if (List.IndexOf(Table.TableName) <> -1) then
        Table.GetIndexNames(cbIndexList.Items);
  finally
     List.Free;
  end;

  // The first index entry is set to <NONE>
  with cbIndexList do
  begin
     Items.Insert(0, LoadStr(sNONE));
     ItemIndex := 0;
  end;
end;

end.

