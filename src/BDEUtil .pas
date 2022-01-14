unit BDEUtil   ;
interface
 uses
  DB, BDE,TUtil32, DBTables, ComCtrls;

type

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

    public
    PBHeader: TProgressBar;
    PBIndexes: TProgressBar;
    PBData: TProgressBar;
    PBRebuild: TProgressBar;
  end;


implementation

uses globals;

 function GenProgressCallBack(ecbType: CBType; Data: LongInt; pcbInfo: Pointer):
  CBRType; stdcall;
var
  CBInfo: TUVerifyCallBack;
begin
  CBInfo := TUVerifyCallBack(pcbInfo^);
  if ecbType = cbGENPROGRESS then
    case CBInfo.Process of
     TUVerifyHeader: begin
      globals.BDEUtil.PBHeader.Position := CBInfo.percentdone;
     end;
     TUVerifyIndex: begin
       globals.BDEUtil.PBIndexes.Position := CBInfo.percentdone;
     end;
     TUVerifyData: begin
       globals.BDEUtil.PBData.Position := CBInfo.percentdone;
     end;
     TURebuild: begin
       globals.BDEUtil.PBRebuild.Position := CBInfo.percentdone;
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
    if TUFillCURProps(vHtSes, PChar(szTable),TUProps) = DBIERR_NONE then
    begin
      Result:=true;
    end
  else Result := False;
end;

procedure TBDEUtil.RegisterCallback;
begin
 Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0, sizeof(TUVerifyCallBack), @CbInfo, GenProgressCallback));
end;

procedure TBDEUtil.UnRegisterCallback;
begin
  Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0, sizeof(TUVerifyCallBack), @CbInfo, nil));
end;

end.
