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
 //Загружаем "скрытый" курсор
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
  0:Txt:='Инициализация игры';
  1:Txt:='Добавляем шрифты в систему';
  2:Txt:='Сброс значений';
  3:Txt:='Инициализация движка';
  4:Txt:='Создание шрифтов';
  5:Txt:='Инициализация таймеров';
  6:Txt:='Конструирование кнопок';
  7:Txt:='Инициализация графики и звука';
  8:Txt:='Создание фигур';
  9:Txt:='Установка областей';
  10:Txt:='Инициализация бонусов';
  11:Txt:='Создание текстовых панелей';
  12:Txt:='Создание подсказок';
  13:Txt:='Очистка поля';
  14:Txt:='Флаг о завершении инициализации';
  15:Txt:='Активация таймеров';
  16:Txt:='Завершение загрузки';
  17:Txt:='Загрузка графики';
  18:Txt:='Загрузка звука';
  19:Txt:='Загрузка статистики и параметров';
  20:Txt:='Загрузка сохраненной игры';
 end;   }
 case LoadState of
  0:Txt:='Только начали';
  1:Txt:='Знакомимся с вашей ОС';
  2:Txt:='Очищаем место для игры';
  3:Txt:='Строим сетку';
  4:Txt:='Рисуем надписи';
  6:Txt:='Загрузка в самом разгаре';
  7:Txt:='Вкючаем звук и загружаем картинки';
  8:Txt:='Разробатываем фигуры';
  9:Txt:='Убираемся за собой';
  10:Txt:='Создаем разные бонусы';
  11:Txt:='Обрабатываем мелочи';
  12:Txt:='Делаем вам подсказки';
  13:Txt:='Очищаем поле от лишних фигур';
  14:Txt:='Почти закончили';
  15:Txt:='Снова мелочи';
  16:Txt:='Ещё чуть-чуть';
  17:Txt:='Рисуем картины';
  18:Txt:='Закидываем звуки';
  19:Txt:='Ищем старую игру';
  20:Txt:='Загружаем старую игру';
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
