unit BDEUtil  ;
interface
 uses
  DB, BDE,TUtil32  ;

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

  end;


implementation
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
 Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
            sizeof(TUVerifyCallBack), @CbInfo, GenProgressCallback));
end;

procedure TBDEUtil.UnRegisterCallback;
begin
  Check(DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
           sizeof(TUVerifyCallBack), @CbInfo, nil));
end;
end.
