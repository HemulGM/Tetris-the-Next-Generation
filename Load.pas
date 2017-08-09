unit Load;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, pngextra;

type
  TFormLoading = class(TForm)
    ImageLoad: TImage;
    TimerState: TTimer;
    LabelState: TLabel;
    ButtonCancel: TPNGButton;
    procedure FormCreate(Sender: TObject);
    procedure TimerStateTimer(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLoading: TFormLoading;

implementation
 uses TheTetris;

{$R *.dfm}

procedure TFormLoading.FormCreate(Sender: TObject);
var DLL:Cardinal;
  PNG:TPNGObject;
begin
 DLL:=LoadLibrary(PChar(ProgramPath+'\Data\'+TetDll));
 //��������� "�������" ������
 Screen.Cursors[1]:=LoadCursor(DLL, 'HIDDEN');
 PNG:=TPNGObject.Create;
 PNG.LoadFromResourceName(Dll, 'LOAD');
 ImageLoad.Picture.Assign(PNG);
 FreeLibrary(Dll);
 PNG.Free;
end;

procedure TFormLoading.TimerStateTimer(Sender: TObject);
var Txt:string;
begin
 {case LoadState of
  0:Txt:='������������� ����';
  1:Txt:='��������� ������ � �������';
  2:Txt:='����� ��������';
  3:Txt:='������������� ������';
  4:Txt:='�������� �������';
  5:Txt:='������������� ��������';
  6:Txt:='��������������� ������';
  7:Txt:='������������� ������� � �����';
  8:Txt:='�������� �����';
  9:Txt:='��������� ��������';
  10:Txt:='������������� �������';
  11:Txt:='�������� ��������� �������';
  12:Txt:='�������� ���������';
  13:Txt:='������� ����';
  14:Txt:='���� � ���������� �������������';
  15:Txt:='��������� ��������';
  16:Txt:='���������� ��������';
  17:Txt:='�������� �������';
  18:Txt:='�������� �����';
  19:Txt:='�������� ���������� � ����������';
  20:Txt:='�������� ����������� ����';
 end;   }
 case LoadState of
  0:Txt:='������ ������';
  1:Txt:='���������� � ����� ��';
  2:Txt:='������� ����� ��� ����';
  3:Txt:='������ �����';
  4:Txt:='������ �������';
  6:Txt:='�������� � ����� �������';
  7:Txt:='������� ���� � ��������� ��������';
  8:Txt:='������������� ������';
  9:Txt:='��������� �� �����';
  10:Txt:='������� ������ ������';
  11:Txt:='������������ ������';
  12:Txt:='������ ��� ���������';
  13:Txt:='������� ���� �� ������ �����';
  14:Txt:='����� ���������';
  15:Txt:='����� ������';
  16:Txt:='��� ����-����';
  17:Txt:='������ �������';
  18:Txt:='���������� �����';
  19:Txt:='���� ������ ����';
  20:Txt:='��������� ������ ����';
 end;
 Txt:=Txt+'...';
 LabelState.Caption:=Txt;
 Application.ProcessMessages;
end;

procedure TFormLoading.ButtonCancelClick(Sender: TObject);
begin
 Application.Terminate;
end;

end.
