unit xaUtils;
// 2001/01/05 Added rpc code alex
interface
uses winsock, comctrls,messages,classes,SysUtils,controls,forms,windows,BDE,dbtables,jclStrings,extctrls,ShlObj;

const
	//for xaKeyPress... functions
	KP_INTEGERS ='1234567890';
  KP_FLOATS ='1234567890.,';
  shfolder = 'ShFolder.dll'; 




//imported functions from Rpcrt4.dll
function RpcStringFree(ppString:POINTER): Longint; stdcall;
function UuidCreate(pUUid:PGUID): Longint; stdcall;
function UuidToString(pUUid:PGUID;szUuid:PCHAR): Longint; stdcall;
function UuidFromString(szUuid:PCHAR; pUUid:PGUID): Longint; stdcall;

//imported from ShFolder.dll
function ShGetFolderPath(hWndOwner: HWnd; csidl: Integer; hToken:THandle; dwReserved: DWord; lpszPath: PChar): HResult; stdcall;
function ShGetFolderPathA(hWndOwner: HWnd; csidl: Integer; hToken:THandle; dwReserved: DWord; lpszPath: PAnsiChar): HResult; stdcall;
function ShGetFolderPathW(hWndOwner: HWnd; csidl: Integer; hToken:THandle; dwReserved: DWord; lpszPath: PWideChar): HResult; stdcall;
function ShGetFolderLocation(hWndOwner: HWnd; csidl: Integer; hToken:THandle; dwReserved: DWord; out pidl: PItemIDList): HResult; stdcall;




//local functions
function xaButtonClick(btnButton:Twincontrol):boolean;
function xaGetIP: string;
function xaGetIPs: TStrings;
function xaGetFormFromHandle(hWnd:HWND):TForm;
function xaGetControlFromHandle(clParentForm:TForm;hWnd:HWND):TControl;
function xaDelDir(sDir: String): boolean;
function xaMoveDir(sFrom:String; sTo: String): boolean;
function xaCopyDir(sFrom:String ; sTo: String): boolean;
function xaRenameFiles(sFrom:String ; sTo: String): boolean;
function xaCopyFiles(sFrom:String ; sTo: String): boolean;
function xaGetBits(iValue:integer; iStartPos:integer; iEndpos:integer):integer;
function xaGetBit(iValue:integer; iPos:integer):boolean;
function xaSetBits(var iVariable:integer; iValue:integer; iStartPos:integer; iEndpos:integer):integer;
function xaCreateTimeDateFilename(sFilename:string; sType:string):string;
function xaCreateSubdirectoryFilename(sFilename:string; sSubDirectory:string):string;
function xaGetDdbError(ErrCode:DBiResult):String;
function xaGetUuidString(var sUuid: String):Longint;
function xaUuidCreate(var pUuid:PGUID): Longint;
function xaUuidToString(pUUid:PGUID;var sUuid:string): Longint;
function xaUuidFromString(sUuid:String; var pUUid:PGUID): Longint;
function xaGetComputerName:string;
function xaSetFocus(ctlTemp: TWinControl):Boolean;
function xaGetPathForAlias(session:Tsession ;sAlias:string):string;
procedure xaShowDeletedRecords(Table: TTable; SioNo: Boolean);
function xaSpaceChildrenVertical(panel:Tpanel):Boolean;
function xaCenterPanel(var panel:Tpanel; percentOfParentTop:integer):integer;
function xaSetMaxConstraints(var form:tform): integer;
procedure xaSetToMainFormSize(form:Tform);
function xaGetCommonAppDataPath : string;

//Key validation functions
function xaKeyPressExclude(var cKey:char; sKeyInString: string; cErrorReturnKey:char): char;
function xaKeyPressInclude(var cKey:char; sKeyInString: string; cErrorReturnKey:char): char;

implementation
uses ShellAPI; 


function RpcStringFree; external 'Rpcrt4.dll' name 'RpcStringFreeA';
function UuidCreate; external 'Rpcrt4.dll' name 'UuidCreate';
function UuidToString; external 'Rpcrt4.dll' name 'UuidToStringA';
function UuidFromString; external 'Rpcrt4.dll' name 'UuidFromStringA';

function ShGetFolderPath; external shfolder name 'SHGetFolderPathA';
function ShGetFolderPathA; external shfolder name 'SHGetFolderPathA';
function ShGetFolderPathW; external shfolder name 'SHGetFolderPathW';
function ShGetFolderLocation; external shell32 name 'SHGetFolderLocation';


function xaGetCommonAppDataPath : string;
{const
   SHGFP_TYPE_CURRENT = 0;
   CSIDL_COMMON_APPDATA = $0023  ;
  function GetSpecialFolderLocation(const Folder: Integer): string;
  var
   //path: array [0..255] of char;
    FolderPidl: PItemIdList;
  begin
     if Succeeded(SHGetSpecialFolderLocation(0, Folder, FolderPidl)) then
    begin
      Result := PidlToPath(FolderPidl);
      PidlFree(FolderPidl);
    end
    else
      Result := '';
  end;
}
begin
  	//SHGetFolderPath(0,CSIDL_COMMON_APPDATA ,0,SHGFP_TYPE_CURRENT,@path[0]) ;
end;


function xaSetMaxConstraints(var form:tform): integer;
begin
  with form.Constraints do
  begin
    MaxHeight:=screen.Height;
    MinHeight:=screen.Height;
    MaxWidth:=screen.Width;
    MinWidth:=screen.Width;
  end;
  result:=1;
end;

procedure xaSetToMainFormSize(form:Tform);
begin
  form.Left:=application.mainform.left;
  form.Top:=application.mainform.Top;
  form.width:=application.mainform.width;
  form.height:=application.mainform.height;

end;

procedure xaShowDeletedRecords(Table: TTable; SioNo: Boolean);
begin
  Table.DisableControls;
  try
    Check(DbiSetProp(hDBIObj(Table.Handle), curSOFTDELETEON, Longint(SioNo)));
  finally
    Table.EnableControls;
  end;
  Table.Refresh;
end;

function xaCenterPanel(var panel:Tpanel; percentOfParentTop:integer):integer;
begin
    with panel do
    begin
         left := (parent.Width div 2) - (Width div 2);
         if percentOfParentTop > 0 then
           Top := ((parent.Height * percentOfParentTop) div 100)
         else
           Top := (parent.Height div 2) - (Height div 2);
    end;
  result:=panel.Top;
end;


function xaSpaceChildrenVertical(panel:Tpanel):Boolean;
var
  iComponentCount:integer;
  iControlHeight:integer;
  iControlAdjust:integer;
  iBorderOffset:integer;
begin
    iControlAdjust := panel.Height mod panel.ControlCount;
    iBorderOffset :=  panel.BorderWidth + panel.BevelWidth;
    iControlHeight := (panel.Height - (2*iBorderOffset)) div panel.ControlCount;

    for iComponentCount := 0 to panel.ControlCount - 1 do
    begin
      Panel.Controls[iComponentCount].Top := iBorderOffset + (iControlHeight * TPANEL(Panel.Controls[iComponentCount]).TabOrder);
      Panel.Controls[iComponentCount].Height := iControlHeight;
      Panel.Controls[iComponentCount].width := panel.width - 2*iBorderOffset;
    end;

  result:=true;
end;

function xaGetComputerName:string;
var
  szBuffer:array[0..MAX_COMPUTERNAME_LENGTH+1] of Char;
  length:Cardinal;
begin
  length:=MAX_COMPUTERNAME_LENGTH+1;
  GetComputerName(@szBuffer,length);
  result:=szBuffer;
end;


function xaGetBit(iValue:integer; iPos:integer):boolean;
begin
	result:=boolean(xaGetBits(iValue, iPos,iPos));
end;


function xaGetBits(iValue:integer; iStartPos:integer; iEndpos:integer):integer;
var iI:integer;
iMask:integer;
begin
	iMask:=1;
	for iI := 1 TO iEndPos-iStartPos do
   	iMask:= (iMask shl 1) +1;
	for iI := 1 TO iStartPos do
   	iMask:= (iMask shl 1) ;
   Result:= iValue and iMask;
   Result:=   Result shr iStartPos;
end;

function xaSetBits(var iVariable:integer; iValue:integer; iStartPos:integer; iEndpos:integer):integer;
var iI:integer;
iMask:integer;
begin
	iMask:=1;
	for iI := 1 TO iEndPos-iStartPos do
   	iMask:= (iMask shl 1) +1;
	for iI := 1 TO iStartPos do
   	iMask:= (iMask shl 1) ;
   Result:= iValue and iMask;
   Result:=   Result shr iStartPos;
end;

function xaGetIP: string;
var
  phoste:PHostEnt;
  Buffer:array[0..100] of char;
  WSAData:TWSADATA;
begin
  result:='';
  if WSASTartup($0101, WSAData) <> 0 then exit;
  GetHostName(Buffer,Sizeof(Buffer));
  phoste:=GetHostByName(buffer);
  if phoste = nil then
  begin
    result:='127.0.0.1';
  end
  else
    result:=StrPas(inet_ntoa(PInAddr(phoste^.h_addr_list^)^));
  WSACleanup;
end;

function xaGetIPs: TStrings;
type
  TaPInAddr = Array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: Array[0..63] of Char;
  I: Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  Result:=TStringList.Create;
  Result.Clear;
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(buffer);
  if phe = nil then
  begin
    Exit;
  end;
  pPtr := PaPInAddr(phe^.h_addr_list);
  I := 0;
  while pPtr^[I] <> nil do
  begin
    Result.Add(inet_ntoa(pptr^[I]^));
    Inc(I);
  end;
  WSACleanup;
end;


function xaGetFormFromHandle(hWnd:HWND):TForm;
 var
  iComponentCount:Integer;
begin
	xaGetFormFromHandle:=nil;
	//check all the components on the form. The application components.
	with Application do
   begin
      for iComponentCount := ComponentCount - 1 downto 0 do
      begin
         if (Components[iComponentCount].InheritsFrom(TForm)) then
         begin
         	if TForm(Components[iComponentCount]).Handle = hWnd then
            begin
					xaGetFormFromHandle:=TForm(Components[iComponentCount]);
            	exit;
            end;
      	end;
      end;
  	end;
end;

function xaGetControlFromHandle(clParentForm:TForm;hWnd:HWND):TControl;
 var
  iControlCount: Integer;

	function CheckControl(clControl:TControl):boolean;
	var
   	iControlCount:integer;
	begin
   	CheckControl:=False; //Set to not found
		if clControl.InheritsFrom(Twincontrol) then
      begin
      	if (Twincontrol(clControl)).Handle = hWnd then
         begin
           xaGetControlFromHandle:=clControl;       //tcontrol
           CheckControl:=True;
           exit;
         end
         else
         begin
            for iControlCount:=(tWinControl(clControl)).ControlCount - 1 downto 0  do
            begin
               if CheckControl(tWinControl(tWinControl(clControl).Controls[iControlCount])) then
                  exit;
            end;
         end;
      end;
   end;

begin
	xaGetControlFromHandle:=nil;
   for iControlCount := clParentForm.ControlCount - 1 downto 0 do
   	CheckControl(clParentForm.Controls[iControlCount]);
end;

function xaRenameFiles(sFrom:String ; sTo: String): boolean;
var stFileOp: TSHFileOpStruct;
begin
	ZeroMemory(@stFileOp, SizeOf(stFileOp));
	with stFileOp do
   begin
		wFunc := FO_RENAME;
		fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
		pFrom := PChar(sFrom+#0);
		pTo := PChar(sTo)
	end;
	Result:=(0=ShFileOperation(stFileOp));
end;

function xaCopyFiles(sFrom:String ; sTo: String): boolean;
var stFileOp: TSHFileOpStruct;
begin
	ZeroMemory(@stFileOp, SizeOf(stFileOp));
	with stFileOp do
   begin
		wFunc := FO_COPY;
  		fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
		pFrom := PChar(sFrom+#0);
		pTo := PChar(sTo)
	end;
	Result:=(0=ShFileOperation(stFileOp));
end;

function xaCopyDir(sFrom:String ; sTo: String): boolean;
var stFileOp: TSHFileOpStruct;
begin
	ZeroMemory(@stFileOp, SizeOf(stFileOp));
	with stFileOp do
   begin
		wFunc := FO_COPY;
		fFlags := FOF_FILESONLY or FOF_NOCONFIRMATION;
		pFrom := PChar(sFrom+#0);
		pTo := PChar(sTo)
	end;
	Result:=(0=ShFileOperation(stFileOp));
end;

function xaMOveDir(sFrom:String; sTo: String): boolean;
var stFileOp: TSHFileOpStruct;
begin
	ZeroMemory(@stFileOp, SizeOf(stFileOp));
	with stFileOp do
   begin
		wFunc := FO_MOVE;
		fFlags := FOF_FILESONLY;
		pFrom := PChar(sFrom+#0);
		pTo := PChar(sTo)
	end;
Result:=(0=ShFileOperation(stFileOp));
end;

function xaDelDir(sDir: String): boolean;
var stFileOp: TSHFileOpStruct;
begin
 ZeroMemory(@stFileOp, SizeOf(stFileOp));
 with stFileOp do begin
  wFunc := FO_DELETE;
  fFlags := FOF_NOCONFIRMATION;    // FOF_SILENT
  pFrom := PChar(sDir+#0);
 end;
 Result:=(0=ShFileOperation(stFileOp));
end;

function xaButtonClick(btnButton:Twincontrol):boolean;
begin
	result:=postmessage(btnButton.Handle,BM_CLICK,0,0);
end;

function xaCreateTimeDateFilename(sFilename:string; sType:string):string;
begin
	if length(sType)> 0 then
   	sType:=sType + '_';
	Result:=ChangeFileExt(sFilename,('.' + sType +
   			FormatDateTime('yyyymmdd@hhnnss', NOW) + extractFileExt(sFilename)));
end;

function xaCreateSubdirectoryFilename(sFilename:string; sSubDirectory:string):string;
begin

end;

function xaGetDdbError(ErrCode:DBiResult):String;
var
	sEngineMsg:string;
begin
	DbiGetErrorString(ErrCode,PCHAR(sEngineMsg));
   Result:=sEngineMsg;
end;

function xaGetUuidString(var sUuid: String):Longint;
var
	Uuid:TGUID;
	pUuid:PGUID;
begin
   pUuid:=@Uuid;
	ZeroMemory(pUuid,sizeof(TGUID));

	result:= xaUuidCreate(pUuid);
   xaUuidToString(pUUid,sUuid);
end;

//RPC_S_OK
//RPC_S_UUID_LOCAL_ONLY
//RPC_S_UUID_NO_ADDRESS
function xaUuidCreate(var pUuid:PGUID): Longint;
begin
	result:=UUidCreate(pUuid);
end;

function xaUuidToString(pUUid:PGUID;var sUuid:string): Longint;
var
	pszString: POINTER;
begin
   pszString:=nil;
   result:= UuidToString(pUuid,@pszString);
   if result = 0 then
   begin
		sUuid:=strpas(PCHAR(pszString));
   	RpcStringFree(@pszString);
   end;
end;

// returns RPC_S_INVALID_STRING_UUID if string is invalid
// 0 if ok or RPC_S_OK
function xaUuidFromString(sUuid:String; var pUUid:PGUID): Longint;
//var
//	 szString: array of char[255];
begin
   result:=UuidFromString(PCHAR(sUuid),pUuid);
end;
function xaKeyPressExclude(var cKey:char; sKeyInString: string; cErrorReturnKey:char): char;
var
  iCount: integer;
  iKeyInStringLen: Integer;
begin
	Result:=cKey;
	iKeyInStringLen := Length(sKeyInString);

	for iCount := 1 to iKeyInStringLen do
	begin
   	if (sKeyInString[iCount] = cKey) then
      begin
      	Result := cErrorReturnKey;
      	Exit;
      end;
  end;
end;

function xaKeyPressInclude(var cKey:char; sKeyInString: string; cErrorReturnKey:char): char;
var
  iCount: integer;
  iKeyInStringLen: Integer;
  stPassAlong: set of char;
begin
	stPassAlong:=[#8,#13];
	if (cKey in stPassAlong) then
   begin
     result:=cKey;
   end
   else
   begin
      Result:=cErrorReturnKey;
      iKeyInStringLen := Length(sKeyInString);

      for iCount := 1 to iKeyInStringLen do
      begin
         if (sKeyInString[iCount] = cKey) then
         begin
            Result := cKey;
            Exit;
         end;
     end;
   end;
end;

function xaSetFocus(ctlTemp: TWinControl):boolean;
var	ctlParent: TWinControl;
begin
	result:=false;
	ctlParent := ctlTemp.Parent;
   if ctlParent is TTabSheet then
   begin
      TPageControl(ctlParent.Parent).ActivePage := TTabSheet(ctlParent);
   end
   else
   begin
		while (not ctlTemp.CanFocus) and (ctlParent.CanFocus) do
   	begin
      	ctlParent.SetFocus;
	      ctlParent := ctlParent.Parent;
   	end;
   end;

	if ctlTemp.CanFocus then
   begin
   	result:=true;
   	ctlTemp.SetFocus;
   end
end;

function xaGetPathForAlias(session:Tsession ;sAlias:string):string;
var
    ParamList :TStringList;
    i: integer;
begin
    ParamList := TStringList.Create;
    Result:='';
    Session.GetAliasParams(sAlias,ParamList);
    for i:=0 to ParamList.Count -1 do
    begin
        if 0 <> strFind('PATH=',ParamList.Strings[i],1) then
        begin
            Result:=strAfter('PATH=',ParamList.Strings[i]);
            break;
        end;
    end;
   ParamList.free;
end;

end.
