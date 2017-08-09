unit TheTetris;

////////////////////////////////////////////////////////////////////////////////
//Модуль: Тетрис - Новое поколение
//Автор: Геннадий Малинин, 2013 год
//Зависимости: Bass, pngimage
//               ____                                ____
//             /    /\                             /    /\
//            /____/  \ ____                     _/____/  \ _____
//            \    \  /     /\                 /  \    \  /     /\
//             \____\/____ /  \               /____\____\/____ /  \
//              \    \     \  /\              \    \     \     \  /
//               \____\ ____\/  \              \____\ ____\ ____\/
//                     \     \  /                    \     \  /
//                      \ ____\/                      \ ____\/
//
//   ___  ____ ___  ___  ____      ___  ____ ___  ___  ____      ___  ____ ___  ___  ____      ___  ____ ___             ___             ___  ____ ____
// /    /    /    /    /    /\   /    /    /    /    /    /\   /    /    /    /    /    /\   /    /    /    /\         /    /\         /    /    /    /\
///___ /____/____/____/____/  \ /___ /____/____/____/____/  \ /___ /____/____/____/____/  \ /___ /____/____/  \ ____  /____/  \       /____/____/____/  \
//\    \    \    \    \    \  / \    \    \    \    \    \  / \    \    \    \    \    \  / \    \    \    \  /    /\ \    \  /      /\    \    \    \  /
// \____\____\ ___\ ___\____\/   \____\____\ ___\ ___\____\/   \____\____\ ___\ ___\____\/   \____\____\____\/____/  \ \____\/___   /__\____\____\____\/
//            \    \  /\          \    \  /    /    /\                    \    \  /\          \    \  /    / \    \  /     /    /\ \    \  /    /    /\
//             \ ___\/  \          \ ___\/____/____/  \                    \ ___\/  \          \ ___\/___ /___\ ___\/     /____/  \ \____\/____/____/  \ ____
//              \    \  /\          \    \    \    \  /                     \    \  /\          \    \    \    \  /\      \    \  /\      \    \    \  /    /\
//               \ ___\/  \          \ ___\___ \____\/__  ____               \ ___\/  \          \ ___\ ___\____\/  \ ____ \____\/  \      \ ___\ ___\/___ /  \
//                \    \  /\          \    \  /    /    /    /\               \    \  /\          \    \  / \    \  /    /\ \    \  /\    /    /    / \    \  /
//                 \ ___\/  \          \ ___\/____/____/____/  \               \ ___\/  \          \ ___\/   \____\/____/  \ \____\/  \  /____/____/___\ ___\/
//                  \    \  /           \    \    \    \    \  /                \    \  /           \    \  /      \    \  /  \    \  /  \    \    \    \  /
//                   \ ___\/             \ ___\ ___\ ___\ ___\/                  \ ___\/             \ ___\/        \____\/    \____\/    \____\____\____\/
//
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Forms, pngimage, ExtCtrls,
  Controls, Vcl.Direct2D, Winapi.D2D1;

const

 GlSize = 4;                                                                    //Размерность матрицы-фигуры
 GlAmnt = GlSize * GlSize;                                                      //Кол-во элементов в фигуре
 GlAutr = 'Геннадий Малинин aka HemulGM';                                       //Автор =)
 GlCols = 15;                                                                   //Кол-во столбцов
 GlLvls = 15;                                                                   //Кол-во уровней игры
 GlRows = 23;                                                                   //Кол-во строк
 GlExes = 14;                                                                   //Кол-во последних исп. бонусов
 GlHdRw = 3;                                                                    //Кол-во скрытых строк поля
 GlVbRw = GlRows - GlHdRw;                                                      //Кол-во видимых строк
 GlFVRw = GlHdRw + 1;                                                           //Первая видимая строка
 TetDll = 'TetPic.dll';                                                         //Библиотека с графическими объектами
 SaveFN = '\Data.sav';                                                          //Файл сохранения игры
 DebgFN = '\Debug.log';                                                         //Файл ведения лога игры (Отладка)
 ScrnFN = 'Screen.bmp';                                                         //Файл битового образа снимка игры (Отладка)


type

  TBitmaps     = class;                                                         //Графические объекты (картинки)
  TBonus       = class;                                                         //Основа бонуса
  TExtButton   = class;                                                         //Графическая кнопка (не control)
  THelpObject  = class;                                                         //Подсказка
  TLineClear   = class;                                                         //Линия удаления (для отрисовки анимированного стирания)
  TSimpleBonus = class;                                                         //Простой бонус
  TSound       = class;                                                         //Звуковое сопровождение (потоки звуков, bass.dll)
  TTetrisGame  = class;                                                         //Движок игры
  TTextHint    = class;                                                         //Простая подсказка
  TTextPanel   = class;                                                         //Текстовая панель
  TTimeBonus   = class;                                                         //Временной бонус
  TRedrawing   = class;                                                         //Клаасс перерисовки
  TStatistics  = class;                                                         //Статистика
  TAppendStat  = class;                                                         //Математика статистики
  TGameKey     = class;                                                         //Игровая клавиша

  TState = (bsEmpty, bsElement, bsBonus, bsBonusTiming, bsBonusBroken);         //Состояние элемента (Пусто, Элемент фигуры, Бонус, Бонус (Таймер), Бонус (Сломан))
  TFigureItem = record                                                          //Элемент фигуры
   ID:Byte;                                                                      //Идентификатор элемента (фигуры)
   State:TState;                                                                 //Состояние
   TimeLeft:Word;                                                                //Осталось времени (для бонуса)
  end;
  TClearFigureItem = record                                                     //Удаляемый элемент
   X, Y:Extended;                                                                //Текущие координаты
   Speed:Byte;                                                                   //Скорость
   Angle:Smallint;                                                               //Угол отклонения
  end;
  TExing = record                                                               //Элемент массива выполненных бонусов
   Bonus:TBonus;                                                                 //Бонус
   Active:Boolean;                                                               //Есть ли элемент в сетке
  end;
  TElements = array[1..GlSize, 1..GlSize] of TFigureItem;                       //Матрица элементов фигуры
  TFigure = record                                                              //Одна фигура
   Allowed:Boolean;                                                              //Доступность
   Elements:TElements;                                                           //Элементы фигуры
   Name:string;                                                                  //Название
  end;
  TStatRecord = record                                                          //Запись статистики
   Gold:Cardinal;                                                                //Кол-во золота
   Score:Cardinal;                                                               //Счет
   Lines:Cardinal;                                                               //Кол-во удаленных линии
   Figure:Cardinal;                                                              //Кол-во сброшенных фигур
   Level:Byte;                                                                   //Уровень
  end;
  TStatTop = record                                                             //Запись топ - игрока
   Name:string[255];                                                             //Имя
   Score:Cardinal;                                                               //Счет
  end;
  TGameKeyInfo = record                                                         //Структура информации о клавише
   Code:Word;                                                                    //Код клавиши
   FForceDown:Word;                                                              //Время в нажатом состоянии (мс)
   Name:string;                                                                  //Название
  end;


  TArrayOfButton = array of TExtButton;                                         //Массив кнопок
  TArrayOfClears = array[1..GlRows] of TLineClear;                              //Удаляющие классы
  TArrayOfExing  = array[1..GlExes] of TExing;                                  //Список выполннеых бонусов
  TArrayOfFigure = array of TFigure;                                            //Массив имеющихся фигур
  TArrayOfPanels = array of TTextPanel;                                         //Массив текстовых панелей
  TBonuses       = array of TBonus;                                             //Список бонусов
  TBonusType     = (btForAll, btForGame, btForUser);                            //Тип доступа к бонусам
  TDrawType      = (dtNotWork, dtNone, dtElement, dtEmpty);                     //Режим рисования (Не рисуем, ожидание, рисуем, стираем)
  TFiguresL1     = array[1..GlCols] of TClearFigureItem;                        //Список удаляющихся элементов
  TFiguresL2     = array[1..GlCols] of TFigureItem;                             //Список удаляемых элементов
  TGameKeys      = array of TGameKey;                                           //Список игровых клавиш
  TButtonState   = (bsNormal, bsOver, bsDown);                                  //Состояние кнопки
  TButtonType    = (btFigure, btPicture);                                       //Тип кнопки (Фигура, рисунок)
  TGameState     = (gsNone, gsPlay, gsPause, gsStop, gsDrawFigure, gsShutdown); //Состояние игры (Нет, Идет игра, На паузе, Конец игры, Рисует фигуру, Завершение игры)
  TInfoMode      = (imInfoText, imBonuses, imTransforming);                     //Режим инф. дисплея
  TLevels        = array[1..GlLvls] of Boolean;                                 //Массив уровней
  TPoints        = array[0..255] of TPoint;                                     //Массив точек для полигона (для кнопки)
  TProcedure     = procedure of object;                                         //Процедура
  TTetArray      = array[1..GlRows, 1..GlCols] of TFigureItem;                  //Основной тип - поле
  TTypeBonus     = (tbCare, tbBad, tbGood);                                     //Вид бонуса (Нейтральный, отрицательный, положительный)

  TGameKey = class                                                              //Игровая клавиша
    class function GetGameKeyInfo(ACode, AForceDown:Word; AName:string):TGameKeyInfo;
   private                                                                      //Личные
    FContradictionEnable:Boolean;                                                //Противостоящая клавиша имеется
    FContradiction:Word;                                                         //ИД противостаящей клавиши
    FStartTime:Word;                                                             //Начальное время
    FMinTime:Word;                                                               //Минимальное время задержки таймера
    FOwner:TTetrisGame;                                                          //Владелец
    FGameKeyInfo:TGameKeyInfo;                                                   //Информация о клавише
    FTimer:TTimer;                                                               //Таймер обработки нажатия
    FAction:TProcedure;                                                          //Действие клавиши
    procedure FTimerTime(Sender:TObject);                                        //Процедура обработки нажатия клавиши
    procedure SetStartTime(Value:Word);                                          //Установка начального времени
    procedure SetMinTime(Value:Word);                                            //Установка минимального времени
    procedure SetContradiction(Value:Word);                                      //Установка противостаящей клавиши
    function GetForceDown:Byte;                                                  //Получить силу нажатия на клавишу
   public                                                                       //Общие
    property Contradiction:Word read FContradiction write SetContradiction;      //Противостощая клавиша (ИД)
    procedure Press;                                                             //Нажатие на клавишу
    procedure Release;                                                           //Опускание клавиши
    property Action:TProcedure read FAction write FAction;                       //Действие
    property GameKeyInfo:TGameKeyInfo read FGameKeyInfo write FGameKeyInfo;      //Инфо. о клавише
    property StartTime:Word read FStartTime write SetStartTime;                  //Начальное время
    property MinTime:Word read FMinTime write SetMinTime;                        //Минимальное время
    property ForceDown:Byte read GetForceDown;                                   //Сила нажатия
    constructor Create(AOwner:TTetrisGame);                                      //Конструктор
  end;

  TAppendStat = class                                                           //Математика статистики
   private                                                                      //Личные
    FOwner:TStatistics;                                                          //Владелец (Статистика)
   public                                                                       //Общие
    procedure Figure(Size:Cardinal);                                             //Увеличить кол-во сброшенных фигур
    procedure Gold(Size:Cardinal);                                               //Увеличить кол-во золота
    procedure Score(Size:Cardinal);                                              //Увеличить счет
    procedure Lines(Size:Cardinal);                                              //Увеличить кол-во удаленных линий
    procedure Level(Size:Byte);                                                  //Увеличить уровень
    property Owner:TStatistics read FOwner;                                      //Владелец
    constructor Create(AOwner:TStatistics);                                      //Конструктор
  end;

  TStatistics = class                                                           //Статистика
   private                                                                      //Личные
    FOwner:TTetrisGame;                                                          //Владелец (Тетрис)
   public                                                                       //Общие
    TheBest:array[1..10] of TStatTop;                                            //Топ-игроки
    Statistics:TStatRecord;                                                      //Данные
    Append:TAppendStat;                                                          //Увеличение значений данных
    procedure Reset;                                                             //Сбросить
    procedure Update;                                                            //Обновить
    procedure Load;                                                              //Загрузить
    procedure Save;                                                              //Сохранить
    function CheckScore(Score:Cardinal):Boolean;                                 //Проверить счет на вхождение в топ-игроков
    function InsertTheBest(Stat:TStatTop):Byte; overload;                        //Установить топ-игрока в список
    function InsertTheBest(AName:string; AScore:Cardinal):Byte; overload;        //Установить топ-игрока в список
    procedure ResetTheBest;                                                      //Сбросить записи топ-игроков
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    constructor Create(AOwner:TTetrisGame);                                      //Конструктор
  end;

  TDrawThread = class(TThread)                                                  //Дополнительный поток для выполнения отрисовки
   private                                                                      //Личные
    FOwner:TTetrisGame;                                                          //Владелец
   protected                                                                    //Защищенные
    procedure Execute; override;                                                 //Выполнение (обяз.)
   public                                                                       //Общие
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    constructor Create(AOwner:TTetrisGame; CreateSuspended:Boolean);             //Конструктор
  end;

  TExtButton = class                                                            //Графическая кнопка
   private                                                                      //Личные
    AType:TButtonType;                                                           //Тип (фигура, рисунок)
    DisablePic:TPNGObject;                                                       //Рисунок - недоступен
    DownPic:TPNGObject;                                                          //Рисунок - нажат
    FBlink:Boolean;                                                              //Мигание (только фигура)
    FButtonState:TButtonState;                                                   //Состояние
    FEnable:Boolean;                                                             //Активность
    FHeight:Integer;                                                             //Высота
    FLeft:Integer;                                                               //Слева
    FNormal:TColor;                                                              //Цвет - норм.
    FOver:TColor;                                                                //Цвет - наведен
    FOwner:TTetrisGame;                                                          //Владелец
    FPoly:TPoints;                                                               //Точки фигуры
    FRect:TRect;                                                                 //Прямоугольная область
    FRGN:HRGN;                                                                   //Регион активности
    FTop:Integer;                                                                //Сверху
    FWidth:Integer;                                                              //Ширина
    LBlink:Boolean;                                                              //Мигание (предыд.)
    NormalPic:TPNGObject;                                                        //Рисунок - норм. состояние
    OverPic:TPNGObject;                                                          //Рисунок - наведен
    PCount:Byte;                                                                 //Кол-во точек фигуры
    function CreateRegionFromBMP(Image: TBitmap; var Width, Height:Integer):HRGN;//Создать регион из BMP
    procedure SetBlink(Value:Boolean);                                           //Установить мигание
    procedure SetEnable(Value:Boolean);                                          //Установить доступность
   public                                                                       //Общие
    CTop:Integer;                                                                //Константа положения сверху
    Click:TProcedure;                                                            //Процедура клика
    Down:TColor;                                                                 //Цвет при нажатии
    Font:TFont;                                                                  //Шрифт подписи
    HintList:TStrings;                                                           //Подсказка
    Normal:TColor;                                                               //Обычный цвет
    Over:TColor;                                                                 //Цвет при наведении
    ShowHint:Boolean;                                                            //Отображать подсказку
    Text:string;                                                                 //Текст подписи
    function OnMouseUp(X, Y:Integer):Boolean;                                    //При отпускании кнопки
    procedure OnMouseDown(X, Y:Integer);                                         //При нажатии
    procedure OnMouseMove(X, Y:Integer);                                         //При передвижении
    procedure Paint;                                                             //Рисовать
    constructor Create(AOwner:TtetrisGame; APoly:TPoints; LCount:Byte; AText:string; AWidth:Integer; ALeft, ATop:Integer); overload;
    constructor Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer); overload;
    constructor Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer; NFont:TFont; APc:TProcedure); overload;
   published                                                                     //Опубликованные
    property Blink:Boolean read FBlink write SetBlink;                           //Мигание
    property ButtonState:TButtonState read FButtonState default bsNormal;        //Состояние
    property Enable:Boolean read FEnable write SetEnable default True;           //Активность
    property Bounds:TRect read FRect;                                            //Прямоугольная область
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    property RGN:HRGN read FRGN;                                                 //Регион
  end;

  TSound = class                                                                //Звуковое сопровождение
   private                                                                      //Личные
    Bitmaps:TBitmaps;                                                            //Ссылка на графические объекты
    FEnable:Boolean;                                                             //Инициализирован ли звук
    FOwner:TTetrisGame;                                                          //Владелец
    function GetVolume:Byte;                                                     //Узнать громкость
    procedure SetVolume(Value:Byte);                                             //Установить громкость всех потоков
   public                                                                       //Общие
    Music:array of Cardinal;                                                     //Массив музыкальных потоков
    Sounds:array of Cardinal;                                                    //Массив звуковых потоков
    function CreateStream(FileName:string; Channel:Boolean):Cardinal;            //Загрузить поток из файла
    function AddStream(FileName:TFileName; Channel:Boolean):Word;                //Добавить поток
    property Enable:Boolean read FEnable write FEnable default False;            //Доступен ли звук
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    property Volume:Byte read GetVolume write SetVolume;                         //Громкость всех звуков
    procedure Play(ID:Byte); overload;                                           //Проиграть звук
    procedure PlaySound(MSTREAM:Cardinal);                                       //Добавить звук в поток
    procedure PlaySound_2(MSTREAM:Cardinal);                                     //Проиграть звуковую дорожку
    procedure Stop(ID:Byte); overload;                                           //Остановить звук
    procedure Stop(MSTREAM:Cardinal); overload;                                  //Остановить звук. дорожку
    constructor Create(AOwner:TTetrisGame);                                      //Конструктор
  end;

  TBitmaps = class                                                              //Графичексие объекты
   private                                                                      //Личные
    AniID:Byte;                                                                  //Номер анимаци персонажа
    AniNum:Byte;                                                                 //Номер кадра текущей анимации персонажа
    BGStep:Byte;                                                                 //Текущий шаг смены фона
    BonusAni:Byte;                                                               //Номер кадра анимации бонуса
    BonusAniTime:Byte;                                                           //Анимация бонусных элементов
    CurNum:Byte;                                                                 //Аним. курсор
    DrawAni:Boolean;                                                             //Рисовать ли анимацию персонажа
    FLeft:Integer;                                                               //Положение рисунка режима редактирования
    FOwner:TTetrisGame;                                                          //Ссылка на владельца
    FPath:string;                                                                //Путь ресурсов
    function GetAnimate:Byte;                                                    //Текущая анимация
    procedure SetAnimate(Value:Byte);                                            //Задать анимацию
   public                                                                       //Общие
    AniBonus:array of TPNGObject;                                                //Массив анимационных обектов бонуса
    AniBonusTime:array of TPNGObject;                                            //Массив анимационных обектов бонуса с временем
    Animations:array [1..10, 1..8] of TPNGObject;                                //Анимация пероснажа
    Backgrounds:array of TBitmap;                                                //Фоновые рисунки
    BackGroundDraw:TBitmap;                                                      //Результирующий фоновый рисунок
    BackgroundOne:TBitmap;                                                       //Начальный рисунок
    BackgroundTwo:TBitmap;                                                       //Конечный рисунок
    BlackPoly:TPNGObject;                                                        //Затемнение поля
    BonusBusy:TPNGObject;                                                        //Бонус занят
    BonusExeing:TPNGObject;                                                      //Бонус выполняется
    BreakBonus:TPNGObject;                                                       //Исчезнувший бонус
    Contin:TPNGObject;                                                           //Сохранение игры
    Cost:TPNGObject;                                                             //Элемент подсказки - "Стоимость"
    Cursor:array of TPNGObject;                                                  //Курсор
    CurPen:TPNGObject;                                                           //Курсор - Карандаш
    CurDel:TPNGObject;                                                           //Курсор - Ластик
    EditInfo:TPNGObject;                                                         //Информационная маска для режима редактирования фигуры
    EditBox:TPNGObject;                                                          //Область ввода имени игрока (Статистика)
    FShade:TPNGObject;                                                           //Тень элемента фигуры
    ExedPanel:TPNGObject;                                                        //Панель исп. бонусов
    ExedPanelEx:TPNGObject;                                                      //Панель для шкалы уровня
    Figures:array of TPNGObject;                                                 //Массив рисунков фигур
    GameOver:TPNGObject;                                                         //Надпись - конец игры
    GridPoly:TPNGObject;                                                         //Сетка с затемнением
    Hint:TPNGObject;                                                             //Подсказка
    Light:TPNGObject;                                                            //Глянец 81x81
    LightField:TPNGObject;                                                       //Глянец (Поле)
    MPoly:TPNGObject;                                                            //Затенение - поле 4x21x4x21
    NextLvl:TPNGObject;                                                          //След. уровень
    Panel:TPNGObject;                                                            //Инф. панель
    Pause:TPNGObject;                                                            //Надпись - пауза
    Poly:TPNGObject;                                                             //Затенение - все поле
    Saved:TBitmap;                                                               //Сохраненный вариант поля (при рисовании)
    ScaleBG:TPNGObject;                                                          //Шкала уровня
    ShadePNG:TPNGObject;                                                         //Рисунок "тени"
    OveredBonus:TPNGObject;                                                      //Подсветка бонуса
    Start:TPNGObject;                                                            //Надпись - страт
    property Animate:Byte read GetAnimate write SetAnimate default 1;            //Текущая анимация
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    procedure LoadFigures(FArray:TArrayOfFigure; SW, SH:Byte);                   //Загрузка рисунков фигур
    procedure NextFrame;                                                         //Следующий кадр анимации
    constructor Create(Path:string; AOwner:TTetrisGame);                         //Конструктор
  end;

  TShade = class                                                                //Тень
   private                                                                      //Личные
    FOwner:TTetrisGame;                                                          //Владелец
   public                                                                       //Общие
    Ready:Boolean;                                                               //Готовность
    ShadeArray:TTetArray;                                                        //Поле
    procedure Clear;                                                             //Очистить поле
    procedure Update;                                                            //Обновить
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    constructor Create(AOwner:TTetrisGame);                                      //Конструктор
  end;

  TLineClear = class                                                            //Удаление линии
   private                                                                      //Личные
    FID:Byte;                                                                    //ИД в списке (для удаления)
    FOwner:TTetrisGame;                                                          //Владелец
    FTop:Integer;                                                                //Координата Y  (Высота)
    GravityTimer:TTimer;                                                         //Таймер "Движения"
    procedure GravityTimerTime(Sender:TObject);                                  //Обработка движения
   public                                                                       //Общие
    ElementsL1:TFiguresL1;                                                       //Координаты и направление движения
    ElementsL2:TFiguresL2;                                                       //Список элементов
    FlyTime:Word;                                                                //Время полета
    procedure Paint;                                                             //Отрисовка
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    constructor Create(ID:Byte; AOwner:TTetrisGame; Elements:TFiguresL2; ATop:Integer); //Конструктор
  end;

  TRedrawing = class                                                            //Перерисовка объектов
   private                                                                      //Личные
    FScaleSize:Word;                                                             //Размер шкалы уровня
    FScalePos:TPoint;                                                            //Позиция шкалы уровня
    FOwner:TTetrisGame;                                                          //Владелец
   public                                                                       //Общие
    procedure Background;                                                        //Рисовать фоновый рисунок
    procedure EditBox;                                                           //Рисовать поле для ввода имени игрока (Статистика)
    procedure Field(Left, Top:Integer);                                          //Рисовать поле по координатам
    procedure GameOver;                                                          //Рисовать "Конец игры"
    procedure InfoPanels;                                                        //Рисовать инф. панели
    procedure LastBonuses(Left:Integer);                                         //Рисовать посл. исп. бонусы
    procedure NextFigure(Left, Top:Integer);                                     //Рисовать след. фигуру
    procedure Save;                                                              //Рисовать "Сохранить игру"
    procedure SavedBG;                                                           //Рисовать сохраненный вариант игрового поля
    procedure Scale(Left:Integer);                                               //Рисовать шкалу уровня
    procedure Stared;                                                            //Рисовать "Нажмите старт"
    procedure Statistics;                                                        //Рисовать статистику (топ-игроков)
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    constructor Create(AOwner:TTetrisGame);                                      //Конструктор
  end;

  TTetrisGame = class                                                           //Игровой "двигатель"
   private                                                                      //Личные
    aEmpty:Byte;                                                                 //Пустая ячейка
    AlreadyShownButtons:Boolean;                                                 //Уже были показаны кнопки (при запуске)
    AnswerShut:Byte;                                                             //Переменная для ответа при завершении игры
    BonusAmountWidth:Byte;                                                       //Кол-во бонусов в ширину
    CanBeContinue:Boolean;                                                       //Игра может быть продолжена
    Confirm:Boolean;                                                             //Дан ответ или нет
    CreatedBoss:Boolean;                                                         //Создан босс
    Creating:Boolean;                                                            //Идет инициализация
    DebugEnabled:Boolean;                                                        //Отладка
    DoDrawFigure:TDrawType;                                                      //Состояние редактирования фигуры
    Drawing:Boolean;                                                             //Идет отрисовка
    FBoom:Byte;                                                                  //Сила тряски
    FButtonsHided:Boolean;                                                       //Кнопки скрыты
    FButtonsHiding:Boolean;                                                      //Кнопки скрываются
    FCanvas:TCanvas;
    FCols:Byte;                                                                  //Кол-во столбцов
    FDrawCanvas:TCanvas;                                                         //Холст для передачи
    FEditBoxActive:Boolean;                                                      //Поле для ввода имени активно (Статистика)
    FEditBoxText:string;                                                         //Текст поля для ввода (Статистика)
    FFPS:integer;                                                                //Показаталь FPS
    FGameKeyCount:Byte;                                                          //Кол-во игровых клавиш спец. обработки
    FGameState:TGameState;                                                       //Состояние игры
    FHelper:Boolean;                                                             //Бонус - "Помошник"
    FHeight:Byte;                                                                //Высота ячеек
    FieldWidth:Word;                                                             //Ширина поля
    FieldHeight:Word;                                                            //Высота поля
    FInfoMode:TInfoMode;                                                         //Режим инф. дисплея
    FirstUpGold:Boolean;                                                         //Первое пополнение золота
    FKeyIDDown:Byte;                                                             //ИД клавиши вниз
    FKeyIDLeft:Byte;                                                             //ИД клавиши влево
    FKeyIDRight:Byte;                                                            //ИД клавиши вправо
    FKeyIDRL:Byte;                                                               //ИД клавиши поворот влево
    FKeyIDRR:Byte;                                                               //ИД клавиши поворот вправо
    FKeyIDUP:Byte;                                                               //ИД клавиши вверх
    FLevel:Byte;                                                                 //Текущий уровень
    FLevels:TLevels;                                                             //Уровни
    FLines:Integer;                                                              //Собранные линии
    FPauseTutorial:Boolean;                                                      //Пауза для туториала
    FRows:Byte;                                                                  //Кол-во строк
    FShownTutScene:set of Byte;                                                  //Показанные сцены
    FSpeedRate:Smallint;                                                         //Повышение/понижение скорости
    FTimerActivate:Boolean;                                                      //Активность таймеров
    FWaitAmount:Word;                                                            //Кол-во ожиданий
    FWidth:Byte;                                                                 //Ширина ячеек
    GameKeys:TGameKeys;                                                          //Игровые клавиши
    Ghost:Boolean;                                                               //Режим "Призрачная фигура"
    IDDrawFigure:Byte;                                                           //ИД элемента фигуры
    OldIM:TInfoMode;                                                             //Перыдущий режим инф. дисплея
    SLeft:Integer;                                                               //Положение поля слева
    STop:Integer;                                                                //Положение поля справа
    TutorialImg:TPNGObject;                                                      //Страница туториала
    TutorialPos:Integer;                                                         //Позиция страницы по X
    WasGhostColl:Boolean;                                                        //Произошло столкновение "Призрака о дно"
    function GetFLevel(Index:Byte):Boolean;                                      //Пройденные уровни
    function GetLevel:Byte;                                                      //Текущий уровень
    function GetScaleLvl:Byte;                                                   //Получить значение кол-ва строк %
    function KeyIsDown(VK_KEY:Word):Boolean;                                     //Нажата ли клавиша
    procedure SetGameState(Value:TGameState);                                    //Установить состояние игры
    procedure SetLevel(Value:Byte);                                              //Установить уровень
    procedure SetLines(Value:Integer);                                           //Установить кол-во удаленных линий
    procedure SetHelper(Value:Boolean);                                          //Установить значение "Помошника"
    procedure SetIM(Value:TInfoMode);                                            //Установить режми
    procedure SetTimers(Value:Boolean);                                          //Установить активность таймеров
   public                                                                       //Общие
    ArrayOfBonuses:TBonuses;                                                     //Список бонусов
    ArrayOfBosses:TArrayOfFigure;                                                //Массив боссов
    ArrayOfButtons:TArrayOfButton;                                               //Список кнопок
    ArrayOfClears:TArrayOfClears;                                                //Список удалюящихся элементов
    ArrayOfExing:TArrayOfExing;                                                  //Список выполненных бонусов
    ArrayOfFigure:TArrayOfFigure;                                                //Массив имеющихся фигур
    ArrayOfPanels:TArrayOfPanels;                                                //Список панелей
    ArrayOfToDo:TBonuses;                                                        //Список бонусов на выполнение
    BadGameBonusCount:Word;                                                      //Кол-во пропущенных бонусов
    Bitmaps:TBitmaps;                                                            //Графические объекты
    CurFigure:TFigure;                                                           //Текущая фигура
    DoBoom:Boolean;                                                              //"Тряска"

    DrawBMP:TBitmap;                                                             //Холст
    ExecutingBonus:Boolean;                                                      //Выполняется одноразовый бонус
    FigureEnable:Boolean;                                                        //Фигура идет
    FontTextAutor:TFont;                                                         //Шрифт - автор
    FontTextBonuses:TFont;                                                       //Шрифт - таймер бонусов
    FontTextButtons:TFont;                                                       //Шрифт - кнопки
    FontTextDisplay:TFont;                                                       //Шрифт - инф. текст
    FontTextGameOver:TFont;                                                      //Шрифт - конец игры (ваш счет)
    ForcedCoord:TPoint;                                                          //Принудительные координаты
    ForcedCoordinates:Boolean;                                                   //Использовать принудительное смещение поля
    FPS:Integer;                                                                 //Показатель FPS
    Gold:Cardinal;                                                               //Золото
    GoldPos:TPoint;                                                              //Позиция золота
    Hint:TTextHint;                                                              //Подсказка
    IsCreating:Boolean;                                                          //Идет создание фигуры
    IsTheBoss:Boolean;                                                           //Идет босс
    IsWait:Boolean;                                                              //Ожидание
    LeftPos:Byte;                                                                //Позиция идущей фигуры слева
    LinesAmountForLevelUp:Byte;                                                  //Количество линия для повышения уровня
    MainTet:TTetArray;                                                           //Главный массив
    MoveTet:TTetArray;                                                           //Двигающийся массив
    NeedShot:Boolean;                                                            //Сделсть снимок
    NextFigure:TFigure;                                                          //Следуюшая фигура
    NextFigureOld:TFigure;                                                       //Старая "следующая фигура"
    NextID:Integer;                                                              //ID следующей фигуры
    MarshMode:Boolean;                                                           //Режмим "Болото"
    Mouse:TPoint;                                                                //Курсор
    OldLevel:Byte;                                                               //Предыдущий уровень
    Patched:TFigureItem;                                                         //Залатанный элемент
    RectForAutor:TRect;                                                          //Область для автора т.е. меня =)
    RectForBonuses:TRect;                                                        //Поле для бонусов
    RectForBonusesMouse:TRect;                                                   //Поле активности мыши для бонусов
    RectForButtons:TRect;                                                        //Поле для кнопок
    RectForChangeMode:TRect;                                                     //Поле для изменения режима инф. дисплея
    RectForExed:TRect;                                                           //Поле для исп. бонусов
    RectForInfoText:TRect;                                                       //Поле для текста
    RectForNextFigure:TRect;                                                     //Поле для след. фигуры
    Redraw:TRedrawing;                                                           //Класс перерисовки
    Score:Cardinal;                                                              //Дисплейный счет
    Shade:TShade;                                                                //"Тень"
    ShowCursos:Boolean;                                                          //Отрисовка собственного курсора
    Shutdowning:Boolean;                                                         //Идет завершение игры
    Sound:TSound;                                                                //Звуковое сопровождение
    StartGold:Cardinal;                                                          //Стартовое золото
    StartSpeed:Word;                                                             //Стартовое значение таймера шага
    Statistics:TStatistics;                                                      //Статистика
    TimerAnalysis:TTimer;                                                        //Таймер анализирования игры
    TimerAnimateFrames:TTimer;                                                   //Таймер аимации кадров персонажа
    TimerBG:TTimer;                                                              //Таймер смены фона
    TimerBonus:TTimer;                                                           //Таймер истечения времени бонусов
    TimerBonusCtrl:TTimer;                                                       //Таймер контроля выполнения бонусов
    TimerBoom:TTimer;                                                            //Таймер обработки тряски
    TimerDraw:TTimer;                                                            //Таймер отрисовки
    TimerStep: TTimer;                                                           //Таймер шага фигуры
    TimerUpValues:TTimer;                                                        //Таймер счета
    TheardDraw:TDrawThread;                                                      //Отдельный поток для отрисовки
    ToGold:Cardinal;                                                             //Золото
    TopPos:Byte;                                                                 //Позиция идущей фигуры сверху
    ToScore:Cardinal;                                                            //Счет
    Versa:Boolean;                                                               //Обратить управление
    UserFPS:Word;                                                                //Предел кадров в сек.
    ZeroGravity:Boolean;                                                         //Невесомость
    function BuyAndExcecute(ABonus:TBonus):Integer;                              //Купить и выполнить бонус (результат - затрата, 0 - не куплен)
    function CalcBrokenBonus:Word;                                               //Анализ игрового поля
    function CheckCollision(TetArray:TTetArray; ATop:Byte; IsShade:Boolean):Boolean; overload; //Проверить измен. фигуру на столкновение на определенной высоте
    function CheckCollision(TetArray:TTetArray; ATop, ALeft:Byte; IsShade:Boolean):Boolean; overload; //Проверить измен. фигуру на столкновение в опред. коорд.
    function CheckCollision(TetArray:TTetArray; IsShade:Boolean):Boolean; overload; //Проверить измен. фигуру на столкновение на высоте фигуры
    function CheckLine:Boolean;                                                  //Проверить на заполнение верхней (скрытой) части поля
    function CheckPause:Boolean;                                                 //Проверить на пауза и на завершение игры
    function CreateBMP(FName:string):TBitmap; overload;                          //Создать BMP
    function CreateBMP(DLL:Cardinal; ID:string):TBitmap; overload;               //Создать BMP из ресурса
    function CreateBonus(var Figure:TFigure):Boolean;                            //Создать бонусы в фигуре
    function CreateFigure(Deg:Word; FigureName:string):TFigure;                  //Создание фигуры (преобразование 10 to 2)
    function DeleteFilled(Row:Byte):Byte;                                        //Удалить заполненные линии, начиная с Row
    function ElemCount(Figure:TFigure):Byte;                                     //Объем фигуры
    function GetNextBoss:TFigure;                                                //Получить следующего босса
    function GetPreviewFigure:TFigure;                                           //Получить случайную фигуру
    function GetRandomFigure:TFigure;                                            //Получить случайную фигуру
    function GetSpeed:Word;                                                      //Текущая скорость
    function GetTop:Byte;                                                        //Узнать высоту заполнения поля
    function HeightOfFigure(AFigure:TFigure):Byte;                               //Высота фигуры
    function Load:Boolean;                                                       //Выполнить загрузку игры
    function LoadGame:Boolean;                                                   //Загрузка игры
    function Max(Val1, Val2:Integer):Integer;                                    //Максимальное из двух значение
    function Min(Val1, Val2:Integer):Integer;                                    //Минимальное из двух значение
    function RotateFigure(Figure:TFigure; OnSentry:Boolean):TFigure;             //Поворот фигуры (со смещением вверх, влево)
    function SaveGame:Boolean;                                                   //Сохранить игру
    function UpGold(Value:Word):Word;                                            //Добавить золота
    function UpScore(Value:Integer):Integer;                                     //Добавить к счету
    function WidthOfFigure(AFigure:TFigure):Byte;                                //Ширина фигуры
    procedure ActuateTimers;                                                     //Активировать необходимые таймеры
    procedure AddButton(AButton:TExtButton);                                     //Добавить кнопку
    procedure AddFigure(Figure:TFigure; var Dest:TArrayOfFigure);                //Добавить фигуру в массив фигур
    procedure AddToActionList(Bonus:TBonus);                                     //Добавить бонус к списку для выполнения в свободное время
    procedure AddToExed(Bonus:TBonus);                                           //Добавить бонус в список только что исп.
    procedure AnimateDelete(ATop:Integer); overload;                             //Выполнить удаление элементов в строке ATop
    procedure AnimateDelete(ATop:Integer; Elems:TFiguresL2); overload;           //Выполнить удаление некоторых элементов на высоте ATop
    procedure Boom(Size:Byte; BTime:Word);                                       //Тряска
    procedure BoomStop;                                                          //Остановить тряску
    procedure ContinueGame;                                                      //Продолжить сохраненную игру
    procedure CreateBonuses;                                                     //Заполнить список бонусов
    procedure CreateButtons;                                                     //Заполнить список кнопок
    procedure CreateFigures;                                                     //Создать фигуры
    procedure CreateFonts;                                                       //Создание шрифтов
    procedure CreateGameKeys;                                                    //Создание игровых клавиш
    procedure CreateGraphicsAndSound;                                            //Инициализация графики и звука
    procedure CreateHints;                                                       //Создание подсказок
    procedure CreateNextBoss;                                                    //Следующая фигура - босс
    procedure CreateNextFigure;                                                  //Создать следующую фигуру
    procedure CreatePanels;                                                      //Заполнить список панелей
    procedure CreateRectAreas;                                                   //Создание областей реагирования
    procedure CreateTimers;                                                      //Создание таймеров
    procedure ChangeBackground(ALevel:Byte);                                     //Сменить фон
    procedure ClearAll;                                                          //Очистить все поля
    procedure ClrChng(var Chng:TTetArray);                                       //Очистить изм. массив
    procedure DeactivateAllBonuses;                                              //Деактивировать все бонусы
    procedure DecGold(Cost:Word);                                                //Снять золото
    procedure DeleteSaved;                                                       //Удалить сохр. игру
    procedure Draw;                                                              //Отрисовка на холсте
    procedure DrawBonuses;                                                       //Рисовать бонусы
    procedure DrawingFigure;                                                     //Включить режим редактирования след. фигуры
    procedure DrawingFigureClose(State:TGameState);                              //Выключить режим ред. с выходом из игры
    procedure DrawingFigureEnd(State:TGameState);                                //Выключить режим ред.
    procedure ExecuteBonus(Bonus:TBonus);                                        //Выполнить бонус
    procedure ExecuteRandomBonus(TB:TTypeBonus);                                 //Выполнить случайный бонус
    procedure ExecutingDelete;                                                   //Проверить и удалить заполненные строки
    procedure Event(e, param1, param2:Integer);                                  //Событие
    procedure HideButtons(ShowAnimate:Boolean);                                  //Скрыть кнопки управления (Показывать анимацию скрытия)
    procedure KeyDown;                                                           //Действие клавиши вниз
    procedure KeyLeft;                                                           //Действие клавиши влево
    procedure KeyRight;                                                          //Действие клавиши вправо
    procedure KeyRotateLeft;                                                     //Действие клавиши поворот влево
    procedure KeyRotateRight;                                                    //Действие клавиши поворот вправо
    procedure KeyUp;                                                             //Действие клавиши вверх
    procedure LevelUp;                                                           //Увеличить уровень
    procedure LinesUp(Value:Integer);                                            //Увеличить кол-во удаленных линий
    procedure Merger;                                                            //Слияние осн. поля и фигуры
    procedure Move(Bottom:Byte);                                                 //Удалиние линии
    procedure MoveMouse;                                                         //Убрать мышь с поля
    procedure NeedDraw;                                                          //Принудительная отрисовка
    procedure NewFigure;                                                         //Новая фигура
    procedure NewGame;                                                           //Новая игра
    procedure Normalization(var Figure:TFigure);                                 //Нормализовать фигуру
    procedure OnBonusExecuted(Bonus:TBonus);                                     //После выполнения бонуса
    procedure OnBonusStartExecute(Bonus:TBonus);                                 //Перед выполнением
    procedure OnKeyDown(Key:Word; Shift:TShiftState);                            //При нажатии клавиши
    procedure OnKeyPress(Key:Char);                                              //При нажатии клавиши (Символ)
    procedure OnMouseDown(Button:TMouseButton; Shift:TShiftState; X, Y: Integer);//При нажатии кнопки мыши
    procedure OnMouseMove(Shift:TShiftState; X, Y: Integer);                     //При перемещении мыши
    procedure OnMouseUp(Button:TMouseButton; Shift:TShiftState; X, Y: Integer);  //При отпускинии кнопки мыши
    procedure PauseGame;                                                         //Пауза
    procedure Reset;                                                             //Сбросить значения
    procedure RotateGameFigure(OnSentry:Boolean);                                //Повернуть текущую фигуру
    procedure ShowAnimate(ID:Byte);                                              //Установить нужную анимацию
    procedure ShowButtons;                                                       //Показать кнопки
    procedure ShowFigureChanging(FStart, FEnd:TFigure);                          //Анимация изменения фигуры
    procedure ShowGoldDec(Size:Word);                                            //Показать сколько золота убыло (-Size)
    procedure ShowHideButtons;                                                   //Показать/скрыть кнопки
    procedure Shutdown;                                                          //Завершение работы программы
    procedure SpeedDown(Value:Byte);                                             //Понизить скорость
    procedure SpeedUp(Value:Byte);                                               //Повысить скорость
    procedure StepDown;                                                          //Упустить фигуру на одну линии (шаг)
    procedure StepDownBonuses;                                                   //Шаг таймеров бонусов
    procedure StepLeft;                                                          //Сместить влево
    procedure StepRight;                                                         //Сместить вправо
    procedure StopGame;                                                          //Закончить игру
    procedure StepUp;                                                            //Сместить вверх
    procedure TimerAnalysisTimer(Sender: TObject);                               //Обработка таймера для анализа игры
    procedure TimerAnimateFramesTimer(Sender: TObject);                          //Обработка анимационных кадров
    procedure TimerBGTimer(Sender: TObject);                                     //Обработка смены фона
    procedure TimerBonusCtrlTimer(Sender: TObject);                              //Обработка очереди бонусов
    procedure TimerBonusTimer(Sender: TObject);                                  //Обработка таймеров бонусов
    procedure TimerBoomTimer(Sender: TObject);                                   //Обработка тряски
    procedure TimerDownStart;                                                    //Запуск таймера движения
    procedure TimerDownStop;                                                     //Остановка таймера движения
    procedure TimerDrawTimer(Sender: TObject);                                   //Обработка отрисовки
    procedure TimerStepTimer(Sender: TObject);                                   //Обработка шага
    procedure TimerUpValuesTimer(Sender: TObject);                               //Обработка значений
    procedure Tutorial(Scene:Byte);                                              //Туториал определённой сцены
    procedure UpdateSpeed;                                                       //Обновить скорость движения фигуры
    procedure UseAllExcept(IDOfTheFigure:Byte);                                  //Исп. все фигуры кроме одной
    procedure UseAllFigures;                                                     //Исп. все фигуры
    procedure UseOnly(IDOfTheFigure:Byte);                                       //Исп. только один тип фигуры
    procedure Wait(MTime:Word);                                                  //Подождать
    procedure WaitWithoutStop(MTime:Word);                                       //Подождать без остановки игры
    procedure WriteDebug(Text:string);                                           //Запись в отладочный файл
    property ButtonsHided:Boolean read FButtonsHided;                            //Скрыты ли кнопки
    property Canvas:TCanvas read FCanvas;
    property Cols:Byte read FCols default 15;                                    //Кол-во столбцов
    property EditBoxActive:Boolean read FEditBoxActive;                          //Активность поля для ввода имени игрока (Статистика)
    property GameState:TGameState read FGameState write SetGameState;            //Состояние игры
    property Helper:Boolean read FHelper write SetHelper;                        //Помошник
    property InfoMode:TInfoMode read FInfoMode write SetIM;                      //Режим инф. дисп.
    property Level:Byte read GetLevel write SetLevel;                            //Уровень
    property Levels[Index :Byte]:Boolean read GetFLevel;                         //Список уровней
    property Lines:Integer read FLines write SetLines;                           //Собранные и удаленные линии
    property Rows:Byte read FRows default 23;                                    //Кол-во строк
    property ScaleLvl:Byte read GetScaleLvl;                                     //Шкала линий
    property SHeight:Byte read FHeight default 20;                               //Высота ячеек
    property SWidth:Byte read FWidth default 20;                                 //Ширина ячеек
    property Timers:Boolean read FTimerActivate write SetTimers;                 //Активность таймеров
    constructor Create(ACanvas:TCanvas);                                         //Конструктор
  end;

  THelpObject  = class                                                          //Подсказка (Начальный класс)
   private                                                                      //Личные
    FCaption:string;                                                             //Заголовок
    FFont:TFont;                                                                 //Шрифт
    FGraphic:TPNGObject;                                                         //Графическое исполнение подсказки
    FOwner:TTetrisGame;                                                          //Владелец
    FPosition:TPoint;                                                            //Позиция
    FRect:TRect;                                                                 //Прямоугольник (область подсказки)
    FText:string;                                                                //Текст
    FVisible:Boolean;                                                            //Видимость
    function GetCaption:string; virtual;                                         //Узнать заголовок
    function GetGraphic:TPNGObject; virtual;                                     //Узнать граф. предст.
    function GetText:string; virtual;                                            //Узнать текст
    procedure SetCaption(Value:string); virtual;                                 //Установить заголовок
    procedure SetGraphic(Value:TPNGObject); virtual;                             //Установить граф. предст.
    procedure SetText(Value:string); virtual;                                    //Установить текст
   public                                                                       //Общие
    procedure Hide; virtual;                                                     //Скрытие
    procedure Paint; virtual;                                                    //Отрисовка на холсте владелца
    procedure Show(AText, ACaption:string); overload; virtual;                   //Отображение с параметрами
    procedure Show; overload; virtual;                                           //Отображение
    property Caption:string read GetCaption write SetCaption;                    //Заголовок
    property Font:TFont read FFont write FFont;                                  //Шрифт
    property Graphic:TPNGObject read GetGraphic write SetGraphic;                //Графика
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    property Position:TPoint read FPosition write FPosition;                     //Позиция
    property RectObj:TRect read FRect write FRect;                               //Область
    property Text:string read GetText write SetText;                             //Текст
    property Visible:Boolean read FVisible write FVisible;                       //Видимость
    constructor Create(AOwner:TTetrisGame); virtual;                             //Конструктор
  end;

  TTextHint = class(THelpObject)                                                //Подсказка
   public                                                                       //Общие
    BeforeShowTime:Word;                                                         //Время перед показом
    FTimer:TTimer;                                                               //Таймер обработки скрытия и отображения
    GCost:TPNGObject;                                                            //Графика - стоимость
    HintList:TStrings;                                                           //Список строк в подсказке
    ShowFooter:Boolean;                                                          //Доп. поле подсказки
    ShowingTime:Word;                                                            //Время показа
    FooterText:string;                                                           //Текст доп. поля
    procedure Hide; override;                                                    //Скрыть
    procedure Paint; override;                                                   //Отрисовка
    procedure Show(Button:TExtButton); overload;                                 //Показ подсказки кнопки
    procedure Show(ACaption, FF:string; AText:TStrings; ATime, BTime:Cardinal); overload; //Показ подсказки
    procedure Show(ACaption, FF, AText:string; ATime, BTime:Cardinal); overload; //Показ подсказки
    procedure TimerHideTimer(Sender: TObject);                                   //Обработка скрытия и отображения
    property Timer:TTimer read FTimer;                                           //Таймер обработки скрытия и отображения
    constructor Create(AOwner:TTetrisGame); override;                            //Конструктор
  end;

  TBonus = class                                                                //Бонус
   private                                                                      //Личные
    FCost:Word;                                                                  //Стоимость
    FDesc:string;                                                                //Описание
    FEnabled:Boolean;                                                            //Доступность граф. элемента
    FGraphics:array of TPNGObject;                                               //Графика
    FID:Integer;                                                                 //Уникальный номер
    FIcon:TPNGObject;                                                            //Иконка
    FLevel:TLevels;                                                              //Уровни доступа
    FName:string;                                                                //Название
    FOver:Boolean;                                                               //Фокус мыши граф. элемента
    FOwner:TTetrisGame;                                                          //Владелец
    FPositive:Boolean;                                                           //Положительный для игрока бонус
    FRectObject:TRect;                                                           //Расположение граф. элемента
    FSounds:array of Cardinal;                                                   //Список звуков
    FType:TBonusType;                                                            //Тип доступа к бонусу
    function GetGraphics(Index:Byte):TPNGObject; virtual;                        //Получить графику
    function GetLevel(Index:Byte):Boolean; virtual;                              //Узнать возможность на уровне
    function GetSound(Index:Byte):Cardinal; virtual;                             //Получить звук
    function GetRectObj:TRect;                                                   //Область иконки - кнопки
    procedure SetCost(Value:Word); virtual;                                      //Установить стоимость
    procedure SetDesc(Value:string); virtual;                                    //Устнаовить описание
    procedure SetEnabled(Value:Boolean); virtual;                                //Установить доступность
    procedure SetGraphics(Index:Byte; Value:TPNGObject); virtual;                //Установить графику
    procedure SetLevel(Index:Byte; Value:Boolean); virtual;                      //Установить уровень
    procedure SetName(Value:string); virtual;                                    //Установить имя
    procedure SetOver(Value:Boolean); virtual;                                   //Установить фокус
    procedure SetPositive(Value:Boolean); virtual;                               //Установить свойство "Положительный/отрицательный"
    procedure SetRectObject(Value:TRect); virtual;                               //Установить область иконки - кнопки
    procedure SetSound(Index:Byte; Value:Cardinal); virtual;                     //Установить звук
   public                                                                       //Общие
    HintList:TStrings;                                                           //Подсказка
    function AddGraphic(PNG:TPNGObject):Word; virtual;                           //Добавить графику
    function AddSound(HSTREAM:Cardinal):Word; virtual;                           //Добавить звук
    procedure Paint; virtual;                                                    //Рисование иконки - кнопки
    procedure PaintGraphics; virtual;                                            //Отрисовка графического сопровождения
    procedure SetIcon(AIcon:TPNGObject); virtual;                                //Установить иконки
    procedure SetLevels(Deg:Word);                                               //Установка доступа уровней (10 -> 2 -> Array)
    property BonusType:TBonusType read FType write FType;                        //Тип доступа к бонусу
    property Cost:Word read FCost write SetCost;                                 //Стоимость
    property Desc:String read FDesc write SetDesc;                               //Описание
    property Enabled:Boolean read FEnabled write SetEnabled;                     //Доступность
    property Graphics[Index:Byte]:TPNGObject read GetGraphics write SetGraphics; //Список графики
    property Icon:TPNGObject read FIcon;                                         //Иконка
    property BID:Integer read FID write FID;                                     //Личный идентификтор
    property Levels[Index:Byte]:Boolean read GetLevel write SetLevel;            //Уровни доступа
    property Name:String read FName write SetName;                               //Название
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    property Over:Boolean read FOver write SetOver;                              //Фокус
    property Positive:Boolean read FPositive write SetPositive;                  //Свойтво "Положительны\отрицательный"
    property RectObject:TRect read GetRectObj write SetRectObject;               //Область иконки-кнопки
    property Sounds[Index:Byte]:Cardinal read GetSound write SetSound;           //Список звуков
    constructor Create(AOwner:TTetrisGame); virtual;                             //Конструктор
  end;

  TSimpleBonus = class(TBonus)                                                  //Простой бонус (одиночное действие)
   private                                                                      //Личные
    FExecuting:Boolean;                                                          //Идет выполнение
    procedure Action; virtual; abstract;                                         //Действие
   public                                                                       //Общие
    procedure Execute; virtual;                                                  //Выполнить
    procedure Paint; override;                                                   //Отрисовка кнопки - иконки
    property Executing:Boolean read FExecuting write FExecuting;                 //Идет выполнение
    constructor Create(AOwner:TTetrisGame); override;                            //Конструктор
  end;

  TTimeBonus = class(TBonus)                                                    //Временной бонус (включение свойства на время)
   private                                                                      //Личные
    FActive:Boolean;                                                             //Активность бонуса
    FLastTime:Word;                                                              //Остаточное время действия
    FTime:Word;                                                                  //Время действия
    FTimer:TTimer;                                                               //Таймер обработки временя
    procedure SetTime(Value:Word);                                               //Установить время
    procedure TimerTime(Sender:TObject); virtual;                                //Обработки временя
   public                                                                       //Общие
    procedure Activate; virtual;                                                 //Активировать
    procedure Deactivate; virtual;                                               //Деактивировать
    procedure Paint; override;                                                   //Отрисовка кнопки-иконки
    property ActionTime:Word read FTime write SetTime;                           //Время действия
    property Activated:Boolean read FActive;                                     //Активность
    property LastTime:Word read FLastTime;                                       //Остаточное время
    property Timer:TTimer read FTimer;                                            //Таймер
    constructor Create(AOwner:TTetrisGame); override;                            //Конструктор
  end;

  TTextPanel = class                                                            //Текстовая панель
   private                                                                      //Личные
    FFont:TFont;                                                                 //Шрифт
    FGraphic:TPNGObject;                                                         //Графика
    FRect:TRect;                                                                 //Область
    FOwner:TTetrisGame;                                                          //Владелец
    FText:TStrings;                                                              //Тескт
    FVisible:Boolean;                                                            //Видимость
    FWS:Boolean;                                                                 //Уже была раз показана
    function GetText(Index:Word):String;                                         //Получить строку
    function GetLeft:Integer;                                                    //Слева
    function GetTop:Integer;                                                     //Сверху
    function GetHeight:Integer;                                                  //Высота
    function GetWidth:Integer;                                                   //Ширина
    procedure SetHeight(Value:Integer);                                          //Установить параметр "высота"
    procedure SetLeft(Value:Integer);                                            //Установить параметр "слева"
    procedure SetRect(Value:TRect);                                              //Установить область
    procedure SetText(Index:Word; Value:string);                                 //Установить текст
    procedure SetTop(Value:Integer);                                             //Установить параметр "сверху"
    procedure SetWidth(Value:Integer);                                           //Установить параметр "ширина"
   public                                                                       //Общие
    procedure Hide;                                                              //Скрыть
    procedure Paint; virtual;                                                    //Отрисовка
    procedure Show;                                                              //Показать
    property ClipRect:TRect read FRect write SetRect;                            //Область
    property Font:TFont read FFont write FFont;                                  //Шрифт
    property Graphic:TPNGObject read FGraphic write FGraphic;                    //Графика
    property Height:Integer read GetHeight write SetHeight;                      //Высота
    property Left:Integer read GetLeft write SetLeft;                            //Слева
    property Owner:TTetrisGame read FOwner;                                      //Владелец
    property Strings:TStrings read FText;                                        //Текст
    property Text[Index:Word]:string read GetText write SetText;                 //Текстовый строки
    property Top:Integer read GetTop write SetTop;                               //Сверху
    property Visible:Boolean read FVisible write FVisible;                       //Видимость
    property WasShown:Boolean read FWS write FWS;                                //Уже была раз показана
    property Width:Integer read GetWidth write SetWidth;                         //Ширина
    constructor Create(AOwner:TTetrisGame); virtual;                             //Конструктор
  end;

///////////////////////////////Описание бонусов/////////////////////////////////

  TShot = class(TSimpleBonus)                                                   //Простой бонус - "Дробь"
   public                                                                       //Общие
    procedure Action; override;                                                  //Удалить случайное кол-во элементов поля
  end;

  TKnife = class(TSimpleBonus)                                                  //Простой бонус - "Нож"
   public                                                                       //Общие
    procedure Action; override;                                                  //Удалить самый верхний слой поля
  end;

  THelper = class(TTimeBonus)                                                   //Временной бонус - "Помошник"
   public                                                                       //Общие
    procedure Activate; override;                                                //Включить помошника (отражение фигуры)
    procedure Deactivate; override;                                              //Деактивация
  end;

  TPatch = class(TSimpleBonus)                                                  //Простой бонус - "Patcher"
   public                                                                       //Общие
    procedure Action; override;                                                  //Вставить элементы фигуры в одиночные "дыры"
  end;

  TVersa = class(TTimeBonus)                                                    //Временной бонус "Ой, ой"
   public                                                                       //Общие
    procedure Activate; override;                                                //Поменять местами кнопки управления
    procedure Deactivate; override;                                              //Деактивация
  end;

  TScan = class(TSimpleBonus)                                                   //Простой бонус - "Лазер"
   public                                                                       //Общий
    Drawing:Boolean;                                                             //Отрисовка
    GX, GY:Integer;                                                              //Координаты позиционирования графики
    procedure Action; override;                                                  //Удалить верхние слои столбцов
    procedure PaintGraphics; override;                                           //Отрисовка графического сопровождения
  end;

  TBoss = class(TSimpleBonus)                                                   //Простой бонус - "Босс"
   public                                                                       //Общие
    procedure Action; override;                                                  //Установить следующей фигурой босса теущего уровня
  end;

  TChangeFigure = class(TSimpleBonus)                                           //Простой бонус - "Фигура"
   public                                                                       //Общие
    procedure Action; override;                                                  //Изменить следующую фигуру
  end;

  TKick = class(TSimpleBonus)                                                   //Простой бонус - "Удар"
   public                                                                       //Общий
    Drawing:Boolean;                                                             //Отрисовка
    GX, GY:Integer;                                                              //Координаты позиционирования графики
    procedure Action; override;                                                  //Удалить верхние слои столбцов
  end;

  TEditFigure = class(TSimpleBonus)                                             //Простой бонус - "Редактор"
   public                                                                       //Общие
    procedure Action; override;                                                  //Отредактировать следующую фигуру
  end;

  TScatter = class(TSimpleBonus)                                                //Простой антибонус - "Разброс"
   public                                                                       //Общие
    procedure Action; override;                                                  //Разбросать элементы поля
  end;

  TRestart = class(TSimpleBonus)                                                //Простой бонус - "Сброс"
   public                                                                       //Общие
    procedure Action; override;                                                  //Очищает всё поле
  end;

  TFull = class(TSimpleBonus)                                                   //Простой бонус - "Заполнение"
   public                                                                       //Общие
    procedure Action; override;                                                  //Заполняет все поле элементами
  end;

  TUseOnly = class(TTimeBonus)                                                  //Временной бонус "Только фигура"
   public                                                                       //Общие
    procedure Activate; override;                                                //Использовать только один тип фигур
    procedure Deactivate; override;                                              //Деактивация
  end;

  TUseAllExcept = class(TTimeBonus)                                             //Временной бонус "Исключить тип фигур"
   public                                                                       //Общие
    procedure Activate; override;                                                //Исключить один тип фигур
    procedure Deactivate; override;                                              //Деактивация
  end;

  TGhostMode = class(TSimpleBonus)                                              //Режим "Призрачная фигура"
   public                                                                       //Общие
    procedure Action; override;                                                  //Включить/выключить режим "Призрачная фигура"
  end;

  TSally = class(TSimpleBonus)                                                  //Отрицательный бонсу "Вылазка фигуры"
   public                                                                       //Общие
    DoDrawing:Boolean;                                                           //Выполнять отрисовку
    FTop:Byte;                                                                   //Положение фигуры сверху
    FLeft:Byte;                                                                  //Положение фигуры слева
    WF:Byte;                                                                     //Ширина фигуры
    HF:Byte;                                                                     //Высота фигуры
    SallyFigure:TTetArray;                                                       //Поле для отрисовки "вылазки" фигуры
    procedure Action; override;                                                  //Выполнить
    procedure PaintGraphics; override;                                           //Метод отрисовки графического сопровождения
  end;

  TRndRotate = class(TTimeBonus)                                                //Случайный поворот фигуры
   private                                                                      //Личные
    TimerRotate:TTimer;                                                          //Таймер изменения угла движения
    TimerSpeed:TTimer;                                                           //Таймер изменения скорости
    procedure TimerSpeedTime(Sender:TObject);                                    //Обработка таймера изм. угла движ.
    procedure TimerRotateTime(Sender:TObject);                                   //Обработка таймера изм. скор.
   public                                                                       //Общие
    procedure Activate; overload; override;                                     //Включить случайный поворот фигуры
    procedure ActivateWith(Tm1, Tm2:Word);                                       //Активация с параметрами времени
    procedure Deactivate; override;                                              //Деактивация
    constructor Create(AOwner:TTetrisGame); override;                            //Конструктор
  end;

  TZeroGravity = class(TSimpleBonus)                                            //Невесомость
   public                                                                       //Общие
    procedure Action; override;                                                  //Включить/выключить гравитацию
  end;

  THail = class(TSimpleBonus)                                                   //Град
   public                                                                       //Общие
    procedure Action; override;                                                  //Выполнить действие
  end;

  TMarsh = class(TTimeBonus)                                                    //Временной бонус "Режим "Болото""
   public                                                                       //Общие
    procedure Activate; override;                                                //Включить режим "Болото"
    procedure Deactivate; override;                                              //Деактивация
  end;

  TSpeedUp = class(TTimeBonus)                                                  //Временной бонус "Повышение скорости"
   private
    FValue:SmallInt;
   public                                                                       //Общие
    procedure Activate; override;                                                //Повысить скорость
    procedure Deactivate; override;                                              //Понизить скорость
    constructor Create(AOwner:TTetrisGame); override;                            //Конструктор
  end;

//////////////////////////////////////Конец/////////////////////////////////////

const
 eventTutorial = 2;
 eventBoss = 1;
 eventBonus = 2;
 eventBonus_1 = 3;

var
 ProgramPath:string;                                                            //Каталог программы
 LoadState:Word;                                                                //Состояние игры в общем


procedure Ahtung;                                                               //Ошибка
procedure State(ID:Word);                                                       //Установить состояние игры в общем
procedure TextOutAdv(Canvas:TCanvas; Angle:Smallint; X, Y:Integer; Text:string);//Отрисовка текста под определенным углом

implementation
 uses PNGWork, WorkWithRect, IniFiles, Bass;                                    //Работа с PNG, работа с прямоуг., конфиг. файлы, Bass.dll

procedure State(ID:Word);                                                       //Состояние загрузки игры
begin
 LoadState:=ID;
 Application.ProcessMessages;
end;

procedure TextOutAdv(Canvas:TCanvas; Angle:Smallint; X, Y:Integer; Text:string);//Вывод текста под опред. углом
var logfont: TLogFont;
    haFont:HFONT;
begin
 logfont.lfheight:=Canvas.Font.Height;
 logfont.lfWidth:=0;
 logfont.lfweight:=0;
 if fsBold in Canvas.Font.Style then logfont.lfweight:=FW_BOLD;
 StrPCopy(logfont.lfFaceName, Canvas.Font.Name);
 logfont.lfItalic:=Ord(fsItalic in Canvas.Font.Style);
 logfont.lfUnderline:=Ord(fsUnderline in Canvas.Font.Style);
 logfont.lfStrikeOut:=Ord(fsStrikeOut in Canvas.Font.Style);
 LogFont.lfEscapement:=10 * Angle;
 logfont.lfcharset:=DEFAULT_CHARSET;
 logfont.lfoutprecision:=OUT_DEFAULT_PRECIS;
 logfont.lfquality:=ANTIALIASED_QUALITY;
 logfont.lfpitchandfamily:=FF_DONTCARE;
 haFont:=createfontindirect(logfont);
 Selectobject(Canvas.Handle, haFont);
 Textout(Canvas.Handle, X, Y, PChar(Text), Length(Text));
 Deleteobject(haFont);
end;

procedure Ahtung;
begin
 MessageBox(Application.Handle, PChar(
  'Произошла ошибка при инициализации игры. Возможно отсутствую некоторые файлы.'+
  #13+#10+
  #13+#10+
  #13+#10+
  'Повторная установка позволит решить данную проблему.'+
  #13+#10+
  'Ошибка: "'+SysErrorMessage(GetLastError)+'"'), 'Ошибка', MB_ICONSTOP or MB_OK);
 Application.Terminate;
end;

/////////////////////////////TGameKey///////////////////////////////////////////

constructor TGameKey.Create(AOwner:TTetrisGame);
begin
 inherited Create;
 //Установка изначальных параметров и инициализация таймера
 FContradictionEnable:=False;
 FContradiction:=0;
 FOwner:=AOwner;
 FStartTime:=100;
 FMinTime:=20;
 FGameKeyInfo.FForceDown:=0;
 FTimer:=TTimer.Create(nil);
 FTimer.OnTimer:=FTimerTime;
 //Кнопка отпущена
 Release;
end;

class function TGameKey.GetGameKeyInfo(ACode, AForceDown:Word; AName:string):TGameKeyInfo;
begin
 Result.Code:=ACode;
 Result.FForceDown:=AForceDown;
 Result.Name:=AName;
end;

procedure TGameKey.SetContradiction(Value:Word);
begin
 //Противостоящая клавиша имеется
 FContradictionEnable:=True;
 //Указываем пришедший ИД
 FContradiction:=Value;
end;

procedure TGameKey.Release;
begin
 //Если кнопка не нажата - Выходим
 //if not FTimer.Enabled then Exit;
 //Пререстаем обробатывать нажатие
 FTimer.Enabled:=False;
 FTimer.Interval:=FStartTime;
 //Сбрасываем силу нажатия
 FGameKeyInfo.FForceDown:=Abs(FStartTime - FTimer.Interval);
end;

function TGameKey.GetForceDown:Byte;
begin
 //Сила нажатия = (Время нажатия / (Изначальное время - Минимальное время) * 100)
 Result:=Round((FGameKeyInfo.FForceDown / (FStartTime - FMinTime)) * 100);
end;

procedure TGameKey.Press;
begin
 //Сразу обрабатываем нажатие
 FTimerTime(nil);
 //Запускаем таймер для дальнейшей обработки
 FTimer.Enabled:=True;
end;

procedure TGameKey.SetStartTime(Value:Word);
begin
 //Если параметр меньше 100 - устанавливаем минимальное значение (100)
 if Value < 100 then Value:=100;
 FStartTime:=Value;
 //Сверяем с уже установленным минимальным значением для его корректировки
 SetMinTime(FMinTime);
end;

procedure TGameKey.SetMinTime(Value:Word);
begin
 //Если значение больше изначального времени - минимальное будет равно изначальному (без возрастания скорости)
 if Value > FStartTime then Value:=FStartTime;
 //Если параметр меньше 20 - устанавливаем минимальное значение (20)
 if Value < 20 then Value:=20;
 FMinTime:=Value;
 //Устанавливаем таймер
 FTimer.Interval:=FStartTime;
end;

procedure TGameKey.FTimerTime(Sender:TObject);
begin
 //Если ожидание - выходим
 if FOwner.IsWait then Exit;
 //Если нажата клавиша вниз - делаем шаг вниз
 if FOwner.KeyIsDown(FGameKeyInfo.Code) then
  begin
   //Если имеется клавиша противостояния, то симулируем её отпускание
   if FContradictionEnable then FOwner.GameKeys[FContradiction].Release;
   //Если ещё есть возможность ускорить обработку - ускоряем
   if FTimer.Interval > FMinTime then FTimer.Interval:=FTimer.Interval - 10;
   //Если действие привязано - выполняем
   if Assigned(Action) then Action;
   //Устанавливаем силу нажатия (Разность между изначальным временем и текущим)
   FGameKeyInfo.FForceDown:=Abs(FStartTime - FTimer.Interval);
  end
 //В противном случае отпускаем клавишу
 else Release;
end;

///////////////////////////////TAppendStat//////////////////////////////////////

procedure TAppendStat.Figure(Size:Cardinal);
begin
 with FOwner do
  begin
   Statistics.Figure:=Statistics.Figure + Size;
  end;
end;

procedure TAppendStat.Gold(Size:Cardinal);
begin
 with FOwner do
  begin
   Statistics.Gold:=Statistics.Gold + Size;
  end;
end;

procedure TAppendStat.Score(Size:Cardinal);
begin
 with FOwner do
  begin
   Statistics.Score:=Statistics.Score + Size;
  end;
end;

procedure TAppendStat.Level(Size:Byte);
begin
 with FOwner do
  begin
   Statistics.Level:=Statistics.Level + Size;
  end;
end;

procedure TAppendStat.Lines(Size:Cardinal);
begin
 with FOwner do
  begin
   Statistics.Lines:=Statistics.Lines + Size;
  end;
end;

constructor TAppendStat.Create(AOwner:TStatistics);
begin
 FOwner:=AOwner;
end;

///////////////////////////////TStatistics//////////////////////////////////////

function TStatistics.InsertTheBest(AName:string; AScore:Cardinal):Byte;
var TMP:TStatTop;
begin
 TMP.Name:=AName;
 TMP.Score:=AScore;
 Result:=InsertTheBest(TMP);
end;

function TStatistics.InsertTheBest(Stat:TStatTop):Byte;
var i:Byte;
begin
 Result:=1;
 for i:=9 downto 1 do if Stat.Score < TheBest[i].Score then
  begin
   Result:=i + 1;
   Break;
  end;
 TheBest[10]:=Stat;
 Update;
end;

function TStatistics.CheckScore(Score:Cardinal):Boolean;
var i:Byte;
begin
 Result:=True;
 for i:=1 to 10 do if Score > TheBest[i].Score then Exit;
 Result:=False;
end;

procedure TStatistics.ResetTheBest;
var i:Byte;
begin
 for i:=1 to 10 do
  begin
   TheBest[i].Name:='';
   TheBest[i].Score:=0;
  end;
end;

procedure TStatistics.Reset;
begin
 with Statistics do
  begin
   Figure:=0;
   Gold:=0;
   Score:=0;
   Lines:=0;
   Level:=1;
  end;
end;

constructor TStatistics.Create(AOwner:TTetrisGame);
begin
 FOwner:=AOwner;
 Append:=TAppendStat.Create(Self);
 Reset;
end;

procedure TStatistics.Update;
var i, j:Byte;
    TMP:TStatTop;
begin
 //Сортируем записи по убыванию (кол-во очков)
 for i:=1 to 9 do
  for j:=i + 1 to 10 do
   begin
    if TheBest[j].Score > TheBest[i].Score then
     begin
      TMP:=TheBest[i];
      TheBest[i]:=TheBest[j];
      TheBest[j]:=TMP;
     end;
   end;
end;

procedure TStatistics.Load;
var FS:TFileStream;
    i:Byte;
begin
 if not FileExists(ProgramPath+'\Top') then Exit;
 try
  FS:=TFileStream.Create(ProgramPath+'\Top', fmOpenRead);
  for i:=1 to 10 do FS.Read(TheBest[i], SizeOf(TStatTop));
 except
  begin
   Owner.Hint.Show('Ошибочка', '', 'Не удалось|загрузить|список|топ-игроков.', 3, 3);
   Exit;
  end;
 end;
 if Assigned(FS) then FS.Free;
 Update;
end;

procedure TStatistics.Save;
var FS:TFileStream;
    i:Byte;
begin
 FileClose(FileCreate(ProgramPath+'\Top'));
 try
  FS:=TFileStream.Create(ProgramPath+'\Top', fmOpenReadWrite);
  for i:=1 to 10 do FS.Write(TheBest[i], SizeOf(TStatTop));
 except
  begin
   Owner.Hint.Show('Ошибочка', '', 'Не удалось|сохранить|некоторые|данные', 3, 0);
   Exit;
  end;
 end;
 FS.Free;
end;

/////////////////////////////////TRedrawing/////////////////////////////////////

//Отрисовка не имеет алгоритмов отрисовки

procedure TRedrawing.Scale;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   //Draw(FScalePos.X + FScaleSize - 5, FScalePos.Y - 15, NextLvl);
   //Draw(Left + ExedPanel.Width - 1, FieldHeight - 31, ExedPanelEx);
   //Рисуем панель для шкалы
   Draw(FScalePos.X - 10, FScalePos.Y - 11, ExedPanelEx);
   //Рисуем осн. линию
   Pen.Width:=4;
   Pen.Color:=$00B6FF;
   MoveTo(FScalePos.X - 2, FScalePos.Y);
   LineTo(Round(FScalePos.X + (FScaleSize / 100) * ScaleLvl), FScalePos.Y);
   //Рисуем отрезки шкалы
   Draw(FScalePos.X - 4, FScalePos.Y - 10, ScaleBG);
  end;
end;

procedure TRedrawing.Save;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(21, 94, Contin);
  end;
end;

procedure TRedrawing.SavedBG;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(0, 0, Saved);
  end;
end;

procedure TRedrawing.Stared;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(21, 94, Start);
   Font.Assign(FontTextAutor);
   Brush.Style:=bsClear;
   TextOut(5, FieldHeight - 15, '«Тетрис» © '+GlAutr+' 2013');
  end;
end;

procedure TRedrawing.LastBonuses;
var C, R:Byte;
    RectObject:TRect;
    UsedBS:set of Byte;
begin
 UsedBS:=[];
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(Left, FieldHeight - 31, ExedPanel);
   R:=0;
   if Length(ArrayOfExing) > 0 then
   //Рисуем исп. бонус
   for C:=1 to GlExes do
    begin
     if not ArrayOfExing[C].Active then Continue;
     Draw(R * 21 + Left + 3, FieldHeight - 30, ArrayOfExing[C].Bonus.Icon);
     if not (ArrayOfExing[C].Bonus.BID in UsedBS) then
      begin
       //Отображение оставшегося времени временного бонуса
       if (ArrayOfExing[C].Bonus is TTimeBonus) then
        if (ArrayOfExing[C].Bonus as TTimeBonus).Activated then
         begin
          RectObject:=Rect(R * 21 + Left + 3, FieldHeight - 30, R * 21 + Left + 3 + 21, FieldHeight - 30 + 21);
          //Рисуем иконку - "занят" и время
          StretchDraw(RectObject, Owner.Bitmaps.BonusBusy);
          Font.Assign(Owner.FontTextBonuses);
          TextOut(RectObject.Left + ((Owner.SWidth div 2) - (TextWidth(IntToStr((ArrayOfExing[C].Bonus as TTimeBonus).LastTime)) div 2)), RectObject.Top + 5, IntToStr((ArrayOfExing[C].Bonus as TTimeBonus).LastTime));
         end;
      end;
     Include(UsedBS, ArrayOfExing[C].Bonus.BID);
     Inc(R);
    end;
  end;
end;

procedure TRedrawing.GameOver;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(125, 280, GameOver);
   Font.Assign(FontTextGameOver);
   TextOut((125 + 115) - (TextWidth(IntToStr(Score)) div 2), 340, IntToStr(Score));
  end;
end;

procedure TRedrawing.InfoPanels;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   //Отрисовка режима панели
   if InfoMode in [imInfoText, imTransforming] then
    begin
     //Информационная панель
     Brush.Style:=bsClear;
     Draw(RectForInfoText.Left, RectForInfoText.Top, MPoly);
     Font.Assign(FontTextDisplay);
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 0), {ormat}'Инф. дисплей'{[Simple]});
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 1), Format('Счет: %d',    [Score]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 2), Format('Золото: %d',  [Gold]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 3), Format('Линии: %d',   [Lines]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 4), Format('Уровень: %d', [GetLevel]));
     Draw(RectForInfoText.Left, RectForInfoText.Top, Light);
    end;
   if InfoMode in [imBonuses, imTransforming] then
    begin
     //Панель бонусов
     Draw(RectForBonuses.Left, RectForBonuses.Top, MPoly);
     DrawBonuses;
     Draw(RectForBonuses.Left, RectForBonuses.Top, Light);
    end;
  end;
end;

procedure TRedrawing.EditBox;
var EBW, L:Word;
    EBH, T:Word;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   EBW:=(FCols * SWidth) - 40;
   EBH:=40;
   if Creating then Exit;
   L:=SLeft + (((FCols * SWidth) div 2) - (EBW div 2));
   T:=STop + (((FRows * SHeight) div 2) - (EBH div 2));
   Draw(SLeft, STop, BlackPoly);
   Draw(SLeft, T - 40, EditBox);
   Font.Assign(FontTextDisplay);
   Font.Color:=clWhite;
   Font.Size:=15;
   Font.Style:=[];
   TextOut(L + 5, T - 35, 'Введите ваше имя:');
   Pen.Color:=clGray;
   Pen.Width:=4;
   Brush.Color:=clWindow;
   Brush.Style:=bsSolid;
   Rectangle(L, T, L + EBW, T + EBH);
   Font.Size:=20;
   Font.Color:=clBlack;
   Brush.Style:=bsClear;
   TextOut(L + 5, T, FEditBoxText);
  end;
end;

procedure TRedrawing.Statistics;
var i:Byte;
    W, BSz:Word;

function GetPoints(Cnv:TCanvas; Sz:Word):string;
begin
 Result:='.';
 while Cnv.TextWidth(Result) < Sz do Result:=Result + '. ';
 Delete(Result, 1, 10);
 Result:='  ' + Result;
end;

begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Font.Assign(FontTextDisplay);
   W:=Cols * SWidth;

   Font.Size:=25;
   Font.Color:=clWhite;
   Font.Style:=[fsBold];
   TextOut(SLeft + W div 2 - TextWidth('Топ 10 игроков') div 2, STop + 10, 'Топ 10 игроков');

   Font.Color:=clBlack;
   Font.Size:=20;
   TextOut(SLeft + W div 2 - TextWidth('Топ 10 игроков') div 2, STop + 10, 'Топ 10 игроков');

   Font.Style:=[];
   Font.Size:=10;
   for i:=1 to 10 do
    begin
     BSz:=W - (TextWidth(IntToStr(i) + '. ' + Statistics.TheBest[i].Name) + TextWidth(IntToStr(Statistics.TheBest[i].Score)) + 10);
     TextOut(SLeft + 10, STop + i * 20 + 40, IntToStr(i) + '. ' + Statistics.TheBest[i].Name + GetPoints(Owner.Canvas, BSz));
     TextOut((SLeft + W) - (TextWidth(IntToStr(Statistics.TheBest[i].Score)) + 10), STop + i * 20 + 40, IntToStr(Statistics.TheBest[i].Score));
    end;
  end;
end;

procedure TRedrawing.Background;
begin
 try
  with Owner, Owner.Canvas, Owner.Bitmaps do
   begin
    if Creating then Exit;
    //Если "тряска" - рисуем смещенный фон
    if DoBoom then Draw(Random(FBoom) - 10, Random(FBoom) - 10, BackGroundDraw)
     //Если нет тряски - просто рисуем фон
    else Draw(-10, -10, BackGroundDraw);
   end;
 except
  MessageBox(0, 'Error', '', MB_ICONWARNING or MB_OK);
 end;
end;

procedure TRedrawing.Field;
var R, C:Byte;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   Draw(Left, Top, GridPoly);
   //Главное поле, идущая фигура, бонус ("Помошник")
   Brush.Style:=bsClear;
   Font.Assign(FontTextBonuses);
   for R:=GlFVRw to Rows do
    for C:=1 to Cols do
     begin
      //Если элемент движ. фигуры не пуст
      if MoveTet[R, C].State <> bsEmpty then
       Draw((C - 1) * SWidth + Left - 2, (R - GlFVRw) * SHeight + Top - 2, FShade);
     end;   
   for R:=GlFVRw to Rows do
    for C:=1 to Cols do
     begin    
      //Если включен помошник и он готов к работе
      if Helper and Shade.Ready then
       //Если элемент тени не пуст
       if Shade.ShadeArray[R, C].State <> bsEmpty then
        Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, ShadePNG);
      //Если элемент движ. фигуры не пуст
      if MoveTet[R, C].State <> bsEmpty then
       begin
        //Рисуем элемент фигуры
        Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, Figures[MoveTet[R, C].ID - 1]);
        //Если элемент бонусный - рисуем анимацию
        if MoveTet[R, C].State = bsBonus then Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonus[BonusAni]);
        //Если режим "Призрачная фигура" - рисуем наложение
        if Ghost then Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, OveredBonus);
        //Т.к. движ. фигура имеет приоритет, то позволяем себе пропустить дальнейшие действия
        Continue;
       end;
      //Если элемент гл. поля не пуст - рисуем элемент фигуры
      if MainTet[R, C].State <> bsEmpty then
       begin
        try
         Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, Figures[MainTet[R, C].ID - 1]);
        except
         MessageBox(0, PChar('Ошибка при отрисовке ячейки: '+IntToStr(R)+' '+IntToStr(C)), '', 0);
        end;
        //Проверить на доп. состояние
         try
          case MainTet[R, C].State of
           //Если просто бонус (без времени) - рисуем анимацию бонуса (для гарантии "не мигания")
           bsBonus: Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonus[BonusAni]);
           //Если не элементе таймер бонуса
           bsBonusTiming:
            begin
             //Рисуем графику бонуса с таймером
             Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonusTime[BonusAniTime]);
             //Остаточное время
             TextOut((C - 1) * SWidth + Left + (SWidth div 2) - (TextWidth(IntToStr(MainTet[R, C].TimeLeft)) div 2) + 1,
              (R - GlFVRw) * SHeight + Top + (SHeight div 2) - (TextHeight(IntToStr(MainTet[R, C].TimeLeft)) div 2), IntToStr(MainTet[R, C].TimeLeft));
            end;
           //Если время на бонусе истекло - рисуем графику "сломанного" бонуса
           bsBonusBroken:Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, BreakBonus);
          end;
         except
          MessageBox(0, PChar(IntToStr(R)+' '+IntToStr(C)), '', 0);
         end;
       end;  
     end;
   //Draw(Left, Top, LightField);
  end;
end;

procedure TRedrawing.NextFigure;
var R, C:Byte;
begin
 with Owner.Bitmaps, Owner, Owner.Canvas do
  begin
   if Creating then Exit;
   Draw(340, SHeight, MPoly);
   //Рисуем тень
   for R:=1 to GlSize do
    for C:=1 to GlSize do
     begin
      if NextFigure.Elements[R, C].State <> bsEmpty then
       begin
        Draw(((C - 1) * SWidth) + 340 - 2, ((R - GlSize) * SHeight) + 80 - 2, FShade);
       end;
     end;
   //Рисуем элементы
   for R:=1 to GlSize do
    for C:=1 to GlSize do
     begin
      if NextFigure.Elements[R, C].State <> bsEmpty then
       begin
        Draw(((C - 1) * SWidth) + 340, ((R - GlSize) * SHeight) + 80, Figures[NextFigure.Elements[R, C].ID - 1]);
       end;
     end;
   Draw(340, SHeight, Light);
  end;
end;

constructor TRedrawing.Create(AOwner:TTetrisGame);
begin
 FOwner:=AOwner;
end;

/////////////////////////////////TDrawThread////////////////////////////////////

procedure TDrawThread.Execute;
begin
 //Synchronize(Owner.Draw);
 Owner.Draw;
end;

constructor TDrawThread.Create(AOwner:TTetrisGame; CreateSuspended:Boolean);
begin
 inherited Create(CreateSuspended);
 FOwner:=AOwner;
end;

//////////////////////////////////TLineClear////////////////////////////////////

procedure TLineClear.Paint;
var i:Byte;
begin
 for i:=1 to GlCols do
  begin
   //Пропускаем пустые элемнты (если они есть)
   if ElementsL2[i].State = bsEmpty then Continue;
   //Рисуем падающие элементы фигур
   Owner.Canvas.Draw(Round(ElementsL1[i].X) - 2, Round(ElementsL1[i].Y) - 2, Owner.Bitmaps.FShade);
   Owner.Canvas.Draw(Round(ElementsL1[i].X), Round(ElementsL1[i].Y), Owner.Bitmaps.Figures[ElementsL2[i].ID - 1]);
   //Рисуем доп. состояние элемента
   case ElementsL2[i].State of
    bsBonus,
    bsBonusTiming: Owner.Canvas.Draw(Round(ElementsL1[i].X), Round(ElementsL1[i].Y), Owner.Bitmaps.AniBonus[Owner.Bitmaps.BonusAni]);
    bsBonusBroken: Owner.Canvas.Draw(Round(ElementsL1[i].X), Round(ElementsL1[i].Y), Owner.Bitmaps.BreakBonus);
   end;
  end;
end;

procedure TLineClear.GravityTimerTime(Sender:TObject);
var i:Byte;
    Hidden:Boolean;
begin
 //Увеличиваем скорость падения
 if GravityTimer.Interval > 5 then GravityTimer.Interval:=GravityTimer.Interval - 5;
 Hidden:=True;
 for i:=1 to GlCols do
  begin
   with ElementsL1[i] do
    begin
     X:=X + 3 * Cos((Pi / 180) * Angle);
     Y:=Y - (Speed + 10) * Sin((Pi / 180) * Angle);
     if (Angle < 90) and (Angle >= 0) then
      begin
       if Angle = 0 then Angle:=360;
       Dec(Angle, Random(3) + 3);
      end
     else
      if Angle < 270 then Inc(Angle, Random(3) + 3)
      else if Angle > 270 then Dec(Angle, Random(3) + 3);
    end;
   if Hidden then if ElementsL1[i].Y < Owner.FieldHeight + 30 then Hidden:=False;
  end;
 //Если элементы скрылись
 if Hidden then
  begin
   //Удаляем таймер
   GravityTimer.Free;
   //Удаляем удаляющиеся элементы из списка
   FreeAndNil(Owner.ArrayOfClears[FID]);
  end;
end;

constructor TLineClear.Create(ID:Byte; AOwner:TTetrisGame; Elements:TFiguresL2; ATop:Integer);
var i, Left:Byte;
begin
 inherited Create;
 //Ссылка на владельца
 FOwner:=AOwner;
 //Запоминаем свой положени в массиве элементов
 FID:=ID;
 //Узнаем высоту, на которой произошло удаление
 FTop:=ATop;
 //Время полета
 FlyTime:=5;
 //Создаем "спящий" таймер "гравитации" с изначальными значениями и обработчиком падения
 GravityTimer:=TTimer.Create(nil);
 with GravityTimer do
  begin
   Interval:=FlyTime;
   Enabled:=False;
   OnTimer:=GravityTimerTime;
  end;
 //Узнаем состояние удаленных элементов
 ElementsL2:=Elements;
 //Положение по X - равно общему смещению (хотя и ложное (небольшое) смещение заметно не будет)
 Left:=Owner.SWidth;
 //Up:=True;
 //Задаем значения падающих элементов
 for i:=1 to GlCols do
  begin
   with ElementsL1[i] do
    begin
     //Высота
     Y:=ATop;
     //Положение слева (зависит от удаляемого элемента + смещение)
     X:=((i - 1) * Owner.SWidth) + Left;
     //Случайный угол отклонения
     Angle:=Random(360);
     //Начальная скорость движения
     Speed:=Random(5) + 5;
    end;
  end;
 //Включаем "гравитацию"
 GravityTimer.Enabled:=True;
end;

///////////////////////////////////TTextPanel///////////////////////////////////

procedure TTextPanel.Show;
var s, t:Integer;
begin
 //Если нет игры - выходим
 if Owner.GameState = gsPlay then Exit;
 //Если уже видна - выходим
 if Visible then Exit;
 //Плавно смещаем панель в нужные координаты с ускорением
 //Была показана
 FWS:=True;
 //Запомним высоту
 t:=Top;
 //Зададим высоту так, чтобы панель скрылась сверху
 Top:=0 - (Owner.SHeight + Height);
 //Начинаем показывать (разрешим рисовать)
 Visible:=True;
 //Скорость падения - 0
 s:=0;
 //Пока высота меньше той, что нужно
 while Top < Owner.SHeight do
  begin
   //Увеличиваем скорость
   Inc(s);
   //Опускаем панель на текущее значение скорости
   Top:=Top + s;
   //Принудительная отрисовка
   Owner.WaitWithoutStop(2);
  end;
 //Фиксируем положение (чтоб небыло смещений)
 Top:=t;
end;

procedure TTextPanel.Hide;
var s:Integer;
begin
 //Если уже скрыта - выходим
 if not Visible then Exit;
 s:=0;
 //Плавное перемещение панели в нужные координаты с ускорением
 while (Top + Height) > 0 do
  begin
   Inc(s);
   Top:=Top - s;
   Owner.WaitWithoutStop(2);
  end;
 //Фиксируем видимость - ложь
 Visible:=False;
end;

function TTextPanel.GetText(Index:Word):String;
begin
 Result:='';
 if Index >= FText.Count then Exit;
 Result:=FText[index];
end;

procedure TTextPanel.SetText(Index:Word; Value:string);
begin
 if Index >= FText.Count then Exit;
 FText[Index]:=Value;
end;

procedure TTextPanel.Paint;
var i:Word;
begin
 if not Visible then Exit;
 with Owner.Canvas do
  begin
   //Рисуем графику
   Draw(Self.ClipRect.Left, Self.ClipRect.Top, Graphic);
   Font.Assign(Self.Font);
   //И текст
   if Strings.Count > 0 then
    for i:=0 to Strings.Count - 1 do
     begin
      TextOut(Self.ClipRect.Left + 10, Self.ClipRect.Top + (i * (Self.Font.Size + 5)), Strings[i]);
     end;
  end;
end;

constructor TTextPanel.Create;
begin
 inherited Create;
 FFont:=TFont.Create;
 FText:=TStringList.Create;
 FOwner:=AOwner;
 FWS:=False;
end;

procedure TTextPanel.SetRect(Value:TRect);
begin
 FRect:=Value;
end;

procedure TTextPanel.SetLeft(Value:Integer);
begin
 FRect.Left:=Value;
end;

procedure TTextPanel.SetTop(Value:Integer);
var T:Integer;
begin
 T:=Height;
 FRect.Top:=Value;
 FRect.Bottom:=Value + T;
end;

procedure TTextPanel.SetWidth(Value:Integer);
begin
 FRect.Right:=FRect.Left + Value;
end;

procedure TTextPanel.SetHeight(Value:Integer);
begin
 FRect.Bottom:=FRect.Top + Value;
end;

function TTextPanel.GetLeft:Integer;
begin
 Result:=FRect.Left;
end;

function TTextPanel.GetTop:Integer;
begin
 Result:=FRect.Top;
end;

function TTextPanel.GetHeight:Integer;
begin
 Result:=Abs(FRect.Bottom - FRect.Top);
end;

function TTextPanel.GetWidth:Integer;
begin
 Result:=Abs(FRect.Right - FRect.Left);
end;

///////////////////////////////////////TTextHint////////////////////////////////

procedure TTextHint.Hide;
begin
 if not Visible then Exit;
 Timer.Enabled:=False;
 Visible:=False;
end;

procedure TTextHint.Show(Button:TExtButton);
begin
 ShowFooter:=False;
 HintList.Clear;
 HintList.AddStrings(Button.HintList);
 ShowingTime:=5 * 1000;
 Text:='';
 Caption:=Button.Text;
 Visible:=True;
 Timer.Interval:=ShowingTime;
 Timer.Enabled:=True;
end;

procedure TTextHint.Show(ACaption, FF:string; AText:TStrings; ATime, BTime:Cardinal); //Показ подсказки кнопки
begin
 Timer.Enabled:=False;
 HintList.Clear;
 Visible:=False;
 //Преобразовываем время из сек. в мсек.
 ShowingTime:=ATime * 1000;
 HintList.AddStrings(AText);
 ShowFooter:=FF <> '';
 FooterText:=FF;
 Caption:=ACaption;
 //Если показ обычный
 if BTime > 0 then Timer.Interval:=BTime
 else //Если нужно срочно показать
  begin
   //Показываем срузу
   Visible:=True;
   //Запускаем таймер на скрытие
   Timer.Enabled:=False;
   Timer.Interval:=ShowingTime;
  end;
 //Запускаем таймер на отображение
 Timer.Enabled:=True;
end;

procedure TTextHint.Show(ACaption, FF, AText:string; ATime, BTime:Cardinal);
var i, l:Word;
 TMP:TStrings;
begin
 TMP:=TStringList.Create;
 TMP.Clear;
 //Разделяем текст на строки (разделитель "|")
 AText:=AText + '|';
 l:=1;
 for i:=1 to Length(AText) do
  begin
   if (AText[i] = '|') or (i = Length(AText)) then
    begin
     TMP.Add(Copy(AText, l, (i - l)));
     l:=i + 1;
    end;
  end;
 Show(ACaption, FF, TMP, ATime, BTime);
 TMP.Free;
end;

procedure TTextHint.TimerHideTimer(Sender: TObject);
begin
 if Visible then Timer.Enabled:=False;
 Timer.Interval:=ShowingTime;
 Visible:=not Visible;
end;

constructor TTextHint.Create;
begin
 inherited;
 BeforeShowTime:=2 * 1000;
 FTimer:=TTimer.Create(nil);
 with FTimer do
  begin
   OnTimer:=TimerHideTimer;
   Enabled:=False;
   Interval:=2000;
   Name:='FTimer';
  end;
 HintList:=TStringList.Create;
end;

procedure TTextHint.Paint;
const Width = 128;
const Height = 96;
var i:Byte;
begin
 if not Visible then Exit;
 with Owner.Canvas do
  begin
   Font.Assign(Self.Font);
   if ShowFooter then
    begin
     //Рисуем доп. графическую часть бонуса "Стоимость" по зарание вычисленным координатам
     Draw(Position.X + 65, Position.Y - 15, GCost);
     //Отрисовка стоимости бонуса под углом -40 градусов
     TextOutAdv(Owner.Canvas, -40, ((Position.X + 105) + (30 - TextWidth(FooterText)) div 2) + 6, ((Position.Y - 5) + (30 - TextWidth(FooterText)) div 2) + 3, FooterText);
    end;
   //Рисуем осн. граф. объект подсказки
   Draw(Position.X, Position.Y, Graphic);
   //Шрифт и текаст подсказки
   Font.Style:=[fsBold];
   TextOut(Position.X + (128 div 2) - (TextWidth(Caption) div 2), Position.Y + 10, Caption);
   Font.Style:=[];
   //Каждая строка расположена в центре прфмоугольной области доступности
   if HintList.Count > 0 then
   for i:=0 to HintList.Count -  1 do
    TextOut(Position.X + (128 div 2) - (TextWidth(HintList.Strings[i]) div 2), (Position.Y + 10) + (15 * (i + 1)), HintList.Strings[i]);
  end;
end;

//////////////////////////////////////THelpObject///////////////////////////////

function THelpObject.GetGraphic: TPNGObject;
begin
 Result:=FGraphic;
end;

procedure THelpObject.SetGraphic(Value: TPNGObject);
begin
 FGraphic:=Value;
end;

function THelpObject.GetText:string;
begin
 Result:=FText;
end;

procedure THelpObject.SetText(Value:string);
begin
 FText:=Value;
end;

procedure THelpObject.Paint;
begin
 if not Visible then Exit;
 with Owner.Canvas do
  begin
   //Отрисовка графики подсказки
   StretchDraw(Rect(RectObj.Left + Position.X, RectObj.Top + Position.Y ,RectObj.Right + Position.X, RectObj.Bottom + Position.Y), Graphic);
   //Отрисовка заголовка
   TextOut(Position.X + 5, Position.Y + 5, Caption);
   //Отрисовка текста
   TextOut(Position.X + 5, Position.Y + 15, Text);
  end;
end;

procedure THelpObject.Show(AText, ACaption:string);
begin
 FText:=AText;
 FCaption:=FCaption;
 FVisible:=True;
end;

procedure THelpObject.Show;
begin
 FVisible:=True;
end;

procedure THelpObject.Hide;
begin
 FVisible:=False;
end;

constructor THelpObject.Create;  
begin
 inherited Create;
 FOwner:=AOwner;
end;

function THelpObject.GetCaption:string;
begin
 Result:=FCaption;
end;

procedure THelpObject.SetCaption(Value:string);
begin
 FCaption:=Value;
end;

/////////////////////////////////////TBonus/////////////////////////////////////

procedure TBonus.PaintGraphics;
begin
 //"Полу - абстрактныя" процедура отрисовки графического сопровождения
end;

procedure TBonus.Paint;
begin
 //Если бонус только для игры - выходим
 if BonusType = btForGame then Exit;
 //Процедура отрисовки кнопки
 with Owner.Canvas do
  begin
   //Рисуем иконку
   StretchDraw(RectObject, FIcon);
   //Если под мышью - то рисуем рамку цветом зависящим от состояния
   if FOver then
    begin
     Brush.Style:=bsClear;
     Pen.Width:=1;
     if (not Enabled) or (Owner.ToGold < FCost) then Pen.Color:=clRed else
      if Owner.ExecutingBonus then Pen.Color:=clGrayText else
       if not Levels[Owner.GetLevel] then Pen.Color:=clYellow else Pen.Color:=clLime;
     //Draw(RectObject.Left, RectObject.Top, Owner.Bitmaps.ShadePNG);
     Rectangle(Rect(RectObject.Left + 1, RectObject.Top + 1, RectObject.Right, RectObject.Bottom));
     Draw(RectObject.Left, RectObject.Top, Owner.Bitmaps.OveredBonus);
    end;
  end;
end;

function TBonus.GetRectObj:TRect;
begin
 //Позиционируем прямоугольную область относительно смещения панели бонусов
 Result:=Rect(Owner.RectForBonuses.Left + FRectObject.Left,
              Owner.RectForBonuses.Top  + FRectObject.Top,
              Owner.RectForBonuses.Left + FRectObject.Right,
              Owner.RectForBonuses.Top  + FRectObject.Bottom);
end;

procedure TBonus.SetRectObject(Value:TRect);
begin
 FRectObject:=Value;
end;

procedure TBonus.SetPositive(Value:Boolean);
begin
 FPositive:=Value;
end;

procedure TBonus.SetOver(Value:Boolean);
begin
 FOver:=Value;
end;

function TBonus.AddGraphic(PNG:TPNGObject):Word;
begin
 //Устанавливаем размер массива +1
 SetLength(FGraphics, Length(FGraphics) + 1);
 //Результат номер последнего элемента
 Result:=Length(FGraphics) - 1;
 //Добавляем в список объект
 FGraphics[Result]:=PNG;
end;

function TBonus.AddSound(HSTREAM:Cardinal):Word;
begin
 SetLength(FSounds, Length(FSounds) + 1);
 Result:=Length(FSounds) - 1;
 FSounds[Result]:=HSTREAM;
end;

procedure TBonus.SetIcon(AIcon:TPNGObject);
begin
 FIcon:=AIcon;
end;

procedure TBonus.SetEnabled(Value:Boolean);
begin
 FEnabled:=Value;
end;

function TBonus.GetSound(Index:Byte):Cardinal;
begin
 Result:=FSounds[Index];
end;

function TBonus.GetGraphics(Index:Byte):TPNGObject;
begin
 Result:=FGraphics[Index];
end;

procedure TBonus.SetGraphics(Index:Byte; Value:TPNGObject);
begin
 FGraphics[Index]:=Value;
end;

procedure TBonus.SetSound(Index:Byte; Value:Cardinal);
begin
 if Index > High(FSounds) then Exit;
 FSounds[Index]:=Value;
end;

procedure TBonus.SetCost(Value:Word);
begin
 FCost:=Value;
end;

procedure TBonus.SetName(Value:string);
begin
 FName:=Value;
end;

procedure TBonus.SetLevels(Deg:Word);
var i:Byte;
begin
 for i:=GlLvls downto 1 do
  FLevel[(GlLvls + 1) - i]:=Deg and (1 shl i) <> 0;
end;

procedure TBonus.SetLevel(Index:Byte; Value:Boolean);
begin
 FLevel[Index]:=Value;
end;

function TBonus.GetLevel(Index:Byte):Boolean;
begin
 Result:=FLevel[Index];
end;

procedure TBonus.SetDesc(Value:string);
begin
 FDesc:=Value;
end;

constructor TBonus.Create;
begin
 inherited Create;
 HintList:=TStringList.Create;
 FOwner:=AOwner;
end;

//////////////////////////////////TChangeFigure/////////////////////////////////

procedure TChangeFigure.Action;
begin
 //Создаем новую следующую фигуру
 FOwner.CreateNextFigure;
end;

///////////////////////////////////TKick////////////////////////////////////////

procedure TKick.Action;
var i, R, C:Byte;
    Done:Boolean;

//Проверить столбец на пустоты
function CheckCol(ACol:Byte):Byte;
var AR:Byte;
    CR:Boolean; {False - пусто, True - фигура}
begin
 Result:=0;
 with Owner do
  begin
   CR:=MainTet[Rows, ACol].State <> bsEmpty;
   for AR:=(Rows - 1) downto 1 do
    begin
     if CR <> (MainTet[AR, ACol].State <> bsEmpty) then
      if not CR then
       begin
        Result:=AR;
        Break;
       end;
     CR:=MainTet[AR, ACol].State <> bsEmpty;
    end;
  end;
end;

//Сдвинуть верхнюю часть столбца ACol вниз до WTop
procedure MoveCol(WTop, ACol:Byte);
var AR:Byte;
begin
 with Owner do
  begin
   for AR:=WTop downto 1 do
    MainTet[AR + 1, ACol]:=MainTet[AR, ACol];
   MainTet[1, ACol].State:=bsEmpty;
  end;
end;

begin
 with Owner do
  begin
   //Изначально координаты верные (обычные)
   ForcedCoord.X:=SWidth;
   ForcedCoord.Y:=SHeight;
   //Перехватываем координаты смещения поля
   ForcedCoordinates:=True;
   //Начальная скорость - 0
   i:=0;
   //Пока определенная часть поля не скроется вверху на 200 пкс. (половина поля)
   while ForcedCoord.Y > - 400 do
    begin
     //Если игра окончена - выходим
     if Owner.CheckPause then Exit;
     //Увеличиваем скорость поднятия
     Inc(i);
     //Поднимаем поле
     Dec(ForcedCoord.Y, i);
     //Ждем и отрисовываем
     Wait(25);
    end;
   //Начальная скорость - 2
   i:=2;
   //Пока поле не "встанет на место"
   while ForcedCoord.Y < SHeight do
    begin
     //Если игра окончена - выходим
     if Owner.CheckPause then Exit;
     //Увеличиваем скорость падения на 2
     Inc(i, 2);
     //Опускаем поле со скоростью i
     Inc(ForcedCoord.Y, i);
     //Ждем и отрисовываем
     Wait(5);
    end;
   //Освобождаем координаты (первая же отрисовка их выровняет сама)
   ForcedCoordinates:=False;
   //Бум (средний такой)
   Boom(5, 60);
   //Идем по столбцам игрового поля (очень редко, ходим исключительно по столбцам, такой торжественный момент =))
   for C:=1 to Cols do
    begin
     //Обработка столбца не закончена
     Done:=False;
     //Пока обработка столбца не закончится
     repeat
      //Узнаем высоту на которой есть пустоты
      R:=CheckCol(C);
      //Если высота больше 0, то
      if R > 0 then
       begin
        //Выполняем сдвиг на этой высоте
        MoveCol(R, C);
        //Бум
        Boom(2, 50);
       end //Если же высота = 0, то обработка закончена
      else Done:=True;
     until Done;
    end;
   //Останавливаем звук поток
   //Sound.Stop(Sounds[0]);
  end;
end;

///////////////////////////////////TScan////////////////////////////////////////

procedure TScan.Action;
var Line:array of Boolean;
    i, R, C, ElAm:Byte;
    Elem:TFiguresL2;
begin
 //Кол-во столбцов
 SetLength(Line, Owner.Cols);
 //Изначально все свободны
 for i:=0 to Length(Line) - 1 do Line[i]:=True;
 //X - координата
 GX:=Owner.SWidth;
 //Да, рисовать сопровождение
 Drawing:=True;
 Owner.IsWait:=True;
 //Запускаем звуковой поток
 Owner.Sound.PlaySound_2(Sounds[0]);
 //Идем по полю
 for R:=GlHdRw to Owner.Rows do
  begin
   //Если игра окончена - выходим
   if Owner.CheckPause then Exit;
   //Если последняя строка - выходим
   if R = Owner.Rows then Drawing:=False;
   //Координата Y = (Строка - GlHdRw) * Высота элемента фигуры
   GY:=((R - GlHdRw) * Owner.SHeight);
   //Кол-во элементов для удаления - 0
   ElAm:=0;
   //Проверям строку
   for C:=1 to Owner.Cols do
    begin
     //Если элемент не пуст и ещё не использовался элемент массива "лазера"
     if (Owner.MainTet[R, C].State <> bsEmpty) and Line[C - 1] then
      begin
       //Увеличиваем кол-во элементов для удаления
       Inc(ElAm);
       //Добавляем элемент к удаления
       Elem[C]:=Owner.MainTet[R, C];
       //Мы использовали элемент массива
       Line[C - 1]:=False;
      end //В противном случае элемент для удаления - пуст
     else Elem[C].State:=bsEmpty;
     //Увеличиваем координату Y на часть высоты элемента фигуры (для плавности хода картинки лазера)
     Inc(GY, Owner.SHeight div Owner.Cols);
     //Ждем 1 мсек.
     Owner.Wait(2);
    end;
   if ElAm > 0 then
    begin
     for C:=1 to Owner.Cols do
      if Elem[C].State <> bsEmpty then
       begin
        //Удаляем элемент
        Owner.MainTet[R, C].State:=bsEmpty;
        //Воспроизводим звук удаления элемента
        Owner.Sound.PlaySound(Sounds[1]);
       end;
     Owner.AnimateDelete(R, Elem);
    end;
  end;
 //Останавливаем звук поток
 Owner.Sound.Stop(Sounds[0]);
 //Нет, не рисуем сопровождение
 Drawing:=False;
end;

procedure TScan.PaintGraphics;
begin
 if not Drawing then Exit;
 //Рисуем линию "лазера" в GX;GY
 with Owner.Canvas do Draw(Owner.SLeft, GY, Graphics[0]);
end;

///////////////////////////////////TEditFigure////////////////////////////////////////

procedure TEditFigure.Action;
begin
 //Включаем режим редактирования след. фигуры
 Owner.DrawingFigure;
end;

///////////////////////////////////TBoss////////////////////////////////////////

procedure TBoss.Action;
begin
 //Следующая фигура - босс текущего уровня
 Owner.CreateNextBoss;
end;

///////////////////////////////////TRestart/////////////////////////////////////

procedure TRestart.Action;
begin
 with Owner do
  begin
   //Сливаем фигуру с полем
   Merger;
   //Очищаем поле с эффектом "Падение элементов"
   ClearAll;
   //След. фигуры нет
   FigureEnable:=False;
   //Шаг: создем след. фигуру и пускаем текущую
   StepDown;
  end;
end;

////////////////////////////////////TFull///////////////////////////////////////

procedure TFull.Action;
var R, C:Byte;
    Elems, Top, n:Word;
    Used:set of Byte;

function Filled:Boolean;
var AR, AC:Byte;
begin
 Result:=True;
 for AR:=GlHdRw to Owner.Rows do
  begin
   if not Result then Break;
   for AC:=1 to Owner.Cols do
    begin
     if Owner.MainTet[AR, AC].State = bsEmpty then Result:=False;
     if not Result then Break;
    end;
  end;
end;

begin
 with Owner do
  begin
   //Сливаем идущую фигуру с полем
   Merger;
   //Верхняя часть поля - GlHdRw
   Top:=GlHdRw;
   //Добавляем флаг об ожидании
   Inc(FWaitAmount);
   WaitWithoutStop(2);
   //Запускаем звук. поток
   Sound.PlaySound(Sounds[0]);
   //Делаем выстрелы
   repeat
    //Если игра окончена - выходим
    if Owner.CheckPause then Exit;
    //Выбираем координаты непустого элемента
    repeat
     R:=Random(Rows - Top + 1) + Top;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State = bsEmpty;
    Elems:=0;
    //Добавляем элемент
    Used:=[];
    //Выбираем ID ближнего элемента
    repeat
     repeat n:=Random(4) until (not (n in Used)) or (Used = [0,1,2,3]);
     Include(Used, n);
     case n of
      0:if (C - 1 > 0    ) then Elems:=MainTet[R, C - 1].ID;
      1:if (C + 1 <= Cols) then Elems:=MainTet[R, C + 1].ID;
      2:if (R - 1 > 0    ) then Elems:=MainTet[R - 1, C].ID;
      3:if (R + 1 <= Rows) then Elems:=MainTet[R + 1, C].ID;
     end;
     if Used = [0, 1, 2, 3] then Elems:=Random(15) + 1;
    until Elems <> 0;
    //Вставляем элемент
    Patched.ID:=Elems;
    MainTet[R, C]:=Patched;
    if Random(3) in [2, 1] then Continue;
    //Ждем 1 мсек.
    Wait(10);
   until Filled;
   Dec(FWaitAmount);
   ExecutingDelete;
   FigureEnable:=False;
   StepDown;
  end;
end;

///////////////////////////////////TScatter/////////////////////////////////////

procedure TScatter.Action;
var R, C, Shoots, DoShoots:Byte;
    Elems, Top, n:Word;
    Used:set of Byte;
    i:Byte;
    Elem:TFiguresL2;
    ATop:Integer;
begin
 with Owner do
  begin
   //Кол-во выстрелов элементами
   Shoots:=Random(20) + 1;
   //Сделано выстрелов - 0
   DoShoots:=0;
   //Задаем границу работы
   Top:=GetTop;
   if GlRows - Top > 5 then Top:=GlVbRw div 2;
   //////
   //Создаем массив удаляемой строки
   for i:=1 to Cols do
    begin
     Elem[i].ID:=Random(13) + 1;
     Elem[i].State:=bsElement;
    end;
   //Переводим выстоу в координату Y  *** GlSize <> 4
   ATop:=(((Top + 1) - GlSize) * SHeight) + SHeight;
   //Ищем свободное место для добавления новой анимации удаления
   for i:=1 to Rows do
    if not Assigned(ArrayOfClears[i]) then
     begin
      ArrayOfClears[i]:=TLineClear.Create(i, Owner, Elem, ATop);
      Break;
     end;
     ////
   //Узнаем кол-во пустых элементов на поле
   Elems:=0;
   for R:=Rows downto Top do
    for C:=1 to Cols do if MainTet[R, C].State = bsEmpty then Inc(Elems);
   //Если элементов нет (почти не возможно), то выходим
   if Elems = 0 then Exit;
   //Есди кол-во элементов на поле меньше чем выстрелов, то заново устанавливаем кол-во выстрелов исходя из кол-ва элементов
   if Elems < Shoots then Shoots:=Random(Elems) + 1;
   //Запускаем звук. поток
   Sound.PlaySound(Sounds[0]);
   //Делаем выстрелы
   repeat
    //Если игра окончена - выходим
    if Owner.CheckPause then Exit;
    //Выбираем координаты не пустого элемента
    repeat
     R:=Random(Rows - Top + 1) + Top;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State = bsEmpty;
    Elems:=0;
    //Добавляем элемент
    Used:=[];
    repeat
     repeat n:=Random(4);
     until not (n in Used) or (Used = [0,1,2,3]);
     Include(Used, n);
     case n of
      0:if (C - 1 > 0    ) then Elems:=MainTet[R, C - 1].ID;
      1:if (C + 1 >= Cols) then Elems:=MainTet[R, C + 1].ID;
      2:if (R - 1 > 0    ) then Elems:=MainTet[R - 1, C].ID;
      3:if (R + 1 <= Rows) then Elems:=MainTet[R + 1, C].ID;
     end;
     if Used = [0,1,2,3] then Elems:=Random(15) + 1;
    until Elems <> 0;
    Patched.ID:=Elems;
    MainTet[R, C]:=Patched;
    Wait(10);
    //Увеличиваем кол-во сделанных выстрелов
    Inc(DoShoots);
   until Shoots <= DoShoots;
  end;
end;

///////////////////////////////////TShot////////////////////////////////////////

procedure TShot.Action;
var R, C, Shoots, DoneShoots:Byte;
    Elems:Word;
begin
 with Owner do
  begin
   //Кол-во выстрелов
   Shoots:=Random(10)+1;
   //Сделано выстрелов - 0
   DoneShoots:=0;
   //Кол-во элементов в фигуре - 0
   Elems:=0;
   //Узнаем кол-во элементов на поле
   for R:=1 to Rows do
    for C:=1 to Cols do if MainTet[R, C].State <> bsEmpty then Inc(Elems);
   //Если элементов нет, то выходим
   if Elems = 0 then Exit;
   //Есди кол-во элементов на поле меньше чем выстрелов, то заново устанавливаем кол-во выстрелов исзодя из кол-во элементов
   if Elems < Shoots then Shoots:=Random(Elems)+1;
   //Запускаем звук. поток
   Sound.PlaySound(Sounds[0]);
   //Делаем выстрелы
   repeat
    //Если игра окончена - выходим
    if Owner.CheckPause then Exit;
    //Выбираем координаты не пустого элемента
    repeat
     R:=Random(Rows)+1;
     C:=Random(Cols)+1;
    until MainTet[R, C].State <> bsEmpty;
    //Очищаем элемент
    MainTet[R, C].State:=bsEmpty;
    //Увеличиваем кол-во выстрелов
    Inc(DoneShoots);
   until Shoots <= DoneShoots;
  end;
end;

////////////////////////////////////TPatch//////////////////////////////////////

procedure TPatch.Action;
var R, C:Byte;

//Проверка координаты на пригодность (больше 0, меньше границ)
function CheckField(AR, AC:Integer):Boolean;
begin
 if (AR > 0) and (AC > 0) and (AR <= Owner.Rows) and (AC <= Owner.Cols) then
  begin
   Result:=Owner.MainTet[AR, AC].State <> bsEmpty;
  end
 else Result:=True;
end;

begin
 with Owner do
  begin
   //Запускаем звук. поток
   Sound.PlaySound(Sounds[0]);
   //Идем по полю
   for R:=GlHdRw to Rows do
    begin
     for C:=1 to Cols do
      begin
       //Если игра окончена - выходим
       if Owner.CheckPause then Exit;
       //Если элемент пуст
       if MainTet[R, C].State = bsEmpty then
        begin
         //Проверяем координаты вокруг пустого
         if CheckField(R - 1, C) and
            CheckField(R, C - 1) and
            CheckField(R + 1, C) and
            CheckField(R, C + 1)
         then
          begin
           //Если нашли такой, то выбираем ближайший случайный элемент для вставки
           case Random(4) of
            0: if C + 1 <= Cols then Patched.ID:=MainTet[R, C + 1].ID else Patched.ID:=MainTet[R, C - 1].ID;
            1: if C - 1 > 0     then Patched.ID:=MainTet[R, C - 1].ID else Patched.ID:=MainTet[R, C + 1].ID;
            2: if R + 1 <= Rows then Patched.ID:=MainTet[R + 1, C].ID else Patched.ID:=MainTet[R - 1, C].ID;
            3: if R - 1 > 0     then Patched.ID:=MainTet[R - 1, C].ID else Patched.ID:=MainTet[R + 1, C].ID;
           else
            if R + 1 <= Rows then Patched.ID:=MainTet[R + 1, C].ID else Patched.ID:=MainTet[R - 1, C].ID;
           end;
           //Вставляем в пустое место
           MainTet[R, C]:=Patched;
           //Ждем 50 мсек
           Wait(50);
          end;
        end;
      end;
    end;
  end;
end;

////////////////////////////////////TKnife//////////////////////////////////////

procedure TKnife.Action;
var R, C:Byte;
begin
 with Owner do
  begin
   //Устанваливаем высоту
   R:=GetTop;
   //Воспроизводим звук
   Sound.PlaySound(Sounds[0]);
   //Удаляем верхушки
   for C:=1 to Cols do
    begin
     //Если игра окончена - выходим
     if Owner.CheckPause then Exit;
     //Если элемент не пуст - "срезаем"
     if MainTet[R, C].State <> bsEmpty then
      begin
       MainTet[R, C].State:=bsEmpty;
       //Ожидаем 50 мсек
       Wait(50);
      end;
    end;
  end;
end;

////////////////////////////////TSally//////////////////////////////////////////

procedure TSally.Action;
const DelayTime = 40;
var CheckSFigure:TTetArray;
    i, R, C, Counter, FigureID, T:Byte;
    FoundPos:Boolean;
    UsedF, FF:set of Byte;
begin
 inherited;
 FoundPos:=False;
 UsedF:=[];
 FF:=[];
 with Owner do
  begin
   for i:=0 to Length(ArrayOfFigure) - 1 do Include(FF, i);
   repeat
    if UsedF = FF then Exit;
    //Выбираем фигуру, которую ещё не бирали
    repeat
     FigureID:=Random(Length(ArrayOfFigure));
    until not (FigureID in UsedF);
    //Если что, мы её уже брали
    Include(UsedF, FigureID);
    //while Random(5) <> 3 do Result:=RotateFigure(Result);
    //Узнаем высоту и ширину фигуры
    WF:=WidthOfFigure(ArrayOfFigure[FigureID]);
    HF:=HeightOfFigure(ArrayOfFigure[FigureID]);
    Counter:=0;
    //Выбираем случайную сторону
    case Random(2) of
     //Слева
     0:
      begin
       FLeft:=1;
       //Пока не найдем позицию
       while not FoundPos do
        begin
         //Очищаем поле для фигурой
         ClrChng(CheckSFigure);
         //Берём случайную высоту
         FTop:=Random(Rows - GlFVRw) + GlFVRw;
         //Увеличиваем критический счетчик
         Inc(Counter);
         //Если счетчик вышел из границ - прерываем поиск позиции
         if Counter >= 200 then Break;
         //Вставляем крайнюю часть фигуры
         for R:=0 to HF - 1 do
          CheckSFigure[FTop + R, FLeft]:=ArrayOfFigure[FigureID].Elements[R + 1, WF];
         //Проверяем на столкновение с игровым полем, если есть, то прерывем дальнейшие дейтвия и повторяем вставку
         if CheckCollision(CheckSFigure, FTop, FLeft, False) then Continue;
         //Позиция найдена
         FoundPos:=True;
        end;
       //Если позиция не найдена - повторяем выбор стороны и фигуры
       if not FoundPos then Continue;

       //Ставим флаг отрисовки бонуса
       DoDrawing:=True;
       //Вставляем части фигуры в зависимости от стороны появления
       for i:=1 to WF do
        begin
         ClrChng(CheckSFigure);
         T:=i;
         for C:=WF downto (WF - (i - 1)) do
          begin
           for R:=0 to HF - 1 do CheckSFigure[FTop + R, FLeft + (T - 1)]:=ArrayOfFigure[FigureID].Elements[R + 1, C];
           Dec(T);
          end;
         if CheckCollision(CheckSFigure, FTop, FLeft, False) then Break;
         SallyFigure:=CheckSFigure;
         //Даем понять игроку "Что происходит"
         Wait(DelayTime);
        end;
      end;
     //Справа (комменатрии аналогичны левой стороне)
     1:
      begin
       FLeft:=Cols;
       while not FoundPos do
        begin
         ClrChng(CheckSFigure);
         FTop:=Random(Rows - 6) + GlSize;
         Inc(Counter);
         if Counter >= 200 then Break;
         for R:=0 to HF - 1 do
          CheckSFigure[FTop + R, FLeft + (WF - 1)]:=ArrayOfFigure[FigureID].Elements[R + 1, 1];
         if CheckCollision(CheckSFigure, FTop, FLeft, False) then Continue;
         FoundPos:=True;
        end;
       if not FoundPos then Continue;

       DoDrawing:=True;
       for i:=1 to WF do
        begin
         ClrChng(CheckSFigure);
         T:=1;
         for C:=1 to i do
          begin
           for R:=0 to HF - 1 do CheckSFigure[FTop + R, FLeft + (T - 1)]:=ArrayOfFigure[FigureID].Elements[R + 1, C];
           Inc(T);
          end;
         if CheckCollision(CheckSFigure, FTop, FLeft, False) then Break;
         SallyFigure:=CheckSFigure;
         Wait(DelayTime);
         Dec(FLeft);
        end;
      end;
    else Exit; 
    end;
    //Сливаем временное поле с игровым
    for R:=FTop to FTop + HF do
     for C:=FLeft to FLeft + WF do
      begin
       if (R <= 0) or (R > Rows) or (C <= 0) or (C > Cols) then Continue;
       if SallyFigure[R, C].State <> bsEmpty then MainTet[R, C]:=SallyFigure[R, C];
      end;
    //Ставим флаг о прекращении отрисовки бонуса
    DoDrawing:=False;
    //Выходим
    Exit;
   until UsedF = FF;
  end;
end;

procedure TSally.PaintGraphics;
var R, C:Byte;
begin
 if not DoDrawing then Exit;
 //Рисуем поле с фигурой
 for R:=FTop to FTop + (HF - 1) do
  for C:=FLeft to FLeft + (WF - 1) do
   with Owner, Owner.Canvas do
    begin
     if (R <= 0) or (R > Rows) or (C <= 0) or (C > Cols) then Continue;
     if SallyFigure[R, C].State <> bsEmpty then        //(C - 1) * SWidth + Left
      Draw(SLeft + (C - 1) * SWidth, STop + (R - GlFVRw) * SHeight, Owner.Bitmaps.Figures[SallyFigure[R, C].ID - 1]);
    end;
end;

///////////////////////////////////THail////////////////////////////////////////

procedure THail.Action;
var R, C, Shoots, DoneShoots:Byte;
    Elems:Word;
begin
 with Owner do
  begin
   //Кол-во выстрелов
   Shoots:=Random(10) + 1;
   //Сделано выстрелов - 0
   DoneShoots:=0;
   //Кол-во элементов в фигуре - 0
   Elems:=0;
   //Узнаем кол-во элементов на поле
   for R:=1 to Rows do
    for C:=1 to Cols do if MainTet[R, C].State <> bsEmpty then Inc(Elems);
   //Если элементов нет, то выходим
   if Elems = 0 then Exit;
   //Есди кол-во элементов на поле меньше чем выстрелов, то заново устанавливаем кол-во выстрелов исзодя из кол-во элементов
   if Elems < Shoots then Shoots:=Random(Elems)+1;
   //Запускаем звук. поток
   //Sound.PlaySound(Sounds[0]);
   //Делаем выстрелы
   repeat
    //Если игра окончена - выходим
    if Owner.CheckPause then Exit;
    //Выбираем координаты не пустого элемента
    repeat
     R:=Random(Rows) + 1;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State <> bsEmpty;
    //Очищаем элемент
    MainTet[R, C].State:=bsBonusTiming;
    MainTet[R, C].TimeLeft:=Random(30) + 30;
    //Увеличиваем кол-во выстрелов
    Inc(DoneShoots);
   until Shoots <= DoneShoots;
  end;
end;

////////////////////////////////TZeroGravity////////////////////////////////////

procedure TZeroGravity.Action;
begin
 inherited;
 if Owner.TopPos <= GlHdRw then Exit;
 Owner.ZeroGravity:=not Owner.ZeroGravity;
end;

///////////////////////////////TGhostMode///////////////////////////////////////

procedure TGhostMode.Action;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 Owner.Ghost:=not Owner.Ghost;
end;

/////////////////////////////////////TRndRotate/////////////////////////////////

constructor TRndRotate.Create;
begin
 inherited;
 TimerRotate:=TTimer.Create(nil);
 with TimerRotate do
  begin
   Name:='TimerRotate';
   OnTimer:=TimerRotateTime;
   Interval:=1000;
   Enabled:=False;
  end;
 TimerSpeed:=TTimer.Create(nil);
 with TimerSpeed do
  begin
   Name:='TimerSpeed';
   OnTimer:=TimerSpeedTime;
   Interval:=1000;
   Enabled:=False;
  end;
end;

procedure TRndRotate.Activate;
begin
 inherited;
 with TimerRotate do
  begin
   Interval:=1000;
   Enabled:=True;
  end;
 with TimerSpeed do
  begin
   Interval:=1000;
   Enabled:=True;
  end;
end;

procedure TRndRotate.ActivateWith(Tm1, Tm2:Word);
begin
 inherited Activate;
 with TimerRotate do
  begin
   Interval:=Tm1;
   Enabled:=True;
  end;
 with TimerSpeed do
  begin
   Interval:=Tm2;
   Enabled:=True;
  end;
end;

procedure TRndRotate.Deactivate;
begin
 inherited;
 TimerRotate.Enabled:=False;
 TimerSpeed.Enabled:=False;
 TimerRotate.Free;
 TimerSpeed.Free;
end;

procedure TRndRotate.TimerSpeedTime(Sender:TObject);
begin
 if (Random(22) mod 2) = 0 then
  begin
   if TimerRotate.Interval <= 100 then Exit
   else TimerRotate.Interval:=TimerRotate.Interval - 100;
  end
 else
  begin
   if TimerRotate.Interval >= 1000 then Exit
   else TimerRotate.Interval:=TimerRotate.Interval + 100;
  end;
end;

procedure TRndRotate.TimerRotateTime(Sender:TObject);
begin
 case Random(22 + 22) of
  1..11:Owner.StepLeft;
  12..22:Owner.StepRight;
  23..33:Owner.StepDown;
  34..44:Owner.RotateGameFigure((Random(22) mod 2) = 0);
 end;
end;

/////////////////////////////////TSpeedUp///////////////////////////////////////

procedure TSpeedUp.Activate;
begin
 inherited;
 Owner.SpeedUp(FValue);
 Owner.UpdateSpeed;
end;

procedure TSpeedUp.Deactivate;
begin
 inherited;
 Owner.SpeedDown(FValue);
 Owner.UpdateSpeed;
end;

constructor TSpeedUp.Create;
begin
 inherited;
 FValue:=500 div Owner.Level;
end;

//////////////////////////////////TMarsh////////////////////////////////////////

procedure TMarsh.Activate;
begin
 inherited;
 //Включаем режим "Болото"
 Owner.MarshMode:=True;
end;

procedure TMarsh.Deactivate;
begin
 inherited;
 //Выключаем режим "Болото"
 Owner.MarshMode:=False;
end;

//////////////////////////////TUseAllExcept/////////////////////////////////////

procedure TUseAllExcept.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //Запрещаем использовать тпи следующей фигуры
 if (Owner.NextID > 0) and (Owner.NextID < Length(Owner.ArrayOfFigure))
 then Owner.UseAllExcept(Owner.NextID)
 else Owner.UseAllExcept(Random(Length(Owner.ArrayOfFigure)));
end;

procedure TUseAllExcept.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //Позволяем использовать все фигруы
 Owner.UseAllFigures;
end;

////////////////////////////////TUseOnly////////////////////////////////////////

procedure TUseOnly.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //Запрещаем использовать все типы фигур кроме следующего
 if (Owner.NextID > 0) and (Owner.NextID < Length(Owner.ArrayOfFigure))
 then Owner.UseOnly(Owner.NextID)
 else Owner.UseOnly(Random(Length(Owner.ArrayOfFigure)));
end;

procedure TUseOnly.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //Позволяем использовать все фигруы
 Owner.UseAllFigures;
end;

/////////////////////////////////TVersa////////////////////////////////////////

procedure TVersa.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //Включаем смену управления
 Owner.Versa:=True;
end;

procedure TVersa.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //Отключаем смену управления
 Owner.Versa:=False;
end;

/////////////////////////////////THelper////////////////////////////////////////

procedure THelper.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //Включаем тень
 Owner.Helper:=True;
end;

procedure THelper.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //Отключаем тень
 Owner.Helper:=False;
end;

//////////////////////////////////TSimpleBonus//////////////////////////////////

procedure TSimpleBonus.Execute;
begin
 //Если бонус выплняется - выходим
 if Executing then Exit;
 //Бонус выполняется
 Executing:=True;
 //Бонус не доступен
 Enabled:=False;
 //Ждем 100 мсек.
 Owner.Wait(100);
 //Выполняем действие
 Action;
 //Ждем 100 мсек.
 Owner.Wait(100);
 //Бонус не выполняется
 Executing:=False;
 //Бонус доступен
 Enabled:=True;
end;

constructor TSimpleBonus.Create;
begin
 inherited;
 //Бонус не выполняется
 Executing:=False;
end;

procedure TSimpleBonus.Paint;
begin
 //Если бонус только для игры - выходим
 if BonusType = btForGame then Exit;
 //Рисуем общие данные
 inherited;
 //Рисуем свои данные
 with Owner.Canvas do
  begin
   //Если бонус выполняется - рисуем иконку "занят"
   if Executing then StretchDraw(RectObject, Owner.Bitmaps.BonusExeing);
  end;
end;

//////////////////////////////////TTimeBonus////////////////////////////////////

constructor TTimeBonus.Create;
begin
 inherited;
 //Таймер - истечение времени
 FTimer:=TTimer.Create(nil);
 with FTimer do
  begin
   Name:='FTimer';
   OnTimer:=TimerTime;
   Interval:=1000;
   Enabled:=False;
  end;
end;

procedure TTimeBonus.SetTime(Value:Word);
begin
 FTime:=Value;
end;

procedure TTimeBonus.Paint;
begin
 //Если бонус только для игры - выходим
 if BonusType = btForGame then Exit;
 //Рисуем общие данные
 inherited;
 //Рисуем свои данные
 with Owner.Canvas do
  begin
   //Если активирован
   if Activated then
    begin
     //Рисуем иконку - "занят" и время
     StretchDraw(RectObject, Owner.Bitmaps.BonusBusy);
     Font.Assign(Owner.FontTextBonuses);
     TextOut(RectObject.Left + ((Owner.SWidth div 2) - (TextWidth(IntToStr(LastTime)) div 2)), RectObject.Top + 5, IntToStr(LastTime));
    end;
  end;
end;

procedure TTimeBonus.Activate;
begin
 //Оставшееся время - время действия
 FLastTime:=FTime;
 //Бонус активирован
 FActive:=True;
 //Запускаем таймер
 Timer.Enabled:=True;
end;

procedure TTimeBonus.Deactivate;
begin
 //Бонус не выполняется
 FActive:=False;
 //Выключаем таймер
 Timer.Enabled:=False;
end;

procedure TTimeBonus.TimerTime(Sender:TObject);
begin
 //Если время истекло
 if FLastTime <= 0 then
  begin
   //Деактивируем бонус и выходим
   Deactivate;
   Exit;
  end;
 //Если идет время ожидания или сейчас не игра
 if (Owner.IsWait) or (Owner.GameState <> gsPlay) then Exit;
 //Уменьшаем время
 Dec(FLastTime);
end;

//////////////////////////////////TShade////////////////////////////////////////

procedure TShade.Clear;
var R, C:Byte;
begin
 for R:=1 to Owner.Rows do
  for C:=1 to Owner.Cols do ShadeArray[R, C].State:=bsEmpty;
end;

procedure TShade.Update;
var C, R, ATop:Byte;
begin
 //Если "тень" отключена - выходим
 if not Owner.Helper then Exit;
 //Выполняется обновление - выходим
 if not Ready then Exit;
 //Если игра остановлена - выходим
 if Owner.GameState <> gsPlay then Exit;
 //Если идет создание фигуры - выходим
 if Owner.IsCreating then Exit;
 //Если нет фигуры - выходим
 if not Owner.FigureEnable then Exit;
 //Состояние - "не готов"
 Ready:=False;
 //Изначальное поле - фигура
 ShadeArray:=Owner.MoveTet;
 //Текущая высота
 ATop:=Owner.TopPos;
 //Пока можем опускать - опускаем "тень" вниз
 repeat
  //Смещаем вниз
  for R:=Owner.Rows downto 2 do for C:=1 to Owner.Cols do ShadeArray[R, C]:=ShadeArray[R-1, C];
  for C:=1 to Owner.Cols do ShadeArray[1, C].State:=bsEmpty;
  //Увеличиваем высоту
  Inc(ATop);
 until Owner.CheckCollision(ShadeArray, ATop, True);
 //Состояние - готов
 Ready:=True;
end;

constructor TShade.Create(AOwner:TTetrisGame);
begin
 inherited Create;
 Ready:=True;
 FOwner:=AOwner;
end;

///////////////////////////////TTetrisGame//////////////////////////////////////

function TTetrisGame.CheckPause:Boolean;
begin
 //"Крутимся" пока не начнется игра
 while (GameState <> gsPlay) do
  begin
   //Если программа закрывается - прерываем цикл
   if Shutdowning then Break;
   //Уступаем место другим обработчикам
   Application.ProcessMessages;
  end;
 //Результат - идет ли завершение программы
 Result:=Shutdowning;
end;

procedure TTetrisGame.DrawingFigureClose(State:TGameState);
var C:Byte;
begin
 //Если состояние рисования - не рисует
 if DoDrawFigure = dtNotWork then
  begin
   //Состояние игры - переданное состояние
   GameState:=State;
   //Выходим
   Exit;
  end;
 //ИД рси. элемента - 1
 IDDrawFigure:=1;
 //Положение слева - 0 (т.е. полностью выдвинута)
 Bitmaps.FLeft:=0;
 //Скорость перемещения
 C:=0;
 //Пока не достигнем критической точки
 while Bitmaps.FLeft > (-FieldWidth) do
  begin
   //Увеличиваем скорость перемещения
   Inc(C);
   //Смещаем маск на значение скорости к критической точке
   Dec(Bitmaps.FLeft, C);
   //Ждем 10 мсек.
   Wait(10);
  end;
 //Фиксируем маску за полем
 Bitmaps.FLeft:=-FieldWidth;
 //Состояние игры - переданное состояние
 GameState:=State;
 //Состояние рисования - не рисует
 DoDrawFigure:=dtNotWork;
end;

procedure TTetrisGame.DrawingFigureEnd;
begin
 //Звук "выхода из паузы"
 Sound.Play(4);
 //Если кол-во элементов в фигуре меньше 0
 if WidthOfFigure(NextFigure) <= 0 then
  begin
   NextFigure:=NextFigureOld;
   //Отображаем подсказку
  end;
 //Нормализуем фигуру
 Normalization(NextFigure);
 //Выключаем редактирование
 DrawingFigureClose(State);
 //Выключить ожидание
 IsWait:=False;
end;

procedure TTetrisGame.DrawingFigure;
var R, C:Byte;
    ID:Byte;
begin
 //ИД элемента для рисования - 0 (не определен)
 ID:=0;
 //ИД элемента рисования - 1 (пока)
 IDDrawFigure:=1;
 //Сохраняем след. фигуру
 NextFigureOld:=NextFigure;
 //Идем по массиву элементов след. фигуры
 for R:=1 to GlSize do
  begin
   for C:=1 to GlSize do
    begin
     //Если встретили элемент
     if NextFigure.Elements[R, C].State <> bsEmpty then
      begin
       //Задаем найденный ИД
       ID:=NextFigure.Elements[R, C].ID;
       //Прерываем цикл
       Break;
      end;
    end;
   //Если нашли ИД - прерываем цикл
   if ID > 0 then Break;
  end;
 //Если нашли ИД устанавливаем в качестве ИД элемента рисования
 if ID > 0 then IDDrawFigure:=ID;
 //Позиция маски - за полем
 Bitmaps.FLeft:= -FieldWidth;
 //Скорость - 0
 C:=0;
 //Состояние рисования - ожидаем
 DoDrawFigure:=dtNone;
 //Говорим о том, что нужно сохранить снимок
 NeedShot:=True;
 //Пока маска не достигнет критической отметки
 while Bitmaps.FLeft < 0 do
  begin
   //Увеличиваем скорость
   Inc(C);
   //Смещаем положение к критической точке
   Inc(Bitmaps.FLeft, C);
   //Ждем 10 мсек.
   Wait(10);
  end;
 //Фиксируем маску - выдвинута
 Bitmaps.FLeft:=0;
 //Состояние игры - рисуем след. фигуру
 GameState:=gsDrawFigure;
 //Рстанавливаем все таймеры
 TimerDownStop;
 //
 Timers:=False;
 //Флаг ожидания
 IsWait:=True;
 //
 ShowButtons;
end;

procedure TTetrisGame.DrawBonuses;
var i:Word;
begin
 //Если нет бонусов - выходим
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //Даем каждому бонусу отрисоваться
 for i:= 0 to Length(ArrayOfBonuses) - 1 do ArrayOfBonuses[i].Paint;
end;

function TTetrisGame.CalcBrokenBonus:Word;
var R, C:Byte;
begin
 Result:=0;
 //Считаем испорченные бонусы
 for R:=GlFVRw to FRows do
  for C:=1 to FCols do
   begin
    if MainTet[R, C].State = bsBonusBroken then Inc(Result);
   end;
end;

function TTetrisGame.BuyAndExcecute;
begin
 Result:=0;
 //Если выполняется коко-то бонус, идет ожидание, идет создание фигуры или фигуры нет
 if ExecutingBonus or IsWait or IsCreating or (not FigureEnable) then
  begin
   //Невозможно выполнить бонус
   Hint.Show('Подожди', '', '| Время |не подходящее', 3, 0);
   //Выходим
   Exit;
  end;
 //Если бонус не доступен
 if (not ABonus.Enabled) then
  begin
   //Бонус не доступен
   Hint.Show('', '', 'Бонус|не доступен', 3, 0);
   //Выходим
   Exit;
  end;
 if not ABonus.Levels[GetLevel] then
  begin
   //Уровень не позволяет
   Hint.Show('', '', 'Вы не можете|использовать|на этом|уровне', 3, 0);
   //Выходим
   Exit;
  end;
 //Если обычный бонус
 if ABonus is TSimpleBonus then
  //Если бонус выполняется
  if (ABonus as TSimpleBonus).Executing then
   begin
    //Бонус уже выполняется
    //Выходим
    Exit;
   end;
 //Если не хватает золота
 if ABonus.Cost > ToGold then
  begin
   Hint.Show('', '', 'Не хватает|золота', 3, 0);
   //Мало золота
   Sound.Play(16);
   //Выходим
   Exit;
  end;
 //Вычитание золота и выполнение
 DecGold(ABonus.Cost);
 //Результат - потраченное золото
 Result:=ABonus.Cost;
 //Выполняем бонус
 ExecuteBonus(ABonus);
end;

procedure TTetrisGame.DecGold(Cost:Word);
begin
 //Вычитаем золото
 Dec(ToGold, Cost);
 //Выполнить показ убытка золота
 ShowGoldDec(Cost);
 //Звук "Золото убыло"
end;

procedure TTetrisGame.DeactivateAllBonuses;
var i:Word;
begin
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //Деактивируем все временные бонусы
 for i:=0 to Length(ArrayOfBonuses) - 1 do
  begin
   if ArrayOfBonuses[i] is TTimeBonus then
    if (ArrayOfBonuses[i] as TTimeBonus).Activated then
     (ArrayOfBonuses[i] as TTimeBonus).Deactivate;
  end;
end;

procedure TTetrisGame.ExecuteRandomBonus;
var ID:Byte;

function Approach(BPos:Boolean):Boolean;
begin
 case TB of
  tbBad:Result:=(not BPos);
  tbGood:Result:=BPos;
 else
  Result:=True;
 end;
end;

begin
 //Если нет бонусов - выходим
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //Выбираем случайный бонус, который можно использовать, который позволен на текущем уровне и удовлетворяет указанному типу
 repeat ID:=Random(Length(ArrayOfBonuses))
 until (ArrayOfBonuses[ID].BonusType in [btForAll, btForGame]) and
        ArrayOfBonuses[ID].Levels[GetLevel] and
        Approach(ArrayOfBonuses[ID].Positive);
 //Добавляем бонус в список для выполнения
 AddToActionList(ArrayOfBonuses[ID]);
end;

procedure TTetrisGame.ExecuteBonus(Bonus:TBonus);
begin
 Event(eventTutorial, Bonus.BID + eventBonus, 0);
 //Если обычный бонус
 if Bonus is TSimpleBonus then
  begin
   //Если выполняется какой-то бонус, идет ожидание, создается фигура или фигуры нет - выходм
   if ExecutingBonus or IsWait or IsCreating or (not FigureEnable) then Exit
   else //Если же нет
    begin
     //Выполняем действия перед выполненем бонуса
     OnBonusStartExecute(Bonus);
     //Выполняем действие бонуса
     (Bonus as TSimpleBonus).Execute;
     //Выполняем действия после выполнения бонуса
     OnBonusExecuted(Bonus);
    end;
   //Выходим
   Exit;
  end;
 //Если временной бонус
 if Bonus is TTimeBonus then
  begin
   //Если бонус активирован - деактивируем, в противном случае активируем
   if (Bonus as TTimeBonus).Activated then (Bonus as TTimeBonus).Deactivate
   else (Bonus as TTimeBonus).Activate;
   //Добавлеям в список использованных бонусов
   AddToExed(Bonus);
   //Выходим
   Exit;
  end;
end;

procedure TTetrisGame.AddToExed(Bonus:TBonus);
var Exe:TExing;
    i:Byte;
begin
 //Ссылка на бонус
 Exe.Bonus:=Bonus;
 //Элемент есть в сетке
 Exe.Active:=True;
 //Сдвигаем элементы вправо
 for i:=GlExes downto 2 do ArrayOfExing[i]:=ArrayOfExing[i - 1];
 //Заносим исп. бонус
 ArrayOfExing[1]:=Exe;
end;

procedure TTetrisGame.AddToActionList(Bonus:TBonus);
var i:Word;
begin
 //Если есть элементы в массиве
 if Length(ArrayOfToDo) > 0 then
  begin
   //Ищем первую не занятую ячейку
   for i:=0 to Length(ArrayOfToDo) - 1 do
    //Если ячейка не занята
    if not Assigned(ArrayOfToDo[i]) then
     begin
      //Вставляем бонус
      ArrayOfToDo[i]:=Bonus;
      //Выходим
      Exit;
     end;
  end;
 //Если массив пуст, или нет свободных ячеек
 //Увеличиваем массив
 SetLength(ArrayOfToDo, Length(ArrayOfToDo) + 1);
 //Добавляяем бонус
 ArrayOfToDo[Length(ArrayOfToDo) - 1]:=Bonus;
end;

procedure TTetrisGame.OnBonusExecuted;
begin
 //Выполнить проверку на удаление заполненных строк
 ExecutingDelete;
 //Обновим тень
 Shade.Update;
 //Хватит ждать
 IsWait:=False;
 //Запускаем таймер шага фигуры
 TimerDownStart;
 //Запускаем остальные таймеры
 Timers:=True;
 //Бонус не выполняется
 ExecutingBonus:=False;
end;

procedure TTetrisGame.OnBonusStartExecute;
begin
 //Добавляем в список для показа снизу
 AddToExed(Bonus);
 //Звук
 Sound.Play(13);
 //Выполняется бонус
 ExecutingBonus:=True;
 //Ожидение
 IsWait:=True;
 //Остановить таймер шага фигуры
 TimerDownStop;
 //Останавливаем таймеры
 Timers:=False;
end;

procedure TTetrisGame.ShowGoldDec(Size:Word);
begin
 if Size = 0 then Exit;
 //Алгоритм показа удаления золота
 //TODO
end;

procedure TTetrisGame.CreateGraphicsAndSound;
begin
 //Создаем холст
 DrawBMP:=TBitmap.Create;
 //Устанавливаем размеры холста
 DrawBMP.Width:=FieldWidth;
 DrawBMP.Height:=FieldHeight;
 ///Формат пикселей 24 бита (для ускоренной работы)
 DrawBMP.PixelFormat:=pf24bit;
 FCanvas:=DrawBMP.Canvas;
 //Создаем класс графики
 State(17);
 Bitmaps:=TBitmaps.Create(ProgramPath+'Data\', Self);
 //Создаем класс звука
 State(18);
 Sound:=TSound.Create(Self);
 //Создаем клас тень - помошник
 Shade:=TShade.Create(Self);
end;

procedure TTetrisGame.CreateButtons;
begin
 //Добавляем кнопку "Старт"
 AddButton(TExtButton.Create(Self, 'MaskButtonStart', 'Начать', 326, 321, FontTextButtons, PauseGame));
 //Добавляем кнопку "Стоп"
 AddButton(TExtButton.Create(Self, 'MaskButtonStop',  'Закончить',  326, 357, FontTextButtons, StopGame ));
 //Добавляем кнопку "Выход"
 AddButton(TExtButton.Create(Self, 'MaskButtonQuit',  'Выход', 326, 392, FontTextButtons, Shutdown ));
 //Кнопка "Стоп" не активна
 ArrayOfButtons[1].Enable:=False;
 //Подсказка для кнопки "Выход"
 with ArrayOfButtons[2] do
  begin
   ShowHint:=True;
   HintList.Add('Вы уверены,');
   HintList.Add('что хотите');
   HintList.Add('выйти?');
  end;
 HideButtons(False);
end;

procedure TTetrisGame.ShowHideButtons;
begin
 ShowAnimate(8);
 if ButtonsHided then ShowButtons else HideButtons(True);
end;

procedure TTetrisGame.AnimateDelete(ATop:Integer);
var i:Byte;
    Elem:TFiguresL2;
    NoElem:Boolean;
begin
 NoElem:=True;
 //Создаем массив удаляемой строки
 for i:=1 to Cols do
  begin
   Elem[i]:=MainTet[ATop, i];
   if Elem[i].State <> bsEmpty then NoElem:=False;
  end;
 //Если на этой высоте нет элементов - выходим
 if NoElem then Exit;
 //Переводим выстоу в координату Y  *** GlSize <> 4
 ATop:=((ATop - GlSize) * SHeight) + SHeight;
 //Ищем свободное место для добавления новой анимации удаления
 for i:=1 to Rows do
  if not Assigned(ArrayOfClears[i]) then
   begin
    ArrayOfClears[i]:=TLineClear.Create(i, Self, Elem, ATop);
    Exit;
   end;
end;

procedure TTetrisGame.AnimateDelete(ATop:Integer; Elems:TFiguresL2);
var i:Byte;
begin
 //Переводим выстоу в координату Y  *** GlSize <> 4
 ATop:=((ATop - GlSize) * SHeight) + SHeight;
 //Ищем свободное место для добавления новой анимации удаления
 for i:=1 to Rows do
  if not Assigned(ArrayOfClears[i]) then
   begin
    ArrayOfClears[i]:=TLineClear.Create(i, Self, Elems, ATop);
    Exit;
   end;
end;

procedure TTetrisGame.ActuateTimers;
begin
 //Таймер бонусов
 TimerBonus.Enabled:=True;
 //Таймер счетчиков
 TimerUpValues.Enabled:=True;
 //Таймер анимаций
 TimerAnimateFrames.Enabled:=True;
end;

procedure TTetrisGame.CreateTimers;
begin
 //Создаем таймеры с изначальными параметрами
 TimerBG:=TTimer.Create(nil);
 with TimerBG do
  begin
   Name:='TimerBG';
   Enabled:=False;
   Interval:=30;
   OnTimer:=TimerBGTimer;
  end;
 TimerBonus:=TTimer.Create(nil);
 with TimerBonus do
  begin
   Name:='TimerBonus';
   Enabled:=False;
   Interval:=1000;
   OnTimer:=TimerBonusTimer;
  end;
 TimerUpValues:=TTimer.Create(nil);
 with TimerUpValues do
  begin
   Name:='TimerUpValues';
   Enabled:=False;
   Interval:=5;
   OnTimer:=TimerUpValuesTimer;
  end;
 TimerAnimateFrames:=TTimer.Create(nil);
 with TimerAnimateFrames do
  begin
   Name:='TimerAnimateFrames';
   Enabled:=False;
   Interval:=100;
   OnTimer:=TimerAnimateFramesTimer;
  end;
 TimerBoom:=TTimer.Create(nil);
 with TimerBoom do
  begin
   Name:='TimerBoom';
   Enabled:=False;
   Interval:=1000;
   OnTimer:=TimerBoomTimer;
  end;
 TimerStep:=TTimer.Create(nil);
 with TimerStep do
  begin
   Name:='TimerStep';
   Enabled:=False;
   Interval:=StartSpeed;
   OnTimer:=TimerStepTimer;
  end;
 TimerBonusCtrl:=TTimer.Create(nil);
 with TimerBonusCtrl do
  begin
   Name:='TimerBonusCtrl';
   Enabled:=True;
   Interval:=1000;
   OnTimer:=TimerBonusCtrlTimer;
  end;
 TimerDraw:=TTimer.Create(nil);
 with TimerDraw do
  begin
   Name:='TimerDraw';
   Enabled:=True;
   Interval:=1000 div UserFPS;
   OnTimer:=TimerDrawTimer;
  end;
 TimerAnalysis:=TTimer.Create(nil);
 with TimerAnalysis do
  begin
   Name:='TimerAnalysis';
   Enabled:=True;
   Interval:=60 * 1000;
   OnTimer:=TimerAnalysisTimer;
  end;       //ExecuteRandomBonus(tbBad);
end;

procedure TTetrisGame.UseOnly(IDOfTheFigure:Byte);
var i:Byte;
begin
 if Length(ArrayOfFigure) <= 0 then Exit;
 for i:= 0 to Length(ArrayOfFigure) - 1 do ArrayOfFigure[i].Allowed:=False;
 ArrayOfFigure[IDOfTheFigure].Allowed:=True;
end;

procedure TTetrisGame.UseAllExcept(IDOfTheFigure:Byte);
var i:Byte;
begin
 if Length(ArrayOfFigure) <= 0 then Exit;
 for i:= 0 to Length(ArrayOfFigure) - 1 do ArrayOfFigure[i].Allowed:=True;
 ArrayOfFigure[IDOfTheFigure].Allowed:=False;
end;

procedure TTetrisGame.UseAllFigures;
var i:Byte;
begin
 if Length(ArrayOfFigure) <= 0 then Exit;
 for i:= 0 to Length(ArrayOfFigure) - 1 do ArrayOfFigure[i].Allowed:=True;
end;

procedure TTetrisGame.CreateFonts;
begin
 //Создаем шрифты с изначальными данными
 FontTextButtons:=TFont.Create;
 with FontTextButtons do
  begin
   Name:='DS Goose';  //
   Size:=10;
   Style:=[];
   Color:=$00161616;
  end;
 FontTextBonuses:=TFont.Create;
 with FontTextBonuses do
  begin
   Name:='Segoe UI';
   Style:=[];
   Size:=5;
  end;
 FontTextDisplay:=TFont.Create;
 with FontTextDisplay do
  begin
   Name:='DS Goose';     //Techno28
   Size:=8;
   Style:=[];
  end;
 FontTextAutor:=TFont.Create;
 with FontTextAutor do
  begin
   Name:='DS Goose';      ///
   Size:=8;
   Style:=[];
  end;
 FontTextGameOver:=TFont.Create;
 with FontTextGameOver do
  begin
   Name:='DS Goose';  //DS Goose
   Size:=14;
   Style:=[];
   Color:=$00161616;
  end; 
end;

procedure TTetrisGame.CreateHints;
begin
 Hint:=TTextHint.Create(Self);
 with Hint do
  begin
   Graphic:=Bitmaps.Hint;
   GCost:=Bitmaps.Cost;
   Position:=Point(200, 130);
   Font:=TFont.Create;
   with Font do
    begin
     Name:='DS Goose';
     Size:=10;
     Style:=[];
     Color:=$00161616;
    end;
  end;
end;

procedure TTetrisGame.CreateGameKeys;

  function AddKey(KC:Word; UN:string; AAction:TProcedure; FTime, MTime:Word):Byte;
  begin
   SetLength(GameKeys, Length(GameKeys) + 1);
   Result:=Length(GameKeys) - 1;
   GameKeys[Result]:=TGameKey.Create(Self);
   with GameKeys[Result] do
    begin
     GameKeyInfo:=GetGameKeyInfo(KC, GameKeyInfo.FForceDown, UN);
     {with GameKeyInfo do
      begin
       Code:=KC;
       Name:=UN;
      end;   }
     Action:=AAction;
     StartTime:=FTime;
     MinTime:=MTime;
    end;
  end;

begin
 //Создаем специальные игровые клавиши управления
 FKeyIDDown:= AddKey(VK_DOWN,  'Вниз',   KeyDown, 100, 20);    //Стрелка вниз/"S"
 FKeyIDUP:=   AddKey(VK_UP,    'Вверх',  KeyUp, 150, 50);      //Стрелка вверх/"W"
 FKeyIDLeft:= AddKey(VK_LEFT,  'Влево',  KeyLeft, 150, 50);    //Стрелка влево/"A"
 FKeyIDRight:=AddKey(VK_RIGHT, 'Вправо', KeyRight, 150, 50);   //Стрелка вправо/"D"
 FKeyIDRL:=AddKey(Ord('Q'), 'Поворот фигуры против часовой стрелки', KeyRotateLeft, 200, 50);
 FKeyIDRR:=AddKey(Ord('E'), 'Поворот фигуры по часовой стрелке',     KeyRotateRight, 200, 50);
 //Укажем количество клавиш
 FGameKeyCount:=Length(GameKeys);
 //Установка противостоящих клавиш
 GameKeys[FKeyIDDown].Contradiction:=FKeyIDUP;
 GameKeys[FKeyIDUP].Contradiction:=FKeyIDDown;
 GameKeys[FKeyIDLeft].Contradiction:=FKeyIDRight;
 GameKeys[FKeyIDRight].Contradiction:=FKeyIDLeft;
 GameKeys[FKeyIDRL].Contradiction:=FKeyIDRR;
 GameKeys[FKeyIDRR].Contradiction:=FKeyIDRL;
end;

procedure TTetrisGame.CreatePanels;

//Добавить место для новой панели
function AddField:Integer;
begin
 SetLength(ArrayOfPanels, Length(ArrayOfPanels)+1);
 Result:=Length(ArrayOfPanels) - 1;
 ArrayOfPanels[Result]:=TTextPanel.Create(Self);
end;

begin
 //Панель с правовой информацией
 with ArrayOfPanels[AddField] do
  begin
   Left:=Self.SWidth;
   Top:=Self.SHeight;
   Width:=Self.SWidth * Self.Cols;
   Height:=Self.SHeight * (Self.Rows - GlFVRw) div 3; 
   Graphic:=Bitmaps.Panel;
   Font.Name:='DS Goose';
   Font.Size:=10;
   Strings.Add('Данное программное обеспечение');
   Strings.Add('абсолютно бесплатно все элементы');
   Strings.Add('графики взяты из поискового');
   Strings.Add('результата. Большое спасибо');
   Strings.Add('FL Studio 9 за звуковое сопровождение');
   Strings.Add('и за позаимствованного персонажа');
   Strings.Add('  ');
   Strings.Add('Автор: Геннадий Малинин, 2013 год');
   WasShown:=False;
  end;
end;

function TTetrisGame.Load:Boolean;
var Ini:TIniFile;
    TMP:string;
begin
 Result:=False;
 try
  //Добавляем шрифты в систему
  State(1);
  AddFontResource(PChar(ProgramPath + 'Data\Fonts\SegoeUI.ttf'));
  AddFontResource(PChar(ProgramPath + 'Data\Fonts\DS Goose.ttf'));
  //Говорим системе о смене шрифтов
  SendMessage(0, WM_FONTCHANGE, 0, 0);
  //Курсор в центр
  Mouse:=Point(FieldWidth div 2, FieldHeight div 2);
  //Сброс значений
  State(2);
  Reset;
  //Инициализация движка (Порядок инициализации очень важен!)
  State(3);
  //Создание шрифтов
  State(4);
  CreateFonts;
  //Инициализация таймеров
  State(5);
  CreateTimers;
  //Конструирование кнопок
  State(6);
  CreateButtons;
  CreateGameKeys;
  //Инициализация графики и звука
  State(7);
  CreateGraphicsAndSound;
  //Создание фигур
  State(8);
  CreateFigures;
  //Установка областей взаимодействия на экране
  State(9);
  CreateRectAreas;
  //Инициализация бонусов
  State(10);
  CreateBonuses;
  //Создание текстовых панелей
  State(11);
  CreatePanels;
  //Создание подсказок
  State(12);
  CreateHints;
  //Очистка поля
  State(13);
  ClearAll;
  //Флаг о завершении инициализации
  State(14);
  //Активация таймеров
  State(15);
  ActuateTimers;
  //Инф. режим - Инф. дисплей
  State(19);
  InfoMode:=imInfoText;
  //Загрузка топа
  Statistics.Load;
  //Загружаем параметры игры (FPS, уровень линий, звук и др.)
  Ini:=TIniFile.Create(ProgramPath+'\Config.ini');
  UserFPS:=Ini.ReadInteger('Tetris', 'FPS', 40);
  DebugEnabled:=Ini.ReadBool('Tetris', 'Debug', False);
  ArrayOfPanels[0].WasShown:=Ini.ReadBool('Tetris', 'NotFirstRun', False);
  Ini.WriteBool('Tetris', 'NotFirstRun', True);
  TMP:=Ini.ReadString('Tetris', 'Password', '');
  LinesAmountForLevelUp:=Ini.ReadInteger('Tetris', 'LinesForLevel', 20);
  if LinesAmountForLevelUp < 20 then LinesAmountForLevelUp:=20;
  if Sound.Enable then Sound.Enable:=Ini.ReadBool('Tetris', 'Sound', True);
  //Фоновая музыка
  Sound.Play(100);
  if TMP <> '' then
   begin
    if Length(TMP) = 5 then
     begin
      if TMP[2] = Chr(Ord('2') - 1) then
       if TMP[1] = Chr(Ord('i') - 1) then
        if TMP[4] = Chr(Ord('1') + 1) then
         if TMP[5] = Chr(Ord('m') - 1) then
          if TMP[3] = Chr(Ord('l') + 1) then StartGold:=50000;
     end;
   end;
  Ini.Free;
  if UserFPS < 20 then UserFPS:=20;
  if UserFPS > 999 then UserFPS:=999;
  //Загрузка сохраненной игры
  State(20);
  if FileExists(ProgramPath + SaveFN) then
   begin
    with ArrayOfButtons[1] do
     begin
      CanBeContinue:=True;
      Enable:=True;
      Text:='Продолжить';
     end;
   end
  else CanBeContinue:=False;
  //Состояние игры - только запустили
  GameState:=gsNone;
  Creating:=False;
  State(16);
 except
  Exit;
 end;
 Result:=True;
end;

procedure TTetrisGame.CreateBonuses;
var X, Y, Index, ID:Integer;
    DLL:Cardinal;

//Добавить место в массив и установить положение бонуса в сетке отностельно позиции в массиве, т.е. порядка добавления
function AddField:Integer;
begin
 SetLength(ArrayOfBonuses, Length(ArrayOfBonuses) + 1);
 Result:=Length(ArrayOfBonuses) - 1;
 X:=((ID mod BonusAmountWidth) * SWidth);
 Y:=((ID div BonusAmountWidth) * SHeight);
end;

{
//////////////////////////////Бонус - Название/////////////////////////////////№
 //Добавляем ячейку
 Index:=AddField;
 //Создаем нужны класс бонуса
 ArrayOfBonuses[Index]:=TТип.Create(Self);
 //
 with ArrayOfBonuses[Index] do
  begin
   //Устанавливаем положение бонуса на экране
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   //Указываем название
   Name:='Название';
   //Указываем описание
   Desc:='Пишем описание бонуса';
   //Указываем строки подсказки
   HintList.Add('Первая строка подсказаи');
   HintList.Add('вторая строка подсказки');
   //Загружаем иконку бонуса
   SetIcon(CreatePNG(DLL, 'shot'));
   //Устанавливаем стоимость
   Cost:=0;
   //Указываем уровни, на которых можно использовать бонус
   SetLevels($FFFF);
   //Загружаем звуки
   AddSound(Sound.CreateStream(ProgramPath + 'Data\Sound\звук.wav', True));
   //Устанавливаем тип действия бонуса
   Positive:=False;
   //Устанавливаем доступность
   Enabled:=True;
   //Устанавливаем тпи (видимость) бонуса
   BonusType:=btForGame;
   //Если бонус на только для игры - добавляем в ячейку 
   if BonusType <> btForGame then Inc(ID);
  end;
}

begin
 DLL:=LoadLibrary(PChar(ProgramPath+'Data\'+TetDll));
 //Номер на панели - 0
 ID:=0;
//////////////////////////////Бонус - Дробь////////////////////////////////////1
 Index:=AddField;
 ArrayOfBonuses[Index]:=TShot.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Дробь';
   Desc:='Делает выстрел дробью';
   HintList.Add('Сделать выстрел');
   HintList.Add('дробью');
   BID:=1;
   SetIcon(CreatePNG(DLL, 'shot'));
   Cost:=0;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\shot.wav', True));
   Positive:=False;
   Enabled:=True;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Нож//////////////////////////////////////2
 Index:=AddField;
 ArrayOfBonuses[Index]:=TKnife.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Нож';
   Desc:='Срезает верхушку';
   HintList.Add('Срезать самую');
   HintList.Add('верхную часть');
   HintList.Add('поля');
   BID:=2;
   SetIcon(CreatePNG(DLL, 'trunc'));
   Cost:=50;
   SetLevels($BFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\trunc.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Помошник/////////////////////////////////3
 Index:=AddField;
 ArrayOfBonuses[Index]:=THelper.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Помощник';
   Desc:='Отображает конечный пункт фигуры (2 мин.)';
   HintList.Add('Отображает');
   HintList.Add('конечный пункт');
   HintList.Add('текущей фигуры');
   HintList.Add('в теч. 2 мин.');
   BID:=3;
   SetIcon(CreatePNG(DLL, 'help'));
   Cost:=90;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\helper1.wav', True));
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\helper2.wav', True));
   Positive:=True;
   Enabled:=True;
   ActionTime:=2 * 60;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Пластырь/////////////////////////////////4
 Index:=AddField;
 ArrayOfBonuses[Index]:=TPatch.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Пластырь';
   Desc:='Латает все одиночные "дыры"';
   HintList.Add('Залатать все');
   HintList.Add('одиночные "дыры"');
   BID:=4;
   SetIcon(CreatePNG(DLL, 'patcher'));
   Cost:=100;
   SetLevels($4FFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\patcher.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Ой, ой///////////////////////////////////5
 Index:=AddField;
 ArrayOfBonuses[Index]:=TVersa.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Ой, ой';
   Desc:='Меняет местами кнопки управления';
   HintList.Add('Меняет местами');
   HintList.Add('кнопки');
   HintList.Add('управления');
   HintList.Add('на 1 мин.');
   BID:=5;
   SetIcon(CreatePNG(DLL, 'versa'));
   Cost:=0;
   SetLevels($FFF8);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\versa1.wav', True));
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\versa2.wav', True));
   Positive:=False;
   Enabled:=True;
   ActionTime:=1 * 60;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Сканер-лазер/////////////////////////////6
 Index:=AddField;
 ArrayOfBonuses[Index]:=TScan.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Лазер';
   Desc:='Срезает верхние точки';
   HintList.Add('Срезать верхний');
   HintList.Add('слой каждого');
   HintList.Add('столбца');
   BID:=6;
   SetIcon(CreatePNG(DLL, 'scan'));
   Cost:=20;
   SetLevels($FC7F);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\scan.wav', False));
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\scanfire.wav', True));
   AddGraphic(CreatePNG(DLL, 'ScanLine'));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Босс/////////////////////////////////////7
 Index:=AddField;
 ArrayOfBonuses[Index]:=TBoss.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Босс';
   Desc:='Вызвать босса текущего уровня';
   HintList.Add('Вызвать босса');
   HintList.Add('текущего уровня');
   BID:=7;
   SetIcon(CreatePNG(DLL, 'boss'));
   Cost:=0;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\boss.wav', True));
   Positive:=False;
   Enabled:=True;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Сменить фигуру///////////////////////////8
 Index:=AddField;
 ArrayOfBonuses[Index]:=TChangeFigure.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Фигура';
   Desc:='Сменить следующую фигуру';
   HintList.Add('Сменить');
   HintList.Add('следующую');
   HintList.Add('фигуру');
   BID:=8;
   SetIcon(CreatePNG(DLL, 'figure'));
   Cost:=80;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\figure.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - Удар со смещением фигур//////////////////9
 Index:=AddField;
 ArrayOfBonuses[Index]:=TKick.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Удар-пресс';
   Desc:='Сместить элементы вниз в пустые места';
   HintList.Add('Сместить');
   HintList.Add('элементы вниз');
   HintList.Add('в пустые места');
   BID:=9;
   SetIcon(CreatePNG(DLL, 'kick'));
   Cost:=300;
   SetLevels($1FFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\figure.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////Бонус - Редактирование фигуры след./////////////////10
 Index:=AddField;
 ArrayOfBonuses[Index]:=TEditFigure.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Карандаш';
   Desc:='Позволяет отредактировать след. фигуру';
   HintList.Add('Позволяет');
   HintList.Add('отредактировать');
   HintList.Add('следующую');
   HintList.Add('фигуру');
   BID:=10;
   SetIcon(CreatePNG(DLL, 'edit'));
   Cost:=200;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\edit.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForUser;
   if BonusType <> btForGame then Inc(ID);
  end;
///////////////////////Антибонус - Разбрасывает элменеты поля/////////////////11
 Index:=AddField;
 ArrayOfBonuses[Index]:=TScatter.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Дождь';
   Desc:='Разбросать элементы поля';
   HintList.Add('Разбросать');
   HintList.Add('элементы');
   HintList.Add('по полю');
   BID:=11;
   SetIcon(CreatePNG(DLL, 'scatter'));
   Cost:=0;
   SetLevels($FFF8);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\edit.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////Простой бонус - Очищает всё поле////////////////////12
 Index:=AddField;
 ArrayOfBonuses[Index]:=TRestart.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Очистка';
   Desc:='Очистить всё поле';
   HintList.Add('Очистить');
   HintList.Add('всё поле');
   BID:=12;
   SetIcon(CreatePNG(DLL, 'restart'));
   Cost:=500;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\restart.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForUser;
   if BonusType <> btForGame then Inc(ID);
  end;
/////////////////////////Простой бонус - Заполняет всё поле///////////////////13
 Index:=AddField;
 ArrayOfBonuses[Index]:=TFull.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Заполнение';
   Desc:='Заполнить всё поле';
   HintList.Add('Заполнить');
   HintList.Add('всё поле');
   BID:=13;
   SetIcon(CreatePNG(DLL, 'full'));
   Cost:=1000;
   SetLevels($FFFF);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\full.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForUser;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////Бонус - Использовать только один тип фигур//////////////////14
 Index:=AddField;
 ArrayOfBonuses[Index]:=TUseOnly.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Дубликат';
   Desc:='Использовать только след. тип фигур';
   HintList.Add('Использовать');
   HintList.Add('только след.');
   HintList.Add('тип фигур');
   HintList.Add('в теч. 20 сек.');
   BID:=14;
   SetIcon(CreatePNG(DLL, 'useonly'));
   Cost:=150;
   SetLevels($FFF8);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\useonly1.wav', True));
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\useonly2.wav', True));
   Positive:=True;
   Enabled:=True;
   ActionTime:=20;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////Бонус - Исключить один тип фигур////////////////////////15
 Index:=AddField;
 ArrayOfBonuses[Index]:=TUseAllExcept.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Исключение';
   Desc:='Исключить один тип фигур';
   HintList.Add('Исключить');
   HintList.Add('один тип');
   HintList.Add('фигур');
   HintList.Add('на 40 сек.');
   BID:=15;
   SetIcon(CreatePNG(DLL, 'useallexcept'));
   Cost:=0;
   SetLevels($FFF8);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\useallexcept1.wav', True));
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\useallexcept2.wav', True));
   Positive:=False;
   Enabled:=True;
   ActionTime:=40;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////Бонус - Режим "Призрачная фигура"///////////////////////16
 Index:=AddField;
 ArrayOfBonuses[Index]:=TGhostMode.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Призрак';
   Desc:='Позволяет проходить сквозь элементы';
   HintList.Add('Позволяет');
   HintList.Add('проходить');
   HintList.Add('сквозь элементы');
   BID:=16;
   SetIcon(CreatePNG(DLL, 'ghostfigure'));
   Cost:=200;
   SetLevels($FFF8);
   AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\ghostfigure.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
//////////////////////////////Бонус - "Вылазка фигуры"////////////////////////17
 Index:=AddField;
 ArrayOfBonuses[Index]:=TSally.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Вылазка';
   Desc:='В случайном месте, слева или справа вылазит фигура';
   HintList.Add('Выдавить фигуру');
   HintList.Add('со стороны');
   HintList.Add('поля');
   BID:=17;
   SetIcon(CreatePNG(DLL, 'sally'));
   Cost:=0;
   SetLevels($FFFF);
   //AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\scan.wav', False));
   Positive:=False;
   Enabled:=True;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
///////////////////////Бонус - Случайный поворот фигуры///////////////////////18
 Index:=AddField;
 ArrayOfBonuses[Index]:=TRndRotate.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Дьявол';
   Desc:='Сам дьявол управляет фигурой';
   HintList.Add('Сам дьявол');
   HintList.Add('управляет');
   HintList.Add('фигурой');
   HintList.Add('в теч. 22 сек.');
   BID:=18;
   SetIcon(CreatePNG(DLL, 'RNDROTATE'));
   Cost:=0;
   SetLevels($FFFF);
   Positive:=False;
   Enabled:=True;
   ActionTime:=22;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
////////////////////////////Бонус - Невесомость///////////////////////////////19
 Index:=AddField;
 ArrayOfBonuses[Index]:=TZeroGravity.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Невесомость';
   Desc:='Включить или выключить гравитацию';
   HintList.Add('Включить');
   HintList.Add('или выключить');
   HintList.Add('гравитацию');
   BID:=19;
   SetIcon(CreatePNG(DLL, 'GRAVITY'));
   Cost:=250;
   SetLevels($FFF8);
   //AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\ghostfigure.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForUser;
   if BonusType <> btForGame then Inc(ID);
  end;
///////////////////////////////Бонус - Град///////////////////////////////////20
 Index:=AddField;
 ArrayOfBonuses[Index]:=THail.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Град';
   Desc:='Рассыпать бонусы по фигурам';
   HintList.Add('Рассыпать');
   HintList.Add('бонусы');
   HintList.Add('по фигурам');
   BID:=20;
   SetIcon(CreatePNG(DLL, 'HAIL'));
   Cost:=1300;
   SetLevels($FFF8);
   //AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\ghostfigure.wav', True));
   Positive:=True;
   Enabled:=True;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
///////////////////////////Бонус - Режим "Болото"/////////////////////////////21
 Index:=AddField;
 ArrayOfBonuses[Index]:=TMarsh.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Болото';
   Desc:='Активирует/деактивирует режим "Болото"';
   HintList.Add('Активирует');
   HintList.Add('режим');
   HintList.Add('"Болото"');
   HintList.Add('на 1 мин.');
   BID:=21;
   SetIcon(CreatePNG(DLL, 'marsh'));
   Cost:=70;
   SetLevels($FFFF);
   //AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\versa1.wav', True));
   Positive:=True;
   Enabled:=True;
   ActionTime:=1 * 60;
   BonusType:=btForAll;
   if BonusType <> btForGame then Inc(ID);
  end;
/////////////////////////Бонус - Повышение скорости///////////////////////////22
 Index:=AddField;
 ArrayOfBonuses[Index]:=TSpeedUp.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='Ускорение';
   Desc:='Повысить скорость на 2 мин.';
   HintList.Add('Повысить');
   HintList.Add('скорость');
   HintList.Add('на 2 мин.');
   BID:=22;
   SetIcon(CreatePNG(DLL, 'speedup'));
   Cost:=0;
   SetLevels($FFFF);
   //AddSound(Sound.CreateStream(ProgramPath+'Data\Sound\versa1.wav', True));
   Positive:=False;
   Enabled:=True;
   ActionTime:=2 * 60;
   BonusType:=btForGame;
   if BonusType <> btForGame then Inc(ID);
  end;
/////////////////////////////////////...////////////////////////////////////////
 FreeLibrary(DLL);
end;

function TTetrisGame.GetTop:Byte;
var R, C:Byte;
begin
 Result:=Rows;
 for R:=1 to Rows do
  for C:=1 to Cols do
   begin
    //Если ячейка не пуста
    if MainTet[R, C].State <> bsEmpty then
     begin
      //Это и есть вершина
      Result:=R;
      //Выходим
      Exit;
     end;
   end;
end;

function TTetrisGame.CreateBMP(DLL:Cardinal; ID:string):TBitmap;
begin
 Result:=TBitmap.Create;
 try Result.LoadFromResourceName(DLL, ID) except Ahtung end;
 Result.PixelFormat:=pf24bit;
end;

function TTetrisGame.CreateBMP(FName:string):TBitmap;
begin
 Result:=TBitmap.Create;
 try Result.LoadFromFile(FName) except Ahtung end;
 Result.PixelFormat:=pf24bit;
end;

procedure TTetrisGame.OnKeyPress(Key:Char);
begin
 //Если активно поле для ввода имени
 if FEditBoxActive then
  begin
   case Key of
    #8 :Delete(FEditBoxText, Length(FEditBoxText), 1);
    #13:FEditBoxActive:=False;
   else
    if Length(FEditBoxText) < 13 then FEditBoxText:=FEditBoxText + Key;
   end;
  end;
end;

procedure TTetrisGame.OnKeyDown(Key:Word; Shift:TShiftState);
begin
 //Если активно поле для ввода имени выходим
 if FEditBoxActive then Exit;
 //Проверяем элементы управления фигурой
 if not Versa then
  case Key of
   VK_LEFT, Ord('A'):  if GameKeys[FKeyIDLeft].ForceDown <= 0 then GameKeys[FKeyIDLeft].Press;
   VK_DOWN, Ord('S'):  if GameKeys[FKeyIDDown].ForceDown <= 0 then GameKeys[FKeyIDDown].Press;
   VK_RIGHT, Ord('D'): if GameKeys[FKeyIDRight].ForceDown <= 0 then GameKeys[FKeyIDRight].Press;
   VK_UP, Ord('W'):    if GameKeys[FKeyIDUP].ForceDown <= 0 then GameKeys[FKeyIDUP].Press;
   Ord('Q'):           if GameKeys[FKeyIDRL].ForceDown <= 0 then GameKeys[FKeyIDRL].Press;
   Ord('E'):           if GameKeys[FKeyIDRR].ForceDown <= 0 then GameKeys[FKeyIDRR].Press;
  end
 else
  case Key of
   VK_LEFT, Ord('A'):  if GameKeys[FKeyIDRight].ForceDown <= 0 then GameKeys[FKeyIDRight].Press;
   VK_DOWN, Ord('S'):  if GameKeys[FKeyIDUP].ForceDown <= 0 then GameKeys[FKeyIDUP].Press;
   VK_RIGHT, Ord('D'): if GameKeys[FKeyIDLeft].ForceDown <= 0 then GameKeys[FKeyIDLeft].Press;
   VK_UP, Ord('W'):    if GameKeys[FKeyIDDown].ForceDown <= 0 then GameKeys[FKeyIDDown].Press;
   Ord('Q'):           if GameKeys[FKeyIDRR].ForceDown <= 0 then GameKeys[FKeyIDRR].Press;
   Ord('E'):           if GameKeys[FKeyIDRL].ForceDown <= 0 then GameKeys[FKeyIDRL].Press;
  end;
 //Проверяем элементы управления игрой
 case Key of
  VK_RETURN:PauseGame;
  VK_ESCAPE:ShowHideButtons;
  Ord('H'):if Shift = [ssShift, ssCtrl] then DebugEnabled:=not DebugEnabled;
 end;
end;

procedure TTetrisGame.ChangeBackground(ALevel:Byte);
begin
 //Первый рисунок - текущий рисунок фона
 Bitmaps.BackgroundOne.Canvas.Draw(0, 0, Bitmaps.BackGroundDraw);
 //Второй рисунок - рисунок следующего уровня
 if FLevel >= Length(Bitmaps.Backgrounds) then ALevel:=0;
 Bitmaps.BackgroundTwo.Canvas.Draw(0, 0, Bitmaps.Backgrounds[ALevel]);
 //Текущий шаг - 1-ый
 Bitmaps.BGStep:=1;
 //Запускаем таймер
 TimerBG.Enabled:=True;
end;

procedure TTetrisGame.Event(e, param1, param2:Integer);
begin

 case e of
  2:
  begin
   if not (param1 in FShownTutScene) then Tutorial(param1);
  end;
 else
  Exit;
 end;
end;

procedure TTetrisGame.CreateRectAreas;
var ILeft, IRight, ITop:Integer;
    IWidth:Word;
begin
 //Определяем прямоугольные области
 //Слева = 0, Сверху = самый низ - 20, Справа = 250, Снизу = самый низ.
 RectForAutor:=Rect(0, FieldHeight - 20, 250, FieldHeight);
 //Ширина 4-х мерного поля = (ширина элемента * кол-во элементов в ширину) + 1
 IWidth:=(SWidth * GlSize) + 1;
 //Слева = Ширина элемента * (кол-во столбцов + 2)
 ILeft:=SWidth * (2 + Cols);
 //Справа = слева + ширина 4-х  мерного поля
 IRight:=ILeft + IWidth;
 //Сверху = высота элемента
 ITop:=SHeight;
 //След. фигура
 RectForNextFigure:=Rect(Point(ILeft, ITop), IWidth, IWidth);
 //Серху = позиция предыд. поля + высота элемента
 ITop:=RectForNextFigure.Bottom + SHeight;
 //Поля: Инф. дисп, бонусы, поле мыши бонусов
 RectForInfoText:=Rect(Point(ILeft, ITop), IWidth, IWidth);
 RectForBonuses:=RectForInfoText;
 RectForBonusesMouse:=Scaled(RectForInfoText, 2);
 with RectForChangeMode do
  begin
   Left:=ILeft - 4;
   Top:=RectForInfoText.Bottom + SHeight div 2;
   Right:=IRight + 4;
   Bottom:=Top + 105;
  end;
 with RectForButtons do
  begin
   Left:=327;
   Top:=321;
   Right:=436;
   Bottom:=424;
  end;
 Scale(RectForButtons, 5); 
 with RectForExed do
  begin
   Left:=SWidth;
   Top:=FieldHeight - 31;
   Bottom:=Top + 23;
   Right:=Left + 301;
  end;
 //Устанавливаем размер и позицию шкалы уровня
 with Redraw do
  begin
   FScaleSize:=Abs(FOwner.RectForNextFigure.Right - FOwner.RectForNextFigure.Left) - 2;
   FScalePos:=Point(FOwner.RectForNextFigure.Left - 10, FOwner.FieldHeight - 20);
  end;
end;

procedure TTetrisGame.MoveMouse;
var CPoint, LastPt:TPoint;
begin
 //Если курсор над полем игры
 if PtInRect(Rect(SLeft, STop, SLeft + Cols * SWidth, STop + Rows * SHeight), Mouse) then
  begin
   //Смещаем курсор к персонажу
   Hint.Show('', '', 'Мышь,|не мешайся,|иди сюда.', 5, 0);
   CPoint:=Application.MainForm.ClientToScreen(Point(ArrayOfButtons[0].FLeft + ArrayOfButtons[0].FWidth div 2, ArrayOfButtons[0].CTop + ArrayOfButtons[0].FHeight div 2));
   LastPt:=Controls.Mouse.CursorPos;
   while ((CPoint.X < Controls.Mouse.CursorPos.X - 5) or (CPoint.X > Controls.Mouse.CursorPos.X + 5)) or ((CPoint.Y < Controls.Mouse.CursorPos.Y - 5) or (CPoint.Y > Controls.Mouse.CursorPos.Y + 5)) do
    begin
     WaitWithoutStop(2);
     if ((LastPt.X <> Controls.Mouse.CursorPos.X) or (LastPt.Y <> Controls.Mouse.CursorPos.Y)) then
      begin
       Hint.Hide;
       Exit;
      end;
     //Если мышь здвинули во время перемещения - выходим
     if Controls.Mouse.CursorPos.X < CPoint.X then Controls.Mouse.CursorPos:=Point(Controls.Mouse.CursorPos.X + 5, Controls.Mouse.CursorPos.Y);
     if Controls.Mouse.CursorPos.X > CPoint.X then Controls.Mouse.CursorPos:=Point(Controls.Mouse.CursorPos.X - 5, Controls.Mouse.CursorPos.Y);
     if Controls.Mouse.CursorPos.Y < CPoint.Y then Controls.Mouse.CursorPos:=Point(Controls.Mouse.CursorPos.X, Controls.Mouse.CursorPos.Y + 5);
     if Controls.Mouse.CursorPos.Y > CPoint.Y then Controls.Mouse.CursorPos:=Point(Controls.Mouse.CursorPos.X, Controls.Mouse.CursorPos.Y - 5);
     //Application.ProcessMessages;
     LastPt:=Controls.Mouse.CursorPos;
    end;
  end;
end;

procedure TTetrisGame.HideButtons;
var Speed, B:Byte;
begin
 //Если кнопки скрываются/показываются или уже скрыты - выходим
 if FButtonsHiding or (FButtonsHided) then Exit;
 //Кнокпи скрываются
 FButtonsHiding:=True;
 //Смещаем кнопки вниз, поочереди
 for B:=2 downto 0 do
  begin
   Speed:=5;
   with ArrayOfButtons[B] do
    begin
     FTop:=CTop;
     while FTop < (FieldHeight + 10) do
      begin
       if not ShowAnimate then Break;
       Inc(Speed);
       FTop:=FTop + Speed;
       WaitWithoutStop(2);
      end;
     FTop:=(FieldHeight + 10);
    end;
  end;
 //Кнопки не скрываются
 FButtonsHiding:=False;
 //Кпноки скрыты
 FButtonsHided:=True;
end;

procedure TTetrisGame.ShowButtons;
var Speed, B:Byte;
begin
 //Если кнокпи небыли предварительно показаны - кнокпи предворительно показываются
 if not AlreadyShownButtons then AlreadyShownButtons:=True;
 //Если кнопки скрываются/показываются или уже показаны - выходим
 if FButtonsHiding or (not FButtonsHided) then Exit;
 //Кнопки показываются
 FButtonsHiding:=True;
 for B:=0 to 2 do
  begin
   Speed:=5;
   with ArrayOfButtons[B] do
    begin
     FTop:=(FieldHeight + 10);
     while FTop > CTop do
      begin
       Inc(Speed);
       FTop:=FTop - Speed;
       WaitWithoutStop(2);
      end;
     FTop:=CTop;
    end;
  end;
 FButtonsHiding:=False;
 FButtonsHided:=False;
end;

procedure TTetrisGame.CreateFigures;
begin
 //Заносим список фигур и боссов
 //Deg - десятичное представление 16-ти разрядного двоичного числа
 //Пишем Deg в шестнадцатиричном представлении для пафоса =))
 //Добавление игровых фигур
 AddFigure(CreateFigure($8888, ''), ArrayOfFigure);
 AddFigure(CreateFigure($CC00, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C880, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C440, ''), ArrayOfFigure);
 AddFigure(CreateFigure($4E00, ''), ArrayOfFigure);
 AddFigure(CreateFigure($8C40, ''), ArrayOfFigure);
 AddFigure(CreateFigure($4C80, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C800, ''), ArrayOfFigure);
 AddFigure(CreateFigure($8000, ''), ArrayOfFigure);
 //Добавление боссов
 AddFigure(CreateFigure($FFFF, ''), ArrayOfBosses);  //Lvl 1
 AddFigure(CreateFigure($595B, ''), ArrayOfBosses);  //Lvl 2
 AddFigure(CreateFigure($9699, ''), ArrayOfBosses);  //Lvl 3
 AddFigure(CreateFigure($9FF9, ''), ArrayOfBosses);  //Lvl 4
 AddFigure(CreateFigure($9096, ''), ArrayOfBosses);  //Lvl 5
 AddFigure(CreateFigure($9669, ''), ArrayOfBosses);  //Lvl 6
 AddFigure(CreateFigure($4996, ''), ArrayOfBosses);  //Lvl 7
 AddFigure(CreateFigure($A7E5, ''), ArrayOfBosses);  //Lvl 8
 AddFigure(CreateFigure($4C64, ''), ArrayOfBosses);  //Lvl 9
 AddFigure(CreateFigure($960F, ''), ArrayOfBosses);  //Lvl 10
 AddFigure(CreateFigure($F9AC, ''), ArrayOfBosses);  //Lvl 11
 AddFigure(CreateFigure($A5A5, ''), ArrayOfBosses);  //Lvl 12
 AddFigure(CreateFigure($F99F, ''), ArrayOfBosses);  //Lvl 13
 AddFigure(CreateFigure($9A8F, ''), ArrayOfBosses);  //Lvl 14
 AddFigure(CreateFigure($B2E9, ''), ArrayOfBosses);  //Lvl 15
 //Установка первоначальной фигуры
 NextFigure:=GetRandomFigure;
 //Загрузка графического представления элементов фигур
 Bitmaps.LoadFigures(ArrayOfFigure, SWidth, SHeight);
end;

function TTetrisGame.CreateFigure(Deg:Word; FigureName:string):TFigure;
var i:Byte;
const Sz = GlAmnt - 1;
begin
 //Переводим десятичное число в двоичное занося данные в массив
 //R = (N - 1) div W + 1
 //C = (N - 1) mod W + 1
 //R - Строка
 //C - Столбец
 //W - Кол-во столбцов
 //N - Порядковый номер "ячейки" массива (направление сверху-вниз, слева-направо)
 //Для перевода числа из 2 в 10 начинаем с конца
 with Result do
  begin
   for i:=Sz downto 0 do Elements[((Sz - i) mod GlSize) + 1, ((Sz - i) div GlSize) + 1].ID:=Ord(Deg and (1 shl i) <> 0);
   Allowed:=True;
   Name:=FigureName;
  end;
end;

function TTetrisGame.Max(Val1, Val2:Integer):Integer;
begin
 if Val1 > Val2 then Result:=Val1 else Result:=Val2;
end;

function TTetrisGame.Min(Val1, Val2:Integer):Integer;
begin
 if Val1 < Val2 then Result:=Val1 else Result:=Val2;
end;

function TTetrisGame.KeyIsDown(VK_KEY:Word):Boolean;
begin
 //Если управление "перевернуто" - даем соответствующие значения
 if Versa then
  case VK_KEY of
   VK_DOWN,  Ord('S'): Result:=(GetKeyState(Ord('W')) and $8000 = $8000) or (GetKeyState(Ord(VK_UP))    and $8000 = $8000);
   VK_LEFT,  Ord('A'): Result:=(GetKeyState(Ord('D')) and $8000 = $8000) or (GetKeyState(Ord(VK_RIGHT)) and $8000 = $8000);
   VK_RIGHT, Ord('D'): Result:=(GetKeyState(Ord('A')) and $8000 = $8000) or (GetKeyState(Ord(VK_LEFT))  and $8000 = $8000);
   VK_UP,    Ord('W'): Result:=(GetKeyState(Ord('S')) and $8000 = $8000) or (GetKeyState(Ord(VK_DOWN))  and $8000 = $8000);
   Ord('Q')          : Result:=(GetKeyState(Ord('E')) and $8000 = $8000);
   Ord('E')          : Result:=(GetKeyState(Ord('Q')) and $8000 = $8000);
  else Result:=GetKeyState(VK_KEY) and $8000 = $8000;
  end
 else
  case VK_KEY of
   VK_DOWN,  Ord('S'): Result:=(GetKeyState(Ord('S')) and $8000 = $8000) or (GetKeyState(Ord(VK_DOWN))  and $8000 = $8000);
   VK_LEFT,  Ord('A'): Result:=(GetKeyState(Ord('A')) and $8000 = $8000) or (GetKeyState(Ord(VK_LEFT))  and $8000 = $8000);
   VK_RIGHT, Ord('D'): Result:=(GetKeyState(Ord('D')) and $8000 = $8000) or (GetKeyState(Ord(VK_RIGHT)) and $8000 = $8000);
   VK_UP,    Ord('W'): Result:=(GetKeyState(Ord('W')) and $8000 = $8000) or (GetKeyState(Ord(VK_UP))    and $8000 = $8000);
   Ord('Q')          : Result:=(GetKeyState(Ord('Q')) and $8000 = $8000);
   Ord('E')          : Result:=(GetKeyState(Ord('E')) and $8000 = $8000);
  else Result:=GetKeyState(VK_KEY) and $8000 = $8000;
  end;
end;

procedure TTetrisGame.OnMouseDown(Button:TMouseButton; Shift:TShiftState; X, Y: Integer);
var i:Byte;
begin
 case Button of
  mbLeft:
   begin
    if GameState <> gsPlay then
     begin
      if PtInRect(ArrayOfPanels[0].ClipRect, Point(X, Y)) then ArrayOfPanels[0].Hide;
     end;
    //Если игра или пауза
    if GameState in [gsPlay, gsPause] then
     begin
      //Если есть бонусы
      if Length(ArrayOfBonuses) > 0 then
      //Если мышь в области бонусов
       if PtInRect(RectForBonusesMouse, Point(X, Y)) then
        for i:=0 to Length(ArrayOfBonuses) - 1 do
         //Если под мышью и идет игра
         if ArrayOfBonuses[i].Over and (GameState = gsPlay) and (ArrayOfBonuses[i].BonusType <> btForGame) then
          begin
           //Покупаем, выполняем бонус и показываем сколько убыло золота
           ShowGoldDec(BuyAndExcecute(ArrayOfBonuses[i]));
           //Выходим
           Exit;
          end;
      //Если мышь в прямоугольнике персонажа
      if PtInRect(RectForChangeMode, Point(X, Y)) then
       begin
        //Меняем режим отображения
        if InfoMode = imInfoText then InfoMode:=imBonuses else InfoMode:=imInfoText;
       end;
     end
    else //Если же нет
     //Если мышь в прямоугольнике персонажа показываем подсказку
     if PtInRect(RectForChangeMode, Mouse) then
      begin
       Hint.Show('', '', 'Для начала|начни игру', 5, 3);
      end
     else Hint.Hide; //Если нет убираем подсказку
    if PtInRect(RectForNextFigure, Mouse) and (DoDrawFigure <> dtNotWork) then
     begin
      DoDrawFigure:=dtElement;
      OnMouseMove(Shift, X, Y);
     end;
    //Если есть кнопки
    if (not FButtonsHided) and (not FButtonsHiding) then
     if Length(ArrayOfButtons) > 0 then
      //Посылаем сообщение о нажатии мыши
      for i:=0 to Length(ArrayOfButtons)-1 do ArrayOfButtons[i].OnMouseDown(X, Y);
   end;
  mbRight:
   begin
    //Если мышь в прямоугольнике персонажа
    if PtInRect(RectForChangeMode, Point(X, Y)) then
     begin
      //Отображаем/Скрываем кнопки
      ShowHideButtons;
     end;
    if PtInRect(RectForNextFigure, Mouse) and (DoDrawFigure <> dtNotWork) then
     begin
      DoDrawFigure:=dtEmpty;
      OnMouseMove(Shift, X, Y);
     end;
   end;
 end;
end;

procedure TTetrisGame.OnMouseMove(Shift:TShiftState; X, Y: Integer);
var i:Byte;
    ID:Integer;
    Tmp:TRect;
begin
 Mouse:=Point(X, Y);
 //Если мишь в области персонажа - скрываем подсказку
 if PtInRect(RectForChangeMode, Mouse) then Hint.Hide;
 //Если состояние игры - нейтральное
 case GameState of
  gsNone:
   begin
    //Если мышь в области подписи автора
    if PtInRect(RectForAutor, Mouse) then
     begin
      //Показываем подсказку обо мне
      Hint.Show('Привет', '', 'Разработчик|программы|Геннадий|Малинин', 5, 0);
      Draw;
      //Выходим
      Exit;
     end;
   end;
  gsPlay,
  gsPause:
   begin
    //Если режим бонусов и мышь в области бонусов
    if InfoMode = imBonuses then
     if PtInRect(RectForBonusesMouse, Mouse) then
      begin
       //Если есть бонусы
       if Length(ArrayOfBonuses) > 0 then
        begin
         for i:=0 to Length(ArrayOfBonuses) - 1 do
          begin
           //Если бонус только для игры, пропускаем
           if ArrayOfBonuses[i].BonusType = btForGame then Continue;
           //Состояние бонуса (фокус)
           ArrayOfBonuses[i].Over:=PtInRect(ArrayOfBonuses[i].RectObject, Mouse);
           //Если есть фокус у бонуса
           if ArrayOfBonuses[i].Over then
            begin
             with ArrayOfBonuses[i] do
              begin
               Hint.Show(Name, IntToStr(Cost), HintList, 5, 0);
              end;
             //Hint.Show(ArrayOfBonuses[i]);
            end;
          end;
        end;
      end;
    if PtInRect(RectForExed, Mouse) then
     begin
      ID:=((X - (SWidth + 3)) div 21) + 1;
      if ID in [1..14] then
       begin
        if ArrayOfExing[ID].Active then
         begin
          Hint.Show(ArrayOfExing[ID].Bonus.Name, '', ArrayOfExing[ID].Bonus.HintList, 5, 0);
          ArrayOfExing[ID].Bonus.Over:=True;
          for i:=0 to Length(ArrayOfBonuses) - 1 do
           begin
            if ArrayOfBonuses[i] = ArrayOfExing[ID].Bonus then Continue;
            ArrayOfBonuses[i].Over:=False;
           end;
         end;
       end;
     end;
   end;
  gsDrawFigure:
   begin
    if PtInRect(RectForNextFigure, Mouse) and not (DoDrawFigure in [dtNotWork, dtNone]) then
     begin
      for i:=1 to GlAmnt do
       begin
        Tmp.Left:=RectForNextFigure.Left + (SWidth * (((i - 1) mod GlSize)));
        Tmp.Top:=RectForNextFigure.Top + (SHeight * (((i - 1) div GlSize)));
        Tmp.Right:=Tmp.Left + SWidth;
        Tmp.Bottom:=Tmp.Top + SHeight;
        if PtInRect(Tmp, Mouse) then
         begin
          case DoDrawFigure of
           dtElement:
            begin
             NextFigure.Elements[(((i - 1) div GlSize) + 1), (((i - 1) mod GlSize) + 1)].ID:=IDDrawFigure;
             NextFigure.Elements[(((i - 1) div GlSize) + 1), (((i - 1) mod GlSize) + 1)].State:=bsElement;
            end;
           dtEmpty:
            begin
             NextFigure.Elements[(((i - 1) div GlSize) + 1), (((i - 1) mod GlSize) + 1)].State:=bsEmpty;
            end;
          end;
         end;
       end;
      Exit;
     end;
   end;
 end;
 if (not FButtonsHided) and (not FButtonsHiding) then
  //Если мышь в прямоугольнике кнопок
  if PtInRect(RectForButtons, Mouse) then
   begin
    if Length(ArrayOfButtons) <=0 then Exit;
    ID:= - 1;
    for i:=0 to Length(ArrayOfButtons) - 1 do
     begin
      ArrayOfButtons[i].OnMouseMove(X, Y);
      if (ArrayOfButtons[i].FButtonState = bsOver) and (ArrayOfButtons[i].ShowHint) then
      ID:=i;
     end;
    if GameState = gsShutdown then Exit;
    if ID > -1 then Hint.Show(ArrayOfButtons[ID]);
   end;
end;

procedure TTetrisGame.OnMouseUp(Button:TMouseButton; Shift: TShiftState; X, Y: Integer);
var i:Byte;
begin
 if DoDrawFigure <> dtNotWork then DoDrawFigure:=dtNone;
 //Подача сигнала кнопкам
 if Length(ArrayOfButtons) <=0 then Exit;
 for i:=0 to Length(ArrayOfButtons) - 1 do ArrayOfButtons[i].OnMouseUp(X, Y);
 Draw;
end;

function TTetrisGame.GetFLevel(Index:Byte):Boolean;
begin
 Result:=FLevels[Index];
end;

procedure TTetrisGame.CreateNextBoss;
begin
 ShowFigureChanging(NextFigure, GetNextBoss);
 Event(eventTutorial, eventBoss, 0);
end;

procedure TTetrisGame.KeyUp;
begin
 if ZeroGravity then StepUp else RotateGameFigure(True);
end;

procedure TTetrisGame.KeyDown;
begin
 StepDown
end;

procedure TTetrisGame.KeyLeft;
begin
 StepLeft;
end;

procedure TTetrisGame.KeyRight;
begin
 StepRight;
end;

procedure TTetrisGame.KeyRotateLeft;
begin
 RotateGameFigure(False);
end;

procedure TTetrisGame.KeyRotateRight;
begin
 RotateGameFigure(True);
end;

procedure TTetrisGame.LinesUp(Value:Integer);
begin
 SetLines(FLines + Value);
 Statistics.Append.Lines(Value);
 if FLines = 1 then CreateNextBoss;
end;

procedure TTetrisGame.SetTimers(Value:Boolean);
begin
 FTimerActivate:=Value;
 //TimerUpValues.Enabled:=Value;
 TimerBonusCtrl.Enabled:=Value;
 TimerBonus.Enabled:=True;
 TimerStep.Enabled:=Value;
end;

procedure TTetrisGame.SetIM(Value:TInfoMode);
var s, W:Word;
begin
 //Если идет трансформация - выходим
 if FInfoMode = imTransforming then Exit;
 ShowAnimate(6);
 //Шаг изменения - 0
 s:=0;
 //Берем ширину области
 W:=Abs(RectForBonuses.Left - RectForBonuses.Right);
 //Идет трансформация
 FInfoMode:=imTransforming;
 //Выбираем в какой режим перейти
 case Value of
  imInfoText:
   begin
    //Смещаем области до нужных границ
    while RectForBonuses.Left < FieldWidth do
     begin
      //Увеличиваем шаг и скорость
      Inc(s);
      RectForBonuses.Left:=RectForBonuses.Left + s;
      RectForBonuses.Right:=RectForBonuses.Right + s;
      RectForInfoText.Left:=RectForInfoText.Left - s;
      RectForInfoText.Right:=RectForInfoText.Right - s;
      WaitWithoutStop(4);
     end;
    RectForBonuses.Left:=FieldWidth;
    RectForBonuses.Right:=FieldWidth + W;
    RectForInfoText.Left:=340;
    RectForInfoText.Right:=340 + W;
   end;
  imBonuses:
   begin
    //Смещаем области до нужных границ
    while RectForBonuses.Left > 340 do
     begin
      //Увеличиваем шаг
      Inc(s);
      RectForBonuses.Left:=RectForBonuses.Left - s;
      RectForBonuses.Right:=RectForBonuses.Right - s;
      RectForInfoText.Left:=RectForInfoText.Left + s;
      RectForInfoText.Right:=RectForInfoText.Right + s;
      WaitWithoutStop(4);
     end;
    RectForInfoText.Left:=FieldWidth;
    RectForInfoText.Right:=FieldWidth + W;
    RectForBonuses.Left:=340;
    RectForBonuses.Right:=340 + W;
   end;
 end;
 //Фиксируем режим
 FInfoMode:=Value;
end;

procedure TTetrisGame.SetHelper(Value:Boolean);
begin
 FHelper:=Value;
 //Если включаем помошника - обновляем тень
 if Value then Shade.Update;
end;

procedure TTetrisGame.SetLines(Value:Integer);
var i:Byte;
begin
 //Устанавливаем кол-во линий
 FLines:=Value;
 //Проверка уровней
 for i:=1 to GlLvls do
  begin
   //Если кол-во линий хватает для повышения уровня и уровень ещё не пройден
   if (FLines >= (i * LinesAmountForLevelUp)) and (not Levels[i]) then
    begin
     //Уровень уже пройден
     FLevels[i]:=True;
     //Повышаем уровень
     LevelUp;
     //Выходим
     Exit;
    end;
  end;
end;

procedure TTetrisGame.ContinueGame;
begin
 //Останавливаем фон. музыку
 Sound.Stop(100);
 //Звук "выхода из паузы"
 Sound.Play(4);
 //Состояние игры - пауза
 GameState:=gsPause;
 //Инф. дисп. - текст
 InfoMode:=imInfoText;
 //
 WriteDebug('Игра продолжена');
 //Останавливаем "тряску"
 BoomStop;
 //Фигура не создается
 IsCreating:=False;
 //Сменяем фон для первого уровня
 ChangeBackground(GetLevel - 1);
 //Кнопка "Закончить" активна
 ArrayOfButtons[1].Enable:=True;
 ArrayOfButtons[1].Text:='Закочнить';
 //Если золото не пополнялось показываем подсказку (просто совпало с золотом =))
 if FirstUpGold and (FButtonsHiding or FButtonsHided) then
  begin
   Hint.Show('Кнопки скрылись', '', 'кликни по мне | правой кнопкой мыши | для их возврата', 5, 3);
  end;
 //Состояние игры - "идет игра"
 GameState:=gsPlay;
 if not FButtonsHided then HideButtons(True);
 MoveMouse;
end;

procedure TTetrisGame.DeleteSaved;
begin
 //Удаляем файл сохранения
 DeleteFile(ProgramPath + SaveFN);
end;

function TTetrisGame.SaveGame:Boolean;
var FE:TFileStream;
    Lvl:Byte;
begin
 Result:=False;
 try
  begin
   //Создаем пустой файл
   FileClose(FileCreate(ProgramPath + SaveFN));
   //Открываем файл в режиме потока
   try
    FE:=TFileStream.Create(ProgramPath + SaveFN, fmOpenReadWrite);
   except
    begin
     Wait(2000);
     Hint.Show('Ошибочка', '', 'Не получилось|сохранить|игру', 3, 0);
     Exit;
    end;
   end;
   //Записываем Главное поле
   FE.Write(MainTet, SizeOf(TTetArray));
   //Движ. фигура
   FE.Write(MoveTet, SizeOf(TTetArray));
   //След. фигура
   FE.Write(NextFigure, SizeOf(TFigure));
   //Текущая движ. фигура
   FE.Write(CurFigure, SizeOf(TFigure));
   //Золото
   FE.Write(ToGold, SizeOf(Cardinal));
   //Счет
   FE.Write(ToScore, SizeOf(Cardinal));
   //Линии
   FE.Write(Lines, SizeOf(Integer));
   //Имеется ли фигура
   FE.Write(FigureEnable, SizeOf(Boolean));
   //Положение движ. фигуры сверху
   FE.Write(TopPos, SizeOf(Byte));
   //Положение движ. фигуры слева
   FE.Write(LeftPos, SizeOf(Byte));
   //Положение поля слева
   FE.Write(SLeft, SizeOf(Integer));
   //Положение поля сверху
   FE.Write(STop, SizeOf(Integer));
   //Данные об уровне
   Lvl:=GetLevel;
   FE.Write(Lvl, SizeOf(Byte));
   FE.Write(FLevels, SizeOf(TLevels));
   //Статистика
   FE.Write(Statistics.Statistics, SizeOf(TStatRecord));
   //-------Сохранение бонусов
   FE.Write(ZeroGravity, SizeOf(Boolean));
   FE.Write(Ghost, SizeOf(Boolean));
   if Length(ArrayOfFigure) > 0 then
    for Lvl:= 0 to Length(ArrayOfFigure) - 1 do FE.Write(ArrayOfFigure[Lvl].Allowed, SizeOf(Boolean));
   FE.Write(Helper, SizeOf(Boolean));
   FE.Write(MarshMode, SizeOf(Boolean));
   FE.Write(FSpeedRate, SizeOf(Smallint));
   FE.Write(Versa, SizeOf(Boolean));
   FE.Write(FShownTutScene, SizeOf(Byte) * SizeOf(Byte));
   FE.Write(IsTheBoss, SizeOf(Boolean));

   for Lvl:=0 to Length(ArrayOfBonuses) - 1 do
    if ArrayOfBonuses[Lvl] is TTimeBonus then
     begin
      //Заносим включен ли бонус или нет
      FE.Write((ArrayOfBonuses[Lvl] as TTimeBonus).FActive, SizeOf(Boolean));
      //Заносим оставшееся время
      FE.Write((ArrayOfBonuses[Lvl] as TTimeBonus).FLastTime, SizeOf(Word));
     end;

   //-------------------------
   //Освобождаем файл
   FE.Free;
  end;
 except
  begin
   //Освобождаем файл
   FileClose(FileCreate(ProgramPath + SaveFN));
   //Удаляем сохранение
   DeleteSaved;
   //Выходим
   Exit;
  end;
 end;
 //Сохранение успешно завершено
 Result:=True;
end;

function TTetrisGame.LoadGame:Boolean;
var FE:TFileStream;
    LNs:Integer;
    Lvl:Byte;
    Tmp:Boolean;
begin
 Result:=False;
 //Если файла сохр. нет - выходим
 if not FileExists(ProgramPath + SaveFN) then Exit;
 //Открываем файл на чтение в режиме потока
 FE:=TFileStream.Create(ProgramPath + SaveFN, fmOpenRead);
 try
  //Считываем гл. поле
  FE.Read(MainTet, SizeOf(TTetArray));
  //Движ. фигура
  FE.Read(MoveTet, SizeOf(TTetArray));
  //След. фигура
  FE.Read(NextFigure, SizeOf(TFigure));
  //Текущая движ. фигура
  FE.Read(CurFigure, SizeOf(TFigure));
  //Золото
  FE.Read(ToGold, SizeOf(Cardinal));
  //Счет
  FE.Read(ToScore, SizeOf(Cardinal));
  //Линии
  FE.Read(LNs, SizeOf(Integer));
  //Имеется ли фигура
  FE.Read(FigureEnable, SizeOf(Boolean));
  //Положение движ. фигуры сверху
  FE.Read(TopPos, SizeOf(Byte));
  //Положение движ. фигуры слева
  FE.Read(LeftPos, SizeOf(Byte));
  //Поле слева
  FE.Read(SLeft, SizeOf(Integer));
  //Поле справа
  FE.Read(STop, SizeOf(Integer));
  //Данные об уровне
  FE.Read(Lvl, SizeOf(Byte));
  Level:=Lvl;
  FE.Read(FLevels, SizeOf(TLevels));
  OldLevel:=Lvl;
  SetLines(Lns);
  //Статистика
  FE.Read(Statistics.Statistics, SizeOf(TStatRecord));
  //--------------------Загрузка бонусов
  FE.Read(ZeroGravity, SizeOf(Boolean));
  FE.Read(Ghost, SizeOf(Boolean));
  if Length(ArrayOfFigure) > 0 then
   for Lvl:= 0 to Length(ArrayOfFigure) - 1 do FE.Read(ArrayOfFigure[Lvl].Allowed, SizeOf(Boolean));

  FE.Read(Tmp, SizeOf(Boolean));
  if Tmp then Helper:=True;
  FE.Read(MarshMode, SizeOf(Boolean));
  FE.Read(FSpeedRate, SizeOf(Smallint));
  FE.Read(Versa, SizeOf(Boolean));
  FE.Read(FShownTutScene, SizeOf(Byte) * SizeOf(Byte));
  FE.Read(IsTheBoss, SizeOf(Boolean));

  for Lvl:=0 to Length(ArrayOfBonuses) - 1 do
   if ArrayOfBonuses[Lvl] is TTimeBonus then
    begin
     FE.Read(Tmp, SizeOf(Boolean));
     if Tmp then
      begin
       (ArrayOfBonuses[Lvl] as TTimeBonus).Activate;
       AddToExed((ArrayOfBonuses[Lvl] as TTimeBonus));
      end;
     FE.Read((ArrayOfBonuses[Lvl] as TTimeBonus).FLastTime, SizeOf(Word));
    end;
  //------------------------------------
  //Освобождаем файл
  FE.Free;
 except
  //Если произойдет исключение
  begin
   //Удаляем сохранение
   DeleteSaved;
   //Сбрасываем значения
   Reset;
   //Освобождаем файл
   FE.Free;
   //Выходим
   Exit;
  end;
 end;
 //Сохранения загружены
 Result:=True;
end;

procedure TTetrisGame.SpeedDown(Value:Byte);
begin
 Dec(FSpeedRate, Value);
end;

procedure TTetrisGame.SpeedUp(Value:Byte);
begin
 Inc(FSpeedRate, Value);
end;

procedure TTetrisGame.Shutdown;
begin
 if FPauseTutorial then
  begin
   PauseGame;
   Exit;
  end;
 if ExecutingBonus then
  begin
   Hint.Show('Подождите', '', ' |Выполняется|бонус', 3, 0);
   Exit;
  end;
 //Если состояние игры - завершение
 if GameState = gsShutdown then
  begin
   //Не выключать игру
   AnswerShut:=0;
   //Ответ дан
   Confirm:=True;
   //Выходим
   Exit;
  end;
 //Если кнопки скрыты - показывем
 if FButtonsHided then
  begin
   ShowButtons;
   Exit;
  end;
 //Если состояние игры - пауза, игра или рисование
 if GameState in [gsPause, gsPlay, gsDrawFigure] then
  begin
   if GameState = gsDrawFigure then DrawingFigureEnd(gsShutdown)
   else GameState:=gsShutdown;
   //Ответ пока не дан
   Confirm:=False;
   //Не сохранять игру
   AnswerShut:=2;
   //Смена названий кнопок
   ArrayOfButtons[0].Text:='Сохранить';
   ArrayOfButtons[1].Text:='Не сохранять';
   ArrayOfButtons[2].Text:='Не выходить';
   //Ждем пока не будет дан ответ или пока программа не будет выключаться
   repeat Application.ProcessMessages until Confirm or Application.Terminated;
   //Смена названий кнопок
   ArrayOfButtons[0].Text:='Пауза';
   ArrayOfButtons[1].Text:='Закончить';
   ArrayOfButtons[2].Text:='Выход';
   //Выбираем действие в зависимости от ответа
   case AnswerShut of
    //Сохраняем игру
    1:if SaveGame then
       begin
        Hint.Show('Мы продолжим?', '', 'Игра|успешно|сохранена', 3, 0);
        Wait(1000);
       end;
    //Не выходим
    0:begin
       //Ставим паузу
       GameState:=gsPlay;
       PauseGame;
       //Выходим
       Exit;
      end;
   end;
   ArrayOfButtons[0].Enable:=False;
   ArrayOfButtons[1].Enable:=False;
   ArrayOfButtons[2].Enable:=False;
  end //Если же состояние игры - окончена или др., то удаляем сохр. игру
 else if not CanBeContinue then DeleteSaved;
 //Звук выключание игры
 Sound.Play(10);
 //Показываем подсказку
 Hint.Show('', '', 'Пока|Возвращайся!', 6, 0);
 //Флаг о завершении игры
 Shutdowning:=True;
 //
 Statistics.Save;
 //Ожидание анимаци
 Wait(1500);
 //Завершение работы
 Application.Terminate;
end;

procedure TTetrisGame.LevelUp;
begin
 Statistics.Append.Level(1);
 //Звук
 Sound.Play(6);
 if FLevel = GlLvls then Exit;
 //Повышаем уровень, устанавливаем скорость
 Level:=FLevel + 1;
 //"Выпускаем" босса
 CreateNextBoss;
 //Сменяем фон
 ChangeBackground(FLevel - 1);
 //Debug
 WriteDebug(Format('Уровень: %d, Счет: %d, Золото: %d', [FLevel, ToScore, ToGold]));
end;

procedure TTetrisGame.StepDownBonuses;
var R, C:Byte;
begin
 //Идем по полю и уменьшаем остаточное время
 for R:=1 to Rows do
  for C:=1 to Cols do
   begin
    if MainTet[R, C].State = bsBonusTiming then
     if MainTet[R, C].TimeLeft > 0 then Dec(MainTet[R, C].TimeLeft)
     else //Если время истекло
      begin
       //Звук исключения бонуса
       Sound.Play(8);
       //Состояние бонуса - сломан
       MainTet[R, C].State:=bsBonusBroken;
      end;
   end;
 //Поднимаем счет
 UpScore(1);
end;

function TTetrisGame.UpGold(Value:Word):Word;
begin
 //Увеличиваем золото
 Inc(ToGold, Value);
 Statistics.Append.Gold(Value);
 //Уже не первое пополнение
 if FirstUpGold and (InfoMode <> imBonuses) then
  begin
   Hint.Show('', '', 'Нажми на меня | чтобы перейти | к бонусам|и обратно', 5, 2);
  end;
 FirstUpGold:=False;
 //Результат - текущиее кол-во золота
 Result:=ToGold;
end;

function TTetrisGame.ElemCount(Figure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //Постой подсчет кол-во элементов фигуры
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   if Figure.Elements[R, C].State <> bsEmpty then Inc(Result);
end;

function TTetrisGame.CreateBonus(var Figure:TFigure):Boolean;
const Size = 30;
var   Chance, R, C, FS, FChance:Byte;
begin
 //В зависимости от уровня две системы подсчета
 //Первые 4 уровня - один бонус на фигуру (если повезет)
 //Последующие уровни - максимальное число бонуов в фигуре
 case FLevel of
  1..4:
   begin
    //Шанс = случайное число из (30 - (Уровень * 2)) + 1
    //1: 2 из 28
    //3: 2 из 26
    //Шанс выпадения бонуса
    Chance:=Random(Size - (FLevel * 2)) + 1;
    //Создаем бонус если значение шанса равно 1 или 2
    Result:=(Chance = 1) or (Chance = 2);
    //Если шанс не выпал - выходим
    if not Result then Exit;
    //Берем случайный пустой элемент
    repeat
     R:=Random(GlSize) + 1;
     C:=Random(GlSize) + 1;
    until Figure.Elements[R, C].State <> bsEmpty;
    //Делаем элемент - бонусом
    Figure.Elements[R, C].State:=bsBonus;
    //Выходим
    Exit;
   end;
 else
  begin
   //Шанс = случайное число из (30 - Уровень) + 1
   //5: 1 из 25
   //13: 1 из 17
   Chance:=Random(Size - FLevel) + 1;
   //Создаем бонусы если значение шанса равно 1
   Result:=Chance = 1;
   //Если не повезло - выходим
   if not Result then Exit;
   //Берем случайное кол-во бонусов для фигуры
   FChance:=Random(6) + 1;
   //Соотносим с кол-во элементов в фигуре
   FChance:=Min(FChance, ElemCount(Figure));
   //Создано бонусов - 0
   FS:=0;
   //Создаем бонусы пока не создадим столько, сколько нужно
   repeat
    //Берем пустой элемент
    repeat
     R:=Random(GlSize) + 1;
     C:=Random(GlSize) + 1;
    until Figure.Elements[R, C].State <> bsEmpty;
    //Делаем из него бонус
    Figure.Elements[R, C].State:=bsBonus;
    //Увеличиваем кол-во созданных бонусов
    Inc(FS);
   until FS = FChance;
   //Выходим (лишнее, да ладно)
   Exit;
  end;
 end;
end;

function TTetrisGame.UpScore(Value:Integer):Integer;
begin
 //Поднимаем счет
 Inc(ToScore, Value);
 Statistics.Append.Score(Value);
 //Разультат - текущее состояние счета
 Result:=ToScore;
end;

function TTetrisGame.GetScaleLvl:Byte;
var FChk:Integer;
begin
 FChk:=Round(((FLines mod LinesAmountForLevelUp) / LinesAmountForLevelUp) * 100);
 if FChk <= 0 then FChk:=1;
 Result:=FChk;
end;

function TTetrisGame.GetLevel:Byte;
begin
 //Уровень = Округленное число((Скорость / (Начальная скорость / GlLvls)) + 1)
 //Result:=Round(GetSpeed / (StartSpeed / GlLvls)) + 1;
 Result:=FLevel;
end;

procedure TTetrisGame.UpdateSpeed;
var ForChk:Integer;
begin
 if Assigned(TimerStep) then
  begin
   ForChk:=(StartSpeed - (StartSpeed div GlLvls) * FLevel) - FSpeedRate;
   if ForChk <= 0 then ForChk:=1;
   TimerStep.Interval:=ForChk;
  end;
end;

procedure TTetrisGame.SetLevel(Value:Byte);
begin
 //if Value = FLevel then Exit;
 if Value <= 0 then Value:=1;
 if Value > GlLvls then Value:=GlLvls;
 UpdateSpeed;
 FLevel:=Value;
end;

procedure TTetrisGame.SetGameState(Value:TGameState);
begin
 //Фиксация состояния игры
 FGameState:=Value;
 //Если есть панели скрываем их
 if Length(ArrayOfPanels) > 0 then if Value <> gsNone then ArrayOfPanels[0].Hide;
 case Value of
  gsNone,
  gsStop:
   begin
    ArrayOfButtons[0].Text:='Начать';
    //Остановка таймеров
    TimerDownStop;
    //
    Timers:=False;
   end;
  gsPause,
  gsDrawFigure:
   begin
    ArrayOfButtons[0].Text:='Продолжить';
    //Остановка таймеров
    TimerDownStop;
    //
    Timers:=False;
   end;
  gsPlay:
   begin
    ArrayOfButtons[0].Text:='Пауза';
    //Пуск таймеров
    TimerDownStart;
    //
    Timers:=True;
   end;
 end;
end;

procedure TTetrisGame.Reset;
var i:Byte;
begin
 //Очищаем зависимые от игры списки
 SetLength(ArrayOfToDo, 0);
 for i:=1 to GlExes do ArrayOfExing[i].Active:=False;
 //Восстанавливаем доступность уровней
 for i:=1 to GlLvls do FLevels[i]:=False;
 //Сбрасываем значения ирока
 Lines:=0;
 OldLevel:=1;
 ToScore:=0;
 ToGold:=StartGold;
 //Устанавливаем изначальную скорость снижения фигуры
 Level:=1;
 //if Assigned(TimerStep) then TimerStep.Interval:=StartSpeed;
end;

procedure TTetrisGame.Boom(Size:Byte; BTime:Word);
begin
 //Сбрасываем счетчик "тряски"
 TimerBoom.Enabled:=False;
 TimerBoom.Interval:=BTime;
 TimerBoom.Enabled:=True;
 //Если новый "толчок" меньше или равен текущей "тряске", то увеличиваем на
 if Size <= FBoom then Inc(FBoom, (Size div 2) + (Size div 3)) else FBoom:=Size;
 if FBoom > 30 then FBoom:=30; //Если "тряска" больше 30, то "вгоняем" ее в границы
 //Да, есть "тряска"
 DoBoom:=True;
end;

procedure TTetrisGame.BoomStop;
begin
 //Если и так нет "тряски" - выходим
 if not DoBoom then Exit;
 //Ускоряем "затухение тряски" если нужно
 if TimerBoom.Interval > 50 then TimerBoom.Interval:=50;
 //Уменьшаем тряску на 3
 if FBoom > 5 then Dec(FBoom, 3);
end;

procedure TTetrisGame.ShowAnimate(ID:Byte);
begin
 if Assigned(Bitmaps) then Bitmaps.Animate:=ID;
end;

procedure TTetrisGame.ShowFigureChanging(FStart, FEnd:TFigure);
var R, C, S:Byte;
begin
 //Создаем следующую фигуру смещением врем1 врем2
 for S:=(GlSize - 1) downto 0 do
  begin
   //На первом шаге берется последняя строка новой фигуры и первые 3 строки предудущей фигуры
   //На втором шаге беретутся 2 последние строки новой и 2 первые строки предыдущей
   //etc.
   for R:=1 to GlSize do
    for C:=1 to GlSize do
     begin
      if (S + R)   <  (GlSize + 1) then NextFigure.Elements[R, C]:=FEnd.Elements[S + R, C] else
      if (R - Abs(S - GlSize)) > 0 then NextFigure.Elements[R, C]:=FStart.Elements[R - Abs(S - GlSize), C];
     end;
   Wait(40);
  end;
 //Фиксация фигуры для устранения конфликтов
 NextFigure:=FEnd;
end;

procedure TTetrisGame.CreateNextFigure;
begin
 ShowFigureChanging(NextFigure, GetRandomFigure);
end;

procedure TTetrisGame.TimerDownStop;
begin
 //Деактивация таймера спуска
 TimerStep.Enabled:=False;
end;

procedure TTetrisGame.TimerDownStart;
begin
 //Запуск таймера спуска
 TimerStep.Enabled:=True;
end;

procedure TTetrisGame.AddButton(AButton:TExtButton);
begin
 //Добавляем в массив ешё одну кнопку
 SetLength(ArrayOfButtons, Length(ArrayOfButtons) + 1);
 ArrayOfButtons[Length(ArrayOfButtons) - 1]:=AButton;
end;

procedure TTetrisGame.Normalization(var Figure:TFigure);

//Проверка на смещение вверх
function Check_C(AF:TFigure):Boolean;
var Fill:Boolean;
    CC:Byte;
begin
 Fill:=False;
 for CC:=1 to GlSize do
  if AF.Elements[1, CC].State <> bsEmpty then
   begin
    Fill:=True;
    Break;
   end;
 Result:=Fill;
end;

//Проверка на смещение влево
function Check_R(AF:TFigure):Boolean;
var Fill:Boolean;
    CR:Byte;
begin
 Fill:=False;
 for CR:=1 to GlSize do
  if AF.Elements[CR, 1].State <> bsEmpty then
   begin
    Fill:=True;
    Break;
   end;
 Result:=Fill;
end;

//Смещение вверх
procedure MoveUp(var Figure:TFigure);
var C:Byte;
begin
 for C:=1 to GlSize do
  begin
   Figure.Elements[1, C]:=Figure.Elements[2, C];
   Figure.Elements[2, C]:=Figure.Elements[3, C];
   Figure.Elements[3, C]:=Figure.Elements[4, C];
   Figure.Elements[4, C].State:=bsEmpty;
  end;
end;

//Смещение влево
procedure MoveLeft(var Figure:TFigure);
var R:Byte;
begin
 for R:=1 to GlSize do
  begin
   Figure.Elements[R, 1]:=Figure.Elements[R, 2];
   Figure.Elements[R, 2]:=Figure.Elements[R, 3];
   Figure.Elements[R, 3]:=Figure.Elements[R, 4];
   Figure.Elements[R, 4].State:=bsEmpty;
  end;
end;

begin
 //Сместим как нужно (влево, вверх)
 while not Check_C(Figure) do MoveUp(Figure);
 while not Check_R(Figure) do MoveLeft(Figure);
end;

function TTetrisGame.RotateFigure(Figure:TFigure; OnSentry:Boolean):TFigure;
var R, C:Byte;
begin
 //Повернем фигуру
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    if OnSentry then
     Result.Elements[C, Abs(R - GlSize) + 1]:=Figure.Elements[R, C]
    else Result.Elements[(GlSize - C) + 1, R]:=Figure.Elements[R, C];
   end;
 Normalization(Result);
end;

constructor TTetrisGame.Create(ACanvas:TCanvas);
begin
 //Шаг загрузки игры - 0
 LoadState:=0;
 //Флаг о том, что идет инициализация игры
 Creating:=True;
 //Включение/выключение отладки
 DebugEnabled:=False;
 //Конструирование игрового движка
 FDrawCanvas:=ACanvas;
 //Установка значений "констант" и первоначальных значений других величин
 FieldWidth:=440;
 FieldHeight:=460;
 //FCanvas:=TDirect2DCanvas.Create(ACanvas, Rect(0, 0, FieldWidth, FieldHeight));
 FWaitAmount:=0;
 BadGameBonusCount:=5;
 aEmpty:=0;
 Shutdowning:=False;
 BonusAmountWidth:=GlSize;
 StartSpeed:=900;
 DoDrawFigure:=dtNotWork;
 IDDrawFigure:=1;
 OldIM:=imInfoText;
 UserFPS:=40;
 LinesAmountForLevelUp:=50; //20
 Helper:=False;
 FButtonsHiding:=False;
 FButtonsHided:=False;
 Versa:=False;
 FirstUpGold:=True;
 ShowCursos:=True;
 GoldPos:=Point(300, 200);
 FSpeedRate:=0;
 FRows:=GlRows;
 FCols:=GlCols;
 FWidth:=20;
 FBoom:=0;
 FHeight:=20;
 Patched.ID:=0;
 IsCreating:=False;
 FigureEnable:=False;
 StartGold:=0;
 Patched.State:=bsElement;
 TheardDraw:=TDrawThread.Create(Self, False);
 Redraw:=TRedrawing.Create(Self);
 Statistics:=TStatistics.Create(Self);
end;

function TTetrisGame.GetSpeed:Word;
begin
 //Узнать скорость исходя из значений таймера
 Result:=Abs(TimerStep.Interval - StartSpeed) + 1;
end;

procedure TTetrisGame.ClearAll;
var R, C:Word;
begin
 //Очистка тени
 Shade.Clear;
 //Очищаем поле с эффектом "стирание по элементу"
 for R:=1 to Rows do
  begin
   //Стираем строку тем же методом, которым удаляем заполенную
   AnimateDelete(R);
   for C:=1 to Cols do
    begin
     MoveTet[R, C].State:=bsEmpty;
     MainTet[R, C].State:=bsEmpty;
    end;
  end;
end;

procedure TTetrisGame.WriteDebug(Text:string);
var Debug:TextFile;
begin
 //if not DebugEnabled then Exit;
 AssignFile(Debug, ProgramPath + DebgFN);
 if FileExists(ProgramPath + DebgFN) then Append(Debug) else Rewrite(Debug);
 write(Debug, FormatDateTime('dd.mm.yy hh:mm:ss', Now)+': '+Text);
 write(Debug, #13#10);
 CloseFile(Debug);
end;

procedure TTetrisGame.WaitWithoutStop(MTime:Word);
var Tick:Cardinal;
begin
 //Если идет инициализация - выходим
 if Creating then Exit;
 //Если требуется ожидание меньше 2 мсек.
 if MTime < 2 then
  begin
   //Позволяем Windows подать нам сообщение
   Application.ProcessMessages;
   //Выходим
   Exit;
  end;
 //Фиксируем текущее время
 Tick:=GetTickCount;
 //Ждем прихода нужного времени
 repeat
  //Позволяем Windows подать нам сообщение
  Application.ProcessMessages;
 until Tick + MTime < GetTickCount;
end;

procedure TTetrisGame.Wait(MTime:Word);
var Tick:Cardinal;
begin
 //Если идет инициализация - выходим
 if Creating then Exit;
 //Если требуется ожидание меньше 2 мсек.
 if MTime < 2 then
  begin
   //Позволяем Windows подать нам сообщение
   Application.ProcessMessages;
   //Выходим
   Exit;
  end;
 //Останавливаем таймер
 TimerDownStop;
 //Идет ожидание
 IsWait:=True;
 //Фиксируем текущее время
 Tick:=GetTickCount;
 //Увеличиваем счетчик ожиданий (для синхронизации с другими входами в эту процедуру)
 Inc(FWaitAmount);
 //Ждем прихода нужного времени
 repeat
  //Позволяем Windows подать нам сообщение
  Application.ProcessMessages;
 until Tick + MTime < GetTickCount;
 //Уменьшаем кол-во ожиданий
 Dec(FWaitAmount);
 //Если кол-во ожиданий = 0
 if FWaitAmount <=0 then
  begin
   //Запускаем таймер
   TimerDownStart;
   //Снимаем ожидание
   IsWait:=False;
  end;
 //Если же был ещё один вход в процедуру ожидания, то по её окончании она, если условие позволит, и снимет флаг ожидания
end;

procedure TTetrisGame.AddFigure(Figure:TFigure; var Dest:TArrayOfFigure);
var R, C, Num:Byte;
begin
 //Пополняем массив
 SetLength(Dest, Length(Dest) + 1);
 //Личный ИД фигуры - порядковый номер в массиве
 Num:=Length(Dest);
 //Меняем "активные" элементы фигуры на ИД
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    if Figure.Elements[R, C].ID = aEmpty then Figure.Elements[R, C].State:=bsEmpty else Figure.Elements[R, C].State:=bsElement;
    Figure.Elements[R, C].ID:=Num;
    Figure.Elements[R, C].TimeLeft:=0;
   end;
 //Добавляем в массив
 Dest[Length(Dest)-1]:=Figure;
end;

function TTetrisGame.GetRandomFigure:TFigure;
begin
 //Выбираем случайную доступную фигура
 repeat NextID:=Random(Length(ArrayOfFigure)) until ArrayOfFigure[NextID].Allowed;
 CreatedBoss:=False;
 Result:=ArrayOfFigure[NextID];
 while Random(5) <> 3 do Result:=RotateFigure(Result, Boolean(Random(2)));
end;

function TTetrisGame.GetPreviewFigure:TFigure;
var i, j:Byte;
begin
 //Выбираем случайную доступную фигура
 repeat NextID:=Random(Length(ArrayOfFigure)) until ArrayOfFigure[NextID].Allowed;
 CreatedBoss:=False;
 Result:=ArrayOfFigure[NextID];
 for i:= 1 to 4 do for j:=1 to 4 do
  begin
   Result.Elements[i, j].State:=bsElement;
   Result.Elements[i, j].ID:=Random(5) + 1;
  end;
 while Random(5) <> 3 do Result:=RotateFigure(Result, Boolean(Random(2)));
end;

function TTetrisGame.GetNextBoss:TFigure;
begin
 //Если (пусть и невозможно) уровень превышает кол-во боссов
 if FLevel > Length(ArrayOfBosses) then
  begin
   //Берем обычную фигуру
   Result:=GetRandomFigure;
   //Выходим
   Exit;
  end;
 //Босс создан
 CreatedBoss:=True;
 //Результат - босс текущего уровня
 Result:=ArrayOfBosses[FLevel - 1];
end;

procedure TTetrisGame.Merger;
var C, R:Byte;
begin
 for C:=1 to Cols do
  for R:=1 to Rows do
   begin
    //Если элемент не пуст то сливаем с осн. массивом
    if MoveTet[R, C].State <> bsEmpty then MainTet[R, C]:=MoveTet[R, C];
    //Если элемент фигуры - бонус
    if MainTet[R, C].State = bsBonus then
     begin
      //Задаем случайное время 30 - 50 сек.
      MainTet[R, C].TimeLeft:=Random(50 - 30) + 30;
      //Состояние элемента - идет таймер
      MainTet[R, C].State:=bsBonusTiming;
     end;
    //Очищаем элемент в движ. массиве
    MoveTet[R, C].State:=bsEmpty;
   end;
end;

function TTetrisGame.CheckLine:Boolean;
var R, C:Byte;
begin
 //"Подозреваем", что есть элементы в поле до GlHdRw для прекращения игры
 Result:=True;
 for R:=1 to GlHdRw do
  for C:=1 to Cols div 2 do
   begin
    //Если есть элемент фигуры выходим (подтверждая, что будем заканчивать игру)
    if MainTet[R, C].State <> bsEmpty then Exit;
    if MainTet[R, C + (Cols div 2)].State <> bsEmpty then Exit;
    //Алгоритм ускорен в два раза
   end;
 //Нет, поле впорядке, продолжаем играть
 Result:=False;
end;

procedure TTetrisGame.ClrChng(var Chng:TTetArray);
var C, R:Byte;
begin
 for C:=1 to Cols do for R:=1 to Rows do Chng[R, C].State:=bsEmpty;
end;

procedure TTetrisGame.NewGame;
begin
 WriteDebug('Новая игра');
 //Останавливаем фон. музыку
 Sound.Stop(100);
 //Играем звук "запуск игры"
 Sound.Play(3);
 //Останавливаем "тряску"
 BoomStop;
 //Останавливаем таймер спуска
 TimerDownStop;
 FEditBoxActive:=False;
 ZeroGravity:=False;
 //
 Timers:=False;
 //Сбрасываем значения игрока
 Reset;
 //Фигура не создается
 IsCreating:=False;
 //Фигура отсутствует
 FigureEnable:=False;
 //Сменяем фон для первого уровня
 ChangeBackground(0);
 //Очищаем все массивы
 ClearAll;
 //Состояние игры - "идет игра"
 GameState:=gsPlay;
 //Делаем первый шаг (создавая фигуру и перемещая ее вниз)
 StepDown;
 //Запускаем таймер спуска
 TimerDownStart;
 //
 Timers:=True;
 //Кнопка "Стоп" активна
 ArrayOfButtons[1].Enable:=True;
 //Восстанавливаем текст на кнопке
 ArrayOfButtons[1].Text:='Закончить';
 //Если золото не пополнялось показываем подсказку (просто совпало с золотом =))
 if FirstUpGold then
  begin
   Hint.Show('Кнопки скрылись', '', 'кликни по мне | правой кнопкой мыши | для их возврата', 5, 5);
  end;
end;

procedure TTetrisGame.StopGame;
var ScoreTop:Byte;
begin
 if ExecutingBonus then
  begin
   Hint.Show('Подождите', '', ' |Выполняется|бонус', 3, 0);
   Exit;
  end;
 if CanBeContinue then
  begin
   CanBeContinue:=False;
   if LoadGame then
    begin
     ContinueGame;
    end
   else
    begin
     with ArrayOfButtons[1] do
      begin
       Text:='Закончить';
       Enable:=False;
      end;
    end;
   Exit;
  end;
 if GameState = gsShutdown then
  begin
   AnswerShut:=2;
   Confirm:=True;
   Exit;
  end;
 //Если уже не играем - выходим
 if (GameState = gsStop) or (GameState = gsNone) then Exit;
 //Звук "игра окончена"
 Sound.Play(1);
 //Останавливаем таймер спуска
 TimerDownStop;
 //
 Timers:=False;
 //Кнопка "Стоп" не активна
 ArrayOfButtons[1].Enable:=False;
 //Режми дисп. - текст
 InfoMode:=imInfoText;
 //Состояние игры - "игра окончена"
 DrawingFigureClose(gsStop);
 //Создание фигуры - нет
 IsCreating:=False;
 //Есть фигура - нет
 FigureEnable:=False;
 //Удаляем сохраненную игру
 DeleteSaved;
 //Деактивируем временные бонусы
 DeactivateAllBonuses;
 //Выводим счет и поле для ввода имени игрока
 if Statistics.CheckScore(ToScore) then
  begin
   FEditBoxActive:=True;
   while FEditBoxActive and (not Shutdowning) do Application.ProcessMessages;
   if FEditBoxText <> '' then
    begin
     ScoreTop:=Statistics.InsertTheBest(FEditBoxText, ToScore);
     if ScoreTop = 1 then
      Hint.Show('Ура!', '1', 'Вы поставили|новый рекорд|и заняли|1 место', 5, 0)
     else Hint.Show('Молодец', IntToStr(ScoreTop), 'Вы попали|в десятку|лучших игроков', 5, 0);
    end;
  end;
 //Возвращаем кнопки на место
 ShowButtons;
end;

procedure TTetrisGame.PauseGame;
var spd:Byte;
begin
 //Отладочный скрин
 //if DebugEnabled then DrawBMP.SaveToFile(ProgramPath + ScrnFN);
 //
 if ExecutingBonus and (not FPauseTutorial) then
  begin
   Hint.Show('Подождите', '', ' |Выполняется|бонус', 3, 0);
   Exit;
  end
 else
  if FPauseTutorial then
   while ExecutingBonus do
    Application.ProcessMessages;
 //Состояние
 case GameState of
  gsShutdown:
   begin
    AnswerShut:=1;
    Confirm:=True;
    Exit;
   end;
  gsNone,
  gsStop:
   begin
    //Создаем новую игру
    NewGame;
    //ЕСли кнопки не скрыты - скрываем
    if not FButtonsHided then HideButtons(True);
    //Убираем мышь с поля
    MoveMouse;
    //Запрещаем продолжать игру
    CanBeContinue:=False;
    //Выходим
    Exit;
   end;
  gsPlay:
   begin
    if FPauseTutorial then
     begin
      //Звук "пауза"
      Sound.Play(3);
      //Состояние игры - пауза
      GameState:=gsPause;
      ArrayOfButtons[1].Enable:=False;
      ArrayOfButtons[2].Enable:=False;
      spd:=5;
      while TutorialPos < 0 do
       begin
        Inc(spd);
        TutorialPos:=TutorialPos + spd;
        WaitWithoutStop(2);
       end;
      TutorialPos:=0;
      if FButtonsHided then ShowButtons;
     end
    else
     begin
      //Звук "пауза"
      Sound.Play(3);
      //Состояние игры - пауза
      GameState:=gsPause;
      if FButtonsHided then ShowButtons;
      //Инф. дисп. - текст
      OldIM:=InfoMode;
      InfoMode:=imInfoText;
     end;
   end;
  gsPause:
   begin
    FEditBoxActive:=False;
    //Звук "выхода из паузы"
    Sound.Play(4);
    if FPauseTutorial then
     begin
      spd:=5;
      while TutorialPos <= FieldHeight do
       begin
        Inc(spd);
        TutorialPos:=TutorialPos + spd;
        WaitWithoutStop(2);
       end;
      TutorialPos:=FieldHeight + 2;
      FPauseTutorial:=False;
      ArrayOfButtons[1].Enable:=True;
      ArrayOfButtons[2].Enable:=True;
     end;
    //Режми дисп. предыдущий
    InfoMode:=OldIM;
    //Состояние игры - "идет игра"
    GameState:=gsPlay;
    if not FButtonsHided then HideButtons(True);
    MoveMouse;
   end;
  gsDrawFigure:DrawingFigureEnd(gsPlay);
 end;
end;

function TTetrisGame.CheckCollision(TetArray:TTetArray; ATop, ALeft:Byte; IsShade:Boolean):Boolean;
var C, R:Byte;
   CloseGhost:Boolean;
begin
 //Столкновения нет
 Result:=False;
 CloseGhost:=False;
 if ATop > Rows then
  begin
   Ghost:=False;
   Result:=True;
   Exit;
  end;
 //Шагаем по области в которой расположена фигура
 for R:=ATop to ATop + (GlSize - 1) do
  begin
   //Если вышли за границы - выходим
   if R > Rows then Break;
   for C:=ALeft to ALeft + (GlSize - 1) do
    begin
     //Если вышли за границы - прерываем цикл
     if C >= Cols + 1 then Break;
     //Если меньше 0 - пропускаем итерацию
     if C <= 0 then Continue;
     //Если ячейка пустая - пропускаем итерацию
     if TetArray[R, C].State = bsEmpty then Continue;
     //Если следующая строка выходит за границы - столкновение, выходим
     if R + 1 > Rows then
      begin
       CloseGhost:=not IsShade;
       if Ghost then
        begin
         WasGhostColl:=True;
         Result:=True;
         Break;
        end;
      end;
     if not Ghost then
      begin
       //Если следующая строка выходит за границы - столкновение, выходим
       if R + 1 > Rows then
        begin
         Result:=True;
         Break;
        end;
       //Если есть пересечения - столкновение - выходим
       if MainTet[R, C].State <> bsEmpty then begin Result:=True; Break; end;
       //Если в следующей строке ячейка не пуста - столкновение - выходим
       if MainTet[R + 1, C].State <> bsEmpty then begin Result:=True; Break; end;
      end;
    end;
  end;
 if CloseGhost then Ghost:=False;
end;

function TTetrisGame.CheckCollision(TetArray:TTetArray; ATop:Byte; IsShade:Boolean):Boolean;
begin
 //Проверим на столкновения на текущем положении текущей фигуры
 Result:=CheckCollision(TetArray, ATop, LeftPos, IsShade);
end;

function TTetrisGame.CheckCollision(TetArray:TTetArray; IsShade:Boolean):Boolean;
begin
 //Проверим на столкновения на высоте текущей фигуры
 Result:=CheckCollision(TetArray, TopPos, IsShade);
end;

function TTetrisGame.WidthOfFigure(AFigure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //Ширина фигуры - крайние (слева и справа) элементы фигуры
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    //Если элемент не пустой берем его в расчет
    if AFigure.Elements[R, C].State <> bsEmpty then if Result < C then Result:=C;
    //Если ширина уже GlSize - нет смысла продолжать цикл - выходим
    if Result = GlSize then Exit;
   end;
end;

function TTetrisGame.HeightOfFigure(AFigure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //Высота фигуры - крайние (сверху и снизу) элементы фигуры
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    //Если элемент не пустой берем его в расчет
    if AFigure.Elements[R, C].State <> bsEmpty then if Result < R then Result:=R;
    //Если ширина уже GlSize - нет смысла продолжать цикл - выходим
    if Result = GlSize then Exit;
   end;
end;

procedure TTetrisGame.NeedDraw;
begin
 TheardDraw.Execute;
end;

procedure TTetrisGame.NewFigure;
var C, R, L:Byte;
begin
 ZeroGravity:=False;
 //Идет создание фигуры
 IsCreating:=True;
 //Если уже есть фигура, сливаем осн. поле с движ. полем
 if FigureEnable then Merger;
 //Выполнить удаление заполненных строк
 ExecutingDelete;
 //Пока не выберем нормальную фигуру - выбирать фигуру
 while WidthOfFigure(NextFigure) <= 0 do CreateNextFigure;
 //Фигура - заготовленная фигура
 CurFigure:=NextFigure;
 Statistics.Append.Figure(1);
 //Если создастся босс
 if CreatedBoss then
  begin
   //Идет босс
   IsTheBoss:=True;
   //Звук "босс"
   Sound.Play(14);
  end //Если же нет - босса нет
 else IsTheBoss:=False;
 //Если создастся бонус - звук "бонус"
 if CreateBonus(CurFigure) then
  begin
   Sound.Play(12);
   Event(eventTutorial, eventBonus, 0);
  end;
 //Создаем заготовленную фигуру
 CreateNextFigure;
 //Если уровень меньше 10, то фигура по центру поля
 if FLevel < 10 then L:=(Cols div 2) - (WidthOfFigure(CurFigure) div 2)
 //Если же больше, либо равно 10, то в случайном месте
 else L:=Random(Cols - (WidthOfFigure(CurFigure) - 1));
 for C:=1 to GlSize do
  for R:=1 to GlSize do
   begin
    //Если при появлении фигуры, она столкнется
    if (CurFigure.Elements[R, C].State <> bsEmpty) and (MainTet[R, C + L].State <> bsEmpty) then
     begin
      //"Тряска"
      Boom(10, 300);
      //Стоп игра
      StopGame;
      //Выходим
      Exit;
     end;
    //Добавляем элемент фигуры в движ. поле
    MoveTet[R, C + L]:=CurFigure.Elements[R, C];
   end;
 //Высота - 1
 TopPos:=1;
 //Положение слева - положение спуска + 1
 LeftPos:=L + 1;
 //Если найдены столкновения
 if CheckCollision(MoveTet, False) then
  begin
   //Бум
   Boom(10, 300);
   //Стоп игра
   StopGame;
   //Выходим
   Exit;
  end;
 //Фигура есть
 FigureEnable:=True;
 //Создание окончено
 IsCreating:=False;
 //Обновляем тень
 Shade.Update;
 //Сбрасываем силу нажатия кнопки "Вниз"
 //ResetForceDown;
end;

procedure TTetrisGame.Move(Bottom:Byte);
var C, R, ABonuses:Byte;
    UpsGold:Word;
begin
 //Золото - 0
 UpsGold:=0;
 //Бонусов - 0
 ABonuses:=0;
 //Анимация удаления на высоте Bottom
 AnimateDelete(Bottom);
 //
 Wait(100);
 //Удаляем строку с подсчетом бонусов, золота и поднятием счета
 for C:=1 to Cols do
  begin
   //Если это бонус
   if MainTet[Bottom, C].State in [bsBonus, bsBonusTiming] then
    begin
     //Если случайное число от 1 до 3 не равно 1, то прибавляем золото, в противном случае это бонусное действие
     if Random(3) + 1 <> 1 then Inc(UpsGold, Random(86) + 15) else Inc(ABonuses);
     //255 очков за бонус
     UpScore(255);
    end;
   //Опустошаем элемент
   MainTet[Bottom, C].State:=bsEmpty;
  end;
 //Поднимаем золото за строку и за бонусы по формуле (5 * Уровень)
 if UpsGold > 0 then Sound.Play(9);
 UpGold(UpsGold + 5 * FLevel);
 //Звук "удаление линии"
 Sound.Play(2);
 //"Тряска"
 Boom(5, 300);
 //Смещаем поле вниз и очищаем верхнюю строку
 for R:=Bottom downto 1 do
  begin
   for C:=1 to Cols do
    begin
     if R <> 1 then
      begin
       MainTet[R, C]:=MainTet[R - 1, C];
       MainTet[R - 1, C].State:=bsEmpty;
      end
     else MainTet[R, C].State:=bsEmpty;
    end;
  end;
 //Обновляем тень
 Shade.Update;
 //Если попались бонусы - выполняем случайный
 if ABonuses > 0 then for R:=1 to ABonuses do ExecuteRandomBonus(tbCare);
end;

procedure TTetrisGame.RotateGameFigure(OnSentry:Boolean);
var C, R, W:Byte;
    Figure:TFigure;
    ChngTet:TTetArray;
begin
 //Если игра не идет - выходим
 if GameState <> gsPlay then Exit;
 //Если ожидание или создание фигуры - выходим
 if IsWait or IsCreating then Exit;
 //Получаем повернутую фигуру
 Figure:=RotateFigure(CurFigure, OnSentry);
 //Узнаем ширину фигуры
 W:=WidthOfFigure(Figure);
 //Если ширина меньше либо равна 0 - выходим (это тоже не возможно, но все же)
 if W <= 0 then Exit;
 //Если будущее положение выходит из-за границ - выходим
 if LeftPos + (W - 1) >= Cols + 1 then Exit;
 //Очищаем поле для изменения
 ClrChng(ChngTet);
 //Вставляем повернутую фигуру в поле для изменения
 for C:=1 to GlSize do
  for R:=1 to GlSize do
   begin
    if Figure.Elements[R, C].State = bsEmpty then Continue;
    if (TopPos + R - 1 > FRows) or (LeftPos + C - 1 > FCols) then Exit;
    ChngTet[TopPos + R - 1, LeftPos + C - 1]:=Figure.Elements[R, C];
   end;
 //Если не произойдет столкновение с фигурами
 if not CheckCollision(ChngTet, False) then
  begin
   //Звук "повернута фигура"
   Sound.Play(11);
   //Заменяем массив получившимся
   MoveTet:=ChngTet;
   //Меняем текущую фигуру на повернутую (для дисплея)
   CurFigure:=Figure;
   //Обновляем тень
   Shade.Update;
  end;
end;

function TTetrisGame.DeleteFilled(Row:Byte):Byte;
var C, R:Byte;
    Missed:Boolean;
begin
 //Удалено линий - 0
 Result:=0;
 //Если переданная строка вне границ - выходим
 if Row < 1 then Exit;
 //Идем по строкам с текущей
 for R:=Row downto 1 do
  begin
   //Нет пустых
   Missed:=False;
   //Идем по столбцам
   for C:=1 to Cols do
    begin
     //Если элемент - пуст
     if MainTet[R, C].State = bsEmpty then
      begin
       //Есть пустые
       Missed:=True;
       //Прерываем цикл
       Break;
      end;
    end;
   //Если нет пустых
   if not Missed then
    begin
     //Удаляем строку и смещаем поле
     Move(R);
     //Увеличиваем кол-во удаленных строк
     Inc(Result);
     //Увеличиваем кол-во удаленных строк на кол-во удаленных строк рекурсивной функции, передав номер последней обработанной строки
     Inc(Result, DeleteFilled(R));
     //Выходим
     Exit;
    end;
  end;
end;

procedure TTetrisGame.StepUp;
var C, R, AForceDown:Byte;
    Chng:TTetArray;
begin
 //Если не идет игра - выходим
 if GameState <> gsPlay then Exit;
 //Если ожидание или создание фигуры - выходим
 if IsWait or IsCreating then Exit;
 //Если нет фигуры - выходим
 if not FigureEnable then NewFigure;
 //Если есть элементы в верхней части поля
 if CheckLine then
  begin
   //Бум
   Boom(10, 300);
   //стоп игра
   StopGame;
   //Выходим
   Exit;
  end;
 //Фиксируем силу нажатия кнопки "Вверх"
 AForceDown:=GameKeys[FKeyIDUP].ForceDown;
 //AForceUP:=ForceUp;
 WasGhostColl:=False;
 Chng:=MoveTet;
 //Смещаем фигуру вниз и очищаем верх
 for R:=GlFVRw to Rows do
  for C:=1 to Cols do
   begin
    if R = Rows then Chng[R, C].State:=bsEmpty
    else Chng[R, C]:=Chng[R + 1, C];
   end;
 if TopPos - 1 < GlFVRw then Exit;
 if CheckCollision(Chng, TopPos - 1, False) then Exit;
 //Если есть столкновения
 if CheckCollision(MoveTet, False) then
  begin
   //Ожидание 300 мсек. (отдышаться игроку)
   Wait(300);
   //Создаем новую фигуру
   NewFigure;
   //Увеличиваем счет по формуле: 10 + (Уровень * 100)
   UpScore(10 + (FLevel * 100));
   //Если это был босс - увеличиваем ещё счет по формуле: 1000 + (Уровень * 100)
   if IsTheBoss then UpScore(1000 + (FLevel * 100));
   //Выходим
   Exit;
  end;
 //Смещаем фигуру вниз и очищаем верх
 for R:=GlFVRw to Rows do
  for C:=1 to Cols do
   begin
    if R = Rows then MoveTet[R, C].State:=bsEmpty
    else MoveTet[R, C]:=MoveTet[R + 1, C];
   end;
 //Уменьшаем высоту
 Dec(TopPos);
 //Если есть столкновения
 if CheckCollision(MoveTet, False) or WasGhostColl or (TopPos - 1 < GlFVRw) then
  begin
   WasGhostColl:=False;
   //Если был босс звук "босс приземлился", если нет "фигура приземлилась"
   if IsTheBoss then Sound.Play(15) else Sound.Play(5);
   //Если нажата клавиша вверх
   if AForceDown > 30 then
    begin
     //Если был босс - бум 1 если нет бум 2
     if IsTheBoss then Boom(6, 400) else Boom(3, 300);
    end
   else //Если же нет
    begin
     //Если был босс - бум 1 если нет бум 2
     if IsTheBoss then Boom(3, 300) else Boom(2, 100);
    end;
  end;
end;

procedure TTetrisGame.StepDown;
var C, R, AForceDown:Byte;
begin
 //Если не идет игра - выходим
 if GameState <> gsPlay then Exit;
 //Если ожидание или создание фигуры - выходим
 if IsWait or IsCreating then Exit;
 //Если нет фигуры - выходим
 if not FigureEnable then NewFigure;
 //Если есть элементы в верхней части поля
 if CheckLine then
  begin
   //Бум
   Boom(10, 300);
   //стоп игра
   StopGame;
   //Выходим
   Exit;
  end;
 WasGhostColl:=False; 
 //Если есть столкновения
 if CheckCollision(MoveTet, False) then
  begin
   //Ожидание 300 мсек. (отдышаться игроку)
   Wait(300);
   //Создаем новую фигуру
   NewFigure;
   //Увеличиваем счет по формуле: 10 + (Уровень * 100)
   UpScore(10 + (FLevel * 100));
   //Если это был босс - увеличиваем ещё счет по формуле: 1000 + (Уровень * 100)
   if IsTheBoss then UpScore(1000 + (FLevel * 100));
   //Выходим
   Exit;
  end;
 //Фиксируем силу нажатия кнопки "Вниз"
 AForceDown:=GameKeys[FKeyIDDown].ForceDown;
 //Смещаем фигуру вниз и очищаем верх
 for R:=Rows downto 1 do
  for C:=1 to Cols do
   begin
    if R = 1 then MoveTet[1, C].State:=bsEmpty
    else MoveTet[R, C]:=MoveTet[R - 1, C];
   end;
 //Уменьшаем высоту
 Inc(TopPos);
 //Если есть столкновения
 if CheckCollision(MoveTet, False) or WasGhostColl then
  begin
   WasGhostColl:=False;
   //Если был босс или включен режим "Болото", сила нажатия > 30% и высота позволяет
   if (IsTheBoss or MarshMode) and (AForceDown > 30) and (TopPos + HeightOfFigure(CurFigure) <= Rows) then
    begin
     //Смещаем фигуру еще на один уровень вниз
     for R:=Rows downto 2 do
      for C:=1 to Cols do MoveTet[R, C]:=MoveTet[R - 1, C];
     for C:=1 to Cols do MoveTet[1, C].State:=bsEmpty;
     //Уменьшаем высоту
     Inc(TopPos);
    end;
   //Если был босс звук "босс приземлился", если нет "фигура приземлилась"
   if IsTheBoss then Sound.Play(15) else Sound.Play(5);
   //Если нажата клавиша вниз
   if AForceDown > 30 then
    begin
     //Если был босс - бум 1 если нет бум 2
     if IsTheBoss then Boom(6, 400) else Boom(3, 300);
    end
   else //Если же нет
    begin
     //Если был босс - бум 1 если нет бум 2
     if IsTheBoss then Boom(3, 300) else Boom(2, 100);
    end;
  end;
end;

procedure TTetrisGame.ExecutingDelete;
var Dels:Byte;
begin
 //Удаляем и получаем кол-во только что удаленных строк
 Dels:=DeleteFilled(Rows);
 //Если удалено несколько строк
 if Dels > 0 then
  begin
   //Повышаем кол-во удаленных строк
   LinesUp(Dels);
   //Поднмаем счет по формуле Кол-во линий * (Уровень + Скорость + (0..14))
   UpScore(Lines * (FLevel + GetSpeed + Random(15)));
  end;
end;

procedure TTetrisGame.StepLeft;
var C, R:Byte;
    ABoom:Boolean;
begin
 //Если не идет игра = выходим
 if GameState <> gsPlay then Exit;
 //Если ожидание или идет создание фигуры - выходим
 if IsWait or IsCreating then Exit;
 //Делать "бум" - нет
 ABoom:=False;
 //С высоты фигуры порверяем возможность на смещение влево и выходим з процедуры если что-то мешает
 for R:=TopPos to TopPos + (GlSize - 1) do
  begin
   if R > Rows then Break;
   for C:=LeftPos to LeftPos+(GlSize - 1) do
    begin
     if C > Cols then Break;
     if (MoveTet[R, C].State <> bsEmpty) then
      begin
       if C - 1 < 1 then Exit;
       if C - 2 < 1 then ABoom:=True;
       if not Ghost then
        begin
         if (MainTet[R, C - 1].State <> bsEmpty) then Exit;
         if (C - 2) > 0 then if (MainTet[R, C - 2].State <> bsEmpty) then ABoom:=True;
        end;
      end;
    end;
  end;
 //Идем по границам фигуры (Смещение)
 for R:=TopPos to TopPos + (GlSize - 1) do
  begin
   //Если строка вышла за границы - прерываем смещение
   if R > Rows then Break;
   //Идем по границам фигуры
   for C:=LeftPos to LeftPos + (GlSize - 1) do
    begin
     //Проверяем границы
     if (C < 1) or (C > Cols) then Continue;
     //И если не пусто
     if MoveTet[R, C].State <> bsEmpty then
      begin
       //Элемент левее приравнивается к текущему
       MoveTet[R, C - 1]:=MoveTet[R, C];
       //Текущий обнуляется
       MoveTet[R, C].State:=bsEmpty;
      end;
    end;
  end;
 //Если во время проверки появилась необходимость сделать бум, делаем бум
 if ABoom then
  begin
   //Звук "фигура об стену"
   Sound.Play(7);
   //Если зажата клавиша влево делаем бум
   if GameKeys[FKeyIDLeft].ForceDown > 0 then Boom(2, 50);
  end;
 //Уменьшаем положение по X
 Dec(LeftPos);
 //Обновляем тень
 Shade.Update;
end;

procedure TTetrisGame.StepRight;
var C, R:Byte;
    ABoom:Boolean;
begin
 //Аналогично смещению влево (изменив кое-где знак + на -)
 if GameState <> gsPlay then Exit;
 if IsWait or IsCreating then Exit;
 ABoom:=False;
 for R:=TopPos to TopPos + (GlSize - 1) do
  begin
   if R > Rows then Break;
   for C:=LeftPos to LeftPos+(GlSize - 1) do
    begin
     if C > Cols then Break;
     if (MoveTet[R, C].State <> bsEmpty) then
      begin
       if C + 1 > Cols then Exit;
       if C + 2 > Cols then ABoom:=True;
       if not Ghost then
        begin
         if (MainTet[R, C + 1].State <> bsEmpty) then Exit;
         if (C + 2) < Rows - 1 then if (MainTet[R, C + 2].State <> bsEmpty) then ABoom:=True;
        end;
      end;
    end;
  end;
 for R:=TopPos to TopPos + (GlSize - 1) do
  begin
   if R > Rows then Break;
   for C:=LeftPos + (GlSize - 1) downto LeftPos do
    begin
     if (C < 1) or (C > Cols) then Continue;
     if MoveTet[R, C].State <> bsEmpty then
      begin
       MoveTet[R, C + 1]:=MoveTet[R, C];
       MoveTet[R, C].State:=bsEmpty;
      end;
    end;
  end;
 if ABoom then
  begin
   Sound.Play(7);
   if GameKeys[FKeyIDRight].ForceDown > 0 then Boom(2, 50);
  end;
 Inc(LeftPos);
 Shade.Update;
end;

procedure TTetrisGame.Tutorial(Scene:Byte);
var Dll:Cardinal;
begin
 if FPauseTutorial then Exit;
 Include(FShownTutScene, Scene);
 TutorialImg:=TPNGObject.Create;
 DLL:=LoadLibrary(PChar(ProgramPath+'\Data\'+TetDll));
 if FindResource(Dll, PChar('Scene_'+IntToStr(Scene)), RT_RCDATA) = 0 then Exit;
 try
  TutorialImg.LoadFromResourceName(Dll, PChar('Scene_'+IntToStr(Scene)));
 except
  Exit;
 end;
 TutorialPos:= - TutorialImg.Height;
 FreeLibrary(Dll);
 while ExecutingBonus do Application.ProcessMessages;
 FPauseTutorial:=True;
 PauseGame;
end;

procedure TTetrisGame.TimerDrawTimer(Sender: TObject);
begin
 NeedDraw;
end;

procedure TTetrisGame.TimerBonusCtrlTimer(Sender: TObject);
var i, j:Word;
begin
 if ExecutingBonus or IsWait or IsCreating or (not FigureEnable) then Exit;
 if Length(ArrayOfToDo) > 0 then
  begin
   for i:=0 to Length(ArrayOfToDo) - 1 do
    begin
     if Assigned(ArrayOfToDo[i]) then
      begin
       ExecuteBonus(ArrayOfToDo[i]);
       if i = Length(ArrayOfToDo) - 1 then
        begin
         SetLength(ArrayOfToDo, Length(ArrayOfToDo) - 1);
         Break;
        end;
       for j:=i to Length(ArrayOfToDo) - 2 do ArrayOfToDo[j]:=ArrayOfToDo[j + 1];
       SetLength(ArrayOfToDo, Length(ArrayOfToDo) - 1);
       Break;
      end;
    end;
  end;
end;

procedure TTetrisGame.TimerStepTimer(Sender: TObject);
begin
 //Если зажата клавиша вниз - выходим
 if GameKeys[FKeyIDDown].ForceDown > 0 then Exit;
 //Если отключена гравитация - выходим
 if ZeroGravity then Exit;
 //Смещаем фигуру вниз
 try
  StepDown;
 except
  MessageBox(0, '', 'Поймал!', MB_OK);
 end;
end;

procedure TTetrisGame.TimerUpValuesTimer(Sender: TObject);
begin
 //Пошаговое изменение значений (счет и золото) (Для анимации)
 if Score < ToScore then
  begin
   if ToScore - Score < 100000 then
    begin
     if ToScore - Score < 10000 then
      begin
       if ToScore - Score < 1000 then
        begin
         if ToScore - Score < 100 then
          Inc(Score, 1)
         else Inc(Score, 100);
        end
       else Inc(Score, 1000);
      end
     else Inc(Score, 10000)
    end
   else Inc(Score, 100000);
   if Score > ToScore then Score:=ToScore;
  end;
 if Score > ToScore then
  begin
   if Score - ToScore < 100000 then
    begin
     if Score - ToScore < 10000 then
      begin
       if Score - ToScore < 1000 then
        begin
         if Score - ToScore < 100 then
          Dec(Score, 1)
         else Dec(Score, 100);
        end
       else Dec(Score, 1000);
      end
     else Dec(Score, 10000);
    end
   else Dec(Score, 100000);
   if Score < ToScore then Score:=ToScore;
  end;
  
 if Gold < ToGold then
  begin
   if ToGold - Gold < 1000 then
    begin
     if ToGold - Gold < 100 then
      begin
       if ToGold - Gold < 10 then
        Inc(Gold, 1)
       else Inc(Gold, 10);
      end
     else Inc(Gold, 100);
    end
   else Inc(Gold, 1000);
   if Gold > ToGold then Gold:=ToGold;
  end;
 if Gold > ToGold then
  begin
   if Gold - ToGold < 1000 then
    begin
     if Gold - ToGold < 100 then
      begin
       if Gold - ToGold < 10 then
        Dec(Gold, 1)
       else Dec(Gold, 10);
      end
     else Dec(Gold, 100);
    end
   else Dec(Gold, 1000);
   if Gold < ToGold then Gold:=ToGold;
  end;
end;

procedure TTetrisGame.TimerBoomTimer(Sender: TObject);
begin
 //Уменьшаем бум
 if FBoom > 0 then Dec(FBoom);
 //Если можно, увеличиваем скорость затухания
 if TimerBoom.Interval > 10 then TimerBoom.Interval:=TimerBoom.Interval - 10;
 //Если "тряска" меньше 1
 if FBoom <= 1 then
  begin
   //"Тряска" окончена
   DoBoom:=False;
   //Останавливаем таймер "тряски"
   TimerBoom.Enabled:=False;
   //Фиксируем значение - 0
   FBoom:=0;
  end;
end;

procedure TTetrisGame.TimerBGTimer(Sender: TObject);
const Count = 100;
var X, Y:Word;
    P1, P2, P0:PByteArray;
begin
 with Bitmaps do
  begin
   //Увлеичиваем шаг смены фона
   Inc(BGStep);
   //Если последний шаг
   if BGStep >= Count then
    begin
     //Останавливаем таймер
     TimerBG.Enabled:=False;
     //Выходим
     Exit;
    end;
   //Идем по "строкам" рисунка сканируя палитру
   for Y:= 0 to BackGroundDraw.Height - 1 do
    begin
     //Палитра фонового рисунка
     P0:=BackGroundDraw.ScanLine[Y];
     //Палитра первого рисунка
     P1:=BackgroundOne.ScanLine[Y];
     //Палитра второго рисунка
     P2:=BackgroundTwo.ScanLine[Y];
     //Делаем перемешку "линий" первого и второго рисунка в фоновый в зависимости от шага BGStep
     for x:=0 to (BackgroundDraw.Width * 3) - 1 do P0^[X]:=Round((P1^[X] * (Count - BGStep) + P2^[x] * BGStep) / Count);
    end;
  end;
end;

procedure TTetrisGame.TimerBonusTimer(Sender: TObject);
begin
 if not AlreadyShownButtons then ShowButtons;
 //Если панель 0 не отображается и не была ни разу показана - показываем
 if (GameState in [gsNone, gsStop, gsPause]) and (not ArrayOfPanels[0].Visible) and (not ArrayOfPanels[0].WasShown) then ArrayOfPanels[0].Show;
 //Если идет игра - уменьшаем время бонусных элементов
 if (GameState = gsPlay) and (not IsWait) then StepDownBonuses;
 //Захватываем кол-во отрисованных кадров
 FPS:=FFPS;
 //Обнуляем счетчик кадров
 FFPS:=0;
end;

procedure TTetrisGame.TimerAnalysisTimer(Sender: TObject);
begin
 if GameState <> gsPlay then Exit;
 MoveMouse;
 if CalcBrokenBonus > BadGameBonusCount then
  begin
   Hint.Show('Так, так', '', 'Ты наказан!|Слишком много|просроченных|бонусов.', 20, 0);
   ExecuteRandomBonus(tbBad);
  end;
end;

procedure TTetrisGame.TimerAnimateFramesTimer(Sender: TObject);
begin
 //Следующий кадр анимаций
 Bitmaps.NextFrame;
end;

procedure TTetrisGame.Draw;
var C:Byte;
begin
 //Если идет инициализация - выходим
 if Creating then Exit;
 //Если уже идет отрисовка - выходим
 if Drawing then Exit;
 //Если Холст не создан - выходим
 //if not Assigned(DrawBMP) then Exit;
 //Основные ссылки - холста и графические объекты
 //FCanvas:=TDirect2DCanvas.Create(FDrawCanvas, Rect(0, 0, FieldWidth, FieldHeight));
 with Canvas, Bitmaps do
  begin
   //Началась отрисовка
   Drawing:=True;
   //BeginDraw;
   //Установка координат поля и некоторых объектов
   //Если не используются принудительные координаты
   if not ForcedCoordinates then
    begin
     //Если "тряска"
     if DoBoom then
      begin
       //Смещаем положение поля аналогично фону (но делая разные значения)
       SLeft:=SWidth + Random(FBoom);
       STop:=SWidth + Random(FBoom);
      end
     else //Если же нет
      begin
       //Смещение поля (слево - ширина элемента фигуры, сверху - высота элемента фигуры)
       SLeft:=SWidth;
       STop:=SWidth;
      end;
    end
   else //Если же используются принудительные кооринаты
    begin
     //Устанавливаем пинудительные координаты
     SLeft:=ForcedCoord.X;
     STop:=ForcedCoord.Y;
    end;

   /////////////////////////////////////////////////////////////////////////////.............
   //В зависимости от состояния игры рисуем объекты по необходимости и в определенном порядке
   /////////////////////////////////////////////////////////////////////////////.............

   case GameState of
    gsNone:
     begin
      //Фоновый рисунок
      Redraw.Background;
      //Панели инф. и бонусы
      Redraw.InfoPanels;
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
      //Затемнение
      Draw(SLeft, STop, Poly);
      //Первоначальная инф.
      Redraw.Stared;
     end;
    gsPause:
     begin
      //Фоновый рисунок
      Redraw.Background;
      Redraw.Scale(SLeft);
      //Сетка главного поля с затемнением
      Redraw.Field(SLeft, STop);
      //Панели инф. и бонусы
      Redraw.InfoPanels;
      //Панель с исп. бонусами
      Redraw.LastBonuses(SLeft);
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
      //Затемнение
      Draw(SLeft, STop, Poly);
      //Пауза
      if FPauseTutorial then Draw(0, TutorialPos, TutorialImg)
      else Draw(21, 94, Pause);
     end;
    gsPlay:
     begin
      //Фоновый рисунок
      Redraw.Background;
      Redraw.Scale(SLeft);
      //Сетка главного поля с затемнением
      Redraw.Field(SLeft, STop);
      //Если выполняется какой-либо, рисуем графические эффекты бонуса
      if ExecutingBonus then if Length(ArrayOfBonuses) > 0 then for C:= 0 to Length(ArrayOfBonuses) - 1 do ArrayOfBonuses[C].PaintGraphics;
      //Отрисовка стирающихся элементов
      for C:=1 to Rows do if Assigned(ArrayOfClears[C]) then ArrayOfClears[C].Paint;
      //Панели инф. и бонусы
      Redraw.InfoPanels;
      //Панель с исп. бонусами
      Redraw.LastBonuses(SLeft);
      //Если нужно сохранить кадр - сохраняем
      {if NeedShot then
       begin
        //Сохраняем состояние игры в BMP
        Bitmaps.Saved.Canvas.Draw(0, 0, DrawBMP);
        NeedShot:=False;
       end; }
      //Если состояние рисования положительное - рисуем затемнение с инф. о рисовании
      if DoDrawFigure <> dtNotWork then Draw(Bitmaps.FLeft, 0, EditInfo);
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
     end;
    gsStop:
     begin
      //Фоновый рисунок
      Redraw.Background;
      //Панели инф. и бонусы
      Redraw.InfoPanels;
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
      //Поле
      Redraw.Field(SLeft, STop);
      //Затемнение
      Draw(SLeft, STop, Poly);
      //Статистика
      Redraw.Statistics;
      //Конец игры
      Redraw.GameOver;
      if FEditBoxActive then Redraw.EditBox;
     end;
    gsDrawFigure:
     begin
      //Рисуем сохраненный снимок игры (Чтобы не загружать компьютер)
      Redraw.SavedBG;
      //Если состояние рисования положительное - рисуем затемнение с инф. о рисовании
      if DoDrawFigure <> dtNotWork then Draw(Bitmaps.FLeft, 0, EditInfo);
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
     end;
    gsShutdown:
     begin
      //Фоновый рисунок
      Redraw.Background;
      //Панели инф. и бонусы
      Redraw.InfoPanels;
      //Информация о следующей фигуре
      Redraw.NextFigure(340, SHeight);
      //Поле
      Redraw.Field(SLeft, STop);
      //Затемнение
      Draw(SLeft, STop, Poly);
      //Конец игры
      Redraw.Save;
     end;
   end;

   /////////////////////////////////////////////////////////////////////////////
   //Управление, доп. панели и персонаж
   /////////////////////////////////////////////////////////////////////////////

   //Если нужно рисовать персонажа - рисуем
   if DrawAni then
    begin
     if PtInRect(RectForChangeMode, Mouse) then
      StretchDraw(Rect(323, 188, 326+ Animations[AniID, AniNum].Width, 191 + Animations[AniID, AniNum].Height), Animations[AniID, AniNum])
     else
      StretchDraw(Rect(325, 190, 325 + Animations[AniID, AniNum].Width, 190 + Animations[AniID, AniNum].Height), Animations[AniID, AniNum])
     //Draw(325, 190, Animations[AniID, AniNum]);
    end;
   //Кнопки управления
   if Length(ArrayOfButtons) > 0 then for C:=0 to Length(ArrayOfButtons) - 1 do ArrayOfButtons[C].Paint;
   //Доп. инф. панели
   if Length(ArrayOfPanels) > 0 then for C:=0 to Length(ArrayOfPanels) - 1 do ArrayOfPanels[C].Paint;
   //Подсказка
   if Self.Hint.Visible then Self.Hint.Paint;

   /////////////////////////////////////////////////////////////////////////////
   //Курсор и отладочная информация
   /////////////////////////////////////////////////////////////////////////////

   //TextOut(5, 5, Format('Задержка отрисовкой: %d мсек.', [GetTickCount - TM]));
   //Если отладка включена
   if DebugEnabled then
    begin
     //Рисуем красные области объектов
     Pen.Width:=1;
     Pen.Color:=clRed;
     Rectangle(RectForInfoText);
     Rectangle(RectForNextFigure);
     Rectangle(RectForAutor);
     Rectangle(RectForChangeMode);
     Rectangle(RectForBonuses);
     Rectangle(RectForBonusesMouse);
     Rectangle(RectForButtons);
     Rectangle(RectForExed);

     //FillRgn(DrawBMP.Canvas.Handle, Owner.ArrayOfButtons[0].RGN, CreateSolidBrush(RGB(100, 34, 54)));
     //FillRgn(DrawBMP.Canvas.Handle, Owner.ArrayOfButtons[1].RGN, CreateSolidBrush(RGB(200, 34, 54)));
     //FillRgn(DrawBMP.Canvas.Handle, Owner.ArrayOfButtons[2].RGN, CreateSolidBrush(RGB(100, 134, 54)));
     //Шрифт для КВС
     Font.Assign(FontTextAutor);
     //Показываем КВС
     TextOut(5, 5, Format('FPS: %d', [FPS]));
     TextOut(5, 15, Format('FKeyIDUP: %d', [GameKeys[FKeyIDUP].ForceDown]));
     TextOut(5, 25, Format('FKeyIDDown: %d', [GameKeys[FKeyIDDown].ForceDown]));
     TextOut(5, 35, Format('FKeyIDLeft: %d', [GameKeys[FKeyIDLeft].ForceDown]));
     TextOut(5, 45, Format('FKeyIDRight: %d', [GameKeys[FKeyIDRight].ForceDown]));

    end;
   TextOut(5, 5, Format('FPS: %d', [FPS]));
   //Курсор
   if ShowCursos then
    begin
     if GameState <> gsDrawFigure then Draw(Mouse.X, Mouse.Y, Cursor[CurNum])
     else
      begin
       if PtInRect(RectForNextFigure, Mouse) then
        begin
         if DoDrawFigure = dtEmpty then Draw(Mouse.X, Mouse.Y, CurDel)
         else Draw(Mouse.X, Mouse.Y, CurPen);
        end
       else Draw(Mouse.X, Mouse.Y, Cursor[CurNum]);
      end;
    end;

   /////////////////////////////////////////////////////////////////////////////
   //Конец отрисовки
   /////////////////////////////////////////////////////////////////////////////


   //Отрисовка холста
   //EndDraw;
   //FDrawCanvas.CopyRect(FDrawCanvas.ClipRect, DrawBMP.Canvas, FDrawCanvas.ClipRect);
   //FDrawCanvas.StretchDraw(FDrawCanvas.ClipRect, DrawBMP);
   BitBlt(FDrawCanvas.Handle, 0, 0, FDrawCanvas.ClipRect.Width, FDrawCanvas.ClipRect.Height, DrawBMP.Canvas.Handle, 0, 0, SRCCOPY);
   //FDrawCanvas.Draw(0, 0, DrawBMP);
   //Увеличиваем кол-во отрисованных кадров
   Inc(FFPS);
  end;
 //Отрисовка окончена
 Drawing:=False;
end;

//////////////////////////////////////TSound////////////////////////////////////

function TSound.GetVolume:Byte;
var Vol:single;
begin
 //Узнаем громкость потока
 BASS_ChannelGetAttribute(Sounds[0], BASS_ATTRIB_VOL, Vol);
 //Переводим в нормальный вид
 Result:=Round(Vol * 100);
end;

procedure TSound.SetVolume(Value:Byte);
var i:Byte;
begin
 BASS_SetVolume(Value/100);
 //Проверяем границу громкости
 if Value > 100 then Value:=100;
 //Устанавливаем громкость для всх потоков
 for i:=0 to Length(Sounds) - 1 do
  BASS_ChannelSetAttribute(Sounds[i], BASS_ATTRIB_VOL, Value/100);
end;

function TSound.AddStream(FileName:TFileName; Channel:Boolean):Word;
begin
 //Добавляем место
 SetLength(Sounds, Length(Sounds) + 1);
 //Создаем поток
 Sounds[Length(Sounds) - 1]:=CreateStream(FileName, Channel);
 //Результат - позиция в массиве
 Result:=Length(Sounds) - 1;
end;

function TSound.CreateStream(FileName:string; Channel:Boolean):Cardinal;
begin
 //Если истина, создаем звуковую дорожку
 if Channel then Result:=BASS_SampleLoad(False, PAnsiChar(AnsiString(FileName)), 0, 0, 3, BASS_SAMPLE_OVER_POS)
 //В противном случае звуковой поток
 else Result:=BASS_StreamCreateFile(False, PAnsiChar(AnsiString(FileName)), 0, 0, 0);
end;

constructor TSound.Create;
begin
 inherited Create;
 //Создаем ссылки на необходимые классы
 //Владелец игра
 FOwner:=AOwner;
 //Графика - берем у владельца
 Bitmaps:=AOwner.Bitmaps;
 //Кол-во звуков - 0
 SetLength(Sounds, 0);
 //Инициализируем звук
 FEnable:=BASS_Init(-1, 44100, 0, Application.Handle, nil) and (HIWORD(BASS_GetVersion) = BASSVERSION);
 //Если звук не инициализирован - выходим (нет смысла добавлять потоки звуков и уж тем более регулировать их громкость)
 if not Enable then Exit;
 AddStream(ProgramPath + 'Data\Sound\first.wav',      False); //0
 AddStream(ProgramPath + 'Data\Sound\gameover.wav',   True);  //1
 AddStream(ProgramPath + 'Data\Sound\line.wav',       True);  //2
 AddStream(ProgramPath + 'Data\Sound\start.wav',      True);  //3
 AddStream(ProgramPath + 'Data\Sound\pause.wav',      True);  //4
 AddStream(ProgramPath + 'Data\Sound\figure.wav',     True);  //5
 AddStream(ProgramPath + 'Data\Sound\levelup.wav',    True);  //6
 AddStream(ProgramPath + 'Data\Sound\wall.wav',       True);  //7
 AddStream(ProgramPath + 'Data\Sound\bonusbreak.wav', True);  //8
 AddStream(ProgramPath + 'Data\Sound\goldup.wav',     True);  //9
 AddStream(ProgramPath + 'Data\Sound\quit.wav',       True);  //10
 AddStream(ProgramPath + 'Data\Sound\change.wav',     True);  //11
 AddStream(ProgramPath + 'Data\Sound\bonus.wav',      True);  //12
 AddStream(ProgramPath + 'Data\Sound\exebonus.wav',   True);  //13
 AddStream(ProgramPath + 'Data\Sound\boss.wav',       True);  //14
 AddStream(ProgramPath + 'Data\Sound\bossboom.wav',   True);  //15
 AddStream(ProgramPath + 'Data\Sound\needgold.wav',   True);  //16
 //Изначальная громкость - 30
 Volume:=30;
end;

procedure TSound.Stop(MSTREAM:Cardinal);
begin
 //Останавливаем поток MSTREAM
 BASS_ChannelStop(MSTREAM);
end;

procedure TSound.Stop(ID:Byte);
begin
 //Если нет звука - выходим
 if not Enable then Exit;
 //Если не тот тип звука  - выходим
 if ID < 100 then Exit;
 //Посылаем на остановку потока
 BASS_ChannelStop(Sounds[ID - 100]);
end;

procedure TSound.Play(ID:Byte);
begin
 //Идентификатор больше 100 означает поток, меньше - звуковая дорожка
 //Поток можно остановить и воспроизводить только раз или перезапуск
 //Дорожка может налакладываться на другую и её не остановить
 //Для проигрывания звука как поток - прибавляем 100 к ID-у звука

 //Выбираем какую анимацию включить 
 case ID of
    1:Bitmaps.Animate:=10;
    2:Bitmaps.Animate:=3;
    3:Bitmaps.Animate:=9;
    4:Bitmaps.Animate:=7;
    6:Bitmaps.Animate:=8;
    8:Bitmaps.Animate:=2;
    9:Bitmaps.Animate:=4;
   10:Bitmaps.Animate:=6;
   13:Bitmaps.Animate:=5;
  100:Bitmaps.Animate:=1;
 end;
 //Если нет звука - выходим
 if not Enable then Exit;
 //Если больше либо равно 100 - запускаем поток
 if ID >= 100 then BASS_ChannelPlay(Sounds[ID - 100], True)
 //Если же нет, добавляем звук в осн. поток
 else BASS_ChannelPlay(BASS_SampleGetChannel(Sounds[ID], False), False);
end;

procedure TSound.PlaySound_2(MSTREAM:Cardinal);
begin
 //Если нет звука - выходим
 if not Enable then Exit;
 //Посылаем на проигрывания потока с перезапуском
 BASS_ChannelPlay(MSTREAM, True);
end;

procedure TSound.PlaySound(MSTREAM:Cardinal);
begin
 //Если нет звука - выходим
 if not Enable then Exit;
 //Послыаем на независимое проигрывание дорожки
 BASS_ChannelPlay(BASS_SampleGetChannel(MSTREAM, False), True);
end;

///////////////////////////////////TBitmaps/////////////////////////////////////

function TBitmaps.GetAnimate:Byte;
begin
 //Текущий ИД анимации
 Result:=AniID;
end;

procedure TBitmaps.SetAnimate(Value:Byte);
begin
 //Если анимация таже самая - выходим
 if GetAnimate = Value then Exit;
 //Установка новой анимации
 AniID:=Value;
 //Сброс кадра на первый
 AniNum:=1;
end;

procedure TBitmaps.NextFrame;
begin
 ///////////////////////////////////////
 //Следующий кадр курсора
 Inc(CurNum);
 //Если он последний или вышел из границ - сбрасываем на первый
 if CurNum >= Length(Cursor) then CurNum:=0;
 ///////////////////////////////////////
 ///////////////////////////////////////
 //Увлеичиваем кадр анимации бонусного элемента
 Inc(BonusAni);
 //Если он последний или вышел из границ - сбрасываем на первый
 if BonusAni >= Length(AniBonus) then BonusAni:=0;
 ///////////////////////////////////////
 //////////////////////////////////////
 //Увлеичиваем кадр анимации бонусного элемента
 Inc(BonusAniTime);
 //Если он последний или вышел из границ - сбрасываем на первый
 if BonusAniTime >= Length(AniBonusTime) then BonusAniTime:=0;
 //////////////////////////////////////
 ///////////////////////////////////////
 //Увлеичиваем кадр анимации персонажа
 Inc(AniNum);
 //Если он последний или вышел из границ
 if AniNum > 8 then
  begin
   //Сбрасываем на первый
   AniNum:=1;
   //Включаем изначальную (нейтральную) анимацию
   AniID:=1;
  end;
 //////////////////////////////////////
end;

procedure TBitmaps.LoadFigures(FArray:TArrayOfFigure; SW, SH:Byte);
var i, ACount:Byte;
    DLL:Cardinal;
begin
 //Если фигур больше чем 15 загружаем больше, если же нет загружаем 15
 ACount:=Owner.Max(Length(FArray), GlLvls);
 //Массив граф. элементов фигур равен кол-во загруж. элементов
 DLL:=LoadLibrary(PChar(FPath + TetDll));
 SetLength(Figures, ACount);
 for i:=0 to ACount - 1 do
  begin
   //Создаем граф. объект
   Figures[i]:=TPNGObject.Create;
   //Если есть файл - загружаем
   try
    Figures[i].LoadFromResourceName(DLL, 'Figure_'+IntToStr(i + 1));
   except
   end;
   //Если объект пуст
   if Figures[i].Empty then
    begin
     //Рисуем объект сами
     Figures[i]:=TPNGObject.CreateBlank(COLOR_RGB, 16, SW + 1, SH + 1);
     //Цвет рамки
     Figures[i].Canvas.Pen.Color:=$00949494;
     //Случайный цвет заливки
     Figures[i].Canvas.Brush.Color:=RGB(Random(255), Random(255), Random(255));
     //Рисуем прямоугольник во весь грф. объект
     Figures[i].Canvas.Rectangle(Figures[i].Canvas.ClipRect);
    end;
  end;
 FreeLibrary(DLL);
end;

constructor TBitmaps.Create(Path:string; AOwner:TTetrisGame);
var i, j, num:Byte;
    TMP:TPNGObject;
    X, Y:Integer;
    SAS:pByteArray;
    DLL:Cardinal;
begin
 //Ссылки и изначальные значения
 FOwner:=AOwner;
 FPath:=Path;
 AniNum:=1;
 AniID:=1;
 BGStep:=1;
 DLL:=LoadLibrary(PChar(FPath + TetDll));
 TMP:=TPNGObject.Create;
 TMP.LoadFromResourceName(DLL, 'FLS9');
 //Анимацию рисуем
 DrawAni:=True;
 //Загрузка анимированного персонажа
 if TMP.Width = 880 then
  begin
   //TMP:=CreatePNG(Path + 'FLS9.png');
   for i:=0 to 9 do
    for j:=0 to 7 do Animations[i + 1, j + 1]:=CreateFrom(j * 110, i * 128, 110, 128, TMP);
  end
  //Если нет, анимированного персонажа - нет
 else DrawAni:=False;
 TMP.LoadFromResourceName(DLL, 'sbonus');
 //Загрузка значка бонуса
 if not TMP.Empty then
  begin
   if TMP.Width div 21 > 0 then
    begin
     for i:=0 to (TMP.Width div 21) - 1 do
      begin
       SetLength(AniBonus, Length(AniBonus) + 1);
       AniBonus[Length(AniBonus) - 1]:=CreateFrom(i * 21, 0, 21, 21, TMP);
      end;
    end;
  end
 else
  begin
   SetLength(AniBonus, Length(AniBonus) + 1);
   AniBonus[Length(AniBonus) - 1]:=TPNGObject.CreateBlank(COLOR_RGB, 16, 21, 21);
  end;

 TMP.LoadFromResourceName(DLL, 'bonustime');
 //Загрузка значка бонуса с временем
 if not TMP.Empty then
  begin
   if TMP.Width div 21 > 0 then
    begin
     for i:=0 to (TMP.Width div 21) - 1 do
      begin
       SetLength(AniBonusTime, Length(AniBonusTime) + 1);
       AniBonusTime[Length(AniBonusTime) - 1]:=CreateFrom(i * 21, 0, 21, 21, TMP);
      end;
    end;
  end
 else
  begin
   SetLength(AniBonusTime, Length(AniBonusTime) + 1);
   AniBonusTime[Length(AniBonusTime) - 1]:=TPNGObject.CreateBlank(COLOR_RGB, 16, 21, 21);
  end;

 TMP.LoadFromResourceName(DLL, 'cursor');
 //Загрузка курсора
 if not TMP.Empty then
  begin
   if TMP.Width div 32 > 0 then
    begin
     for i:=0 to (TMP.Width div 32) - 1 do
      begin
       SetLength(Cursor, Length(Cursor) + 1);
       Cursor[Length(Cursor) - 1]:=CreateFrom(i * 32, 0, 32, 32, TMP);
      end;
    end;
  end
 else
  begin
   SetLength(Cursor, Length(Cursor) + 1);
   Cursor[Length(Cursor) - 1]:=TPNGObject.CreateBlank(COLOR_RGB, 16, 32, 32);
  end;

 //Загрузка фоновых рисунков
 SetLength(Backgrounds, 0);
 for num:=0 to GlLvls - 1 do
  begin
   SetLength(Backgrounds, Length(Backgrounds) + 1);
   try
    begin
     Backgrounds[Length(Backgrounds) - 1]:=TBitmap.Create;
     Backgrounds[Length(Backgrounds) - 1].LoadFromResourceName(Dll, 'bg' + IntToStr(num));
    end;
   except
    Break;
   end;
  end;

 //Загружаем основные графические элементы
 BackGroundDraw:=Owner.CreateBMP(Dll, 'bg0');
 BackgroundOne:= Owner.CreateBMP(Dll, 'bg0');
 BackgroundTwo:= Owner.CreateBMP(Dll, 'bg0');
 BonusExeing:=CreatePNG(Dll, 'exeing');
 EditInfo:=   CreatePNG(Dll, 'editinfo');
 BreakBonus:= CreatePNG(Dll, 'breakbonus');
 GameOver:=   CreatePNG(Dll, 'gameover');
 Contin:=     CreatePNG(Dll, 'contin');
 ShadePNG:=   CreatePNG(Dll, 'shade');
 FShade:=     CreatePNG(Dll, 'FSHADE');
 OveredBonus:=CreatePNG(Dll, 'overed');
 Pause:=      CreatePNG(Dll, 'pause');
 Start:=      CreatePNG(Dll, 'pressstart');
 Hint:=       CreatePNG(Dll, 'hint');
 Cost:=       CreatePNG(Dll, 'cost');
 CurPen:=     CreatePNG(Dll, 'pen');
 CurDel:=     CreatePNG(Dll, 'del');
 Light:=      CreatePNG(Dll, 'light');
 LightField:= CreatePNG(Dll, 'lightfield');
 NextLvl:= CreatePNG(Dll, 'nextlvl');
 ScaleBG:=CreatePNG(Dll, 'scalebg');
 FreeLibrary(DLL);
 //Рисуем стку на затемненном поле
 BonusBusy:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth + 1, Owner.SHeight + 1);
 with BonusBusy.Canvas, Owner do
  begin
   Pen.Color:=clWhite;
   Brush.Style:=bsSolid;
   Brush.Color:=Pen.Color;
   Rectangle(Scaled(ClipRect, - 3));
   for Y:=0 to BonusBusy.Height - 1 do
    begin
     SAS:=BonusBusy.AlphaScanline[Y];
     for X:=0 to BonusBusy.Width - 1 do
      begin
       if Pixels[X, Y] = Pen.Color then SAS^[X]:=150 else SAS^[X]:=0;
      end;
    end;
  end;
 Poly:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, Owner.SHeight * GlVbRw + 1);
 with Poly.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clWhite;
   Rectangle(ClipRect);
   for Y:=0 to Poly.Height - 1 do
    begin
     SAS:=Poly.AlphaScanline[Y];
     for X:=0 to Poly.Width - 1 do
      begin
       if Pixels[X, Y] <> clWhite then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 BlackPoly:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, Owner.SHeight * GlVbRw + 1);
 with BlackPoly.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clBlack;
   Rectangle(ClipRect);
   for Y:=0 to BlackPoly.Height - 1 do
    begin
     SAS:=BlackPoly.AlphaScanline[Y];
     for X:=0 to BlackPoly.Width - 1 do
      begin
       if Pixels[X, Y] <> clBlack then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 EditBox:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, 100);
 with EditBox.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clBlack;
   Rectangle(ClipRect);
   for Y:=0 to EditBox.Height - 1 do
    begin
     SAS:=EditBox.AlphaScanline[Y];
     for X:=0 to EditBox.Width - 1 do
      begin
       if Pixels[X, Y] <> Brush.Color then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 ExedPanel:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, Owner.SHeight + 3);
 with ExedPanel.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clWhite;
   Rectangle(ClipRect);
   for Y:=0 to ExedPanel.Height - 1 do
    begin
     SAS:=ExedPanel.AlphaScanline[Y];
     for X:=0 to ExedPanel.Width - 1 do
      begin
       if Pixels[X, Y] <> clWhite then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 ExedPanelEx:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, 100, Owner.SHeight + 3);
 with ExedPanelEx.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clWhite;
   Rectangle(ClipRect);
   for Y:=0 to ExedPanelEx.Height - 1 do
    begin
     SAS:=ExedPanelEx.AlphaScanline[Y];
     for X:=0 to ExedPanelEx.Width - 1 do
      begin
       if Pixels[X, Y] <> clWhite then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 GridPoly:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, Owner.SHeight * GlVbRw + 1);
 with GridPoly.Canvas, Owner do
  begin
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Brush.Style:=bsSolid;
   Brush.Color:=clWhite;
   Rectangle(ClipRect);
   for X:=0 to GlCols do
    begin
     MoveTo(X * SWidth, 0);
     LineTo(X * SWidth, GridPoly.Height);
    end;
   for X:=0 to GlVbRw do
    begin
     MoveTo(0, X * SHeight);
     LineTo(GridPoly.Width, X * SHeight);
    end;
   for Y:=0 to GridPoly.Height - 1 do
    begin
     SAS:=GridPoly.AlphaScanline[Y];
     for X:=0 to GridPoly.Width - 1 do
      begin
       if Pixels[X, Y] <> clWhite then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 Saved:=TBitmap.Create;
 Saved.Width:=Owner.FieldWidth;
 Saved.Height:=Owner.FieldHeight;
 Panel:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, Owner.SWidth * GlCols + 1, (Owner.SHeight * (GlRows - GlFVRw)) div 3 + 1);
 with Panel.Canvas do
  begin
   Brush.Color:=clWhite;
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Rectangle(ClipRect);
   for Y:=0 to Panel.Height - 1 do
    begin
     SAS:=Panel.AlphaScanline[Y];
     for X:=0 to Panel.Width - 1 do
      begin
       if Pixels[X, Y] = Pen.Color then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
 MPoly:=TPNGObject.CreateBlank(COLOR_RGBALPHA, 16, GlSize * Owner.SWidth + 1, GlSize * Owner.SHeight + 1);
 with MPoly.Canvas do
  begin
   Brush.Color:=clWhite;
   Pen.Color:=MixColors(clGrayText, clWhite, 60);
   Rectangle(ClipRect);
   for Y:=0 to MPoly.Height - 1 do
    begin
     SAS:=MPoly.AlphaScanline[Y];
     for X:=0 to MPoly.Width - 1 do
      begin
       if Pixels[X, Y] = Pen.Color then SAS^[X]:=255 else SAS^[X]:=100;
      end;
    end;
  end;
end;

//////////////////////////////////TExtButton////////////////////////////////////

procedure TExtButton.SetBlink(Value:Boolean);
begin
 //Установка мигания (только для фигуры - кнопки)
 FBlink:=Value;
 //Если нужно чтоб не мигала
 if not FBlink then
  begin
   //Восстанавливаем значения цветов
   Over:=FOver;
   Normal:=FNormal;
  end;
end;

procedure TExtButton.SetEnable(Value:Boolean);
begin
 FEnable:=Value;
 //В зависимости от состояния меняем начертания шрифта
 case FButtonState of
  bsNormal,
  bsDown:Font.Style:=[];
  //Если есть фокус, если кнопка доступна - шрфт - жирный и обычный если не доступна
  bsOver:if FEnable then Font.Style:=[fsBold] else Font.Style:=[];
 end;
end;

procedure TExtButton.Paint;
var TX, TY:Integer;
    OldFont:TFont;
begin
 with Owner.Canvas do
  begin
   case Self.AType of
    btFigure:
     begin
      case Self.ButtonState of
       bsNormal:Brush.Color:=Self.Normal;
       bsOver:Brush.Color:=Self.Over;
       bsDown:Brush.Color:=Self.Down;
      end;
      Brush.Style:=bsSolid;
      Windows.Polygon(0, Self.FPoly, Self.PCount);
     end;
    btPicture:
     begin
      if Self.Enable then
       case Self.ButtonState of
        bsNormal:Draw(Self.FLeft, Self.FTop, Self.NormalPic);
        bsOver:Draw(Self.FLeft, Self.FTop, Self.OverPic);
        bsDown:Draw(Self.FLeft, Self.FTop, Self.DownPic);
       end
      else Draw(Self.FLeft, Self.FTop, Self.DisablePic);
     end;
   end;

   //OldFont:=Font;
   Font.Assign(Self.Font);
   if not FEnable then Font.Color:=$00949494;
   Brush.Style:=bsClear;
   TX:=Self.FLeft+Round((Self.FWidth  / 2) - ( TextWidth(Self.Text) / 2)) + 4;
   TY:=Self.FTop+ Round((Self.FHeight / 2) - (TextHeight(Self.Text) / 2)) + 3;
   TextOut(TX, TY, Self.Text);
   //Font.Assign(OldFont);
  end;
end;

function TExtButton.CreateRegionFromBMP(Image: TBitmap; var Width, Height:Integer): HRGN;
var x, y:integer;
    ConsecutivePixels:integer;
    CurrentPixel:TColor;
    CurrentColor:TColor;
    MinLeft, MaxLeft, MinTop, MaxTop:Integer;
begin
 //Погрешность региона +\- 2 пикселя
 //Изначально регион - весь рисуонк
 Result:=CreateRectRgn(0, 0, Image.Width, Image.Height);
 //Если по какой-то причине размеры графики меньше 0 - выходим
 if (Image.Width <= 0) or (Image.Height <= 0) then Exit;
 //Изначальные мин. и макс. значения границ для подсчета ширины и высоты
 MinLeft:=Image.Width;
 MaxLeft:=0;
 MinTop:=Image.Height;
 MaxTop:=0;
 //Идем по рисунку
 for y:= 0 to Image.Height - 1 do
  begin
   //Текущий цвет - цвет первого пикселя
   CurrentColor:=Image.Canvas.Pixels[0, y];
   //Кол-во пикселей в ряд - 1
   ConsecutivePixels:=1;
   //Идем дальше ...
   for x:= 0 to Image.Width - 1 do
    begin
     //Выяснение самой нижней, самой верхней, самой левой и самой правой точки региона
     if Image.Canvas.Pixels[x, y] <> clWhite then
      begin
       if MinLeft > x then MinLeft:=x;
       if MinTop  > y then MinTop :=y;
       if MaxLeft < x then MaxLeft:=x;
       if MaxTop  < y then MaxTop :=y;
      end;
     //Цвет пикселя
     CurrentPixel:=Image.Canvas.Pixels[x, y];
     //Если цвет тот же, что и первый - увеличиваем ряд пикселей
     if CurrentColor = CurrentPixel then Inc(ConsecutivePixels)
     else //Если же цвета не совпадают
      begin
       //Если цвет белый - значит регион закончен
       if CurrentColor = clWhite then
        begin
         //Комбинируем (исключая) уже имеющийся регион с регионом полученным созданием рядом пикселей
         CombineRgn(Result, Result, CreateRectRgn(x - ConsecutivePixels, y, x, y + 1), RGN_DIFF);
        end;
       //Текущий цвет - цвет текущего пикселя
       CurrentColor:=CurrentPixel;
       //Кол-во пикселей в ряд - 1
       ConsecutivePixels:=1;
      end;
    end;
   //Если тек. цвет - белый и кол-во пикселей в ряд больше 0
   if (CurrentColor = clWhite) and (ConsecutivePixels > 0) then
    begin
     //Комбинируем (исключая) уже имеющийся регион с регионом полученным созданием рядом пикселей по всей ширине рисунка
     CombineRgn(Result, Result, CreateRectRgn((Image.Width - 1) - ConsecutivePixels, y, Image.Width - 1, y + 1), RGN_DIFF);
    end;
  end;
 FRect:=Rect(MinLeft, MinTop, MaxLeft, MaxTop);
 //Ширина и ...
 Width:=Abs(MinLeft - MaxLeft);
 //Высота региона
 Height:=Abs(MinTop - MaxTop);
end;

function TExtButton.OnMouseUp(X, Y:Integer):Boolean;
begin
 Result:=False;
 if FButtonState = bsDown then
  begin
   Result:=PtInRegion(FRGN, X, Y) and Enable;
   FButtonState:=bsNormal;
   if Result then if Assigned(Click) then Click;
  end;
end;

procedure TExtButton.OnMouseDown(X, Y:Integer);
begin
 if FButtonState <> bsDown then
  if PtInRegion(FRGN, X, Y) then FButtonState:=bsDown;
end;

procedure TExtButton.OnMouseMove(X, Y:Integer);
begin
 if (ButtonState <> bsDown) and Enable then
  if PtInRegion(FRGN, X, Y) then
   begin
    if Blink then
     begin
      LBlink:=True;
      Blink:=False;
     end;
    FButtonState:=bsOver;
    Font.Style:=[fsBold];
   end
  else
   begin
    if LBlink then FBlink:=True;
    FButtonState:=bsNormal;
    Font.Style:=[];
   end;
end;

constructor TExtButton.Create(AOwner:TtetrisGame; APoly:TPoints; LCount:Byte; AText:string; AWidth:Integer; ALeft, ATop:Integer);
begin
 inherited Create;
 HintList:=TStringList.Create;
 FOwner:=AOwner;
 Font:=TFont.Create;
 AType:=btFigure;
 PCount:=LCount;
 Blink:=False;
 FPoly:=APoly;
 Text:=AText;
 FWidth:=AWidth;
 FLeft:=ALeft;
 FTop:=ATop;
 CTop:=ATop;
 Enable:=True;
 FRGN:=CreatePolygonRgn(Fpoly, PCount, 2);
end;

constructor TExtButton.Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer);
var BMP:TBitmap;
    DLL:Cardinal;
begin
 inherited Create;
 HintList:=TStringList.Create;
 FOwner:=AOwner;
 Font:=TFont.Create;
 AType:=btPicture;
 Blink:=False;
 Text:=AText;
 FLeft:=ALeft;
 FTop:=ATop;
 CTop:=ATop;
 DLL:=LoadLibrary(PChar(ProgramPath+'\Data\'+TetDll));
 NormalPic:=TPNGObject.Create;
 NormalPic.LoadFromResourceName(DLL, 'normal');
 OverPic:=TPNGObject.Create;
 OverPic.LoadFromResourceName(DLL, 'over');
 DisablePic:=TPNGObject.Create;
 DisablePic.LoadFromResourceName(DLL, 'disable');
 DownPic:=TPNGObject.Create;
 DownPic.LoadFromResourceName(DLL, 'down');
 BMP:=TBitmap.Create;
 BMP.LoadFromResourceName(DLL, Mask);
 FreeLibrary(DLL);
 FRGN:=CreateRegionFromBMP(BMP, FWidth, FHeight);
 OffsetClipRgn(FRGN, 100, 100);
 BMP.Free;
 Enable:=True;
end;

constructor TExtButton.Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer; NFont:TFont; APc:TProcedure);
begin
 Create(AOwner, Mask, AText, ALeft, ATop);
 Font.Name:=NFont.Name;
 Font.Size:=NFont.Size;
 Font.Style:=NFont.Style;
 Font.Color:=NFont.Color;
 Click:=APc;
end;

initialization
 Randomize;
 //Текущий каталог
 ProgramPath:=ExtractFilePath(ParamStr(0));

end.
