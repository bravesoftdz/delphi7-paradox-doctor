unit Globals;

interface
uses bdeutil, jclcounter;

var
  BDEUtil: TBDEUtil;
  sActiveTableName: string;
  sMasterDbName: string;
  sActiveDbName:string;
  sMasterPath: String;
  sDoctorDb: String ;

  Stopwatch: TJclCounter;
  function TimerStart() : boolean;
  function TimerStop() : string;
  function TimerElapsed() : string;

     
implementation
uses SysUtils;

     function TimerStart() : boolean;
     begin
      if Stopwatch = nil then
        Stopwatch:=  TJclCounter.Create();
      Stopwatch.Start;
      result := true;
     end;

     function TimerStop() : string;
     begin
     if Stopwatch <> nil then
     if Stopwatch.Counting then
     begin
        Stopwatch.Stop;
        result := FloatToStr(Stopwatch.ElapsedTime);
     end
     else
          result := '';
     end;

     function TimerElapsed() : string;
     begin
          if Stopwatch <> nil then
            result := FloatToStr(Stopwatch.ElapsedTime);
     end ;
   end.
