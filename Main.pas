unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Controls, Dialogs, TheTetris;

type
  TFormMain = class(TForm)
    //Минимальное кол-во методов обработки событий
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
  TetrisGame:TTetrisGame;                                                       //Движок игры

implementation
 uses Load;

{$R *.dfm}

//Движок тетриса можно подключить к любому проекту в виде модуля
//Инициализировать его на любой канаве (желательно размером 440x440)
//А также необходимо обработать некоторые события, такие как движение мыши, нажатие клавиш, деактивация окна и др. (Всего 7 событий)

procedure TFormMain.FormCreate(Sender: TObject);
begin
 BorderStyle:=bsSingle;
 //Создаем и показываем окно с инф. о загрузке
 FormLoading:=TFormLoading.Create(Self);
 FormLoading.Show;
 Application.ProcessMessages;
 //Принудительно устанавливаем размер клиентской области
 ClientHeight:=460;
 ClientWidth:=440;
 //Устанавливаем его для клиентской части
 Cursor:=1;
 //Перехватываем событие дактивации окна (для паузы)
 Application.OnDeactivate:=FormDeactivate;
 //Попытка инициализировать движок
 try
  TetrisGame:=TTetrisGame.Create(Canvas);
  if not TetrisGame.Load then Application.Terminate;
 except
  Application.Terminate;
 end;
 //Уничтожаем окно с загрузкой
 FormLoading.Free;
end;

procedure TFormMain.FormDeactivate(Sender: TObject);
begin
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Если игра выклчается - выходим
 if TetrisGame.Shutdowning then Exit;
 //Если идет игра - ставим паузу
 if TetrisGame.GameState = gsPlay then TetrisGame.PauseGame;
end;

procedure TFormMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Посылаем игре сигнал о передвижении мыши
 TetrisGame.OnMouseMove(Shift, X, Y);
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin  
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Посылаем игре сигнал о нажатии клавиши
 TetrisGame.OnKeyDown(Key, Shift);
end;

procedure TFormMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin   
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Посылаем игре сигнал о клике машью
 TetrisGame.OnMouseUp(Button, Shift, X, Y);
end;

procedure TFormMain.FormPaint(Sender: TObject);
begin
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 TetrisGame.Draw;
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin  
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Посылаем игре сигнал о нажатии мыши
 TetrisGame.OnMouseDown(Button, Shift, X, Y);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Запрещаем закрывать окно без спроса игового движка
 CanClose:=False;
 //Посылаем игре сигнал о закрытии окна
 TetrisGame.Shutdown;
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
 //Если игра выклчается - выходим
 if Application.Terminated then Exit;
 //Если движок не создан - выходим
 if not Assigned(TetrisGame) then Exit;
 //Посылаем игре сигнал о нажатии и отпущенной клавише
 TetrisGame.OnKeyPress(Key);
end;

end.
