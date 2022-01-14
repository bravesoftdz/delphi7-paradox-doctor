unit AutoInc;
{ After importing existing data into a table with a unique integer first field
  I wanted to restructure it to have an ftAutoInc primary key.  This code
  achieves that using BDE calls.  The main trick is that you must import the
  values into an unkeyed table with ftInteger field, restructure first to
  establish a primary key, then restructure a second time to convert the field
  into ftAutoInc.  It only works if you restructure in separate steps.

  By request I've added code to show how you'd add extra fields to the table,
  should you need to.  What's more, at no extra cost, it will even spit out
  a key violation table if your imported key data happens not to be unique.

  This procedure assumes you've already imported data into a source table
  which is Paradox Level 5 or above and has at least three fields, the
  first being ftInteger.  The table must have no key or secondary indexes
  and it must be closed when you call.

  Here's what it does:
    • Adds a primary index
    • Converts first table field from ftInteger to ftAutoInc.
    • Between the 2nd and 3rd fields it inserts the following new fields:
          Dish       A   60     (string)
          Serves     S          (shortint/Word)
          Recipe     M   1      (memo)
    • Assigns a default value Serves=6, applied to new and existing data.

  Sorry I haven't time to write a full-blown demo project,
  but this code *does* work.  Mail me if you find it useful...

  Delphi 2.0 freeware by G.Walker, December 1996
  gw@enternet.com.au
}

INTERFACE
uses SysUtils;

procedure DemoRestructure(const DatabaseName:TFileName;
                          const TableName:TFileName);


IMPLEMENTATION
uses BDE,DB;

{ When writing to BDE the following resources are worth knowing about:
   • c:\program files\borland\common files\bde\bde32.hlp
   • c:\program files\borland\delphi 2.0\doc\bde.int
   • c:\program files\borland\delphi 2.0\source\vcl\dbtables.pas
   • c:\program files\borland\delphi 2.0\source\vcl\dbconsts.pas
   • c:\program files\borland\delphi 2.0\source\vcl\db.pas
   • c:\program files\borland\delphi 2.0\demos\db\dberrors
   • c:\program files\borland\delphi 2.0\lib\bde.dcu
   • "BDE Basics", Delphi Informant, March 1996
   • "Function mapping from the Paradox Engine to BDE",
      Borland Tech Document #2656, August 5, 1996
   • BDE 3.12 and 3.5 updates (released since Delphi 2.01)
   • PXREST.ZIP unsupported BDE sample at Borland's site, April 1996
   • BDE template program, Chapter 25, "Database Developer's Guide
     with Delphi 2.0", Ken Henderson, 1996
}


procedure AddPrimaryIndex(hDatabase:hDbiDb; const TableName,KeyViolName:TFileName);
var
  hTableCursor: hDbiCur;
  Properties:   CURProps;
  TableDesc:    CRTblDesc;     // see bde32.hlp/bde.int regarding these types
  IndexOp:      CROpType;
  IndexDesc:    IDXDesc;
  szKeyViol:    DbiName;
begin
    // Open the table, returning its cursor handle.
    Check(DbiOpenTable(hDatabase,
                       PChar(TableName),
                       szParadox,
                       nil,nil,0,                 // no result index required
                       dbiReadOnly,dbiOpenShared,
                       xltField,           // use logical field types (normal)
                       False,nil,
                     hTableCursor));  // result
    // Use this handle to get property information about the table.
    Check(DbiGetCursorProps(hTableCursor,Properties));  // see CURProps in bde32.hlp
    // Fill out a blank table descriptor specifying the required index change.
    FillChar(TableDesc,sizeof(CRTblDesc),#0);
    with TableDesc do
      begin
        StrCopy(szTblName,Properties.szName);   // source table name
        StrCopy(szTblType,szParadox);           // I've found this is reqd
        // Write a TableDesc which adds a primary index...
        FillChar(IndexDesc,sizeof(IDXDesc),#0);
        iIdxCount := 1;    // adding one index
        IndexOp := crADD;
        pecrIdxOp := @IndexOp;
        with IndexDesc do
          begin
            StrPCopy(szName,'NameNo');
            bPrimary := True;
            bUnique := True;
            bMaintained := True;
            iFldsInKey := 1;   // primary idx has one field (not composite)
            aiKeyFld[0] := 1;  // and it's the first field
          end;
        TableDesc.pIdxDesc := @IndexDesc;
      end;
    Check(DbiCloseCursor(hTableCursor));  // must close prior to restructure
    // Now we're ready.
    Check(DbiDoRestructure(hDatabase,
                           1, // number of TableDesc records
                              // (BDE currently supports only one)
                           @TableDesc,
                           nil,     // SaveAs destination
                           StrPCopy(szKeyViol,KeyViolName), // nil if not reqd
                           nil,   // problem table (see DbiRegisterCallback)
                           False));
    // Note: Even if an exception occurs the hTableCursor resource isn't leaked
    //      because DbiCloseDatabase releases associated table cursors.
end;

//-----------------------------------------------------------------------
// For an alternative field addressing scheme see Delphi example in bde32.hlp
// for DbiGetFieldDescs function.
type
  FLDDescs = array [1..100] of FLDDesc;
  PFLDDescs = ^FLDDescs;
  CROpTypes = array [1..100] of CROpType;
  PCROpTypes = ^CROpTypes;

procedure ReviseFields(hDatabase:hDbiDb; TableName:TFileName);
var
  hTableCursor:  hDbiCur;
  Properties:    CURProps;
  FieldDescs:    PFLDDescs;
  FieldOps:      PCROpTypes;
  TableDesc:     CRTblDesc;
  NewFieldCount: integer;
  i:             integer;
  ValidityDesc:  VCHKDesc;
  ValidityOp:    CROpType;
  DefaultServes: Word;
begin
    Check(DbiOpenTable(hDatabase,PChar(TableName),szParadox,
                       nil,nil,0,dbiReadOnly,dbiOpenShared,xltField,False,nil,
                     hTableCursor));
    Check(DbiGetCursorProps(hTableCursor,Properties));
    // To fetch the field information we must first have somewhere to put it.
    NewFieldCount := Properties.iFields + 3;  // we're adding 3 extra fields
    GetMem(FieldDescs,NewFieldCount*sizeof(FLDDesc));  // descriptors
    GetMem(FieldOps,NewFieldCount*sizeof(CROpType));   // operators
    try
      // Fetch the existing field definitions.
      Check(DbiGetFieldDescs(hTableCursor,@FieldDescs[1]));
      // Modify the first field definition to be autoincrement.
      FieldOps^[1] := crMODIFY;         // the first is modified
      with FieldDescs^[1] do
        begin
          iFldType := fldINT32;
          iSubType := fldstAUTOINC;
          // Had we nominated xltNone (physical) field types then we would
          // probably replace the above with:  iFldType := fldPDXAUTOINC;
        end;
      // Field #2 is unchanged.
      FieldOps^[2] := crNOOP;
      // Fields #3..#N are pushed right to occupy positions #6..#N+3.
      Move(FieldDescs^[3],FieldDescs^[6],(Properties.iFields-2)*sizeof(FLDDesc));
      for i := 6 to NewFieldCount do
        begin
          FieldOps^[i] := crCOPY;        // These destination fields are copies
          FieldDescs^[i].iFldNum := i-3; // of the nominated source fields
        end;
      // In between are the new fields.
      for i := 3 to 5 do
        begin
          FieldOps^[i] := crADD;    // this field is new
          FillChar(FieldDescs^[i],sizeof(FLDDesc),#0);
          with FieldDescs^[i] do
            begin
              iFldNum := i;
              case i of
                3: begin
                     StrCopy(szName,'Dish');
                     iFldType := fldZSTRING;
                     iUnits1 := 60;   // number of characters
                   end;
                4: begin
                     StrCopy(szName,'Serves');
                     iFldType := fldINT16;
                     // For fldFLOAT, iUnits1 := ... (precision?)
                     //               iUnits2 := ... (decimal places?)
                   end;
                5: begin
                     StrCopy(szName,'Recipe');
                     iFldType := fldBLOB;
                     iSubType := fldstMEMO;
                     iUnits1 := 1;  // size, 1..240
                      // Memo text beyond the above will be stored in *.MB
                      // Use small value if many have empty memos.
                      // Larger value is more efficient if text can generally
                      // fit within the size nominated, as lookup is avoided.
                   end;
              end;
            end;
        end;
      // That's all for the field modifications (FieldOps & FieldDescs).
      // Default field values are (strangely) given in the validity check
      // structures.  We provide one of those to implement a Serves default.
      FillChar(ValidityDesc,sizeof(VCHKDesc),#0);
      ValidityOp := crADD;    // adding a new "validity check" descriptor
      with ValidityDesc do
        begin
          iFldNum := 4;     // destination field number
          // bRequired := True;   (this is how you'd make a field required)
          bHasDefVal := True;
          // Validity check properties are all of generic DBIVCHK type,
          // which you can't cast to.  Instead you must carefully Move,
          // ensuring source size matches size of field's logical iFldType.
          DefaultServes := 6;
          Move(DefaultServes,aDefVal,sizeof(Word));
        end;
      // Fill out a table descriptor, referring to the structures we've made.
      FillChar(TableDesc,sizeof(CRTblDesc),#0);
      with TableDesc do
        begin
          StrCopy(szTblName,Properties.szName);
          StrCopy(szTblType,szParadox);
         // bPack := True;  (you can pack it when finished if you like)
          // field structure...
          iFldCount := NewFieldCount;
          pecrFldOp := @FieldOps^[1];
          pfldDesc := @FieldDescs^[1];
          // validity check (default value)...
          iValChkCount := 1;
          pecrValChkOp := @ValidityOp;
          pvchkDesc := @ValidityDesc;
        end;
      Check(DbiCloseCursor(hTableCursor));
      // If you didn't want the default value to apply to existing data
      // you'd probably have to use DbiRegisterCallback.  (I guess.)
      Check(DbiDoRestructure(hDatabase,1,@TableDesc,nil,nil,
                             nil,      // << add Problem table here if required
                             False));
    finally
      FreeMem(FieldOps);
      FreeMem(FieldDescs);
    end;
end;

//-----------------------------------------------------------------------

procedure DemoRestructure(const DatabaseName:TFileName;
                          const TableName:TFileName);
var
  hDatabase:    hDbiDb;
  WorkingDir:   DbiPath;
  KeyViolName:  TFileName;
begin
  // Open a database session with exclusive read/write access.
  Check(DbiOpenDatabase(PChar(DatabaseName), // alias
                         nil,           // database type (Standard)
                         dbiReadWrite,  // open mode (versus read-only)
                         dbiOpenExcl,   // exclusive (versus shared)
                         nil,           // database login password
                         0,nil,nil,
                      hDatabase));
  try
    Check(DbiGetDirectory(hDatabase,False,WorkingDir));
    KeyViolName := StrPas(WorkingDir)+'V'+ExtractFileName(TableName);  // etc
  //ShowMessage(KeyViolName); (uses Dialogs)
    // ftInteger->ftAutoinc restructure is only supported on keyed tables.
    // We have to introduce the primary key first, as a separate step.
    AddPrimaryIndex(hDatabase,TableName,KeyViolName);
    // Then convert the first field to ftAutoinc and add extra fields,
    // assigning a default value to one of them.
    ReviseFields(hDatabase,TableName);
  finally
    Check(DbiCloseDatabase(hDatabase));  // closes associated cursors too
  end;
end;

end.

