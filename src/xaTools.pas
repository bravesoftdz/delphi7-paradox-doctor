unit xaTools;

interface

uses WinProcs,wintypes, SysUtils, forms, dialogs, dbtables,classes,controls,
	xaTRegisterApp, registry, ShellAPI, dbGrids,comctrls,commctrl,db,math,Aligrid, WinInet;

const
	xaNone  = 	0;
	xaOK = 		1;

type
   eFormStyle = (fsModal,fsModeless);

   TProgramInfo = record
		sFileDescription:string;
		sInternalName:string;
		sFileVersion:string;
      sLegalCopyright:string;
      sLegalTrademarks:string;
      sOriginalFilename:string;
      sProductName:string;
      sProductVersion:string;
      sComments:string;
	end;

	PHWnd = ^HWnd;

   TPrevInstInfo = record
   	szTitle: array [0..255] of char;
   	hPrevInstWnd : HWnd;
   end;

   PTPrevInstInfo=^TPrevInstInfo;

var frmLastForm:TForm;

function xa_RegisterApp(var clApp:TApplication; bBringToFront:boolean):boolean;
function xa_UnRegisterApp(var clApp:TApplication):Boolean;
Function xa_ActivatePreviousInstance(stPrevInstInfo :TPrevInstInfo):boolean;
function xa_OpenQuery(var qryQuery:TQUERY):integer;
function xa_ReOpenQuery(var qryQuery:TQUERY):integer;
function xa_ShowForm(InstanceClass: TComponentClass; var Reference; cParent: TComponent; eStyle:eFormStyle):integer;
function xa_ShowFormX(frmForm: TForm; cParent: TComponent; eStyle:eFormStyle; bAssigned: Boolean): Integer;
function xa_ShowEmail(strRecipient:string): integer;
function xa_ShowBrowserStr(strUrl:string): integer;
function xa_ShowBrowserSz(szUrl:pchar): integer;
procedure xa_GetProgramInfo(var stProgramInfo:TProgramInfo;var lProgramInfo:TstringList);
procedure xa_ResizeDBGrid(var clGrid:TDBGrid);
procedure xaSetImageIndex(var tv:TTreeView; index,SelIndex:integer;sText:string );
function xaFindTreeViewNodeId(tvNode:TTreeNode;sText:string ): HTREEITEM;
procedure xaCopyAppendRecord(var tblFrom,tblTo:ttable);
procedure xaUpdateRecord(var tblFrom,tblTo:ttable;strIndex:string;intRecord:integer);
procedure xa_AdjustGrid(var dbGrid:TDBGrid);overload;
procedure xa_AdjustGrid(var Grid:TStringAlignGrid);overload;
function xaGetInetFile(const fileURL, FileName: String): boolean;

implementation

procedure xaCopyAppendRecord(var tblFrom,tblTo:ttable);
var  i,j,a,b: integer;
   s,f,t,sx:string;
begin    {1}
 if not tblFrom.active then
   tblFrom.active:= TRUE;
 if not tblTo.active then
    tblTo.active:= TRUE;
  a:= tblFrom.FieldCount;
  b:= tblTo.fieldcount;

  s:= tblFrom.tablename;
  s:= tblTo.tablename;

  if ((a <> 0) and (b<>0))  then
  begin {2}
   if not tblTo.Active then
      tblTo.active:= TRUE;
 //  tblTo.locktable(ltwritelock);
   tblTo.insert;

	with tblFrom do
   begin   {3}
      for i:=0 to tblFrom.fieldcount -1 do
      begin {4}
        for j:=0 to tblTo.fieldcount -1 do
         begin {5}
          f:= fields[i].fieldname;
          t:= tblTo.fields[j].fieldname;
          if fields[i].fieldname = tblTo.fields[j].fieldname then
        	   begin  {6}
               if Fields[i].DataType <> ftAutoInc then
               begin
                  t:= tblTo.fields[j].fieldname;
                  f:= fields[i].fieldname;
                  
                  tblTo.Fields[j].value := fields[i].value;
  //                a:=tblTo.Fields[j].value;
   //               b:= fields[i].value;
                  break;
               end
               else
                begin
                   sx:=tblFrom.Fields[i].fieldname;
       //            y:=tblFrom.fields[i].value;
                end;
            end ; {6}
      end; {5}
   end; {4}
   if tblTo.State = dsInsert then
     tblTo.post;
 //  tblTo.unlocktable(ltwritelock);
   end;  {3}
   end {2}
   else
     showmessage('xatools:xaCopyRecord:Tables Have Different Field Count Values: '+intToStr(a)+ ',' +intToStr(b));
end;   {1}

procedure xaUpdateRecord(var tblFrom,tblTo:ttable;strIndex:string;intRecord:integer);
var  i,j: integer;
   f,t:string;
begin
   if not tblTo.Active then
      tblTo.active:= TRUE;

 //  tblTo.locktable(ltwritelock);

   tblTo.indexname:=strIndex;
 //  if strIndex <> '' then        //3/25/2003
      tblTo.findkey([intRecord]);

   tblTo.edit;
   with tblFrom do
   begin   {3}
     for i:=0 to tblFrom.fieldcount -1 do
      begin {4}
        for j:=0 to tblTo.fieldcount -1 do
         begin {5}
          f:= fields[i].fieldname;
          t:= tblTo.fields[j].fieldname;
          if fields[i].fieldname = tblTo.fields[j].fieldname then
        	   begin  {6}
               if Fields[i].DataType <> ftAutoInc then
               begin
                  t:= tblTo.fields[j].fieldname;
                  f:= fields[i].fieldname;
                  tblTo.Fields[j].value := fields[i].value;
                  break;
               end;
            end ; {6}
      end; {5}
   end; {4}
   end; {3}

   tblTo.post;
//   tblTo.unlocktable(ltwritelock);
end;
(*
procedure xa_AdjustGrid(var Grid:TStringAlignGrid);overload;
var
   iTotalWidth:integer;
   iAdjustBy:integer;
   iAdjustLastColumnBy:integer;
   i:integer;
   iLastVisible:integer;
   iExtra:integer;
   iTotal:integer;
   iVisibleColCount:integer;
const
   iScrollBarWitdth:integer=20;
   iIndicatorWitdth:integer=13;
begin  {1}


   if Grid.ColCount > 0 then
   begin {2}
      iTotalWidth:=0;
      iExtra:=0;

      {   if goVertLine in Grid.Options then
 }
//      begin{3}
         {
         if dgIndicator in Grid.Options then
            iExtra:= iExtra + goGridLineWidth;
         }
//         iExtra := iExtra + (Grid.ColCount * Grid.GridLineWidth);
//      end; {3}

      {
      if dgIndicator in Grid.Options then
         iExtra:= iExtra + iIndicatorWitdth;
      }
      iVisibleColCount:= 0;   // initialized the visible Column count

      for i:=0 to Grid.ColCount-1 do
       begin
         iExtra := iExtra + Grid.GridLineWidth; //applies to visible as well.
         if  Grid.ColWidths[i] > 0  then
         begin
    //
            inc(iVisibleColCount,1);
            iTotalWidth:=iTotalWidth+Grid.ColWidths[i];
          end

       end;

    if grid.clientwidth < (iTotalWidth - iExtra) then
      iTotal:= grid.clientWidth
    else
      iTotal:= (Grid.Clientwidth - iTotalWidth  - iExtra);

 //     iAdjustBy:= iTotal div dbGrid.Columns.Count;
 //     iAdjustLastColumnBy:= iTotal MOD dbGrid.Columns.Count;

        iAdjustBy:= iTotal div iVisibleColCount;
        iAdjustLastColumnBy:= iTotal MOD iVisibleColCount;

      for i:=0 to Grid.ColCount-1 do
       begin
         if  Grid.ColWidths[i] > 0 then
         begin
            iLastVisible:=i;
            Grid.ColWidths[i]:=Grid.ColWidths[i] + iAdjustBy;
         end;
       end;
       Grid.ColWidths[iLastVisible]:=Grid.ColWidths[iLastVisible] + iAdjustLastColumnBy;

   end;
end;
*)
procedure xa_AdjustGrid(var Grid:TStringAlignGrid);overload;
var
   iTotalWidth:integer;
   iAdjustBy:integer;
  // iAdjustLastColumnBy:integer;
   i:integer;
  // iLastVisible:integer;
   iExtra:integer;
   iTotal:integer;
   iVisibleColCount:integer;
const
   iScrollBarWitdth:integer=20;
   iIndicatorWitdth:integer=13;
begin  {1}


   if Grid.ColCount > 0 then
   begin {2}
      iTotalWidth:=0;
      iExtra:=0;

      {   if goVertLine in Grid.Options then
 }
//      begin{3}
         {
         if dgIndicator in Grid.Options then
            iExtra:= iExtra + goGridLineWidth;
         }
//         iExtra := iExtra + (Grid.ColCount * Grid.GridLineWidth);
//      end; {3}xtra + iIn
      {
      if dgIndicator in Grid.Options then
         iExtra:= iEdicatorWitdth;
      }

// only make the description and serial number columns bigger

      iVisibleColCount:= 10;   // initialized the visible Column count
      grid.colwidths[0]:=38;
      grid.colwidths[1]:=100;
      grid.colwidths[2]:=100;
      grid.colwidths[3]:=76;
      grid.colwidths[4]:=40;
      grid.colwidths[5]:=76;
      grid.colwidths[6]:=64;
      grid.colwidths[7]:=64;
      grid.colwidths[8]:=76;
      grid.colwidths[9]:=40;
      grid.colwidths[10]:=64;

      for i:=0 to iVisibleColCount do  // Grid.ColCount-1 do
       begin
         iExtra := iExtra + Grid.GridLineWidth; //applies to visible as well.
         if i>10 then
              grid.colwidths[i]:=0;
         if  Grid.ColWidths[i] > 0  then
         begin
    //
         //   inc(iVisibleColCount,1);
  //           m:= grid.colWidths[i];
            iTotalWidth:=iTotalWidth+Grid.ColWidths[i];
          end

       end;

    if grid.width < (iTotalWidth - iExtra) then
      iTotal:= grid.Width
    else
      iTotal:= (Grid.width - iTotalWidth  - iExtra);

 //     iAdjustBy:= iTotal div dbGrid.Columns.Count;
 //     iAdjustLastColumnBy:= iTotal MOD dbGrid.Columns.Count;

        iAdjustBy:= iTotal div 4;
  //      iAdjustLastColumnBy:= iTotal MOD iVisibleColCount;

        grid.colwidths[2]:= grid.colwidths[2]+(3*iAdjustBy);
        grid.colwidths[3]:= grid.colwidths[3]+iAdjustBy;
  (*    for i:=0 to Grid.ColCount-1 do
       begin
         if  Grid.ColWidths[i] > 0 then
         begin
            iLastVisible:=i;
            Grid.ColWidths[i]:=Grid.ColWidths[i] + iAdjustBy;
         end;
       end;
  *)
    //   Grid.ColWidths[iLastVisible]:=Grid.ColWidths[iLastVisible] + iAdjustLastColumnBy;

   end;
end;

procedure xa_AdjustGrid(var dbGrid:TDBGrid);overload;
var
   iTotalWidth:integer;
   iAdjustBy:integer;
   iAdjustLastColumnBy:integer;
   i:integer;
  iExtra:integer;
   iTotal:integer;
   iVisibleColCount:integer;
const
   iScrollBarWitdth:integer=20;
   iIndicatorWitdth:integer=13;
begin  {1}
   if dbGrid.Columns.Count > 0 then
   begin {2}
      iTotalWidth:=0;


      if dgColLines in dbGrid.Options then
      begin{3}
         if dgIndicator in dbGrid.Options then
            iExtra:= iExtra + 4;

         iExtra := dbGrid.Columns.Count
      end {3}
      else
         iExtra:=0;

      if dgIndicator in dbGrid.Options then
         iExtra:= iExtra + iIndicatorWitdth;

   
      iVisibleColCount:= 0;   // initialized the visible Column count
      for i:=0 to dbGrid.Columns.Count-1 do
       begin
         if  dbGrid.columns[i].visible then
           inc(iVisibleColCount,1);
         if dbGrid.columns[i].visible then    // added by nat 3/27/2002
            iTotalWidth:=iTotalWidth+dbGrid.Columns.Items[i].width;
       end;

      iTotal:= (dbGrid.Clientwidth - iTotalWidth  - iExtra);

 //     iAdjustBy:= iTotal div dbGrid.Columns.Count;
 //     iAdjustLastColumnBy:= iTotal MOD dbGrid.Columns.Count;

        iAdjustBy:= iTotal div iVisibleColCount;
        iAdjustLastColumnBy:= iTotal MOD iVisibleColCount;

      for i:=0 to dbGrid.Columns.Count-1 do
       begin
         if  dbGrid.columns[i].visible then
         begin
            dbGrid.Columns.Items[i].width:=dbGrid.Columns.Items[i].width + iAdjustBy;
         end;
       end;
       i := dbGrid.Columns.Count-1;
       dbGrid.Columns.Items[i].width:=dbGrid.Columns.Items[i].width + iAdjustLastColumnBy;

   end;
end;

function xa_RegisterApp(var clApp:TApplication; bBringToFront:boolean):boolean;

var hMutex:THandle;
   bOk: boolean;
   stPrevInstInfo :TPrevInstInfo;
begin
	hMutex:=CreateMutex(nil,True,pchar(clApp.Title));
	if GetLastError <> ERROR_ALREADY_EXISTS then
   begin
      bOk:=SetProp(clApp.Handle,pchar(clApp.Title),hMutex);
      if not bOK then
      	MessageDlg('Could not Register Application Instance.', mtInformation,[mbOk], 0);
 		result:=True;
   end
	else
   begin
   	if bBringToFront then
      begin
      	strPCopy(stPrevInstInfo.szTitle,clApp.Title);
      	stPrevInstInfo.hPrevInstWnd := 0;
			xa_ActivatePreviousInstance(stPrevInstInfo);
         clApp.Terminate;
      end;
   	result:=False;
   end;
end;

function xa_UnregisterApp(var clApp:TApplication):Boolean;
var hMutex:THandle;
begin
   hMutex:=GetProp(clApp.Handle,pchar(clApp.Title));
   removeProp(clApp.Handle,pchar(clApp.Title));
	result:=ReleaseMutex(hMutex);
end;

Function xa_ActivatePreviousInstance(stPrevInstInfo :TPrevInstInfo):boolean;
begin
   Result:=False;
	with stPrevInstInfo do
	begin
      hPrevInstWnd:=GetWindow(GetDeskTopWindow,GW_CHILD);
      while hPrevInstWnd <> 0 do
      begin
         if GetProp(hPrevInstWnd,szTitle) > 0 then
         begin
            if IsIconic(hPrevInstWnd) then
               ShowWindow(hPrevInstWnd,SW_RESTORE);
            hPrevInstWnd:=GetLastActivePopup(hPrevInstWnd);
            SetForegroundWindow(hPrevInstWnd);
			   Result:=True;
            break;
         end;
         hPrevInstWnd:=GetWindow(hPrevInstWnd,GW_HWNDNEXT);
		end;
      if Result = False then
      	MessageDLG('Could not Find Previous Instance.', mtInformation, [mbOK], 0);
   end;
end;

function xa_ReOpenQuery(var qryQuery:TQUERY):integer;
begin
	result:=xaOK;
   qryQuery.Close;
   xa_OpenQuery(qryQuery);
end;

function xa_OpenQuery(var qryQuery:TQUERY):integer;
begin
	with qryQuery do
	begin
		if not Active then
      begin
			Open;
			result:=xaOK
      end
      else
			result:=xaNone;
	end;
end;


function xa_ShowForm(InstanceClass: TComponentClass; var Reference; cParent: TComponent; eStyle:eFormStyle):integer;
var
  	Instance: TComponent;
//   LastForm:TForm;
//   LastForm:TWinControl;

begin
	result:=0;
   if TComponent(Reference) = nil then
   begin
     Instance := TComponent(InstanceClass.NewInstance);
     TComponent(Reference) := Instance;
     if cParent= nil then
     	cParent:=Application.MainForm;
     try
       Instance.Create(cParent);

     except
       TComponent(Reference) := nil;
       Instance.Free;
       raise;
     end;
   end;

   begin
		with TForm(Reference) do
   	begin
         if eStyle= fsModal then
         begin
            try


               result:=ShowModal;
 
            finally
               free;
        			TComponent(Reference) := nil;
            end
         end
         else
         begin
            try
               parent:=TwinControl(cParent);
               Align := alClient;
               BorderStyle:=bsNone;
               Show;
               result:=mrNone;
            except
               free;
            end;
         end;
		end; //with
	end;
end;

function xa_ShowFormX(frmForm: TForm; cParent: TComponent; eStyle:eFormStyle; bAssigned: Boolean): Integer;
begin
	result:=mrNone;
	with frmForm do
   begin
		if Assigned(frmLastForm) then
			if TwinControl(cParent) = TwinControl(frmLastForm.Parent) then
         begin
				// To cause Deactivate
		      SendMessage(frmLastForm.Handle, CM_DEACTIVATE, 0, 0);
//            frmLastForm.visible:=False;
         end;
      if not bAssigned then
      begin
         if eStyle= fsModal then
         begin
            try
               result:=ShowModal;
            finally
               free;
            end
         end
         else
         begin
            try
               parent:=TwinControl(cParent);
               Align := alClient;
               BorderStyle:=bsNone;
               Show;
               result:=mrNone;
            except
               free;
            end;
         end;
      end
      else
      begin
//      	frmForm.visible:=True;
         BringToFront;

//			// Needed due to not receiving Activate event
//	      SendMessage(Handle, CM_ACTIVATE, 0, 0);
      end;


      if eStyle = fsModeless then
   	   // Needed due to not receiving Activate event.  Always send to make sure
      	// that form has the focus
	      SendMessage(Handle, CM_ACTIVATE, 0, 0);


		frmLastForm := frmForm;
	end;
end;

function xa_ShowEmail(strRecipient:string): integer;
var
	rTemp: TRegistry;
	sTemp: String;
	szTemp: array[0..255] of char;
	iPos: Integer;
	strStartUp: TStartupInfo;
	strProcessInfo: TProcessInformation;
	bContinue: Boolean;
begin
	rTemp := TRegistry.Create;
	try
		rTemp.RootKey := HKEY_LOCAL_MACHINE;
		bContinue := True;

      if not rTemp.OpenKeyReadOnly('SOFTWARE\Clients\Mail') then
      begin
      	ShowMessage('No default e-mail editor assigned');
         bContinue := False;
      end
      else
      begin
      	sTemp := rTemp.ReadString('');
         rTemp.CloseKey;

         sTemp := 'SOFTWARE\Clients\Mail'
					+ '\' + sTemp
					+ '\Protocols\mailto\shell\open\command';

         if not rTemp.OpenKeyReadOnly(sTemp) then
         	bContinue := False;
      end;

      if bContinue then
      begin
      	sTemp := rTemp.ReadString('');

         iPos := Pos('%1', sTemp);
         if iPos > 0 then
         	sTemp := Copy(sTemp, 1, (iPos - 1)) + strRecipient + Copy(sTemp, (iPos + 2), (Length(sTemp) - (iPos + 1)));

         FillChar(szTemp, sizeof(szTemp), #0);		// zero init
         StrPCopy(szTemp, sTemp);

         FillChar(strStartUp, sizeof(strStartUp), 0);
         FillChar(strProcessInfo, sizeof(strProcessInfo), 0);

         if not CreateProcess(nil, szTemp, nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil,
																strStartUp, strProcessInfo) then
         	ShowMessage('Unable to start process');
      end;
	finally
		rTemp.Free;
	end;
   result:=1;
end;

function xa_ShowBrowserStr(strUrl:string): integer;
var
	szTemp: array[0..1024] of char;
begin
    try
	FillChar(szTemp, sizeof(szTemp), #0);		// zero init
        StrPCopy(szTemp, strUrl);
        result:= (xa_ShowBrowserSz(szTemp));
    except
    on E:Exception do
     begin
        result := 0;
        ShowMessage('Show Browser Error: '#13#10 + e.Message);
     end;
    end;


end;

function xa_ShowBrowserSz(szUrl:pchar): integer;
begin
  result:= 1;
  try
      //	if ShellExecute(Application.Handle, 'open', StrPCopy(szUrl, 'http://' + szUrl),
    if ShellExecute(Application.Handle, 'open', StrPCopy(szUrl,  szUrl),
   	nil, nil, SW_SHOW) <= 32 then
        begin
   	        ShowMessage('Error. No Browser Installed.');
                result:=0
        end;


  except
     on E: Exception do
     begin
        result := 0;
        ShowMessage('Cannot Open Browser: '#13#10 + e.Message);
     end;
  end;
end;

procedure xa_GetProgramInfo(var stProgramInfo:TProgramInfo;var lProgramInfo:TstringList);
const
	sPassParam = 'StringFileInfo\040904E4\';

var
	S,res     : String;
	n, Len    : Integer;
	Buf       : PChar;
	Value     : PChar;

	function Get(sParam:string):string;
	begin

		if VerQueryValue(Pointer(Buf),PChar(sPassParam+sParam),Pointer(Value),UINT(Len)) then
			result:=Value
		else
			result:='';
	end;

begin  {1}
	res := '';
	S := Application.ExeName;

	n := GetFileVersionInfoSize(PChar(S),DWORD(n));

	if n > 0 then
	begin  {2}
		Buf := AllocMem(n);
      try  {3}
			GetFileVersionInfo(PChar(S),0,n,Pointer(Buf));
         if assigned(@stProgramInfo) then
         begin {4}
            with stProgramInfo do
            begin {5}
               sFileDescription:=Get('FileDescription');
               sFileVersion:=Get('FileVersion');
               sInternalName:=Get('InternalName');
               sLegalCopyright:=Get('LegalCopyright');
               sLegalTrademarks:=Get('sLegalTrademarks');
               sOriginalFilename:=Get('sOriginalFilename');
               sProductName:=Get('sProductName');
               sProductVersion:=Get('sProductVersion');
               sComments:=Get('sComments');
            end; {5}
         end; {4}

         if Assigned(lProgramInfo) then
         begin  {6}
            with lProgramInfo do
            begin  {7}
               add('File Description'+Get('FileDescription'));
               add('File Version: '+Get('FileVersion'));
               add('Internal Name: '+Get('InternalName'));
               add('Legal Copyright: '+Get('LegalCopyright'));
               add('Legal Trademarks: '+Get('sLegalTrademarks'));
               add('Original Filename: '+Get('sOriginalFilename'));
               add('Product Name: '+Get('sProductName'));
               add('Product Version: '+Get('sProductVersion'));
               add('Comments: '+Get('sComments'));
            end;  {7}
         end; {6}
   	finally
      	FreeMem(Buf,n);
		end; {3}
	end; {2}
end; {1}

procedure xa_ResizeDBGrid(var clGrid:TDBGrid);
var iColumnWidth: integer;
	iI: integer;
begin
	iColumnWidth:=0;
   with clGrid do
   begin
		for iI:=0 to Columns.Count -2  do
   		iColumnWidth := iColumnWidth +  Columns[iI].Width;
   	if (dgColLines in clGrid.Options) then
	   	iColumnWidth := iColumnWidth + Columns.Count ;
   	if (dgIndicator in clGrid.Options) then
	   	iColumnWidth := iColumnWidth + 12 ;

   	if (ClientWidth > Columns[Columns.Count-1].Width + iColumnWidth) then
			Columns[Columns.Count-1].Width:=ClientWidth-iColumnWidth ;
   end;
end;

 function xaFindTreeViewNodeId(tvNode:TTreeNode;sText:string ): HTREEITEM;
var i:integer;
begin
   result := nil;
  for i:=0 to 10000 do
   begin
      if uppercase(sText)=uppercase(tvNode.text) then
      begin
         result := tvNode.iTemId;
      end
      else
      begin

         if tvNode.HasChildren  then
         begin
            result:=xaFindTreeViewNodeId(tvNode.GetFirstChild,sText);
            if result <> nil then
               break;
         end;
         tvNode:=tvNode.GetNextSibling;
         if not assigned(tvNode) then
            break;

      end;
   end;
end;

procedure xaSetImageIndex(var tv:TTreeView; index,SelIndex:integer;sText:string );
var i:HTREEITEM;
begin
   i:= xaFindTreeViewNodeId(tv.TopItem,sText);
      if assigned(i)then
       begin
         tv.items.GetNode(i).imageindex:=index;
         tv.items.GetNode(i).SelectedIndex:=selIndex;
       end;
end;


function IsUrlValid(const url: string): boolean;
var
  hInet: HINTERNET;
  hConnect: HINTERNET;
  infoBuffer: array [0..512] of char;
  dummy: DWORD;
  bufLen: DWORD;
  okay: LongBool;
  reply: String;
begin
  hInet := InternetOpen(PChar(application.title),
    INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY,nil,nil,0);
  hConnect := InternetOpenUrl(hInet,PChar(url),nil,0,
    INTERNET_FLAG_NO_UI,0);
  if not Assigned(hConnect) then
    //----------------------------------------------------------
    // If we couldn't open a connection then we know the url
    // is bad. The most likely reason is that the url is bad,
    // but it could be because of an unknown or badly specified
    // protocol.
    //----------------------------------------------------------
    result := false
  else
  begin
    //------------------------------
    // Create a request for the url.
    //------------------------------
    dummy := 0;
    bufLen := Length(infoBuffer);
    okay := HttpQueryInfo(hConnect,HTTP_QUERY_STATUS_CODE,
      @infoBuffer[0],bufLen,dummy);
    if not okay then
      // Probably working offline, or no internet connection.
      result := False
    else
    begin
      reply := infoBuffer;
      if reply = '200' then
        // File exists, all ok.
        result := True
      else if reply = '401' then
        // Not authorised. Assume page exists,
        // but we can't check it.
        result := True
      else if reply = '404' then
        // No such file.
        result := False
      else if reply = '500' then
        // Internal server error.
        result := False
      else
        // Shouldn't get here! It means there is
        // a status code left unhandled.
        result := False;
    end;
    InternetCloseHandle(hConnect);
  end;
  InternetCloseHandle(hInet);
end;


function xaGetInetFile(const fileURL, FileName: String): boolean;
 const
   BufferSize = 1024;
 var
   hSession, hURL: HInternet;
   Buffer: array[1..BufferSize] of Byte;
   BufferLen: DWORD;
   f: File;
   sAppName: string;
 begin
  result := false;
  sAppName := ExtractFileName(Application.ExeName) ;
  hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;
  try
   hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0, INTERNET_FLAG_RELOAD, 0) ;

	if Assigned(  hURL) then
	begin
   try
     FillChar(Buffer, SizeOf(Buffer), 0);
    AssignFile(f, FileName) ;
    Rewrite(f,1) ;
    repeat
     InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) ;
     BlockWrite(f, Buffer, BufferLen)
    until BufferLen = 0;
    CloseFile(f) ;
    result := True;
   finally
    InternetCloseHandle(hURL)
   end
	end
  finally
   InternetCloseHandle(hSession)
  end
end;
end.

