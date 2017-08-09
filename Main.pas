unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Controls, Dialogs, TheTetris;

type
  TFormMain = class(TForm)
    //����������� ���-�� ������� ��������� �������
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormPaint(Sender: TObject);
  end;

var
  FormMain:TFormMain;
  TetrisGame:TTetrisGame;                                                       //������ ����

implementation
 uses Load;

{$R *.dfm}

//������ ������� ����� ���������� � ������ ������� � ���� ������
//���������������� ��� �� ����� ������ (���������� �������� 440x440)
//� ����� ���������� ���������� ��������� �������, ����� ��� �������� ����, ������� ������, ����������� ���� � ��. (����� 7 �������)

procedure TFormMain.FormCreate(Sender: TObject);
begin
 BorderStyle:=bsSingle;
 //������� � ���������� ���� � ���. � ��������
 FormLoading:=TFormLoading.Create(Self);
 FormLoading.Show;
 Application.ProcessMessages;
 //������������� ������������� ������ ���������� �������
 ClientHeight:=460;
 ClientWidth:=440;
 //������������� ��� ��� ���������� �����
 Cursor:=1;
 //������������� ������� ���������� ���� (��� �����)
 Application.OnDeactivate:=FormDeactivate;
 //������� ���������������� ������
 try
  TetrisGame:=TTetrisGame.Create(Canvas);
  if not TetrisGame.Load then Application.Terminate;
 except
  Application.Terminate;
 end;
 //���������� ���� � ���������
 FormLoading.Free;
end;

procedure TFormMain.FormDeactivate(Sender: TObject);
begin
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //���� ���� ���������� - �������
 if TetrisGame.Shutdowning then Exit;
 //���� ���� ���� - ������ �����
 if TetrisGame.GameState = gsPlay then TetrisGame.PauseGame;
end;

procedure TFormMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //�������� ���� ������ � ������������ ����
 TetrisGame.OnMouseMove(Shift, X, Y);
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin  
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //�������� ���� ������ � ������� �������
 TetrisGame.OnKeyDown(Key, Shift);
end;

procedure TFormMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin   
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //�������� ���� ������ � ����� �����
 TetrisGame.OnMouseUp(Button, Shift, X, Y);
end;

procedure TFormMain.FormPaint(Sender: TObject);
begin
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 TetrisGame.Draw;
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin  
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //�������� ���� ������ � ������� ����
 TetrisGame.OnMouseDown(Button, Shift, X, Y);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //��������� ��������� ���� ��� ������ ������� ������
 CanClose:=False;
 //�������� ���� ������ � �������� ����
 TetrisGame.Shutdown;
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
 //���� ���� ���������� - �������
 if Application.Terminated then Exit;
 //���� ������ �� ������ - �������
 if not Assigned(TetrisGame) then Exit;
 //�������� ���� ������ � ������� � ���������� �������
 TetrisGame.OnKeyPress(Key);
end;

end.
