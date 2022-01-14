unit rb;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, lsTableRepair, FileCtrl;

type
  TForm1 = class(TForm)
    lsTableRepair1: TlsTableRepair;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    ProgressBar3: TProgressBar;
    ProgressBar4: TProgressBar;
    ProgressBar5: TProgressBar;
    Button1: TButton;
    FileListBox1: TFileListBox;
    DriveComboBox1: TDriveComboBox;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
     if lsTableRepair1.Verify <> False then
        lsTableRepair1.rebuild;
    showmessage('done');

end;

end.
