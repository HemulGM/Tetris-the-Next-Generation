unit TheTetris;

////////////////////////////////////////////////////////////////////////////////
//������: ������ - ����� ���������
//�����: �������� �������, 2013 ���
//�����������: Bass, pngimage
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

 GlSize = 4;                                                                    //����������� �������-������
 GlAmnt = GlSize * GlSize;                                                      //���-�� ��������� � ������
 GlAutr = '�������� ������� aka HemulGM';                                       //����� =)
 GlCols = 15;                                                                   //���-�� ��������
 GlLvls = 15;                                                                   //���-�� ������� ����
 GlRows = 23;                                                                   //���-�� �����
 GlExes = 14;                                                                   //���-�� ��������� ���. �������
 GlHdRw = 3;                                                                    //���-�� ������� ����� ����
 GlVbRw = GlRows - GlHdRw;                                                      //���-�� ������� �����
 GlFVRw = GlHdRw + 1;                                                           //������ ������� ������
 TetDll = 'TetPic.dll';                                                         //���������� � ������������ ���������
 SaveFN = '\Data.sav';                                                          //���� ���������� ����
 DebgFN = '\Debug.log';                                                         //���� ������� ���� ���� (�������)
 ScrnFN = 'Screen.bmp';                                                         //���� �������� ������ ������ ���� (�������)


type

  TBitmaps     = class;                                                         //����������� ������� (��������)
  TBonus       = class;                                                         //������ ������
  TExtButton   = class;                                                         //����������� ������ (�� control)
  THelpObject  = class;                                                         //���������
  TLineClear   = class;                                                         //����� �������� (��� ��������� �������������� ��������)
  TSimpleBonus = class;                                                         //������� �����
  TSound       = class;                                                         //�������� ������������� (������ ������, bass.dll)
  TTetrisGame  = class;                                                         //������ ����
  TTextHint    = class;                                                         //������� ���������
  TTextPanel   = class;                                                         //��������� ������
  TTimeBonus   = class;                                                         //��������� �����
  TRedrawing   = class;                                                         //������ �����������
  TStatistics  = class;                                                         //����������
  TAppendStat  = class;                                                         //���������� ����������
  TGameKey     = class;                                                         //������� �������

  TState = (bsEmpty, bsElement, bsBonus, bsBonusTiming, bsBonusBroken);         //��������� �������� (�����, ������� ������, �����, ����� (������), ����� (������))
  TFigureItem = record                                                          //������� ������
   ID:Byte;                                                                      //������������� �������� (������)
   State:TState;                                                                 //���������
   TimeLeft:Word;                                                                //�������� ������� (��� ������)
  end;
  TClearFigureItem = record                                                     //��������� �������
   X, Y:Extended;                                                                //������� ����������
   Speed:Byte;                                                                   //��������
   Angle:Smallint;                                                               //���� ����������
  end;
  TExing = record                                                               //������� ������� ����������� �������
   Bonus:TBonus;                                                                 //�����
   Active:Boolean;                                                               //���� �� ������� � �����
  end;
  TElements = array[1..GlSize, 1..GlSize] of TFigureItem;                       //������� ��������� ������
  TFigure = record                                                              //���� ������
   Allowed:Boolean;                                                              //�����������
   Elements:TElements;                                                           //�������� ������
   Name:string;                                                                  //��������
  end;
  TStatRecord = record                                                          //������ ����������
   Gold:Cardinal;                                                                //���-�� ������
   Score:Cardinal;                                                               //����
   Lines:Cardinal;                                                               //���-�� ��������� �����
   Figure:Cardinal;                                                              //���-�� ���������� �����
   Level:Byte;                                                                   //�������
  end;
  TStatTop = record                                                             //������ ��� - ������
   Name:string[255];                                                             //���
   Score:Cardinal;                                                               //����
  end;
  TGameKeyInfo = record                                                         //��������� ���������� � �������
   Code:Word;                                                                    //��� �������
   FForceDown:Word;                                                              //����� � ������� ��������� (��)
   Name:string;                                                                  //��������
  end;


  TArrayOfButton = array of TExtButton;                                         //������ ������
  TArrayOfClears = array[1..GlRows] of TLineClear;                              //��������� ������
  TArrayOfExing  = array[1..GlExes] of TExing;                                  //������ ���������� �������
  TArrayOfFigure = array of TFigure;                                            //������ ��������� �����
  TArrayOfPanels = array of TTextPanel;                                         //������ ��������� �������
  TBonuses       = array of TBonus;                                             //������ �������
  TBonusType     = (btForAll, btForGame, btForUser);                            //��� ������� � �������
  TDrawType      = (dtNotWork, dtNone, dtElement, dtEmpty);                     //����� ��������� (�� ������, ��������, ������, �������)
  TFiguresL1     = array[1..GlCols] of TClearFigureItem;                        //������ ����������� ���������
  TFiguresL2     = array[1..GlCols] of TFigureItem;                             //������ ��������� ���������
  TGameKeys      = array of TGameKey;                                           //������ ������� ������
  TButtonState   = (bsNormal, bsOver, bsDown);                                  //��������� ������
  TButtonType    = (btFigure, btPicture);                                       //��� ������ (������, �������)
  TGameState     = (gsNone, gsPlay, gsPause, gsStop, gsDrawFigure, gsShutdown); //��������� ���� (���, ���� ����, �� �����, ����� ����, ������ ������, ���������� ����)
  TInfoMode      = (imInfoText, imBonuses, imTransforming);                     //����� ���. �������
  TLevels        = array[1..GlLvls] of Boolean;                                 //������ �������
  TPoints        = array[0..255] of TPoint;                                     //������ ����� ��� �������� (��� ������)
  TProcedure     = procedure of object;                                         //���������
  TTetArray      = array[1..GlRows, 1..GlCols] of TFigureItem;                  //�������� ��� - ����
  TTypeBonus     = (tbCare, tbBad, tbGood);                                     //��� ������ (�����������, �������������, �������������)

  TGameKey = class                                                              //������� �������
    class function GetGameKeyInfo(ACode, AForceDown:Word; AName:string):TGameKeyInfo;
   private                                                                      //������
    FContradictionEnable:Boolean;                                                //�������������� ������� �������
    FContradiction:Word;                                                         //�� �������������� �������
    FStartTime:Word;                                                             //��������� �����
    FMinTime:Word;                                                               //����������� ����� �������� �������
    FOwner:TTetrisGame;                                                          //��������
    FGameKeyInfo:TGameKeyInfo;                                                   //���������� � �������
    FTimer:TTimer;                                                               //������ ��������� �������
    FAction:TProcedure;                                                          //�������� �������
    procedure FTimerTime(Sender:TObject);                                        //��������� ��������� ������� �������
    procedure SetStartTime(Value:Word);                                          //��������� ���������� �������
    procedure SetMinTime(Value:Word);                                            //��������� ������������ �������
    procedure SetContradiction(Value:Word);                                      //��������� �������������� �������
    function GetForceDown:Byte;                                                  //�������� ���� ������� �� �������
   public                                                                       //�����
    property Contradiction:Word read FContradiction write SetContradiction;      //������������� ������� (��)
    procedure Press;                                                             //������� �� �������
    procedure Release;                                                           //��������� �������
    property Action:TProcedure read FAction write FAction;                       //��������
    property GameKeyInfo:TGameKeyInfo read FGameKeyInfo write FGameKeyInfo;      //����. � �������
    property StartTime:Word read FStartTime write SetStartTime;                  //��������� �����
    property MinTime:Word read FMinTime write SetMinTime;                        //����������� �����
    property ForceDown:Byte read GetForceDown;                                   //���� �������
    constructor Create(AOwner:TTetrisGame);                                      //�����������
  end;

  TAppendStat = class                                                           //���������� ����������
   private                                                                      //������
    FOwner:TStatistics;                                                          //�������� (����������)
   public                                                                       //�����
    procedure Figure(Size:Cardinal);                                             //��������� ���-�� ���������� �����
    procedure Gold(Size:Cardinal);                                               //��������� ���-�� ������
    procedure Score(Size:Cardinal);                                              //��������� ����
    procedure Lines(Size:Cardinal);                                              //��������� ���-�� ��������� �����
    procedure Level(Size:Byte);                                                  //��������� �������
    property Owner:TStatistics read FOwner;                                      //��������
    constructor Create(AOwner:TStatistics);                                      //�����������
  end;

  TStatistics = class                                                           //����������
   private                                                                      //������
    FOwner:TTetrisGame;                                                          //�������� (������)
   public                                                                       //�����
    TheBest:array[1..10] of TStatTop;                                            //���-������
    Statistics:TStatRecord;                                                      //������
    Append:TAppendStat;                                                          //���������� �������� ������
    procedure Reset;                                                             //��������
    procedure Update;                                                            //��������
    procedure Load;                                                              //���������
    procedure Save;                                                              //���������
    function CheckScore(Score:Cardinal):Boolean;                                 //��������� ���� �� ��������� � ���-�������
    function InsertTheBest(Stat:TStatTop):Byte; overload;                        //���������� ���-������ � ������
    function InsertTheBest(AName:string; AScore:Cardinal):Byte; overload;        //���������� ���-������ � ������
    procedure ResetTheBest;                                                      //�������� ������ ���-�������
    property Owner:TTetrisGame read FOwner;                                      //��������
    constructor Create(AOwner:TTetrisGame);                                      //�����������
  end;

  TDrawThread = class(TThread)                                                  //�������������� ����� ��� ���������� ���������
   private                                                                      //������
    FOwner:TTetrisGame;                                                          //��������
   protected                                                                    //����������
    procedure Execute; override;                                                 //���������� (����.)
   public                                                                       //�����
    property Owner:TTetrisGame read FOwner;                                      //��������
    constructor Create(AOwner:TTetrisGame; CreateSuspended:Boolean);             //�����������
  end;

  TExtButton = class                                                            //����������� ������
   private                                                                      //������
    AType:TButtonType;                                                           //��� (������, �������)
    DisablePic:TPNGObject;                                                       //������� - ����������
    DownPic:TPNGObject;                                                          //������� - �����
    FBlink:Boolean;                                                              //������� (������ ������)
    FButtonState:TButtonState;                                                   //���������
    FEnable:Boolean;                                                             //����������
    FHeight:Integer;                                                             //������
    FLeft:Integer;                                                               //�����
    FNormal:TColor;                                                              //���� - ����.
    FOver:TColor;                                                                //���� - �������
    FOwner:TTetrisGame;                                                          //��������
    FPoly:TPoints;                                                               //����� ������
    FRect:TRect;                                                                 //������������� �������
    FRGN:HRGN;                                                                   //������ ����������
    FTop:Integer;                                                                //������
    FWidth:Integer;                                                              //������
    LBlink:Boolean;                                                              //������� (������.)
    NormalPic:TPNGObject;                                                        //������� - ����. ���������
    OverPic:TPNGObject;                                                          //������� - �������
    PCount:Byte;                                                                 //���-�� ����� ������
    function CreateRegionFromBMP(Image: TBitmap; var Width, Height:Integer):HRGN;//������� ������ �� BMP
    procedure SetBlink(Value:Boolean);                                           //���������� �������
    procedure SetEnable(Value:Boolean);                                          //���������� �����������
   public                                                                       //�����
    CTop:Integer;                                                                //��������� ��������� ������
    Click:TProcedure;                                                            //��������� �����
    Down:TColor;                                                                 //���� ��� �������
    Font:TFont;                                                                  //����� �������
    HintList:TStrings;                                                           //���������
    Normal:TColor;                                                               //������� ����
    Over:TColor;                                                                 //���� ��� ���������
    ShowHint:Boolean;                                                            //���������� ���������
    Text:string;                                                                 //����� �������
    function OnMouseUp(X, Y:Integer):Boolean;                                    //��� ���������� ������
    procedure OnMouseDown(X, Y:Integer);                                         //��� �������
    procedure OnMouseMove(X, Y:Integer);                                         //��� ������������
    procedure Paint;                                                             //��������
    constructor Create(AOwner:TtetrisGame; APoly:TPoints; LCount:Byte; AText:string; AWidth:Integer; ALeft, ATop:Integer); overload;
    constructor Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer); overload;
    constructor Create(AOwner:TtetrisGame; Mask:string; AText:string; ALeft, ATop:Integer; NFont:TFont; APc:TProcedure); overload;
   published                                                                     //��������������
    property Blink:Boolean read FBlink write SetBlink;                           //�������
    property ButtonState:TButtonState read FButtonState default bsNormal;        //���������
    property Enable:Boolean read FEnable write SetEnable default True;           //����������
    property Bounds:TRect read FRect;                                            //������������� �������
    property Owner:TTetrisGame read FOwner;                                      //��������
    property RGN:HRGN read FRGN;                                                 //������
  end;

  TSound = class                                                                //�������� �������������
   private                                                                      //������
    Bitmaps:TBitmaps;                                                            //������ �� ����������� �������
    FEnable:Boolean;                                                             //��������������� �� ����
    FOwner:TTetrisGame;                                                          //��������
    function GetVolume:Byte;                                                     //������ ���������
    procedure SetVolume(Value:Byte);                                             //���������� ��������� ���� �������
   public                                                                       //�����
    Music:array of Cardinal;                                                     //������ ����������� �������
    Sounds:array of Cardinal;                                                    //������ �������� �������
    function CreateStream(FileName:string; Channel:Boolean):Cardinal;            //��������� ����� �� �����
    function AddStream(FileName:TFileName; Channel:Boolean):Word;                //�������� �����
    property Enable:Boolean read FEnable write FEnable default False;            //�������� �� ����
    property Owner:TTetrisGame read FOwner;                                      //��������
    property Volume:Byte read GetVolume write SetVolume;                         //��������� ���� ������
    procedure Play(ID:Byte); overload;                                           //��������� ����
    procedure PlaySound(MSTREAM:Cardinal);                                       //�������� ���� � �����
    procedure PlaySound_2(MSTREAM:Cardinal);                                     //��������� �������� �������
    procedure Stop(ID:Byte); overload;                                           //���������� ����
    procedure Stop(MSTREAM:Cardinal); overload;                                  //���������� ����. �������
    constructor Create(AOwner:TTetrisGame);                                      //�����������
  end;

  TBitmaps = class                                                              //����������� �������
   private                                                                      //������
    AniID:Byte;                                                                  //����� ������� ���������
    AniNum:Byte;                                                                 //����� ����� ������� �������� ���������
    BGStep:Byte;                                                                 //������� ��� ����� ����
    BonusAni:Byte;                                                               //����� ����� �������� ������
    BonusAniTime:Byte;                                                           //�������� �������� ���������
    CurNum:Byte;                                                                 //����. ������
    DrawAni:Boolean;                                                             //�������� �� �������� ���������
    FLeft:Integer;                                                               //��������� ������� ������ ��������������
    FOwner:TTetrisGame;                                                          //������ �� ���������
    FPath:string;                                                                //���� ��������
    function GetAnimate:Byte;                                                    //������� ��������
    procedure SetAnimate(Value:Byte);                                            //������ ��������
   public                                                                       //�����
    AniBonus:array of TPNGObject;                                                //������ ������������ ������� ������
    AniBonusTime:array of TPNGObject;                                            //������ ������������ ������� ������ � ��������
    Animations:array [1..10, 1..8] of TPNGObject;                                //�������� ���������
    Backgrounds:array of TBitmap;                                                //������� �������
    BackGroundDraw:TBitmap;                                                      //�������������� ������� �������
    BackgroundOne:TBitmap;                                                       //��������� �������
    BackgroundTwo:TBitmap;                                                       //�������� �������
    BlackPoly:TPNGObject;                                                        //���������� ����
    BonusBusy:TPNGObject;                                                        //����� �����
    BonusExeing:TPNGObject;                                                      //����� �����������
    BreakBonus:TPNGObject;                                                       //����������� �����
    Contin:TPNGObject;                                                           //���������� ����
    Cost:TPNGObject;                                                             //������� ��������� - "���������"
    Cursor:array of TPNGObject;                                                  //������
    CurPen:TPNGObject;                                                           //������ - ��������
    CurDel:TPNGObject;                                                           //������ - ������
    EditInfo:TPNGObject;                                                         //�������������� ����� ��� ������ �������������� ������
    EditBox:TPNGObject;                                                          //������� ����� ����� ������ (����������)
    FShade:TPNGObject;                                                           //���� �������� ������
    ExedPanel:TPNGObject;                                                        //������ ���. �������
    ExedPanelEx:TPNGObject;                                                      //������ ��� ����� ������
    Figures:array of TPNGObject;                                                 //������ �������� �����
    GameOver:TPNGObject;                                                         //������� - ����� ����
    GridPoly:TPNGObject;                                                         //����� � �����������
    Hint:TPNGObject;                                                             //���������
    Light:TPNGObject;                                                            //������ 81x81
    LightField:TPNGObject;                                                       //������ (����)
    MPoly:TPNGObject;                                                            //��������� - ���� 4x21x4x21
    NextLvl:TPNGObject;                                                          //����. �������
    Panel:TPNGObject;                                                            //���. ������
    Pause:TPNGObject;                                                            //������� - �����
    Poly:TPNGObject;                                                             //��������� - ��� ����
    Saved:TBitmap;                                                               //����������� ������� ���� (��� ���������)
    ScaleBG:TPNGObject;                                                          //����� ������
    ShadePNG:TPNGObject;                                                         //������� "����"
    OveredBonus:TPNGObject;                                                      //��������� ������
    Start:TPNGObject;                                                            //������� - �����
    property Animate:Byte read GetAnimate write SetAnimate default 1;            //������� ��������
    property Owner:TTetrisGame read FOwner;                                      //��������
    procedure LoadFigures(FArray:TArrayOfFigure; SW, SH:Byte);                   //�������� �������� �����
    procedure NextFrame;                                                         //��������� ���� ��������
    constructor Create(Path:string; AOwner:TTetrisGame);                         //�����������
  end;

  TShade = class                                                                //����
   private                                                                      //������
    FOwner:TTetrisGame;                                                          //��������
   public                                                                       //�����
    Ready:Boolean;                                                               //����������
    ShadeArray:TTetArray;                                                        //����
    procedure Clear;                                                             //�������� ����
    procedure Update;                                                            //��������
    property Owner:TTetrisGame read FOwner;                                      //��������
    constructor Create(AOwner:TTetrisGame);                                      //�����������
  end;

  TLineClear = class                                                            //�������� �����
   private                                                                      //������
    FID:Byte;                                                                    //�� � ������ (��� ��������)
    FOwner:TTetrisGame;                                                          //��������
    FTop:Integer;                                                                //���������� Y  (������)
    GravityTimer:TTimer;                                                         //������ "��������"
    procedure GravityTimerTime(Sender:TObject);                                  //��������� ��������
   public                                                                       //�����
    ElementsL1:TFiguresL1;                                                       //���������� � ����������� ��������
    ElementsL2:TFiguresL2;                                                       //������ ���������
    FlyTime:Word;                                                                //����� ������
    procedure Paint;                                                             //���������
    property Owner:TTetrisGame read FOwner;                                      //��������
    constructor Create(ID:Byte; AOwner:TTetrisGame; Elements:TFiguresL2; ATop:Integer); //�����������
  end;

  TRedrawing = class                                                            //����������� ��������
   private                                                                      //������
    FScaleSize:Word;                                                             //������ ����� ������
    FScalePos:TPoint;                                                            //������� ����� ������
    FOwner:TTetrisGame;                                                          //��������
   public                                                                       //�����
    procedure Background;                                                        //�������� ������� �������
    procedure EditBox;                                                           //�������� ���� ��� ����� ����� ������ (����������)
    procedure Field(Left, Top:Integer);                                          //�������� ���� �� �����������
    procedure GameOver;                                                          //�������� "����� ����"
    procedure InfoPanels;                                                        //�������� ���. ������
    procedure LastBonuses(Left:Integer);                                         //�������� ����. ���. ������
    procedure NextFigure(Left, Top:Integer);                                     //�������� ����. ������
    procedure Save;                                                              //�������� "��������� ����"
    procedure SavedBG;                                                           //�������� ����������� ������� �������� ����
    procedure Scale(Left:Integer);                                               //�������� ����� ������
    procedure Stared;                                                            //�������� "������� �����"
    procedure Statistics;                                                        //�������� ���������� (���-�������)
    property Owner:TTetrisGame read FOwner;                                      //��������
    constructor Create(AOwner:TTetrisGame);                                      //�����������
  end;

  TTetrisGame = class                                                           //������� "���������"
   private                                                                      //������
    aEmpty:Byte;                                                                 //������ ������
    AlreadyShownButtons:Boolean;                                                 //��� ���� �������� ������ (��� �������)
    AnswerShut:Byte;                                                             //���������� ��� ������ ��� ���������� ����
    BonusAmountWidth:Byte;                                                       //���-�� ������� � ������
    CanBeContinue:Boolean;                                                       //���� ����� ���� ����������
    Confirm:Boolean;                                                             //��� ����� ��� ���
    CreatedBoss:Boolean;                                                         //������ ����
    Creating:Boolean;                                                            //���� �������������
    DebugEnabled:Boolean;                                                        //�������
    DoDrawFigure:TDrawType;                                                      //��������� �������������� ������
    Drawing:Boolean;                                                             //���� ���������
    FBoom:Byte;                                                                  //���� ������
    FButtonsHided:Boolean;                                                       //������ ������
    FButtonsHiding:Boolean;                                                      //������ ����������
    FCanvas:TCanvas;
    FCols:Byte;                                                                  //���-�� ��������
    FDrawCanvas:TCanvas;                                                         //����� ��� ��������
    FEditBoxActive:Boolean;                                                      //���� ��� ����� ����� ������� (����������)
    FEditBoxText:string;                                                         //����� ���� ��� ����� (����������)
    FFPS:integer;                                                                //���������� FPS
    FGameKeyCount:Byte;                                                          //���-�� ������� ������ ����. ���������
    FGameState:TGameState;                                                       //��������� ����
    FHelper:Boolean;                                                             //����� - "��������"
    FHeight:Byte;                                                                //������ �����
    FieldWidth:Word;                                                             //������ ����
    FieldHeight:Word;                                                            //������ ����
    FInfoMode:TInfoMode;                                                         //����� ���. �������
    FirstUpGold:Boolean;                                                         //������ ���������� ������
    FKeyIDDown:Byte;                                                             //�� ������� ����
    FKeyIDLeft:Byte;                                                             //�� ������� �����
    FKeyIDRight:Byte;                                                            //�� ������� ������
    FKeyIDRL:Byte;                                                               //�� ������� ������� �����
    FKeyIDRR:Byte;                                                               //�� ������� ������� ������
    FKeyIDUP:Byte;                                                               //�� ������� �����
    FLevel:Byte;                                                                 //������� �������
    FLevels:TLevels;                                                             //������
    FLines:Integer;                                                              //��������� �����
    FPauseTutorial:Boolean;                                                      //����� ��� ���������
    FRows:Byte;                                                                  //���-�� �����
    FShownTutScene:set of Byte;                                                  //���������� �����
    FSpeedRate:Smallint;                                                         //���������/��������� ��������
    FTimerActivate:Boolean;                                                      //���������� ��������
    FWaitAmount:Word;                                                            //���-�� ��������
    FWidth:Byte;                                                                 //������ �����
    GameKeys:TGameKeys;                                                          //������� �������
    Ghost:Boolean;                                                               //����� "���������� ������"
    IDDrawFigure:Byte;                                                           //�� �������� ������
    OldIM:TInfoMode;                                                             //��������� ����� ���. �������
    SLeft:Integer;                                                               //��������� ���� �����
    STop:Integer;                                                                //��������� ���� ������
    TutorialImg:TPNGObject;                                                      //�������� ���������
    TutorialPos:Integer;                                                         //������� �������� �� X
    WasGhostColl:Boolean;                                                        //��������� ������������ "�������� � ���"
    function GetFLevel(Index:Byte):Boolean;                                      //���������� ������
    function GetLevel:Byte;                                                      //������� �������
    function GetScaleLvl:Byte;                                                   //�������� �������� ���-�� ����� %
    function KeyIsDown(VK_KEY:Word):Boolean;                                     //������ �� �������
    procedure SetGameState(Value:TGameState);                                    //���������� ��������� ����
    procedure SetLevel(Value:Byte);                                              //���������� �������
    procedure SetLines(Value:Integer);                                           //���������� ���-�� ��������� �����
    procedure SetHelper(Value:Boolean);                                          //���������� �������� "���������"
    procedure SetIM(Value:TInfoMode);                                            //���������� �����
    procedure SetTimers(Value:Boolean);                                          //���������� ���������� ��������
   public                                                                       //�����
    ArrayOfBonuses:TBonuses;                                                     //������ �������
    ArrayOfBosses:TArrayOfFigure;                                                //������ ������
    ArrayOfButtons:TArrayOfButton;                                               //������ ������
    ArrayOfClears:TArrayOfClears;                                                //������ ����������� ���������
    ArrayOfExing:TArrayOfExing;                                                  //������ ����������� �������
    ArrayOfFigure:TArrayOfFigure;                                                //������ ��������� �����
    ArrayOfPanels:TArrayOfPanels;                                                //������ �������
    ArrayOfToDo:TBonuses;                                                        //������ ������� �� ����������
    BadGameBonusCount:Word;                                                      //���-�� ����������� �������
    Bitmaps:TBitmaps;                                                            //����������� �������
    CurFigure:TFigure;                                                           //������� ������
    DoBoom:Boolean;                                                              //"������"

    DrawBMP:TBitmap;                                                             //�����
    ExecutingBonus:Boolean;                                                      //����������� ����������� �����
    FigureEnable:Boolean;                                                        //������ ����
    FontTextAutor:TFont;                                                         //����� - �����
    FontTextBonuses:TFont;                                                       //����� - ������ �������
    FontTextButtons:TFont;                                                       //����� - ������
    FontTextDisplay:TFont;                                                       //����� - ���. �����
    FontTextGameOver:TFont;                                                      //����� - ����� ���� (��� ����)
    ForcedCoord:TPoint;                                                          //�������������� ����������
    ForcedCoordinates:Boolean;                                                   //������������ �������������� �������� ����
    FPS:Integer;                                                                 //���������� FPS
    Gold:Cardinal;                                                               //������
    GoldPos:TPoint;                                                              //������� ������
    Hint:TTextHint;                                                              //���������
    IsCreating:Boolean;                                                          //���� �������� ������
    IsTheBoss:Boolean;                                                           //���� ����
    IsWait:Boolean;                                                              //��������
    LeftPos:Byte;                                                                //������� ������ ������ �����
    LinesAmountForLevelUp:Byte;                                                  //���������� ����� ��� ��������� ������
    MainTet:TTetArray;                                                           //������� ������
    MoveTet:TTetArray;                                                           //����������� ������
    NeedShot:Boolean;                                                            //������� ������
    NextFigure:TFigure;                                                          //��������� ������
    NextFigureOld:TFigure;                                                       //������ "��������� ������"
    NextID:Integer;                                                              //ID ��������� ������
    MarshMode:Boolean;                                                           //������ "������"
    Mouse:TPoint;                                                                //������
    OldLevel:Byte;                                                               //���������� �������
    Patched:TFigureItem;                                                         //���������� �������
    RectForAutor:TRect;                                                          //������� ��� ������ �.�. ���� =)
    RectForBonuses:TRect;                                                        //���� ��� �������
    RectForBonusesMouse:TRect;                                                   //���� ���������� ���� ��� �������
    RectForButtons:TRect;                                                        //���� ��� ������
    RectForChangeMode:TRect;                                                     //���� ��� ��������� ������ ���. �������
    RectForExed:TRect;                                                           //���� ��� ���. �������
    RectForInfoText:TRect;                                                       //���� ��� ������
    RectForNextFigure:TRect;                                                     //���� ��� ����. ������
    Redraw:TRedrawing;                                                           //����� �����������
    Score:Cardinal;                                                              //���������� ����
    Shade:TShade;                                                                //"����"
    ShowCursos:Boolean;                                                          //��������� ������������ �������
    Shutdowning:Boolean;                                                         //���� ���������� ����
    Sound:TSound;                                                                //�������� �������������
    StartGold:Cardinal;                                                          //��������� ������
    StartSpeed:Word;                                                             //��������� �������� ������� ����
    Statistics:TStatistics;                                                      //����������
    TimerAnalysis:TTimer;                                                        //������ �������������� ����
    TimerAnimateFrames:TTimer;                                                   //������ ������� ������ ���������
    TimerBG:TTimer;                                                              //������ ����� ����
    TimerBonus:TTimer;                                                           //������ ��������� ������� �������
    TimerBonusCtrl:TTimer;                                                       //������ �������� ���������� �������
    TimerBoom:TTimer;                                                            //������ ��������� ������
    TimerDraw:TTimer;                                                            //������ ���������
    TimerStep: TTimer;                                                           //������ ���� ������
    TimerUpValues:TTimer;                                                        //������ �����
    TheardDraw:TDrawThread;                                                      //��������� ����� ��� ���������
    ToGold:Cardinal;                                                             //������
    TopPos:Byte;                                                                 //������� ������ ������ ������
    ToScore:Cardinal;                                                            //����
    Versa:Boolean;                                                               //�������� ����������
    UserFPS:Word;                                                                //������ ������ � ���.
    ZeroGravity:Boolean;                                                         //�����������
    function BuyAndExcecute(ABonus:TBonus):Integer;                              //������ � ��������� ����� (��������� - �������, 0 - �� ������)
    function CalcBrokenBonus:Word;                                               //������ �������� ����
    function CheckCollision(TetArray:TTetArray; ATop:Byte; IsShade:Boolean):Boolean; overload; //��������� �����. ������ �� ������������ �� ������������ ������
    function CheckCollision(TetArray:TTetArray; ATop, ALeft:Byte; IsShade:Boolean):Boolean; overload; //��������� �����. ������ �� ������������ � �����. �����.
    function CheckCollision(TetArray:TTetArray; IsShade:Boolean):Boolean; overload; //��������� �����. ������ �� ������������ �� ������ ������
    function CheckLine:Boolean;                                                  //��������� �� ���������� ������� (�������) ����� ����
    function CheckPause:Boolean;                                                 //��������� �� ����� � �� ���������� ����
    function CreateBMP(FName:string):TBitmap; overload;                          //������� BMP
    function CreateBMP(DLL:Cardinal; ID:string):TBitmap; overload;               //������� BMP �� �������
    function CreateBonus(var Figure:TFigure):Boolean;                            //������� ������ � ������
    function CreateFigure(Deg:Word; FigureName:string):TFigure;                  //�������� ������ (�������������� 10 to 2)
    function DeleteFilled(Row:Byte):Byte;                                        //������� ����������� �����, ������� � Row
    function ElemCount(Figure:TFigure):Byte;                                     //����� ������
    function GetNextBoss:TFigure;                                                //�������� ���������� �����
    function GetPreviewFigure:TFigure;                                           //�������� ��������� ������
    function GetRandomFigure:TFigure;                                            //�������� ��������� ������
    function GetSpeed:Word;                                                      //������� ��������
    function GetTop:Byte;                                                        //������ ������ ���������� ����
    function HeightOfFigure(AFigure:TFigure):Byte;                               //������ ������
    function Load:Boolean;                                                       //��������� �������� ����
    function LoadGame:Boolean;                                                   //�������� ����
    function Max(Val1, Val2:Integer):Integer;                                    //������������ �� ���� ��������
    function Min(Val1, Val2:Integer):Integer;                                    //����������� �� ���� ��������
    function RotateFigure(Figure:TFigure; OnSentry:Boolean):TFigure;             //������� ������ (�� ��������� �����, �����)
    function SaveGame:Boolean;                                                   //��������� ����
    function UpGold(Value:Word):Word;                                            //�������� ������
    function UpScore(Value:Integer):Integer;                                     //�������� � �����
    function WidthOfFigure(AFigure:TFigure):Byte;                                //������ ������
    procedure ActuateTimers;                                                     //������������ ����������� �������
    procedure AddButton(AButton:TExtButton);                                     //�������� ������
    procedure AddFigure(Figure:TFigure; var Dest:TArrayOfFigure);                //�������� ������ � ������ �����
    procedure AddToActionList(Bonus:TBonus);                                     //�������� ����� � ������ ��� ���������� � ��������� �����
    procedure AddToExed(Bonus:TBonus);                                           //�������� ����� � ������ ������ ��� ���.
    procedure AnimateDelete(ATop:Integer); overload;                             //��������� �������� ��������� � ������ ATop
    procedure AnimateDelete(ATop:Integer; Elems:TFiguresL2); overload;           //��������� �������� ��������� ��������� �� ������ ATop
    procedure Boom(Size:Byte; BTime:Word);                                       //������
    procedure BoomStop;                                                          //���������� ������
    procedure ContinueGame;                                                      //���������� ����������� ����
    procedure CreateBonuses;                                                     //��������� ������ �������
    procedure CreateButtons;                                                     //��������� ������ ������
    procedure CreateFigures;                                                     //������� ������
    procedure CreateFonts;                                                       //�������� �������
    procedure CreateGameKeys;                                                    //�������� ������� ������
    procedure CreateGraphicsAndSound;                                            //������������� ������� � �����
    procedure CreateHints;                                                       //�������� ���������
    procedure CreateNextBoss;                                                    //��������� ������ - ����
    procedure CreateNextFigure;                                                  //������� ��������� ������
    procedure CreatePanels;                                                      //��������� ������ �������
    procedure CreateRectAreas;                                                   //�������� �������� ������������
    procedure CreateTimers;                                                      //�������� ��������
    procedure ChangeBackground(ALevel:Byte);                                     //������� ���
    procedure ClearAll;                                                          //�������� ��� ����
    procedure ClrChng(var Chng:TTetArray);                                       //�������� ���. ������
    procedure DeactivateAllBonuses;                                              //�������������� ��� ������
    procedure DecGold(Cost:Word);                                                //����� ������
    procedure DeleteSaved;                                                       //������� ����. ����
    procedure Draw;                                                              //��������� �� ������
    procedure DrawBonuses;                                                       //�������� ������
    procedure DrawingFigure;                                                     //�������� ����� �������������� ����. ������
    procedure DrawingFigureClose(State:TGameState);                              //��������� ����� ���. � ������� �� ����
    procedure DrawingFigureEnd(State:TGameState);                                //��������� ����� ���.
    procedure ExecuteBonus(Bonus:TBonus);                                        //��������� �����
    procedure ExecuteRandomBonus(TB:TTypeBonus);                                 //��������� ��������� �����
    procedure ExecutingDelete;                                                   //��������� � ������� ����������� ������
    procedure Event(e, param1, param2:Integer);                                  //�������
    procedure HideButtons(ShowAnimate:Boolean);                                  //������ ������ ���������� (���������� �������� �������)
    procedure KeyDown;                                                           //�������� ������� ����
    procedure KeyLeft;                                                           //�������� ������� �����
    procedure KeyRight;                                                          //�������� ������� ������
    procedure KeyRotateLeft;                                                     //�������� ������� ������� �����
    procedure KeyRotateRight;                                                    //�������� ������� ������� ������
    procedure KeyUp;                                                             //�������� ������� �����
    procedure LevelUp;                                                           //��������� �������
    procedure LinesUp(Value:Integer);                                            //��������� ���-�� ��������� �����
    procedure Merger;                                                            //������� ���. ���� � ������
    procedure Move(Bottom:Byte);                                                 //�������� �����
    procedure MoveMouse;                                                         //������ ���� � ����
    procedure NeedDraw;                                                          //�������������� ���������
    procedure NewFigure;                                                         //����� ������
    procedure NewGame;                                                           //����� ����
    procedure Normalization(var Figure:TFigure);                                 //������������� ������
    procedure OnBonusExecuted(Bonus:TBonus);                                     //����� ���������� ������
    procedure OnBonusStartExecute(Bonus:TBonus);                                 //����� �����������
    procedure OnKeyDown(Key:Word; Shift:TShiftState);                            //��� ������� �������
    procedure OnKeyPress(Key:Char);                                              //��� ������� ������� (������)
    procedure OnMouseDown(Button:TMouseButton; Shift:TShiftState; X, Y: Integer);//��� ������� ������ ����
    procedure OnMouseMove(Shift:TShiftState; X, Y: Integer);                     //��� ����������� ����
    procedure OnMouseUp(Button:TMouseButton; Shift:TShiftState; X, Y: Integer);  //��� ���������� ������ ����
    procedure PauseGame;                                                         //�����
    procedure Reset;                                                             //�������� ��������
    procedure RotateGameFigure(OnSentry:Boolean);                                //��������� ������� ������
    procedure ShowAnimate(ID:Byte);                                              //���������� ������ ��������
    procedure ShowButtons;                                                       //�������� ������
    procedure ShowFigureChanging(FStart, FEnd:TFigure);                          //�������� ��������� ������
    procedure ShowGoldDec(Size:Word);                                            //�������� ������� ������ ����� (-Size)
    procedure ShowHideButtons;                                                   //��������/������ ������
    procedure Shutdown;                                                          //���������� ������ ���������
    procedure SpeedDown(Value:Byte);                                             //�������� ��������
    procedure SpeedUp(Value:Byte);                                               //�������� ��������
    procedure StepDown;                                                          //�������� ������ �� ���� ����� (���)
    procedure StepDownBonuses;                                                   //��� �������� �������
    procedure StepLeft;                                                          //�������� �����
    procedure StepRight;                                                         //�������� ������
    procedure StopGame;                                                          //��������� ����
    procedure StepUp;                                                            //�������� �����
    procedure TimerAnalysisTimer(Sender: TObject);                               //��������� ������� ��� ������� ����
    procedure TimerAnimateFramesTimer(Sender: TObject);                          //��������� ������������ ������
    procedure TimerBGTimer(Sender: TObject);                                     //��������� ����� ����
    procedure TimerBonusCtrlTimer(Sender: TObject);                              //��������� ������� �������
    procedure TimerBonusTimer(Sender: TObject);                                  //��������� �������� �������
    procedure TimerBoomTimer(Sender: TObject);                                   //��������� ������
    procedure TimerDownStart;                                                    //������ ������� ��������
    procedure TimerDownStop;                                                     //��������� ������� ��������
    procedure TimerDrawTimer(Sender: TObject);                                   //��������� ���������
    procedure TimerStepTimer(Sender: TObject);                                   //��������� ����
    procedure TimerUpValuesTimer(Sender: TObject);                               //��������� ��������
    procedure Tutorial(Scene:Byte);                                              //�������� ����������� �����
    procedure UpdateSpeed;                                                       //�������� �������� �������� ������
    procedure UseAllExcept(IDOfTheFigure:Byte);                                  //���. ��� ������ ����� �����
    procedure UseAllFigures;                                                     //���. ��� ������
    procedure UseOnly(IDOfTheFigure:Byte);                                       //���. ������ ���� ��� ������
    procedure Wait(MTime:Word);                                                  //���������
    procedure WaitWithoutStop(MTime:Word);                                       //��������� ��� ��������� ����
    procedure WriteDebug(Text:string);                                           //������ � ���������� ����
    property ButtonsHided:Boolean read FButtonsHided;                            //������ �� ������
    property Canvas:TCanvas read FCanvas;
    property Cols:Byte read FCols default 15;                                    //���-�� ��������
    property EditBoxActive:Boolean read FEditBoxActive;                          //���������� ���� ��� ����� ����� ������ (����������)
    property GameState:TGameState read FGameState write SetGameState;            //��������� ����
    property Helper:Boolean read FHelper write SetHelper;                        //��������
    property InfoMode:TInfoMode read FInfoMode write SetIM;                      //����� ���. ����.
    property Level:Byte read GetLevel write SetLevel;                            //�������
    property Levels[Index :Byte]:Boolean read GetFLevel;                         //������ �������
    property Lines:Integer read FLines write SetLines;                           //��������� � ��������� �����
    property Rows:Byte read FRows default 23;                                    //���-�� �����
    property ScaleLvl:Byte read GetScaleLvl;                                     //����� �����
    property SHeight:Byte read FHeight default 20;                               //������ �����
    property SWidth:Byte read FWidth default 20;                                 //������ �����
    property Timers:Boolean read FTimerActivate write SetTimers;                 //���������� ��������
    constructor Create(ACanvas:TCanvas);                                         //�����������
  end;

  THelpObject  = class                                                          //��������� (��������� �����)
   private                                                                      //������
    FCaption:string;                                                             //���������
    FFont:TFont;                                                                 //�����
    FGraphic:TPNGObject;                                                         //����������� ���������� ���������
    FOwner:TTetrisGame;                                                          //��������
    FPosition:TPoint;                                                            //�������
    FRect:TRect;                                                                 //������������� (������� ���������)
    FText:string;                                                                //�����
    FVisible:Boolean;                                                            //���������
    function GetCaption:string; virtual;                                         //������ ���������
    function GetGraphic:TPNGObject; virtual;                                     //������ ����. ������.
    function GetText:string; virtual;                                            //������ �����
    procedure SetCaption(Value:string); virtual;                                 //���������� ���������
    procedure SetGraphic(Value:TPNGObject); virtual;                             //���������� ����. ������.
    procedure SetText(Value:string); virtual;                                    //���������� �����
   public                                                                       //�����
    procedure Hide; virtual;                                                     //�������
    procedure Paint; virtual;                                                    //��������� �� ������ ��������
    procedure Show(AText, ACaption:string); overload; virtual;                   //����������� � �����������
    procedure Show; overload; virtual;                                           //�����������
    property Caption:string read GetCaption write SetCaption;                    //���������
    property Font:TFont read FFont write FFont;                                  //�����
    property Graphic:TPNGObject read GetGraphic write SetGraphic;                //�������
    property Owner:TTetrisGame read FOwner;                                      //��������
    property Position:TPoint read FPosition write FPosition;                     //�������
    property RectObj:TRect read FRect write FRect;                               //�������
    property Text:string read GetText write SetText;                             //�����
    property Visible:Boolean read FVisible write FVisible;                       //���������
    constructor Create(AOwner:TTetrisGame); virtual;                             //�����������
  end;

  TTextHint = class(THelpObject)                                                //���������
   public                                                                       //�����
    BeforeShowTime:Word;                                                         //����� ����� �������
    FTimer:TTimer;                                                               //������ ��������� ������� � �����������
    GCost:TPNGObject;                                                            //������� - ���������
    HintList:TStrings;                                                           //������ ����� � ���������
    ShowFooter:Boolean;                                                          //���. ���� ���������
    ShowingTime:Word;                                                            //����� ������
    FooterText:string;                                                           //����� ���. ����
    procedure Hide; override;                                                    //������
    procedure Paint; override;                                                   //���������
    procedure Show(Button:TExtButton); overload;                                 //����� ��������� ������
    procedure Show(ACaption, FF:string; AText:TStrings; ATime, BTime:Cardinal); overload; //����� ���������
    procedure Show(ACaption, FF, AText:string; ATime, BTime:Cardinal); overload; //����� ���������
    procedure TimerHideTimer(Sender: TObject);                                   //��������� ������� � �����������
    property Timer:TTimer read FTimer;                                           //������ ��������� ������� � �����������
    constructor Create(AOwner:TTetrisGame); override;                            //�����������
  end;

  TBonus = class                                                                //�����
   private                                                                      //������
    FCost:Word;                                                                  //���������
    FDesc:string;                                                                //��������
    FEnabled:Boolean;                                                            //����������� ����. ��������
    FGraphics:array of TPNGObject;                                               //�������
    FID:Integer;                                                                 //���������� �����
    FIcon:TPNGObject;                                                            //������
    FLevel:TLevels;                                                              //������ �������
    FName:string;                                                                //��������
    FOver:Boolean;                                                               //����� ���� ����. ��������
    FOwner:TTetrisGame;                                                          //��������
    FPositive:Boolean;                                                           //������������� ��� ������ �����
    FRectObject:TRect;                                                           //������������ ����. ��������
    FSounds:array of Cardinal;                                                   //������ ������
    FType:TBonusType;                                                            //��� ������� � ������
    function GetGraphics(Index:Byte):TPNGObject; virtual;                        //�������� �������
    function GetLevel(Index:Byte):Boolean; virtual;                              //������ ����������� �� ������
    function GetSound(Index:Byte):Cardinal; virtual;                             //�������� ����
    function GetRectObj:TRect;                                                   //������� ������ - ������
    procedure SetCost(Value:Word); virtual;                                      //���������� ���������
    procedure SetDesc(Value:string); virtual;                                    //���������� ��������
    procedure SetEnabled(Value:Boolean); virtual;                                //���������� �����������
    procedure SetGraphics(Index:Byte; Value:TPNGObject); virtual;                //���������� �������
    procedure SetLevel(Index:Byte; Value:Boolean); virtual;                      //���������� �������
    procedure SetName(Value:string); virtual;                                    //���������� ���
    procedure SetOver(Value:Boolean); virtual;                                   //���������� �����
    procedure SetPositive(Value:Boolean); virtual;                               //���������� �������� "�������������/�������������"
    procedure SetRectObject(Value:TRect); virtual;                               //���������� ������� ������ - ������
    procedure SetSound(Index:Byte; Value:Cardinal); virtual;                     //���������� ����
   public                                                                       //�����
    HintList:TStrings;                                                           //���������
    function AddGraphic(PNG:TPNGObject):Word; virtual;                           //�������� �������
    function AddSound(HSTREAM:Cardinal):Word; virtual;                           //�������� ����
    procedure Paint; virtual;                                                    //��������� ������ - ������
    procedure PaintGraphics; virtual;                                            //��������� ������������ �������������
    procedure SetIcon(AIcon:TPNGObject); virtual;                                //���������� ������
    procedure SetLevels(Deg:Word);                                               //��������� ������� ������� (10 -> 2 -> Array)
    property BonusType:TBonusType read FType write FType;                        //��� ������� � ������
    property Cost:Word read FCost write SetCost;                                 //���������
    property Desc:String read FDesc write SetDesc;                               //��������
    property Enabled:Boolean read FEnabled write SetEnabled;                     //�����������
    property Graphics[Index:Byte]:TPNGObject read GetGraphics write SetGraphics; //������ �������
    property Icon:TPNGObject read FIcon;                                         //������
    property BID:Integer read FID write FID;                                     //������ ������������
    property Levels[Index:Byte]:Boolean read GetLevel write SetLevel;            //������ �������
    property Name:String read FName write SetName;                               //��������
    property Owner:TTetrisGame read FOwner;                                      //��������
    property Over:Boolean read FOver write SetOver;                              //�����
    property Positive:Boolean read FPositive write SetPositive;                  //������� "������������\�������������"
    property RectObject:TRect read GetRectObj write SetRectObject;               //������� ������-������
    property Sounds[Index:Byte]:Cardinal read GetSound write SetSound;           //������ ������
    constructor Create(AOwner:TTetrisGame); virtual;                             //�����������
  end;

  TSimpleBonus = class(TBonus)                                                  //������� ����� (��������� ��������)
   private                                                                      //������
    FExecuting:Boolean;                                                          //���� ����������
    procedure Action; virtual; abstract;                                         //��������
   public                                                                       //�����
    procedure Execute; virtual;                                                  //���������
    procedure Paint; override;                                                   //��������� ������ - ������
    property Executing:Boolean read FExecuting write FExecuting;                 //���� ����������
    constructor Create(AOwner:TTetrisGame); override;                            //�����������
  end;

  TTimeBonus = class(TBonus)                                                    //��������� ����� (��������� �������� �� �����)
   private                                                                      //������
    FActive:Boolean;                                                             //���������� ������
    FLastTime:Word;                                                              //���������� ����� ��������
    FTime:Word;                                                                  //����� ��������
    FTimer:TTimer;                                                               //������ ��������� �������
    procedure SetTime(Value:Word);                                               //���������� �����
    procedure TimerTime(Sender:TObject); virtual;                                //��������� �������
   public                                                                       //�����
    procedure Activate; virtual;                                                 //������������
    procedure Deactivate; virtual;                                               //��������������
    procedure Paint; override;                                                   //��������� ������-������
    property ActionTime:Word read FTime write SetTime;                           //����� ��������
    property Activated:Boolean read FActive;                                     //����������
    property LastTime:Word read FLastTime;                                       //���������� �����
    property Timer:TTimer read FTimer;                                            //������
    constructor Create(AOwner:TTetrisGame); override;                            //�����������
  end;

  TTextPanel = class                                                            //��������� ������
   private                                                                      //������
    FFont:TFont;                                                                 //�����
    FGraphic:TPNGObject;                                                         //�������
    FRect:TRect;                                                                 //�������
    FOwner:TTetrisGame;                                                          //��������
    FText:TStrings;                                                              //�����
    FVisible:Boolean;                                                            //���������
    FWS:Boolean;                                                                 //��� ���� ��� ��������
    function GetText(Index:Word):String;                                         //�������� ������
    function GetLeft:Integer;                                                    //�����
    function GetTop:Integer;                                                     //������
    function GetHeight:Integer;                                                  //������
    function GetWidth:Integer;                                                   //������
    procedure SetHeight(Value:Integer);                                          //���������� �������� "������"
    procedure SetLeft(Value:Integer);                                            //���������� �������� "�����"
    procedure SetRect(Value:TRect);                                              //���������� �������
    procedure SetText(Index:Word; Value:string);                                 //���������� �����
    procedure SetTop(Value:Integer);                                             //���������� �������� "������"
    procedure SetWidth(Value:Integer);                                           //���������� �������� "������"
   public                                                                       //�����
    procedure Hide;                                                              //������
    procedure Paint; virtual;                                                    //���������
    procedure Show;                                                              //��������
    property ClipRect:TRect read FRect write SetRect;                            //�������
    property Font:TFont read FFont write FFont;                                  //�����
    property Graphic:TPNGObject read FGraphic write FGraphic;                    //�������
    property Height:Integer read GetHeight write SetHeight;                      //������
    property Left:Integer read GetLeft write SetLeft;                            //�����
    property Owner:TTetrisGame read FOwner;                                      //��������
    property Strings:TStrings read FText;                                        //�����
    property Text[Index:Word]:string read GetText write SetText;                 //��������� ������
    property Top:Integer read GetTop write SetTop;                               //������
    property Visible:Boolean read FVisible write FVisible;                       //���������
    property WasShown:Boolean read FWS write FWS;                                //��� ���� ��� ��������
    property Width:Integer read GetWidth write SetWidth;                         //������
    constructor Create(AOwner:TTetrisGame); virtual;                             //�����������
  end;

///////////////////////////////�������� �������/////////////////////////////////

  TShot = class(TSimpleBonus)                                                   //������� ����� - "�����"
   public                                                                       //�����
    procedure Action; override;                                                  //������� ��������� ���-�� ��������� ����
  end;

  TKnife = class(TSimpleBonus)                                                  //������� ����� - "���"
   public                                                                       //�����
    procedure Action; override;                                                  //������� ����� ������� ���� ����
  end;

  THelper = class(TTimeBonus)                                                   //��������� ����� - "��������"
   public                                                                       //�����
    procedure Activate; override;                                                //�������� ��������� (��������� ������)
    procedure Deactivate; override;                                              //�����������
  end;

  TPatch = class(TSimpleBonus)                                                  //������� ����� - "Patcher"
   public                                                                       //�����
    procedure Action; override;                                                  //�������� �������� ������ � ��������� "����"
  end;

  TVersa = class(TTimeBonus)                                                    //��������� ����� "��, ��"
   public                                                                       //�����
    procedure Activate; override;                                                //�������� ������� ������ ����������
    procedure Deactivate; override;                                              //�����������
  end;

  TScan = class(TSimpleBonus)                                                   //������� ����� - "�����"
   public                                                                       //�����
    Drawing:Boolean;                                                             //���������
    GX, GY:Integer;                                                              //���������� ���������������� �������
    procedure Action; override;                                                  //������� ������� ���� ��������
    procedure PaintGraphics; override;                                           //��������� ������������ �������������
  end;

  TBoss = class(TSimpleBonus)                                                   //������� ����� - "����"
   public                                                                       //�����
    procedure Action; override;                                                  //���������� ��������� ������� ����� ������� ������
  end;

  TChangeFigure = class(TSimpleBonus)                                           //������� ����� - "������"
   public                                                                       //�����
    procedure Action; override;                                                  //�������� ��������� ������
  end;

  TKick = class(TSimpleBonus)                                                   //������� ����� - "����"
   public                                                                       //�����
    Drawing:Boolean;                                                             //���������
    GX, GY:Integer;                                                              //���������� ���������������� �������
    procedure Action; override;                                                  //������� ������� ���� ��������
  end;

  TEditFigure = class(TSimpleBonus)                                             //������� ����� - "��������"
   public                                                                       //�����
    procedure Action; override;                                                  //��������������� ��������� ������
  end;

  TScatter = class(TSimpleBonus)                                                //������� ��������� - "�������"
   public                                                                       //�����
    procedure Action; override;                                                  //���������� �������� ����
  end;

  TRestart = class(TSimpleBonus)                                                //������� ����� - "�����"
   public                                                                       //�����
    procedure Action; override;                                                  //������� �� ����
  end;

  TFull = class(TSimpleBonus)                                                   //������� ����� - "����������"
   public                                                                       //�����
    procedure Action; override;                                                  //��������� ��� ���� ����������
  end;

  TUseOnly = class(TTimeBonus)                                                  //��������� ����� "������ ������"
   public                                                                       //�����
    procedure Activate; override;                                                //������������ ������ ���� ��� �����
    procedure Deactivate; override;                                              //�����������
  end;

  TUseAllExcept = class(TTimeBonus)                                             //��������� ����� "��������� ��� �����"
   public                                                                       //�����
    procedure Activate; override;                                                //��������� ���� ��� �����
    procedure Deactivate; override;                                              //�����������
  end;

  TGhostMode = class(TSimpleBonus)                                              //����� "���������� ������"
   public                                                                       //�����
    procedure Action; override;                                                  //��������/��������� ����� "���������� ������"
  end;

  TSally = class(TSimpleBonus)                                                  //������������� ����� "������� ������"
   public                                                                       //�����
    DoDrawing:Boolean;                                                           //��������� ���������
    FTop:Byte;                                                                   //��������� ������ ������
    FLeft:Byte;                                                                  //��������� ������ �����
    WF:Byte;                                                                     //������ ������
    HF:Byte;                                                                     //������ ������
    SallyFigure:TTetArray;                                                       //���� ��� ��������� "�������" ������
    procedure Action; override;                                                  //���������
    procedure PaintGraphics; override;                                           //����� ��������� ������������ �������������
  end;

  TRndRotate = class(TTimeBonus)                                                //��������� ������� ������
   private                                                                      //������
    TimerRotate:TTimer;                                                          //������ ��������� ���� ��������
    TimerSpeed:TTimer;                                                           //������ ��������� ��������
    procedure TimerSpeedTime(Sender:TObject);                                    //��������� ������� ���. ���� ����.
    procedure TimerRotateTime(Sender:TObject);                                   //��������� ������� ���. ����.
   public                                                                       //�����
    procedure Activate; overload; override;                                     //�������� ��������� ������� ������
    procedure ActivateWith(Tm1, Tm2:Word);                                       //��������� � ����������� �������
    procedure Deactivate; override;                                              //�����������
    constructor Create(AOwner:TTetrisGame); override;                            //�����������
  end;

  TZeroGravity = class(TSimpleBonus)                                            //�����������
   public                                                                       //�����
    procedure Action; override;                                                  //��������/��������� ����������
  end;

  THail = class(TSimpleBonus)                                                   //����
   public                                                                       //�����
    procedure Action; override;                                                  //��������� ��������
  end;

  TMarsh = class(TTimeBonus)                                                    //��������� ����� "����� "������""
   public                                                                       //�����
    procedure Activate; override;                                                //�������� ����� "������"
    procedure Deactivate; override;                                              //�����������
  end;

  TSpeedUp = class(TTimeBonus)                                                  //��������� ����� "��������� ��������"
   private
    FValue:SmallInt;
   public                                                                       //�����
    procedure Activate; override;                                                //�������� ��������
    procedure Deactivate; override;                                              //�������� ��������
    constructor Create(AOwner:TTetrisGame); override;                            //�����������
  end;

//////////////////////////////////////�����/////////////////////////////////////

const
 eventTutorial = 2;
 eventBoss = 1;
 eventBonus = 2;
 eventBonus_1 = 3;

var
 ProgramPath:string;                                                            //������� ���������
 LoadState:Word;                                                                //��������� ���� � �����


procedure Ahtung;                                                               //������
procedure State(ID:Word);                                                       //���������� ��������� ���� � �����
procedure TextOutAdv(Canvas:TCanvas; Angle:Smallint; X, Y:Integer; Text:string);//��������� ������ ��� ������������ �����

implementation
 uses PNGWork, WorkWithRect, IniFiles, Bass;                                    //������ � PNG, ������ � �������., ������. �����, Bass.dll

procedure State(ID:Word);                                                       //��������� �������� ����
begin
 LoadState:=ID;
 Application.ProcessMessages;
end;

procedure TextOutAdv(Canvas:TCanvas; Angle:Smallint; X, Y:Integer; Text:string);//����� ������ ��� �����. �����
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
  '��������� ������ ��� ������������� ����. �������� ���������� ��������� �����.'+
  #13+#10+
  #13+#10+
  #13+#10+
  '��������� ��������� �������� ������ ������ ��������.'+
  #13+#10+
  '������: "'+SysErrorMessage(GetLastError)+'"'), '������', MB_ICONSTOP or MB_OK);
 Application.Terminate;
end;

/////////////////////////////TGameKey///////////////////////////////////////////

constructor TGameKey.Create(AOwner:TTetrisGame);
begin
 inherited Create;
 //��������� ����������� ���������� � ������������� �������
 FContradictionEnable:=False;
 FContradiction:=0;
 FOwner:=AOwner;
 FStartTime:=100;
 FMinTime:=20;
 FGameKeyInfo.FForceDown:=0;
 FTimer:=TTimer.Create(nil);
 FTimer.OnTimer:=FTimerTime;
 //������ ��������
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
 //�������������� ������� �������
 FContradictionEnable:=True;
 //��������� ��������� ��
 FContradiction:=Value;
end;

procedure TGameKey.Release;
begin
 //���� ������ �� ������ - �������
 //if not FTimer.Enabled then Exit;
 //���������� ������������ �������
 FTimer.Enabled:=False;
 FTimer.Interval:=FStartTime;
 //���������� ���� �������
 FGameKeyInfo.FForceDown:=Abs(FStartTime - FTimer.Interval);
end;

function TGameKey.GetForceDown:Byte;
begin
 //���� ������� = (����� ������� / (����������� ����� - ����������� �����) * 100)
 Result:=Round((FGameKeyInfo.FForceDown / (FStartTime - FMinTime)) * 100);
end;

procedure TGameKey.Press;
begin
 //����� ������������ �������
 FTimerTime(nil);
 //��������� ������ ��� ���������� ���������
 FTimer.Enabled:=True;
end;

procedure TGameKey.SetStartTime(Value:Word);
begin
 //���� �������� ������ 100 - ������������� ����������� �������� (100)
 if Value < 100 then Value:=100;
 FStartTime:=Value;
 //������� � ��� ������������� ����������� ��������� ��� ��� �������������
 SetMinTime(FMinTime);
end;

procedure TGameKey.SetMinTime(Value:Word);
begin
 //���� �������� ������ ������������ ������� - ����������� ����� ����� ������������ (��� ����������� ��������)
 if Value > FStartTime then Value:=FStartTime;
 //���� �������� ������ 20 - ������������� ����������� �������� (20)
 if Value < 20 then Value:=20;
 FMinTime:=Value;
 //������������� ������
 FTimer.Interval:=FStartTime;
end;

procedure TGameKey.FTimerTime(Sender:TObject);
begin
 //���� �������� - �������
 if FOwner.IsWait then Exit;
 //���� ������ ������� ���� - ������ ��� ����
 if FOwner.KeyIsDown(FGameKeyInfo.Code) then
  begin
   //���� ������� ������� ��������������, �� ���������� � ����������
   if FContradictionEnable then FOwner.GameKeys[FContradiction].Release;
   //���� ��� ���� ����������� �������� ��������� - ��������
   if FTimer.Interval > FMinTime then FTimer.Interval:=FTimer.Interval - 10;
   //���� �������� ��������� - ���������
   if Assigned(Action) then Action;
   //������������� ���� ������� (�������� ����� ����������� �������� � �������)
   FGameKeyInfo.FForceDown:=Abs(FStartTime - FTimer.Interval);
  end
 //� ��������� ������ ��������� �������
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
 //��������� ������ �� �������� (���-�� �����)
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
   Owner.Hint.Show('��������', '', '�� �������|���������|������|���-�������.', 3, 3);
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
   Owner.Hint.Show('��������', '', '�� �������|���������|���������|������', 3, 0);
   Exit;
  end;
 end;
 FS.Free;
end;

/////////////////////////////////TRedrawing/////////////////////////////////////

//��������� �� ����� ���������� ���������

procedure TRedrawing.Scale;
begin
 with Owner, Owner.Canvas, Owner.Bitmaps do
  begin
   if Creating then Exit;
   //Draw(FScalePos.X + FScaleSize - 5, FScalePos.Y - 15, NextLvl);
   //Draw(Left + ExedPanel.Width - 1, FieldHeight - 31, ExedPanelEx);
   //������ ������ ��� �����
   Draw(FScalePos.X - 10, FScalePos.Y - 11, ExedPanelEx);
   //������ ���. �����
   Pen.Width:=4;
   Pen.Color:=$00B6FF;
   MoveTo(FScalePos.X - 2, FScalePos.Y);
   LineTo(Round(FScalePos.X + (FScaleSize / 100) * ScaleLvl), FScalePos.Y);
   //������ ������� �����
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
   TextOut(5, FieldHeight - 15, '������� � '+GlAutr+' 2013');
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
   //������ ���. �����
   for C:=1 to GlExes do
    begin
     if not ArrayOfExing[C].Active then Continue;
     Draw(R * 21 + Left + 3, FieldHeight - 30, ArrayOfExing[C].Bonus.Icon);
     if not (ArrayOfExing[C].Bonus.BID in UsedBS) then
      begin
       //����������� ����������� ������� ���������� ������
       if (ArrayOfExing[C].Bonus is TTimeBonus) then
        if (ArrayOfExing[C].Bonus as TTimeBonus).Activated then
         begin
          RectObject:=Rect(R * 21 + Left + 3, FieldHeight - 30, R * 21 + Left + 3 + 21, FieldHeight - 30 + 21);
          //������ ������ - "�����" � �����
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
   //��������� ������ ������
   if InfoMode in [imInfoText, imTransforming] then
    begin
     //�������������� ������
     Brush.Style:=bsClear;
     Draw(RectForInfoText.Left, RectForInfoText.Top, MPoly);
     Font.Assign(FontTextDisplay);
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 0), {ormat}'���. �������'{[Simple]});
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 1), Format('����: %d',    [Score]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 2), Format('������: %d',  [Gold]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 3), Format('�����: %d',   [Lines]));
     TextOut(RectForInfoText.Left + 4, RectForInfoText.Top + 1 + (16 * 4), Format('�������: %d', [GetLevel]));
     Draw(RectForInfoText.Left, RectForInfoText.Top, Light);
    end;
   if InfoMode in [imBonuses, imTransforming] then
    begin
     //������ �������
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
   TextOut(L + 5, T - 35, '������� ���� ���:');
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
   TextOut(SLeft + W div 2 - TextWidth('��� 10 �������') div 2, STop + 10, '��� 10 �������');

   Font.Color:=clBlack;
   Font.Size:=20;
   TextOut(SLeft + W div 2 - TextWidth('��� 10 �������') div 2, STop + 10, '��� 10 �������');

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
    //���� "������" - ������ ��������� ���
    if DoBoom then Draw(Random(FBoom) - 10, Random(FBoom) - 10, BackGroundDraw)
     //���� ��� ������ - ������ ������ ���
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
   //������� ����, ������ ������, ����� ("��������")
   Brush.Style:=bsClear;
   Font.Assign(FontTextBonuses);
   for R:=GlFVRw to Rows do
    for C:=1 to Cols do
     begin
      //���� ������� ����. ������ �� ����
      if MoveTet[R, C].State <> bsEmpty then
       Draw((C - 1) * SWidth + Left - 2, (R - GlFVRw) * SHeight + Top - 2, FShade);
     end;   
   for R:=GlFVRw to Rows do
    for C:=1 to Cols do
     begin    
      //���� ������� �������� � �� ����� � ������
      if Helper and Shade.Ready then
       //���� ������� ���� �� ����
       if Shade.ShadeArray[R, C].State <> bsEmpty then
        Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, ShadePNG);
      //���� ������� ����. ������ �� ����
      if MoveTet[R, C].State <> bsEmpty then
       begin
        //������ ������� ������
        Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, Figures[MoveTet[R, C].ID - 1]);
        //���� ������� �������� - ������ ��������
        if MoveTet[R, C].State = bsBonus then Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonus[BonusAni]);
        //���� ����� "���������� ������" - ������ ���������
        if Ghost then Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, OveredBonus);
        //�.�. ����. ������ ����� ���������, �� ��������� ���� ���������� ���������� ��������
        Continue;
       end;
      //���� ������� ��. ���� �� ���� - ������ ������� ������
      if MainTet[R, C].State <> bsEmpty then
       begin
        try
         Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, Figures[MainTet[R, C].ID - 1]);
        except
         MessageBox(0, PChar('������ ��� ��������� ������: '+IntToStr(R)+' '+IntToStr(C)), '', 0);
        end;
        //��������� �� ���. ���������
         try
          case MainTet[R, C].State of
           //���� ������ ����� (��� �������) - ������ �������� ������ (��� �������� "�� �������")
           bsBonus: Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonus[BonusAni]);
           //���� �� �������� ������ ������
           bsBonusTiming:
            begin
             //������ ������� ������ � ��������
             Draw((C - 1) * SWidth + Left, (R - GlFVRw) * SHeight + Top, AniBonusTime[BonusAniTime]);
             //���������� �����
             TextOut((C - 1) * SWidth + Left + (SWidth div 2) - (TextWidth(IntToStr(MainTet[R, C].TimeLeft)) div 2) + 1,
              (R - GlFVRw) * SHeight + Top + (SHeight div 2) - (TextHeight(IntToStr(MainTet[R, C].TimeLeft)) div 2), IntToStr(MainTet[R, C].TimeLeft));
            end;
           //���� ����� �� ������ ������� - ������ ������� "����������" ������
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
   //������ ����
   for R:=1 to GlSize do
    for C:=1 to GlSize do
     begin
      if NextFigure.Elements[R, C].State <> bsEmpty then
       begin
        Draw(((C - 1) * SWidth) + 340 - 2, ((R - GlSize) * SHeight) + 80 - 2, FShade);
       end;
     end;
   //������ ��������
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
   //���������� ������ ������� (���� ��� ����)
   if ElementsL2[i].State = bsEmpty then Continue;
   //������ �������� �������� �����
   Owner.Canvas.Draw(Round(ElementsL1[i].X) - 2, Round(ElementsL1[i].Y) - 2, Owner.Bitmaps.FShade);
   Owner.Canvas.Draw(Round(ElementsL1[i].X), Round(ElementsL1[i].Y), Owner.Bitmaps.Figures[ElementsL2[i].ID - 1]);
   //������ ���. ��������� ��������
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
 //����������� �������� �������
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
 //���� �������� ��������
 if Hidden then
  begin
   //������� ������
   GravityTimer.Free;
   //������� ����������� �������� �� ������
   FreeAndNil(Owner.ArrayOfClears[FID]);
  end;
end;

constructor TLineClear.Create(ID:Byte; AOwner:TTetrisGame; Elements:TFiguresL2; ATop:Integer);
var i, Left:Byte;
begin
 inherited Create;
 //������ �� ���������
 FOwner:=AOwner;
 //���������� ���� �������� � ������� ���������
 FID:=ID;
 //������ ������, �� ������� ��������� ��������
 FTop:=ATop;
 //����� ������
 FlyTime:=5;
 //������� "������" ������ "����������" � ������������ ���������� � ������������ �������
 GravityTimer:=TTimer.Create(nil);
 with GravityTimer do
  begin
   Interval:=FlyTime;
   Enabled:=False;
   OnTimer:=GravityTimerTime;
  end;
 //������ ��������� ��������� ���������
 ElementsL2:=Elements;
 //��������� �� X - ����� ������ �������� (���� � ������ (���������) �������� ������� �� �����)
 Left:=Owner.SWidth;
 //Up:=True;
 //������ �������� �������� ���������
 for i:=1 to GlCols do
  begin
   with ElementsL1[i] do
    begin
     //������
     Y:=ATop;
     //��������� ����� (������� �� ���������� �������� + ��������)
     X:=((i - 1) * Owner.SWidth) + Left;
     //��������� ���� ����������
     Angle:=Random(360);
     //��������� �������� ��������
     Speed:=Random(5) + 5;
    end;
  end;
 //�������� "����������"
 GravityTimer.Enabled:=True;
end;

///////////////////////////////////TTextPanel///////////////////////////////////

procedure TTextPanel.Show;
var s, t:Integer;
begin
 //���� ��� ���� - �������
 if Owner.GameState = gsPlay then Exit;
 //���� ��� ����� - �������
 if Visible then Exit;
 //������ ������� ������ � ������ ���������� � ����������
 //���� ��������
 FWS:=True;
 //�������� ������
 t:=Top;
 //������� ������ ���, ����� ������ �������� ������
 Top:=0 - (Owner.SHeight + Height);
 //�������� ���������� (�������� ��������)
 Visible:=True;
 //�������� ������� - 0
 s:=0;
 //���� ������ ������ ���, ��� �����
 while Top < Owner.SHeight do
  begin
   //����������� ��������
   Inc(s);
   //�������� ������ �� ������� �������� ��������
   Top:=Top + s;
   //�������������� ���������
   Owner.WaitWithoutStop(2);
  end;
 //��������� ��������� (���� ������ ��������)
 Top:=t;
end;

procedure TTextPanel.Hide;
var s:Integer;
begin
 //���� ��� ������ - �������
 if not Visible then Exit;
 s:=0;
 //������� ����������� ������ � ������ ���������� � ����������
 while (Top + Height) > 0 do
  begin
   Inc(s);
   Top:=Top - s;
   Owner.WaitWithoutStop(2);
  end;
 //��������� ��������� - ����
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
   //������ �������
   Draw(Self.ClipRect.Left, Self.ClipRect.Top, Graphic);
   Font.Assign(Self.Font);
   //� �����
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

procedure TTextHint.Show(ACaption, FF:string; AText:TStrings; ATime, BTime:Cardinal); //����� ��������� ������
begin
 Timer.Enabled:=False;
 HintList.Clear;
 Visible:=False;
 //��������������� ����� �� ���. � ����.
 ShowingTime:=ATime * 1000;
 HintList.AddStrings(AText);
 ShowFooter:=FF <> '';
 FooterText:=FF;
 Caption:=ACaption;
 //���� ����� �������
 if BTime > 0 then Timer.Interval:=BTime
 else //���� ����� ������ ��������
  begin
   //���������� �����
   Visible:=True;
   //��������� ������ �� �������
   Timer.Enabled:=False;
   Timer.Interval:=ShowingTime;
  end;
 //��������� ������ �� �����������
 Timer.Enabled:=True;
end;

procedure TTextHint.Show(ACaption, FF, AText:string; ATime, BTime:Cardinal);
var i, l:Word;
 TMP:TStrings;
begin
 TMP:=TStringList.Create;
 TMP.Clear;
 //��������� ����� �� ������ (����������� "|")
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
     //������ ���. ����������� ����� ������ "���������" �� ������� ����������� �����������
     Draw(Position.X + 65, Position.Y - 15, GCost);
     //��������� ��������� ������ ��� ����� -40 ��������
     TextOutAdv(Owner.Canvas, -40, ((Position.X + 105) + (30 - TextWidth(FooterText)) div 2) + 6, ((Position.Y - 5) + (30 - TextWidth(FooterText)) div 2) + 3, FooterText);
    end;
   //������ ���. ����. ������ ���������
   Draw(Position.X, Position.Y, Graphic);
   //����� � ������ ���������
   Font.Style:=[fsBold];
   TextOut(Position.X + (128 div 2) - (TextWidth(Caption) div 2), Position.Y + 10, Caption);
   Font.Style:=[];
   //������ ������ ����������� � ������ ������������� ������� �����������
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
   //��������� ������� ���������
   StretchDraw(Rect(RectObj.Left + Position.X, RectObj.Top + Position.Y ,RectObj.Right + Position.X, RectObj.Bottom + Position.Y), Graphic);
   //��������� ���������
   TextOut(Position.X + 5, Position.Y + 5, Caption);
   //��������� ������
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
 //"���� - �����������" ��������� ��������� ������������ �������������
end;

procedure TBonus.Paint;
begin
 //���� ����� ������ ��� ���� - �������
 if BonusType = btForGame then Exit;
 //��������� ��������� ������
 with Owner.Canvas do
  begin
   //������ ������
   StretchDraw(RectObject, FIcon);
   //���� ��� ����� - �� ������ ����� ������ ��������� �� ���������
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
 //������������� ������������� ������� ������������ �������� ������ �������
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
 //������������� ������ ������� +1
 SetLength(FGraphics, Length(FGraphics) + 1);
 //��������� ����� ���������� ��������
 Result:=Length(FGraphics) - 1;
 //��������� � ������ ������
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
 //������� ����� ��������� ������
 FOwner.CreateNextFigure;
end;

///////////////////////////////////TKick////////////////////////////////////////

procedure TKick.Action;
var i, R, C:Byte;
    Done:Boolean;

//��������� ������� �� �������
function CheckCol(ACol:Byte):Byte;
var AR:Byte;
    CR:Boolean; {False - �����, True - ������}
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

//�������� ������� ����� ������� ACol ���� �� WTop
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
   //���������� ���������� ������ (�������)
   ForcedCoord.X:=SWidth;
   ForcedCoord.Y:=SHeight;
   //������������� ���������� �������� ����
   ForcedCoordinates:=True;
   //��������� �������� - 0
   i:=0;
   //���� ������������ ����� ���� �� �������� ������ �� 200 ���. (�������� ����)
   while ForcedCoord.Y > - 400 do
    begin
     //���� ���� �������� - �������
     if Owner.CheckPause then Exit;
     //����������� �������� ��������
     Inc(i);
     //��������� ����
     Dec(ForcedCoord.Y, i);
     //���� � ������������
     Wait(25);
    end;
   //��������� �������� - 2
   i:=2;
   //���� ���� �� "������� �� �����"
   while ForcedCoord.Y < SHeight do
    begin
     //���� ���� �������� - �������
     if Owner.CheckPause then Exit;
     //����������� �������� ������� �� 2
     Inc(i, 2);
     //�������� ���� �� ��������� i
     Inc(ForcedCoord.Y, i);
     //���� � ������������
     Wait(5);
    end;
   //����������� ���������� (������ �� ��������� �� ��������� ����)
   ForcedCoordinates:=False;
   //��� (������� �����)
   Boom(5, 60);
   //���� �� �������� �������� ���� (����� �����, ����� ������������� �� ��������, ����� ������������� ������ =))
   for C:=1 to Cols do
    begin
     //��������� ������� �� ���������
     Done:=False;
     //���� ��������� ������� �� ����������
     repeat
      //������ ������ �� ������� ���� �������
      R:=CheckCol(C);
      //���� ������ ������ 0, ��
      if R > 0 then
       begin
        //��������� ����� �� ���� ������
        MoveCol(R, C);
        //���
        Boom(2, 50);
       end //���� �� ������ = 0, �� ��������� ���������
      else Done:=True;
     until Done;
    end;
   //������������� ���� �����
   //Sound.Stop(Sounds[0]);
  end;
end;

///////////////////////////////////TScan////////////////////////////////////////

procedure TScan.Action;
var Line:array of Boolean;
    i, R, C, ElAm:Byte;
    Elem:TFiguresL2;
begin
 //���-�� ��������
 SetLength(Line, Owner.Cols);
 //���������� ��� ��������
 for i:=0 to Length(Line) - 1 do Line[i]:=True;
 //X - ����������
 GX:=Owner.SWidth;
 //��, �������� �������������
 Drawing:=True;
 Owner.IsWait:=True;
 //��������� �������� �����
 Owner.Sound.PlaySound_2(Sounds[0]);
 //���� �� ����
 for R:=GlHdRw to Owner.Rows do
  begin
   //���� ���� �������� - �������
   if Owner.CheckPause then Exit;
   //���� ��������� ������ - �������
   if R = Owner.Rows then Drawing:=False;
   //���������� Y = (������ - GlHdRw) * ������ �������� ������
   GY:=((R - GlHdRw) * Owner.SHeight);
   //���-�� ��������� ��� �������� - 0
   ElAm:=0;
   //�������� ������
   for C:=1 to Owner.Cols do
    begin
     //���� ������� �� ���� � ��� �� ������������� ������� ������� "������"
     if (Owner.MainTet[R, C].State <> bsEmpty) and Line[C - 1] then
      begin
       //����������� ���-�� ��������� ��� ��������
       Inc(ElAm);
       //��������� ������� � ��������
       Elem[C]:=Owner.MainTet[R, C];
       //�� ������������ ������� �������
       Line[C - 1]:=False;
      end //� ��������� ������ ������� ��� �������� - ����
     else Elem[C].State:=bsEmpty;
     //����������� ���������� Y �� ����� ������ �������� ������ (��� ��������� ���� �������� ������)
     Inc(GY, Owner.SHeight div Owner.Cols);
     //���� 1 ����.
     Owner.Wait(2);
    end;
   if ElAm > 0 then
    begin
     for C:=1 to Owner.Cols do
      if Elem[C].State <> bsEmpty then
       begin
        //������� �������
        Owner.MainTet[R, C].State:=bsEmpty;
        //������������� ���� �������� ��������
        Owner.Sound.PlaySound(Sounds[1]);
       end;
     Owner.AnimateDelete(R, Elem);
    end;
  end;
 //������������� ���� �����
 Owner.Sound.Stop(Sounds[0]);
 //���, �� ������ �������������
 Drawing:=False;
end;

procedure TScan.PaintGraphics;
begin
 if not Drawing then Exit;
 //������ ����� "������" � GX;GY
 with Owner.Canvas do Draw(Owner.SLeft, GY, Graphics[0]);
end;

///////////////////////////////////TEditFigure////////////////////////////////////////

procedure TEditFigure.Action;
begin
 //�������� ����� �������������� ����. ������
 Owner.DrawingFigure;
end;

///////////////////////////////////TBoss////////////////////////////////////////

procedure TBoss.Action;
begin
 //��������� ������ - ���� �������� ������
 Owner.CreateNextBoss;
end;

///////////////////////////////////TRestart/////////////////////////////////////

procedure TRestart.Action;
begin
 with Owner do
  begin
   //������� ������ � �����
   Merger;
   //������� ���� � �������� "������� ���������"
   ClearAll;
   //����. ������ ���
   FigureEnable:=False;
   //���: ������ ����. ������ � ������� �������
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
   //������� ������ ������ � �����
   Merger;
   //������� ����� ���� - GlHdRw
   Top:=GlHdRw;
   //��������� ���� �� ��������
   Inc(FWaitAmount);
   WaitWithoutStop(2);
   //��������� ����. �����
   Sound.PlaySound(Sounds[0]);
   //������ ��������
   repeat
    //���� ���� �������� - �������
    if Owner.CheckPause then Exit;
    //�������� ���������� ��������� ��������
    repeat
     R:=Random(Rows - Top + 1) + Top;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State = bsEmpty;
    Elems:=0;
    //��������� �������
    Used:=[];
    //�������� ID �������� ��������
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
    //��������� �������
    Patched.ID:=Elems;
    MainTet[R, C]:=Patched;
    if Random(3) in [2, 1] then Continue;
    //���� 1 ����.
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
   //���-�� ��������� ����������
   Shoots:=Random(20) + 1;
   //������� ��������� - 0
   DoShoots:=0;
   //������ ������� ������
   Top:=GetTop;
   if GlRows - Top > 5 then Top:=GlVbRw div 2;
   //////
   //������� ������ ��������� ������
   for i:=1 to Cols do
    begin
     Elem[i].ID:=Random(13) + 1;
     Elem[i].State:=bsElement;
    end;
   //��������� ������ � ���������� Y  *** GlSize <> 4
   ATop:=(((Top + 1) - GlSize) * SHeight) + SHeight;
   //���� ��������� ����� ��� ���������� ����� �������� ��������
   for i:=1 to Rows do
    if not Assigned(ArrayOfClears[i]) then
     begin
      ArrayOfClears[i]:=TLineClear.Create(i, Owner, Elem, ATop);
      Break;
     end;
     ////
   //������ ���-�� ������ ��������� �� ����
   Elems:=0;
   for R:=Rows downto Top do
    for C:=1 to Cols do if MainTet[R, C].State = bsEmpty then Inc(Elems);
   //���� ��������� ��� (����� �� ��������), �� �������
   if Elems = 0 then Exit;
   //���� ���-�� ��������� �� ���� ������ ��� ���������, �� ������ ������������� ���-�� ��������� ������ �� ���-�� ���������
   if Elems < Shoots then Shoots:=Random(Elems) + 1;
   //��������� ����. �����
   Sound.PlaySound(Sounds[0]);
   //������ ��������
   repeat
    //���� ���� �������� - �������
    if Owner.CheckPause then Exit;
    //�������� ���������� �� ������� ��������
    repeat
     R:=Random(Rows - Top + 1) + Top;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State = bsEmpty;
    Elems:=0;
    //��������� �������
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
    //����������� ���-�� ��������� ���������
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
   //���-�� ���������
   Shoots:=Random(10)+1;
   //������� ��������� - 0
   DoneShoots:=0;
   //���-�� ��������� � ������ - 0
   Elems:=0;
   //������ ���-�� ��������� �� ����
   for R:=1 to Rows do
    for C:=1 to Cols do if MainTet[R, C].State <> bsEmpty then Inc(Elems);
   //���� ��������� ���, �� �������
   if Elems = 0 then Exit;
   //���� ���-�� ��������� �� ���� ������ ��� ���������, �� ������ ������������� ���-�� ��������� ������ �� ���-�� ���������
   if Elems < Shoots then Shoots:=Random(Elems)+1;
   //��������� ����. �����
   Sound.PlaySound(Sounds[0]);
   //������ ��������
   repeat
    //���� ���� �������� - �������
    if Owner.CheckPause then Exit;
    //�������� ���������� �� ������� ��������
    repeat
     R:=Random(Rows)+1;
     C:=Random(Cols)+1;
    until MainTet[R, C].State <> bsEmpty;
    //������� �������
    MainTet[R, C].State:=bsEmpty;
    //����������� ���-�� ���������
    Inc(DoneShoots);
   until Shoots <= DoneShoots;
  end;
end;

////////////////////////////////////TPatch//////////////////////////////////////

procedure TPatch.Action;
var R, C:Byte;

//�������� ���������� �� ����������� (������ 0, ������ ������)
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
   //��������� ����. �����
   Sound.PlaySound(Sounds[0]);
   //���� �� ����
   for R:=GlHdRw to Rows do
    begin
     for C:=1 to Cols do
      begin
       //���� ���� �������� - �������
       if Owner.CheckPause then Exit;
       //���� ������� ����
       if MainTet[R, C].State = bsEmpty then
        begin
         //��������� ���������� ������ �������
         if CheckField(R - 1, C) and
            CheckField(R, C - 1) and
            CheckField(R + 1, C) and
            CheckField(R, C + 1)
         then
          begin
           //���� ����� �����, �� �������� ��������� ��������� ������� ��� �������
           case Random(4) of
            0: if C + 1 <= Cols then Patched.ID:=MainTet[R, C + 1].ID else Patched.ID:=MainTet[R, C - 1].ID;
            1: if C - 1 > 0     then Patched.ID:=MainTet[R, C - 1].ID else Patched.ID:=MainTet[R, C + 1].ID;
            2: if R + 1 <= Rows then Patched.ID:=MainTet[R + 1, C].ID else Patched.ID:=MainTet[R - 1, C].ID;
            3: if R - 1 > 0     then Patched.ID:=MainTet[R - 1, C].ID else Patched.ID:=MainTet[R + 1, C].ID;
           else
            if R + 1 <= Rows then Patched.ID:=MainTet[R + 1, C].ID else Patched.ID:=MainTet[R - 1, C].ID;
           end;
           //��������� � ������ �����
           MainTet[R, C]:=Patched;
           //���� 50 ����
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
   //������������� ������
   R:=GetTop;
   //������������� ����
   Sound.PlaySound(Sounds[0]);
   //������� ��������
   for C:=1 to Cols do
    begin
     //���� ���� �������� - �������
     if Owner.CheckPause then Exit;
     //���� ������� �� ���� - "�������"
     if MainTet[R, C].State <> bsEmpty then
      begin
       MainTet[R, C].State:=bsEmpty;
       //������� 50 ����
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
    //�������� ������, ������� ��� �� ������
    repeat
     FigureID:=Random(Length(ArrayOfFigure));
    until not (FigureID in UsedF);
    //���� ���, �� � ��� �����
    Include(UsedF, FigureID);
    //while Random(5) <> 3 do Result:=RotateFigure(Result);
    //������ ������ � ������ ������
    WF:=WidthOfFigure(ArrayOfFigure[FigureID]);
    HF:=HeightOfFigure(ArrayOfFigure[FigureID]);
    Counter:=0;
    //�������� ��������� �������
    case Random(2) of
     //�����
     0:
      begin
       FLeft:=1;
       //���� �� ������ �������
       while not FoundPos do
        begin
         //������� ���� ��� �������
         ClrChng(CheckSFigure);
         //���� ��������� ������
         FTop:=Random(Rows - GlFVRw) + GlFVRw;
         //����������� ����������� �������
         Inc(Counter);
         //���� ������� ����� �� ������ - ��������� ����� �������
         if Counter >= 200 then Break;
         //��������� ������� ����� ������
         for R:=0 to HF - 1 do
          CheckSFigure[FTop + R, FLeft]:=ArrayOfFigure[FigureID].Elements[R + 1, WF];
         //��������� �� ������������ � ������� �����, ���� ����, �� �������� ���������� ������� � ��������� �������
         if CheckCollision(CheckSFigure, FTop, FLeft, False) then Continue;
         //������� �������
         FoundPos:=True;
        end;
       //���� ������� �� ������� - ��������� ����� ������� � ������
       if not FoundPos then Continue;

       //������ ���� ��������� ������
       DoDrawing:=True;
       //��������� ����� ������ � ����������� �� ������� ���������
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
         //���� ������ ������ "��� ����������"
         Wait(DelayTime);
        end;
      end;
     //������ (����������� ���������� ����� �������)
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
    //������� ��������� ���� � �������
    for R:=FTop to FTop + HF do
     for C:=FLeft to FLeft + WF do
      begin
       if (R <= 0) or (R > Rows) or (C <= 0) or (C > Cols) then Continue;
       if SallyFigure[R, C].State <> bsEmpty then MainTet[R, C]:=SallyFigure[R, C];
      end;
    //������ ���� � ����������� ��������� ������
    DoDrawing:=False;
    //�������
    Exit;
   until UsedF = FF;
  end;
end;

procedure TSally.PaintGraphics;
var R, C:Byte;
begin
 if not DoDrawing then Exit;
 //������ ���� � �������
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
   //���-�� ���������
   Shoots:=Random(10) + 1;
   //������� ��������� - 0
   DoneShoots:=0;
   //���-�� ��������� � ������ - 0
   Elems:=0;
   //������ ���-�� ��������� �� ����
   for R:=1 to Rows do
    for C:=1 to Cols do if MainTet[R, C].State <> bsEmpty then Inc(Elems);
   //���� ��������� ���, �� �������
   if Elems = 0 then Exit;
   //���� ���-�� ��������� �� ���� ������ ��� ���������, �� ������ ������������� ���-�� ��������� ������ �� ���-�� ���������
   if Elems < Shoots then Shoots:=Random(Elems)+1;
   //��������� ����. �����
   //Sound.PlaySound(Sounds[0]);
   //������ ��������
   repeat
    //���� ���� �������� - �������
    if Owner.CheckPause then Exit;
    //�������� ���������� �� ������� ��������
    repeat
     R:=Random(Rows) + 1;
     C:=Random(Cols) + 1;
    until MainTet[R, C].State <> bsEmpty;
    //������� �������
    MainTet[R, C].State:=bsBonusTiming;
    MainTet[R, C].TimeLeft:=Random(30) + 30;
    //����������� ���-�� ���������
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
 //�������� ����� "������"
 Owner.MarshMode:=True;
end;

procedure TMarsh.Deactivate;
begin
 inherited;
 //��������� ����� "������"
 Owner.MarshMode:=False;
end;

//////////////////////////////TUseAllExcept/////////////////////////////////////

procedure TUseAllExcept.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //��������� ������������ ��� ��������� ������
 if (Owner.NextID > 0) and (Owner.NextID < Length(Owner.ArrayOfFigure))
 then Owner.UseAllExcept(Owner.NextID)
 else Owner.UseAllExcept(Random(Length(Owner.ArrayOfFigure)));
end;

procedure TUseAllExcept.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //��������� ������������ ��� ������
 Owner.UseAllFigures;
end;

////////////////////////////////TUseOnly////////////////////////////////////////

procedure TUseOnly.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //��������� ������������ ��� ���� ����� ����� ����������
 if (Owner.NextID > 0) and (Owner.NextID < Length(Owner.ArrayOfFigure))
 then Owner.UseOnly(Owner.NextID)
 else Owner.UseOnly(Random(Length(Owner.ArrayOfFigure)));
end;

procedure TUseOnly.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //��������� ������������ ��� ������
 Owner.UseAllFigures;
end;

/////////////////////////////////TVersa////////////////////////////////////////

procedure TVersa.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //�������� ����� ����������
 Owner.Versa:=True;
end;

procedure TVersa.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //��������� ����� ����������
 Owner.Versa:=False;
end;

/////////////////////////////////THelper////////////////////////////////////////

procedure THelper.Activate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[0]);
 //�������� ����
 Owner.Helper:=True;
end;

procedure THelper.Deactivate;
begin
 inherited;
 Owner.Sound.PlaySound(Sounds[1]);
 //��������� ����
 Owner.Helper:=False;
end;

//////////////////////////////////TSimpleBonus//////////////////////////////////

procedure TSimpleBonus.Execute;
begin
 //���� ����� ���������� - �������
 if Executing then Exit;
 //����� �����������
 Executing:=True;
 //����� �� ��������
 Enabled:=False;
 //���� 100 ����.
 Owner.Wait(100);
 //��������� ��������
 Action;
 //���� 100 ����.
 Owner.Wait(100);
 //����� �� �����������
 Executing:=False;
 //����� ��������
 Enabled:=True;
end;

constructor TSimpleBonus.Create;
begin
 inherited;
 //����� �� �����������
 Executing:=False;
end;

procedure TSimpleBonus.Paint;
begin
 //���� ����� ������ ��� ���� - �������
 if BonusType = btForGame then Exit;
 //������ ����� ������
 inherited;
 //������ ���� ������
 with Owner.Canvas do
  begin
   //���� ����� ����������� - ������ ������ "�����"
   if Executing then StretchDraw(RectObject, Owner.Bitmaps.BonusExeing);
  end;
end;

//////////////////////////////////TTimeBonus////////////////////////////////////

constructor TTimeBonus.Create;
begin
 inherited;
 //������ - ��������� �������
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
 //���� ����� ������ ��� ���� - �������
 if BonusType = btForGame then Exit;
 //������ ����� ������
 inherited;
 //������ ���� ������
 with Owner.Canvas do
  begin
   //���� �����������
   if Activated then
    begin
     //������ ������ - "�����" � �����
     StretchDraw(RectObject, Owner.Bitmaps.BonusBusy);
     Font.Assign(Owner.FontTextBonuses);
     TextOut(RectObject.Left + ((Owner.SWidth div 2) - (TextWidth(IntToStr(LastTime)) div 2)), RectObject.Top + 5, IntToStr(LastTime));
    end;
  end;
end;

procedure TTimeBonus.Activate;
begin
 //���������� ����� - ����� ��������
 FLastTime:=FTime;
 //����� �����������
 FActive:=True;
 //��������� ������
 Timer.Enabled:=True;
end;

procedure TTimeBonus.Deactivate;
begin
 //����� �� �����������
 FActive:=False;
 //��������� ������
 Timer.Enabled:=False;
end;

procedure TTimeBonus.TimerTime(Sender:TObject);
begin
 //���� ����� �������
 if FLastTime <= 0 then
  begin
   //������������ ����� � �������
   Deactivate;
   Exit;
  end;
 //���� ���� ����� �������� ��� ������ �� ����
 if (Owner.IsWait) or (Owner.GameState <> gsPlay) then Exit;
 //��������� �����
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
 //���� "����" ��������� - �������
 if not Owner.Helper then Exit;
 //����������� ���������� - �������
 if not Ready then Exit;
 //���� ���� ����������� - �������
 if Owner.GameState <> gsPlay then Exit;
 //���� ���� �������� ������ - �������
 if Owner.IsCreating then Exit;
 //���� ��� ������ - �������
 if not Owner.FigureEnable then Exit;
 //��������� - "�� �����"
 Ready:=False;
 //����������� ���� - ������
 ShadeArray:=Owner.MoveTet;
 //������� ������
 ATop:=Owner.TopPos;
 //���� ����� �������� - �������� "����" ����
 repeat
  //������� ����
  for R:=Owner.Rows downto 2 do for C:=1 to Owner.Cols do ShadeArray[R, C]:=ShadeArray[R-1, C];
  for C:=1 to Owner.Cols do ShadeArray[1, C].State:=bsEmpty;
  //����������� ������
  Inc(ATop);
 until Owner.CheckCollision(ShadeArray, ATop, True);
 //��������� - �����
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
 //"��������" ���� �� �������� ����
 while (GameState <> gsPlay) do
  begin
   //���� ��������� ����������� - ��������� ����
   if Shutdowning then Break;
   //�������� ����� ������ ������������
   Application.ProcessMessages;
  end;
 //��������� - ���� �� ���������� ���������
 Result:=Shutdowning;
end;

procedure TTetrisGame.DrawingFigureClose(State:TGameState);
var C:Byte;
begin
 //���� ��������� ��������� - �� ������
 if DoDrawFigure = dtNotWork then
  begin
   //��������� ���� - ���������� ���������
   GameState:=State;
   //�������
   Exit;
  end;
 //�� ���. �������� - 1
 IDDrawFigure:=1;
 //��������� ����� - 0 (�.�. ��������� ���������)
 Bitmaps.FLeft:=0;
 //�������� �����������
 C:=0;
 //���� �� ��������� ����������� �����
 while Bitmaps.FLeft > (-FieldWidth) do
  begin
   //����������� �������� �����������
   Inc(C);
   //������� ���� �� �������� �������� � ����������� �����
   Dec(Bitmaps.FLeft, C);
   //���� 10 ����.
   Wait(10);
  end;
 //��������� ����� �� �����
 Bitmaps.FLeft:=-FieldWidth;
 //��������� ���� - ���������� ���������
 GameState:=State;
 //��������� ��������� - �� ������
 DoDrawFigure:=dtNotWork;
end;

procedure TTetrisGame.DrawingFigureEnd;
begin
 //���� "������ �� �����"
 Sound.Play(4);
 //���� ���-�� ��������� � ������ ������ 0
 if WidthOfFigure(NextFigure) <= 0 then
  begin
   NextFigure:=NextFigureOld;
   //���������� ���������
  end;
 //����������� ������
 Normalization(NextFigure);
 //��������� ��������������
 DrawingFigureClose(State);
 //��������� ��������
 IsWait:=False;
end;

procedure TTetrisGame.DrawingFigure;
var R, C:Byte;
    ID:Byte;
begin
 //�� �������� ��� ��������� - 0 (�� ���������)
 ID:=0;
 //�� �������� ��������� - 1 (����)
 IDDrawFigure:=1;
 //��������� ����. ������
 NextFigureOld:=NextFigure;
 //���� �� ������� ��������� ����. ������
 for R:=1 to GlSize do
  begin
   for C:=1 to GlSize do
    begin
     //���� ��������� �������
     if NextFigure.Elements[R, C].State <> bsEmpty then
      begin
       //������ ��������� ��
       ID:=NextFigure.Elements[R, C].ID;
       //��������� ����
       Break;
      end;
    end;
   //���� ����� �� - ��������� ����
   if ID > 0 then Break;
  end;
 //���� ����� �� ������������� � �������� �� �������� ���������
 if ID > 0 then IDDrawFigure:=ID;
 //������� ����� - �� �����
 Bitmaps.FLeft:= -FieldWidth;
 //�������� - 0
 C:=0;
 //��������� ��������� - �������
 DoDrawFigure:=dtNone;
 //������� � ���, ��� ����� ��������� ������
 NeedShot:=True;
 //���� ����� �� ��������� ����������� �������
 while Bitmaps.FLeft < 0 do
  begin
   //����������� ��������
   Inc(C);
   //������� ��������� � ����������� �����
   Inc(Bitmaps.FLeft, C);
   //���� 10 ����.
   Wait(10);
  end;
 //��������� ����� - ���������
 Bitmaps.FLeft:=0;
 //��������� ���� - ������ ����. ������
 GameState:=gsDrawFigure;
 //������������� ��� �������
 TimerDownStop;
 //
 Timers:=False;
 //���� ��������
 IsWait:=True;
 //
 ShowButtons;
end;

procedure TTetrisGame.DrawBonuses;
var i:Word;
begin
 //���� ��� ������� - �������
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //���� ������� ������ ������������
 for i:= 0 to Length(ArrayOfBonuses) - 1 do ArrayOfBonuses[i].Paint;
end;

function TTetrisGame.CalcBrokenBonus:Word;
var R, C:Byte;
begin
 Result:=0;
 //������� ����������� ������
 for R:=GlFVRw to FRows do
  for C:=1 to FCols do
   begin
    if MainTet[R, C].State = bsBonusBroken then Inc(Result);
   end;
end;

function TTetrisGame.BuyAndExcecute;
begin
 Result:=0;
 //���� ����������� ����-�� �����, ���� ��������, ���� �������� ������ ��� ������ ���
 if ExecutingBonus or IsWait or IsCreating or (not FigureEnable) then
  begin
   //���������� ��������� �����
   Hint.Show('�������', '', '| ����� |�� ����������', 3, 0);
   //�������
   Exit;
  end;
 //���� ����� �� ��������
 if (not ABonus.Enabled) then
  begin
   //����� �� ��������
   Hint.Show('', '', '�����|�� ��������', 3, 0);
   //�������
   Exit;
  end;
 if not ABonus.Levels[GetLevel] then
  begin
   //������� �� ���������
   Hint.Show('', '', '�� �� ������|������������|�� ����|������', 3, 0);
   //�������
   Exit;
  end;
 //���� ������� �����
 if ABonus is TSimpleBonus then
  //���� ����� �����������
  if (ABonus as TSimpleBonus).Executing then
   begin
    //����� ��� �����������
    //�������
    Exit;
   end;
 //���� �� ������� ������
 if ABonus.Cost > ToGold then
  begin
   Hint.Show('', '', '�� �������|������', 3, 0);
   //���� ������
   Sound.Play(16);
   //�������
   Exit;
  end;
 //��������� ������ � ����������
 DecGold(ABonus.Cost);
 //��������� - ����������� ������
 Result:=ABonus.Cost;
 //��������� �����
 ExecuteBonus(ABonus);
end;

procedure TTetrisGame.DecGold(Cost:Word);
begin
 //�������� ������
 Dec(ToGold, Cost);
 //��������� ����� ������ ������
 ShowGoldDec(Cost);
 //���� "������ �����"
end;

procedure TTetrisGame.DeactivateAllBonuses;
var i:Word;
begin
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //������������ ��� ��������� ������
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
 //���� ��� ������� - �������
 if Length(ArrayOfBonuses) <= 0 then Exit;
 //�������� ��������� �����, ������� ����� ������������, ������� �������� �� ������� ������ � ������������� ���������� ����
 repeat ID:=Random(Length(ArrayOfBonuses))
 until (ArrayOfBonuses[ID].BonusType in [btForAll, btForGame]) and
        ArrayOfBonuses[ID].Levels[GetLevel] and
        Approach(ArrayOfBonuses[ID].Positive);
 //��������� ����� � ������ ��� ����������
 AddToActionList(ArrayOfBonuses[ID]);
end;

procedure TTetrisGame.ExecuteBonus(Bonus:TBonus);
begin
 Event(eventTutorial, Bonus.BID + eventBonus, 0);
 //���� ������� �����
 if Bonus is TSimpleBonus then
  begin
   //���� ����������� �����-�� �����, ���� ��������, ��������� ������ ��� ������ ��� - ������
   if ExecutingBonus or IsWait or IsCreating or (not FigureEnable) then Exit
   else //���� �� ���
    begin
     //��������� �������� ����� ���������� ������
     OnBonusStartExecute(Bonus);
     //��������� �������� ������
     (Bonus as TSimpleBonus).Execute;
     //��������� �������� ����� ���������� ������
     OnBonusExecuted(Bonus);
    end;
   //�������
   Exit;
  end;
 //���� ��������� �����
 if Bonus is TTimeBonus then
  begin
   //���� ����� ����������� - ������������, � ��������� ������ ����������
   if (Bonus as TTimeBonus).Activated then (Bonus as TTimeBonus).Deactivate
   else (Bonus as TTimeBonus).Activate;
   //��������� � ������ �������������� �������
   AddToExed(Bonus);
   //�������
   Exit;
  end;
end;

procedure TTetrisGame.AddToExed(Bonus:TBonus);
var Exe:TExing;
    i:Byte;
begin
 //������ �� �����
 Exe.Bonus:=Bonus;
 //������� ���� � �����
 Exe.Active:=True;
 //�������� �������� ������
 for i:=GlExes downto 2 do ArrayOfExing[i]:=ArrayOfExing[i - 1];
 //������� ���. �����
 ArrayOfExing[1]:=Exe;
end;

procedure TTetrisGame.AddToActionList(Bonus:TBonus);
var i:Word;
begin
 //���� ���� �������� � �������
 if Length(ArrayOfToDo) > 0 then
  begin
   //���� ������ �� ������� ������
   for i:=0 to Length(ArrayOfToDo) - 1 do
    //���� ������ �� ������
    if not Assigned(ArrayOfToDo[i]) then
     begin
      //��������� �����
      ArrayOfToDo[i]:=Bonus;
      //�������
      Exit;
     end;
  end;
 //���� ������ ����, ��� ��� ��������� �����
 //����������� ������
 SetLength(ArrayOfToDo, Length(ArrayOfToDo) + 1);
 //���������� �����
 ArrayOfToDo[Length(ArrayOfToDo) - 1]:=Bonus;
end;

procedure TTetrisGame.OnBonusExecuted;
begin
 //��������� �������� �� �������� ����������� �����
 ExecutingDelete;
 //������� ����
 Shade.Update;
 //������ �����
 IsWait:=False;
 //��������� ������ ���� ������
 TimerDownStart;
 //��������� ��������� �������
 Timers:=True;
 //����� �� �����������
 ExecutingBonus:=False;
end;

procedure TTetrisGame.OnBonusStartExecute;
begin
 //��������� � ������ ��� ������ �����
 AddToExed(Bonus);
 //����
 Sound.Play(13);
 //����������� �����
 ExecutingBonus:=True;
 //��������
 IsWait:=True;
 //���������� ������ ���� ������
 TimerDownStop;
 //������������� �������
 Timers:=False;
end;

procedure TTetrisGame.ShowGoldDec(Size:Word);
begin
 if Size = 0 then Exit;
 //�������� ������ �������� ������
 //TODO
end;

procedure TTetrisGame.CreateGraphicsAndSound;
begin
 //������� �����
 DrawBMP:=TBitmap.Create;
 //������������� ������� ������
 DrawBMP.Width:=FieldWidth;
 DrawBMP.Height:=FieldHeight;
 ///������ �������� 24 ���� (��� ���������� ������)
 DrawBMP.PixelFormat:=pf24bit;
 FCanvas:=DrawBMP.Canvas;
 //������� ����� �������
 State(17);
 Bitmaps:=TBitmaps.Create(ProgramPath+'Data\', Self);
 //������� ����� �����
 State(18);
 Sound:=TSound.Create(Self);
 //������� ���� ���� - ��������
 Shade:=TShade.Create(Self);
end;

procedure TTetrisGame.CreateButtons;
begin
 //��������� ������ "�����"
 AddButton(TExtButton.Create(Self, 'MaskButtonStart', '������', 326, 321, FontTextButtons, PauseGame));
 //��������� ������ "����"
 AddButton(TExtButton.Create(Self, 'MaskButtonStop',  '���������',  326, 357, FontTextButtons, StopGame ));
 //��������� ������ "�����"
 AddButton(TExtButton.Create(Self, 'MaskButtonQuit',  '�����', 326, 392, FontTextButtons, Shutdown ));
 //������ "����" �� �������
 ArrayOfButtons[1].Enable:=False;
 //��������� ��� ������ "�����"
 with ArrayOfButtons[2] do
  begin
   ShowHint:=True;
   HintList.Add('�� �������,');
   HintList.Add('��� ������');
   HintList.Add('�����?');
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
 //������� ������ ��������� ������
 for i:=1 to Cols do
  begin
   Elem[i]:=MainTet[ATop, i];
   if Elem[i].State <> bsEmpty then NoElem:=False;
  end;
 //���� �� ���� ������ ��� ��������� - �������
 if NoElem then Exit;
 //��������� ������ � ���������� Y  *** GlSize <> 4
 ATop:=((ATop - GlSize) * SHeight) + SHeight;
 //���� ��������� ����� ��� ���������� ����� �������� ��������
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
 //��������� ������ � ���������� Y  *** GlSize <> 4
 ATop:=((ATop - GlSize) * SHeight) + SHeight;
 //���� ��������� ����� ��� ���������� ����� �������� ��������
 for i:=1 to Rows do
  if not Assigned(ArrayOfClears[i]) then
   begin
    ArrayOfClears[i]:=TLineClear.Create(i, Self, Elems, ATop);
    Exit;
   end;
end;

procedure TTetrisGame.ActuateTimers;
begin
 //������ �������
 TimerBonus.Enabled:=True;
 //������ ���������
 TimerUpValues.Enabled:=True;
 //������ ��������
 TimerAnimateFrames.Enabled:=True;
end;

procedure TTetrisGame.CreateTimers;
begin
 //������� ������� � ������������ �����������
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
 //������� ������ � ������������ �������
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
 //������� ����������� ������� ������� ����������
 FKeyIDDown:= AddKey(VK_DOWN,  '����',   KeyDown, 100, 20);    //������� ����/"S"
 FKeyIDUP:=   AddKey(VK_UP,    '�����',  KeyUp, 150, 50);      //������� �����/"W"
 FKeyIDLeft:= AddKey(VK_LEFT,  '�����',  KeyLeft, 150, 50);    //������� �����/"A"
 FKeyIDRight:=AddKey(VK_RIGHT, '������', KeyRight, 150, 50);   //������� ������/"D"
 FKeyIDRL:=AddKey(Ord('Q'), '������� ������ ������ ������� �������', KeyRotateLeft, 200, 50);
 FKeyIDRR:=AddKey(Ord('E'), '������� ������ �� ������� �������',     KeyRotateRight, 200, 50);
 //������ ���������� ������
 FGameKeyCount:=Length(GameKeys);
 //��������� �������������� ������
 GameKeys[FKeyIDDown].Contradiction:=FKeyIDUP;
 GameKeys[FKeyIDUP].Contradiction:=FKeyIDDown;
 GameKeys[FKeyIDLeft].Contradiction:=FKeyIDRight;
 GameKeys[FKeyIDRight].Contradiction:=FKeyIDLeft;
 GameKeys[FKeyIDRL].Contradiction:=FKeyIDRR;
 GameKeys[FKeyIDRR].Contradiction:=FKeyIDRL;
end;

procedure TTetrisGame.CreatePanels;

//�������� ����� ��� ����� ������
function AddField:Integer;
begin
 SetLength(ArrayOfPanels, Length(ArrayOfPanels)+1);
 Result:=Length(ArrayOfPanels) - 1;
 ArrayOfPanels[Result]:=TTextPanel.Create(Self);
end;

begin
 //������ � �������� �����������
 with ArrayOfPanels[AddField] do
  begin
   Left:=Self.SWidth;
   Top:=Self.SHeight;
   Width:=Self.SWidth * Self.Cols;
   Height:=Self.SHeight * (Self.Rows - GlFVRw) div 3; 
   Graphic:=Bitmaps.Panel;
   Font.Name:='DS Goose';
   Font.Size:=10;
   Strings.Add('������ ����������� �����������');
   Strings.Add('��������� ��������� ��� ��������');
   Strings.Add('������� ����� �� ����������');
   Strings.Add('����������. ������� �������');
   Strings.Add('FL Studio 9 �� �������� �������������');
   Strings.Add('� �� ����������������� ���������');
   Strings.Add('  ');
   Strings.Add('�����: �������� �������, 2013 ���');
   WasShown:=False;
  end;
end;

function TTetrisGame.Load:Boolean;
var Ini:TIniFile;
    TMP:string;
begin
 Result:=False;
 try
  //��������� ������ � �������
  State(1);
  AddFontResource(PChar(ProgramPath + 'Data\Fonts\SegoeUI.ttf'));
  AddFontResource(PChar(ProgramPath + 'Data\Fonts\DS Goose.ttf'));
  //������� ������� � ����� �������
  SendMessage(0, WM_FONTCHANGE, 0, 0);
  //������ � �����
  Mouse:=Point(FieldWidth div 2, FieldHeight div 2);
  //����� ��������
  State(2);
  Reset;
  //������������� ������ (������� ������������� ����� �����!)
  State(3);
  //�������� �������
  State(4);
  CreateFonts;
  //������������� ��������
  State(5);
  CreateTimers;
  //��������������� ������
  State(6);
  CreateButtons;
  CreateGameKeys;
  //������������� ������� � �����
  State(7);
  CreateGraphicsAndSound;
  //�������� �����
  State(8);
  CreateFigures;
  //��������� �������� �������������� �� ������
  State(9);
  CreateRectAreas;
  //������������� �������
  State(10);
  CreateBonuses;
  //�������� ��������� �������
  State(11);
  CreatePanels;
  //�������� ���������
  State(12);
  CreateHints;
  //������� ����
  State(13);
  ClearAll;
  //���� � ���������� �������������
  State(14);
  //��������� ��������
  State(15);
  ActuateTimers;
  //���. ����� - ���. �������
  State(19);
  InfoMode:=imInfoText;
  //�������� ����
  Statistics.Load;
  //��������� ��������� ���� (FPS, ������� �����, ���� � ��.)
  Ini:=TIniFile.Create(ProgramPath+'\Config.ini');
  UserFPS:=Ini.ReadInteger('Tetris', 'FPS', 40);
  DebugEnabled:=Ini.ReadBool('Tetris', 'Debug', False);
  ArrayOfPanels[0].WasShown:=Ini.ReadBool('Tetris', 'NotFirstRun', False);
  Ini.WriteBool('Tetris', 'NotFirstRun', True);
  TMP:=Ini.ReadString('Tetris', 'Password', '');
  LinesAmountForLevelUp:=Ini.ReadInteger('Tetris', 'LinesForLevel', 20);
  if LinesAmountForLevelUp < 20 then LinesAmountForLevelUp:=20;
  if Sound.Enable then Sound.Enable:=Ini.ReadBool('Tetris', 'Sound', True);
  //������� ������
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
  //�������� ����������� ����
  State(20);
  if FileExists(ProgramPath + SaveFN) then
   begin
    with ArrayOfButtons[1] do
     begin
      CanBeContinue:=True;
      Enable:=True;
      Text:='����������';
     end;
   end
  else CanBeContinue:=False;
  //��������� ���� - ������ ���������
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

//�������� ����� � ������ � ���������� ��������� ������ � ����� ����������� ������� � �������, �.�. ������� ����������
function AddField:Integer;
begin
 SetLength(ArrayOfBonuses, Length(ArrayOfBonuses) + 1);
 Result:=Length(ArrayOfBonuses) - 1;
 X:=((ID mod BonusAmountWidth) * SWidth);
 Y:=((ID div BonusAmountWidth) * SHeight);
end;

{
//////////////////////////////����� - ��������/////////////////////////////////�
 //��������� ������
 Index:=AddField;
 //������� ����� ����� ������
 ArrayOfBonuses[Index]:=T���.Create(Self);
 //
 with ArrayOfBonuses[Index] do
  begin
   //������������� ��������� ������ �� ������
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   //��������� ��������
   Name:='��������';
   //��������� ��������
   Desc:='����� �������� ������';
   //��������� ������ ���������
   HintList.Add('������ ������ ���������');
   HintList.Add('������ ������ ���������');
   //��������� ������ ������
   SetIcon(CreatePNG(DLL, 'shot'));
   //������������� ���������
   Cost:=0;
   //��������� ������, �� ������� ����� ������������ �����
   SetLevels($FFFF);
   //��������� �����
   AddSound(Sound.CreateStream(ProgramPath + 'Data\Sound\����.wav', True));
   //������������� ��� �������� ������
   Positive:=False;
   //������������� �����������
   Enabled:=True;
   //������������� ��� (���������) ������
   BonusType:=btForGame;
   //���� ����� �� ������ ��� ���� - ��������� � ������ 
   if BonusType <> btForGame then Inc(ID);
  end;
}

begin
 DLL:=LoadLibrary(PChar(ProgramPath+'Data\'+TetDll));
 //����� �� ������ - 0
 ID:=0;
//////////////////////////////����� - �����////////////////////////////////////1
 Index:=AddField;
 ArrayOfBonuses[Index]:=TShot.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�����';
   Desc:='������ ������� ������';
   HintList.Add('������� �������');
   HintList.Add('������');
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
//////////////////////////////����� - ���//////////////////////////////////////2
 Index:=AddField;
 ArrayOfBonuses[Index]:=TKnife.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='���';
   Desc:='������� ��������';
   HintList.Add('������� �����');
   HintList.Add('������� �����');
   HintList.Add('����');
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
//////////////////////////////����� - ��������/////////////////////////////////3
 Index:=AddField;
 ArrayOfBonuses[Index]:=THelper.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='��������';
   Desc:='���������� �������� ����� ������ (2 ���.)';
   HintList.Add('����������');
   HintList.Add('�������� �����');
   HintList.Add('������� ������');
   HintList.Add('� ���. 2 ���.');
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
//////////////////////////////����� - ��������/////////////////////////////////4
 Index:=AddField;
 ArrayOfBonuses[Index]:=TPatch.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='��������';
   Desc:='������ ��� ��������� "����"';
   HintList.Add('�������� ���');
   HintList.Add('��������� "����"');
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
//////////////////////////////����� - ��, ��///////////////////////////////////5
 Index:=AddField;
 ArrayOfBonuses[Index]:=TVersa.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='��, ��';
   Desc:='������ ������� ������ ����������';
   HintList.Add('������ �������');
   HintList.Add('������');
   HintList.Add('����������');
   HintList.Add('�� 1 ���.');
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
//////////////////////////////����� - ������-�����/////////////////////////////6
 Index:=AddField;
 ArrayOfBonuses[Index]:=TScan.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�����';
   Desc:='������� ������� �����';
   HintList.Add('������� �������');
   HintList.Add('���� �������');
   HintList.Add('�������');
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
//////////////////////////////����� - ����/////////////////////////////////////7
 Index:=AddField;
 ArrayOfBonuses[Index]:=TBoss.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='����';
   Desc:='������� ����� �������� ������';
   HintList.Add('������� �����');
   HintList.Add('�������� ������');
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
//////////////////////////////����� - ������� ������///////////////////////////8
 Index:=AddField;
 ArrayOfBonuses[Index]:=TChangeFigure.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='������';
   Desc:='������� ��������� ������';
   HintList.Add('�������');
   HintList.Add('���������');
   HintList.Add('������');
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
//////////////////////////////����� - ���� �� ��������� �����//////////////////9
 Index:=AddField;
 ArrayOfBonuses[Index]:=TKick.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='����-�����';
   Desc:='�������� �������� ���� � ������ �����';
   HintList.Add('��������');
   HintList.Add('�������� ����');
   HintList.Add('� ������ �����');
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
//////////////////////////����� - �������������� ������ ����./////////////////10
 Index:=AddField;
 ArrayOfBonuses[Index]:=TEditFigure.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='��������';
   Desc:='��������� ��������������� ����. ������';
   HintList.Add('���������');
   HintList.Add('���������������');
   HintList.Add('���������');
   HintList.Add('������');
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
///////////////////////��������� - ������������ �������� ����/////////////////11
 Index:=AddField;
 ArrayOfBonuses[Index]:=TScatter.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�����';
   Desc:='���������� �������� ����';
   HintList.Add('����������');
   HintList.Add('��������');
   HintList.Add('�� ����');
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
//////////////////////////������� ����� - ������� �� ����////////////////////12
 Index:=AddField;
 ArrayOfBonuses[Index]:=TRestart.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�������';
   Desc:='�������� �� ����';
   HintList.Add('��������');
   HintList.Add('�� ����');
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
/////////////////////////������� ����� - ��������� �� ����///////////////////13
 Index:=AddField;
 ArrayOfBonuses[Index]:=TFull.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='����������';
   Desc:='��������� �� ����';
   HintList.Add('���������');
   HintList.Add('�� ����');
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
//////////////////����� - ������������ ������ ���� ��� �����//////////////////14
 Index:=AddField;
 ArrayOfBonuses[Index]:=TUseOnly.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='��������';
   Desc:='������������ ������ ����. ��� �����';
   HintList.Add('������������');
   HintList.Add('������ ����.');
   HintList.Add('��� �����');
   HintList.Add('� ���. 20 ���.');
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
//////////////////////����� - ��������� ���� ��� �����////////////////////////15
 Index:=AddField;
 ArrayOfBonuses[Index]:=TUseAllExcept.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='����������';
   Desc:='��������� ���� ��� �����';
   HintList.Add('���������');
   HintList.Add('���� ���');
   HintList.Add('�����');
   HintList.Add('�� 40 ���.');
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
//////////////////////����� - ����� "���������� ������"///////////////////////16
 Index:=AddField;
 ArrayOfBonuses[Index]:=TGhostMode.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�������';
   Desc:='��������� ��������� ������ ��������';
   HintList.Add('���������');
   HintList.Add('���������');
   HintList.Add('������ ��������');
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
//////////////////////////////����� - "������� ������"////////////////////////17
 Index:=AddField;
 ArrayOfBonuses[Index]:=TSally.Create(Self);
 with ArrayOfBonuses[Index] do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�������';
   Desc:='� ��������� �����, ����� ��� ������ ������� ������';
   HintList.Add('�������� ������');
   HintList.Add('�� �������');
   HintList.Add('����');
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
///////////////////////����� - ��������� ������� ������///////////////////////18
 Index:=AddField;
 ArrayOfBonuses[Index]:=TRndRotate.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='������';
   Desc:='��� ������ ��������� �������';
   HintList.Add('��� ������');
   HintList.Add('���������');
   HintList.Add('�������');
   HintList.Add('� ���. 22 ���.');
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
////////////////////////////����� - �����������///////////////////////////////19
 Index:=AddField;
 ArrayOfBonuses[Index]:=TZeroGravity.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='�����������';
   Desc:='�������� ��� ��������� ����������';
   HintList.Add('��������');
   HintList.Add('��� ���������');
   HintList.Add('����������');
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
///////////////////////////////����� - ����///////////////////////////////////20
 Index:=AddField;
 ArrayOfBonuses[Index]:=THail.Create(Self);
 with (ArrayOfBonuses[Index] as TSimpleBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='����';
   Desc:='��������� ������ �� �������';
   HintList.Add('���������');
   HintList.Add('������');
   HintList.Add('�� �������');
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
///////////////////////////����� - ����� "������"/////////////////////////////21
 Index:=AddField;
 ArrayOfBonuses[Index]:=TMarsh.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='������';
   Desc:='����������/������������ ����� "������"';
   HintList.Add('����������');
   HintList.Add('�����');
   HintList.Add('"������"');
   HintList.Add('�� 1 ���.');
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
/////////////////////////����� - ��������� ��������///////////////////////////22
 Index:=AddField;
 ArrayOfBonuses[Index]:=TSpeedUp.Create(Self);
 with (ArrayOfBonuses[Index] as TTimeBonus) do
  begin
   RectObject:=Rect(X, Y, X + SWidth, Y + SHeight);
   Name:='���������';
   Desc:='�������� �������� �� 2 ���.';
   HintList.Add('��������');
   HintList.Add('��������');
   HintList.Add('�� 2 ���.');
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
    //���� ������ �� �����
    if MainTet[R, C].State <> bsEmpty then
     begin
      //��� � ���� �������
      Result:=R;
      //�������
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
 //���� ������� ���� ��� ����� �����
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
 //���� ������� ���� ��� ����� ����� �������
 if FEditBoxActive then Exit;
 //��������� �������� ���������� �������
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
 //��������� �������� ���������� �����
 case Key of
  VK_RETURN:PauseGame;
  VK_ESCAPE:ShowHideButtons;
  Ord('H'):if Shift = [ssShift, ssCtrl] then DebugEnabled:=not DebugEnabled;
 end;
end;

procedure TTetrisGame.ChangeBackground(ALevel:Byte);
begin
 //������ ������� - ������� ������� ����
 Bitmaps.BackgroundOne.Canvas.Draw(0, 0, Bitmaps.BackGroundDraw);
 //������ ������� - ������� ���������� ������
 if FLevel >= Length(Bitmaps.Backgrounds) then ALevel:=0;
 Bitmaps.BackgroundTwo.Canvas.Draw(0, 0, Bitmaps.Backgrounds[ALevel]);
 //������� ��� - 1-��
 Bitmaps.BGStep:=1;
 //��������� ������
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
 //���������� ������������� �������
 //����� = 0, ������ = ����� ��� - 20, ������ = 250, ����� = ����� ���.
 RectForAutor:=Rect(0, FieldHeight - 20, 250, FieldHeight);
 //������ 4-� ������� ���� = (������ �������� * ���-�� ��������� � ������) + 1
 IWidth:=(SWidth * GlSize) + 1;
 //����� = ������ �������� * (���-�� �������� + 2)
 ILeft:=SWidth * (2 + Cols);
 //������ = ����� + ������ 4-�  ������� ����
 IRight:=ILeft + IWidth;
 //������ = ������ ��������
 ITop:=SHeight;
 //����. ������
 RectForNextFigure:=Rect(Point(ILeft, ITop), IWidth, IWidth);
 //����� = ������� ������. ���� + ������ ��������
 ITop:=RectForNextFigure.Bottom + SHeight;
 //����: ���. ����, ������, ���� ���� �������
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
 //������������� ������ � ������� ����� ������
 with Redraw do
  begin
   FScaleSize:=Abs(FOwner.RectForNextFigure.Right - FOwner.RectForNextFigure.Left) - 2;
   FScalePos:=Point(FOwner.RectForNextFigure.Left - 10, FOwner.FieldHeight - 20);
  end;
end;

procedure TTetrisGame.MoveMouse;
var CPoint, LastPt:TPoint;
begin
 //���� ������ ��� ����� ����
 if PtInRect(Rect(SLeft, STop, SLeft + Cols * SWidth, STop + Rows * SHeight), Mouse) then
  begin
   //������� ������ � ���������
   Hint.Show('', '', '����,|�� �������,|��� ����.', 5, 0);
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
     //���� ���� �������� �� ����� ����������� - �������
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
 //���� ������ ����������/������������ ��� ��� ������ - �������
 if FButtonsHiding or (FButtonsHided) then Exit;
 //������ ����������
 FButtonsHiding:=True;
 //������� ������ ����, ���������
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
 //������ �� ����������
 FButtonsHiding:=False;
 //������ ������
 FButtonsHided:=True;
end;

procedure TTetrisGame.ShowButtons;
var Speed, B:Byte;
begin
 //���� ������ ������ �������������� �������� - ������ �������������� ������������
 if not AlreadyShownButtons then AlreadyShownButtons:=True;
 //���� ������ ����������/������������ ��� ��� �������� - �������
 if FButtonsHiding or (not FButtonsHided) then Exit;
 //������ ������������
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
 //������� ������ ����� � ������
 //Deg - ���������� ������������� 16-�� ���������� ��������� �����
 //����� Deg � ����������������� ������������� ��� ������ =))
 //���������� ������� �����
 AddFigure(CreateFigure($8888, ''), ArrayOfFigure);
 AddFigure(CreateFigure($CC00, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C880, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C440, ''), ArrayOfFigure);
 AddFigure(CreateFigure($4E00, ''), ArrayOfFigure);
 AddFigure(CreateFigure($8C40, ''), ArrayOfFigure);
 AddFigure(CreateFigure($4C80, ''), ArrayOfFigure);
 AddFigure(CreateFigure($C800, ''), ArrayOfFigure);
 AddFigure(CreateFigure($8000, ''), ArrayOfFigure);
 //���������� ������
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
 //��������� �������������� ������
 NextFigure:=GetRandomFigure;
 //�������� ������������ ������������� ��������� �����
 Bitmaps.LoadFigures(ArrayOfFigure, SWidth, SHeight);
end;

function TTetrisGame.CreateFigure(Deg:Word; FigureName:string):TFigure;
var i:Byte;
const Sz = GlAmnt - 1;
begin
 //��������� ���������� ����� � �������� ������ ������ � ������
 //R = (N - 1) div W + 1
 //C = (N - 1) mod W + 1
 //R - ������
 //C - �������
 //W - ���-�� ��������
 //N - ���������� ����� "������" ������� (����������� ������-����, �����-�������)
 //��� �������� ����� �� 2 � 10 �������� � �����
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
 //���� ���������� "�����������" - ���� ��������������� ��������
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
    //���� ���� ��� �����
    if GameState in [gsPlay, gsPause] then
     begin
      //���� ���� ������
      if Length(ArrayOfBonuses) > 0 then
      //���� ���� � ������� �������
       if PtInRect(RectForBonusesMouse, Point(X, Y)) then
        for i:=0 to Length(ArrayOfBonuses) - 1 do
         //���� ��� ����� � ���� ����
         if ArrayOfBonuses[i].Over and (GameState = gsPlay) and (ArrayOfBonuses[i].BonusType <> btForGame) then
          begin
           //��������, ��������� ����� � ���������� ������� ����� ������
           ShowGoldDec(BuyAndExcecute(ArrayOfBonuses[i]));
           //�������
           Exit;
          end;
      //���� ���� � �������������� ���������
      if PtInRect(RectForChangeMode, Point(X, Y)) then
       begin
        //������ ����� �����������
        if InfoMode = imInfoText then InfoMode:=imBonuses else InfoMode:=imInfoText;
       end;
     end
    else //���� �� ���
     //���� ���� � �������������� ��������� ���������� ���������
     if PtInRect(RectForChangeMode, Mouse) then
      begin
       Hint.Show('', '', '��� ������|����� ����', 5, 3);
      end
     else Hint.Hide; //���� ��� ������� ���������
    if PtInRect(RectForNextFigure, Mouse) and (DoDrawFigure <> dtNotWork) then
     begin
      DoDrawFigure:=dtElement;
      OnMouseMove(Shift, X, Y);
     end;
    //���� ���� ������
    if (not FButtonsHided) and (not FButtonsHiding) then
     if Length(ArrayOfButtons) > 0 then
      //�������� ��������� � ������� ����
      for i:=0 to Length(ArrayOfButtons)-1 do ArrayOfButtons[i].OnMouseDown(X, Y);
   end;
  mbRight:
   begin
    //���� ���� � �������������� ���������
    if PtInRect(RectForChangeMode, Point(X, Y)) then
     begin
      //����������/�������� ������
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
 //���� ���� � ������� ��������� - �������� ���������
 if PtInRect(RectForChangeMode, Mouse) then Hint.Hide;
 //���� ��������� ���� - �����������
 case GameState of
  gsNone:
   begin
    //���� ���� � ������� ������� ������
    if PtInRect(RectForAutor, Mouse) then
     begin
      //���������� ��������� ��� ���
      Hint.Show('������', '', '�����������|���������|��������|�������', 5, 0);
      Draw;
      //�������
      Exit;
     end;
   end;
  gsPlay,
  gsPause:
   begin
    //���� ����� ������� � ���� � ������� �������
    if InfoMode = imBonuses then
     if PtInRect(RectForBonusesMouse, Mouse) then
      begin
       //���� ���� ������
       if Length(ArrayOfBonuses) > 0 then
        begin
         for i:=0 to Length(ArrayOfBonuses) - 1 do
          begin
           //���� ����� ������ ��� ����, ����������
           if ArrayOfBonuses[i].BonusType = btForGame then Continue;
           //��������� ������ (�����)
           ArrayOfBonuses[i].Over:=PtInRect(ArrayOfBonuses[i].RectObject, Mouse);
           //���� ���� ����� � ������
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
  //���� ���� � �������������� ������
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
 //������ ������� �������
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
 //���� ���� ������������� - �������
 if FInfoMode = imTransforming then Exit;
 ShowAnimate(6);
 //��� ��������� - 0
 s:=0;
 //����� ������ �������
 W:=Abs(RectForBonuses.Left - RectForBonuses.Right);
 //���� �������������
 FInfoMode:=imTransforming;
 //�������� � ����� ����� �������
 case Value of
  imInfoText:
   begin
    //������� ������� �� ������ ������
    while RectForBonuses.Left < FieldWidth do
     begin
      //����������� ��� � ��������
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
    //������� ������� �� ������ ������
    while RectForBonuses.Left > 340 do
     begin
      //����������� ���
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
 //��������� �����
 FInfoMode:=Value;
end;

procedure TTetrisGame.SetHelper(Value:Boolean);
begin
 FHelper:=Value;
 //���� �������� ��������� - ��������� ����
 if Value then Shade.Update;
end;

procedure TTetrisGame.SetLines(Value:Integer);
var i:Byte;
begin
 //������������� ���-�� �����
 FLines:=Value;
 //�������� �������
 for i:=1 to GlLvls do
  begin
   //���� ���-�� ����� ������� ��� ��������� ������ � ������� ��� �� �������
   if (FLines >= (i * LinesAmountForLevelUp)) and (not Levels[i]) then
    begin
     //������� ��� �������
     FLevels[i]:=True;
     //�������� �������
     LevelUp;
     //�������
     Exit;
    end;
  end;
end;

procedure TTetrisGame.ContinueGame;
begin
 //������������� ���. ������
 Sound.Stop(100);
 //���� "������ �� �����"
 Sound.Play(4);
 //��������� ���� - �����
 GameState:=gsPause;
 //���. ����. - �����
 InfoMode:=imInfoText;
 //
 WriteDebug('���� ����������');
 //������������� "������"
 BoomStop;
 //������ �� ���������
 IsCreating:=False;
 //������� ��� ��� ������� ������
 ChangeBackground(GetLevel - 1);
 //������ "���������" �������
 ArrayOfButtons[1].Enable:=True;
 ArrayOfButtons[1].Text:='���������';
 //���� ������ �� ����������� ���������� ��������� (������ ������� � ������� =))
 if FirstUpGold and (FButtonsHiding or FButtonsHided) then
  begin
   Hint.Show('������ ��������', '', '������ �� ��� | ������ ������� ���� | ��� �� ��������', 5, 3);
  end;
 //��������� ���� - "���� ����"
 GameState:=gsPlay;
 if not FButtonsHided then HideButtons(True);
 MoveMouse;
end;

procedure TTetrisGame.DeleteSaved;
begin
 //������� ���� ����������
 DeleteFile(ProgramPath + SaveFN);
end;

function TTetrisGame.SaveGame:Boolean;
var FE:TFileStream;
    Lvl:Byte;
begin
 Result:=False;
 try
  begin
   //������� ������ ����
   FileClose(FileCreate(ProgramPath + SaveFN));
   //��������� ���� � ������ ������
   try
    FE:=TFileStream.Create(ProgramPath + SaveFN, fmOpenReadWrite);
   except
    begin
     Wait(2000);
     Hint.Show('��������', '', '�� ����������|���������|����', 3, 0);
     Exit;
    end;
   end;
   //���������� ������� ����
   FE.Write(MainTet, SizeOf(TTetArray));
   //����. ������
   FE.Write(MoveTet, SizeOf(TTetArray));
   //����. ������
   FE.Write(NextFigure, SizeOf(TFigure));
   //������� ����. ������
   FE.Write(CurFigure, SizeOf(TFigure));
   //������
   FE.Write(ToGold, SizeOf(Cardinal));
   //����
   FE.Write(ToScore, SizeOf(Cardinal));
   //�����
   FE.Write(Lines, SizeOf(Integer));
   //������� �� ������
   FE.Write(FigureEnable, SizeOf(Boolean));
   //��������� ����. ������ ������
   FE.Write(TopPos, SizeOf(Byte));
   //��������� ����. ������ �����
   FE.Write(LeftPos, SizeOf(Byte));
   //��������� ���� �����
   FE.Write(SLeft, SizeOf(Integer));
   //��������� ���� ������
   FE.Write(STop, SizeOf(Integer));
   //������ �� ������
   Lvl:=GetLevel;
   FE.Write(Lvl, SizeOf(Byte));
   FE.Write(FLevels, SizeOf(TLevels));
   //����������
   FE.Write(Statistics.Statistics, SizeOf(TStatRecord));
   //-------���������� �������
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
      //������� ������� �� ����� ��� ���
      FE.Write((ArrayOfBonuses[Lvl] as TTimeBonus).FActive, SizeOf(Boolean));
      //������� ���������� �����
      FE.Write((ArrayOfBonuses[Lvl] as TTimeBonus).FLastTime, SizeOf(Word));
     end;

   //-------------------------
   //����������� ����
   FE.Free;
  end;
 except
  begin
   //����������� ����
   FileClose(FileCreate(ProgramPath + SaveFN));
   //������� ����������
   DeleteSaved;
   //�������
   Exit;
  end;
 end;
 //���������� ������� ���������
 Result:=True;
end;

function TTetrisGame.LoadGame:Boolean;
var FE:TFileStream;
    LNs:Integer;
    Lvl:Byte;
    Tmp:Boolean;
begin
 Result:=False;
 //���� ����� ����. ��� - �������
 if not FileExists(ProgramPath + SaveFN) then Exit;
 //��������� ���� �� ������ � ������ ������
 FE:=TFileStream.Create(ProgramPath + SaveFN, fmOpenRead);
 try
  //��������� ��. ����
  FE.Read(MainTet, SizeOf(TTetArray));
  //����. ������
  FE.Read(MoveTet, SizeOf(TTetArray));
  //����. ������
  FE.Read(NextFigure, SizeOf(TFigure));
  //������� ����. ������
  FE.Read(CurFigure, SizeOf(TFigure));
  //������
  FE.Read(ToGold, SizeOf(Cardinal));
  //����
  FE.Read(ToScore, SizeOf(Cardinal));
  //�����
  FE.Read(LNs, SizeOf(Integer));
  //������� �� ������
  FE.Read(FigureEnable, SizeOf(Boolean));
  //��������� ����. ������ ������
  FE.Read(TopPos, SizeOf(Byte));
  //��������� ����. ������ �����
  FE.Read(LeftPos, SizeOf(Byte));
  //���� �����
  FE.Read(SLeft, SizeOf(Integer));
  //���� ������
  FE.Read(STop, SizeOf(Integer));
  //������ �� ������
  FE.Read(Lvl, SizeOf(Byte));
  Level:=Lvl;
  FE.Read(FLevels, SizeOf(TLevels));
  OldLevel:=Lvl;
  SetLines(Lns);
  //����������
  FE.Read(Statistics.Statistics, SizeOf(TStatRecord));
  //--------------------�������� �������
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
  //����������� ����
  FE.Free;
 except
  //���� ���������� ����������
  begin
   //������� ����������
   DeleteSaved;
   //���������� ��������
   Reset;
   //����������� ����
   FE.Free;
   //�������
   Exit;
  end;
 end;
 //���������� ���������
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
   Hint.Show('���������', '', ' |�����������|�����', 3, 0);
   Exit;
  end;
 //���� ��������� ���� - ����������
 if GameState = gsShutdown then
  begin
   //�� ��������� ����
   AnswerShut:=0;
   //����� ���
   Confirm:=True;
   //�������
   Exit;
  end;
 //���� ������ ������ - ���������
 if FButtonsHided then
  begin
   ShowButtons;
   Exit;
  end;
 //���� ��������� ���� - �����, ���� ��� ���������
 if GameState in [gsPause, gsPlay, gsDrawFigure] then
  begin
   if GameState = gsDrawFigure then DrawingFigureEnd(gsShutdown)
   else GameState:=gsShutdown;
   //����� ���� �� ���
   Confirm:=False;
   //�� ��������� ����
   AnswerShut:=2;
   //����� �������� ������
   ArrayOfButtons[0].Text:='���������';
   ArrayOfButtons[1].Text:='�� ���������';
   ArrayOfButtons[2].Text:='�� ��������';
   //���� ���� �� ����� ��� ����� ��� ���� ��������� �� ����� �����������
   repeat Application.ProcessMessages until Confirm or Application.Terminated;
   //����� �������� ������
   ArrayOfButtons[0].Text:='�����';
   ArrayOfButtons[1].Text:='���������';
   ArrayOfButtons[2].Text:='�����';
   //�������� �������� � ����������� �� ������
   case AnswerShut of
    //��������� ����
    1:if SaveGame then
       begin
        Hint.Show('�� ���������?', '', '����|�������|���������', 3, 0);
        Wait(1000);
       end;
    //�� �������
    0:begin
       //������ �����
       GameState:=gsPlay;
       PauseGame;
       //�������
       Exit;
      end;
   end;
   ArrayOfButtons[0].Enable:=False;
   ArrayOfButtons[1].Enable:=False;
   ArrayOfButtons[2].Enable:=False;
  end //���� �� ��������� ���� - �������� ��� ��., �� ������� ����. ����
 else if not CanBeContinue then DeleteSaved;
 //���� ���������� ����
 Sound.Play(10);
 //���������� ���������
 Hint.Show('', '', '����|�����������!', 6, 0);
 //���� � ���������� ����
 Shutdowning:=True;
 //
 Statistics.Save;
 //�������� �������
 Wait(1500);
 //���������� ������
 Application.Terminate;
end;

procedure TTetrisGame.LevelUp;
begin
 Statistics.Append.Level(1);
 //����
 Sound.Play(6);
 if FLevel = GlLvls then Exit;
 //�������� �������, ������������� ��������
 Level:=FLevel + 1;
 //"���������" �����
 CreateNextBoss;
 //������� ���
 ChangeBackground(FLevel - 1);
 //Debug
 WriteDebug(Format('�������: %d, ����: %d, ������: %d', [FLevel, ToScore, ToGold]));
end;

procedure TTetrisGame.StepDownBonuses;
var R, C:Byte;
begin
 //���� �� ���� � ��������� ���������� �����
 for R:=1 to Rows do
  for C:=1 to Cols do
   begin
    if MainTet[R, C].State = bsBonusTiming then
     if MainTet[R, C].TimeLeft > 0 then Dec(MainTet[R, C].TimeLeft)
     else //���� ����� �������
      begin
       //���� ���������� ������
       Sound.Play(8);
       //��������� ������ - ������
       MainTet[R, C].State:=bsBonusBroken;
      end;
   end;
 //��������� ����
 UpScore(1);
end;

function TTetrisGame.UpGold(Value:Word):Word;
begin
 //����������� ������
 Inc(ToGold, Value);
 Statistics.Append.Gold(Value);
 //��� �� ������ ����������
 if FirstUpGold and (InfoMode <> imBonuses) then
  begin
   Hint.Show('', '', '����� �� ���� | ����� ������� | � �������|� �������', 5, 2);
  end;
 FirstUpGold:=False;
 //��������� - �������� ���-�� ������
 Result:=ToGold;
end;

function TTetrisGame.ElemCount(Figure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //������ ������� ���-�� ��������� ������
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   if Figure.Elements[R, C].State <> bsEmpty then Inc(Result);
end;

function TTetrisGame.CreateBonus(var Figure:TFigure):Boolean;
const Size = 30;
var   Chance, R, C, FS, FChance:Byte;
begin
 //� ����������� �� ������ ��� ������� ��������
 //������ 4 ������ - ���� ����� �� ������ (���� �������)
 //����������� ������ - ������������ ����� ������ � ������
 case FLevel of
  1..4:
   begin
    //���� = ��������� ����� �� (30 - (������� * 2)) + 1
    //1: 2 �� 28
    //3: 2 �� 26
    //���� ��������� ������
    Chance:=Random(Size - (FLevel * 2)) + 1;
    //������� ����� ���� �������� ����� ����� 1 ��� 2
    Result:=(Chance = 1) or (Chance = 2);
    //���� ���� �� ����� - �������
    if not Result then Exit;
    //����� ��������� ������ �������
    repeat
     R:=Random(GlSize) + 1;
     C:=Random(GlSize) + 1;
    until Figure.Elements[R, C].State <> bsEmpty;
    //������ ������� - �������
    Figure.Elements[R, C].State:=bsBonus;
    //�������
    Exit;
   end;
 else
  begin
   //���� = ��������� ����� �� (30 - �������) + 1
   //5: 1 �� 25
   //13: 1 �� 17
   Chance:=Random(Size - FLevel) + 1;
   //������� ������ ���� �������� ����� ����� 1
   Result:=Chance = 1;
   //���� �� ������� - �������
   if not Result then Exit;
   //����� ��������� ���-�� ������� ��� ������
   FChance:=Random(6) + 1;
   //��������� � ���-�� ��������� � ������
   FChance:=Min(FChance, ElemCount(Figure));
   //������� ������� - 0
   FS:=0;
   //������� ������ ���� �� �������� �������, ������� �����
   repeat
    //����� ������ �������
    repeat
     R:=Random(GlSize) + 1;
     C:=Random(GlSize) + 1;
    until Figure.Elements[R, C].State <> bsEmpty;
    //������ �� ���� �����
    Figure.Elements[R, C].State:=bsBonus;
    //����������� ���-�� ��������� �������
    Inc(FS);
   until FS = FChance;
   //������� (������, �� �����)
   Exit;
  end;
 end;
end;

function TTetrisGame.UpScore(Value:Integer):Integer;
begin
 //��������� ����
 Inc(ToScore, Value);
 Statistics.Append.Score(Value);
 //��������� - ������� ��������� �����
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
 //������� = ����������� �����((�������� / (��������� �������� / GlLvls)) + 1)
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
 //�������� ��������� ����
 FGameState:=Value;
 //���� ���� ������ �������� ��
 if Length(ArrayOfPanels) > 0 then if Value <> gsNone then ArrayOfPanels[0].Hide;
 case Value of
  gsNone,
  gsStop:
   begin
    ArrayOfButtons[0].Text:='������';
    //��������� ��������
    TimerDownStop;
    //
    Timers:=False;
   end;
  gsPause,
  gsDrawFigure:
   begin
    ArrayOfButtons[0].Text:='����������';
    //��������� ��������
    TimerDownStop;
    //
    Timers:=False;
   end;
  gsPlay:
   begin
    ArrayOfButtons[0].Text:='�����';
    //���� ��������
    TimerDownStart;
    //
    Timers:=True;
   end;
 end;
end;

procedure TTetrisGame.Reset;
var i:Byte;
begin
 //������� ��������� �� ���� ������
 SetLength(ArrayOfToDo, 0);
 for i:=1 to GlExes do ArrayOfExing[i].Active:=False;
 //��������������� ����������� �������
 for i:=1 to GlLvls do FLevels[i]:=False;
 //���������� �������� �����
 Lines:=0;
 OldLevel:=1;
 ToScore:=0;
 ToGold:=StartGold;
 //������������� ����������� �������� �������� ������
 Level:=1;
 //if Assigned(TimerStep) then TimerStep.Interval:=StartSpeed;
end;

procedure TTetrisGame.Boom(Size:Byte; BTime:Word);
begin
 //���������� ������� "������"
 TimerBoom.Enabled:=False;
 TimerBoom.Interval:=BTime;
 TimerBoom.Enabled:=True;
 //���� ����� "������" ������ ��� ����� ������� "������", �� ����������� ��
 if Size <= FBoom then Inc(FBoom, (Size div 2) + (Size div 3)) else FBoom:=Size;
 if FBoom > 30 then FBoom:=30; //���� "������" ������ 30, �� "�������" �� � �������
 //��, ���� "������"
 DoBoom:=True;
end;

procedure TTetrisGame.BoomStop;
begin
 //���� � ��� ��� "������" - �������
 if not DoBoom then Exit;
 //�������� "��������� ������" ���� �����
 if TimerBoom.Interval > 50 then TimerBoom.Interval:=50;
 //��������� ������ �� 3
 if FBoom > 5 then Dec(FBoom, 3);
end;

procedure TTetrisGame.ShowAnimate(ID:Byte);
begin
 if Assigned(Bitmaps) then Bitmaps.Animate:=ID;
end;

procedure TTetrisGame.ShowFigureChanging(FStart, FEnd:TFigure);
var R, C, S:Byte;
begin
 //������� ��������� ������ ��������� ����1 ����2
 for S:=(GlSize - 1) downto 0 do
  begin
   //�� ������ ���� ������� ��������� ������ ����� ������ � ������ 3 ������ ���������� ������
   //�� ������ ���� ��������� 2 ��������� ������ ����� � 2 ������ ������ ����������
   //etc.
   for R:=1 to GlSize do
    for C:=1 to GlSize do
     begin
      if (S + R)   <  (GlSize + 1) then NextFigure.Elements[R, C]:=FEnd.Elements[S + R, C] else
      if (R - Abs(S - GlSize)) > 0 then NextFigure.Elements[R, C]:=FStart.Elements[R - Abs(S - GlSize), C];
     end;
   Wait(40);
  end;
 //�������� ������ ��� ���������� ����������
 NextFigure:=FEnd;
end;

procedure TTetrisGame.CreateNextFigure;
begin
 ShowFigureChanging(NextFigure, GetRandomFigure);
end;

procedure TTetrisGame.TimerDownStop;
begin
 //����������� ������� ������
 TimerStep.Enabled:=False;
end;

procedure TTetrisGame.TimerDownStart;
begin
 //������ ������� ������
 TimerStep.Enabled:=True;
end;

procedure TTetrisGame.AddButton(AButton:TExtButton);
begin
 //��������� � ������ ��� ���� ������
 SetLength(ArrayOfButtons, Length(ArrayOfButtons) + 1);
 ArrayOfButtons[Length(ArrayOfButtons) - 1]:=AButton;
end;

procedure TTetrisGame.Normalization(var Figure:TFigure);

//�������� �� �������� �����
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

//�������� �� �������� �����
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

//�������� �����
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

//�������� �����
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
 //������� ��� ����� (�����, �����)
 while not Check_C(Figure) do MoveUp(Figure);
 while not Check_R(Figure) do MoveLeft(Figure);
end;

function TTetrisGame.RotateFigure(Figure:TFigure; OnSentry:Boolean):TFigure;
var R, C:Byte;
begin
 //�������� ������
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
 //��� �������� ���� - 0
 LoadState:=0;
 //���� � ���, ��� ���� ������������� ����
 Creating:=True;
 //���������/���������� �������
 DebugEnabled:=False;
 //��������������� �������� ������
 FDrawCanvas:=ACanvas;
 //��������� �������� "��������" � �������������� �������� ������ �������
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
 //������ �������� ������ �� �������� �������
 Result:=Abs(TimerStep.Interval - StartSpeed) + 1;
end;

procedure TTetrisGame.ClearAll;
var R, C:Word;
begin
 //������� ����
 Shade.Clear;
 //������� ���� � �������� "�������� �� ��������"
 for R:=1 to Rows do
  begin
   //������� ������ ��� �� �������, ������� ������� ����������
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
 //���� ���� ������������� - �������
 if Creating then Exit;
 //���� ��������� �������� ������ 2 ����.
 if MTime < 2 then
  begin
   //��������� Windows ������ ��� ���������
   Application.ProcessMessages;
   //�������
   Exit;
  end;
 //��������� ������� �����
 Tick:=GetTickCount;
 //���� ������� ������� �������
 repeat
  //��������� Windows ������ ��� ���������
  Application.ProcessMessages;
 until Tick + MTime < GetTickCount;
end;

procedure TTetrisGame.Wait(MTime:Word);
var Tick:Cardinal;
begin
 //���� ���� ������������� - �������
 if Creating then Exit;
 //���� ��������� �������� ������ 2 ����.
 if MTime < 2 then
  begin
   //��������� Windows ������ ��� ���������
   Application.ProcessMessages;
   //�������
   Exit;
  end;
 //������������� ������
 TimerDownStop;
 //���� ��������
 IsWait:=True;
 //��������� ������� �����
 Tick:=GetTickCount;
 //����������� ������� �������� (��� ������������� � ������� ������� � ��� ���������)
 Inc(FWaitAmount);
 //���� ������� ������� �������
 repeat
  //��������� Windows ������ ��� ���������
  Application.ProcessMessages;
 until Tick + MTime < GetTickCount;
 //��������� ���-�� ��������
 Dec(FWaitAmount);
 //���� ���-�� �������� = 0
 if FWaitAmount <=0 then
  begin
   //��������� ������
   TimerDownStart;
   //������� ��������
   IsWait:=False;
  end;
 //���� �� ��� ��� ���� ���� � ��������� ��������, �� �� � ��������� ���, ���� ������� ��������, � ������ ���� ��������
end;

procedure TTetrisGame.AddFigure(Figure:TFigure; var Dest:TArrayOfFigure);
var R, C, Num:Byte;
begin
 //��������� ������
 SetLength(Dest, Length(Dest) + 1);
 //������ �� ������ - ���������� ����� � �������
 Num:=Length(Dest);
 //������ "��������" �������� ������ �� ��
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    if Figure.Elements[R, C].ID = aEmpty then Figure.Elements[R, C].State:=bsEmpty else Figure.Elements[R, C].State:=bsElement;
    Figure.Elements[R, C].ID:=Num;
    Figure.Elements[R, C].TimeLeft:=0;
   end;
 //��������� � ������
 Dest[Length(Dest)-1]:=Figure;
end;

function TTetrisGame.GetRandomFigure:TFigure;
begin
 //�������� ��������� ��������� ������
 repeat NextID:=Random(Length(ArrayOfFigure)) until ArrayOfFigure[NextID].Allowed;
 CreatedBoss:=False;
 Result:=ArrayOfFigure[NextID];
 while Random(5) <> 3 do Result:=RotateFigure(Result, Boolean(Random(2)));
end;

function TTetrisGame.GetPreviewFigure:TFigure;
var i, j:Byte;
begin
 //�������� ��������� ��������� ������
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
 //���� (����� � ����������) ������� ��������� ���-�� ������
 if FLevel > Length(ArrayOfBosses) then
  begin
   //����� ������� ������
   Result:=GetRandomFigure;
   //�������
   Exit;
  end;
 //���� ������
 CreatedBoss:=True;
 //��������� - ���� �������� ������
 Result:=ArrayOfBosses[FLevel - 1];
end;

procedure TTetrisGame.Merger;
var C, R:Byte;
begin
 for C:=1 to Cols do
  for R:=1 to Rows do
   begin
    //���� ������� �� ���� �� ������� � ���. ��������
    if MoveTet[R, C].State <> bsEmpty then MainTet[R, C]:=MoveTet[R, C];
    //���� ������� ������ - �����
    if MainTet[R, C].State = bsBonus then
     begin
      //������ ��������� ����� 30 - 50 ���.
      MainTet[R, C].TimeLeft:=Random(50 - 30) + 30;
      //��������� �������� - ���� ������
      MainTet[R, C].State:=bsBonusTiming;
     end;
    //������� ������� � ����. �������
    MoveTet[R, C].State:=bsEmpty;
   end;
end;

function TTetrisGame.CheckLine:Boolean;
var R, C:Byte;
begin
 //"�����������", ��� ���� �������� � ���� �� GlHdRw ��� ����������� ����
 Result:=True;
 for R:=1 to GlHdRw do
  for C:=1 to Cols div 2 do
   begin
    //���� ���� ������� ������ ������� (�����������, ��� ����� ����������� ����)
    if MainTet[R, C].State <> bsEmpty then Exit;
    if MainTet[R, C + (Cols div 2)].State <> bsEmpty then Exit;
    //�������� ������� � ��� ����
   end;
 //���, ���� ��������, ���������� ������
 Result:=False;
end;

procedure TTetrisGame.ClrChng(var Chng:TTetArray);
var C, R:Byte;
begin
 for C:=1 to Cols do for R:=1 to Rows do Chng[R, C].State:=bsEmpty;
end;

procedure TTetrisGame.NewGame;
begin
 WriteDebug('����� ����');
 //������������� ���. ������
 Sound.Stop(100);
 //������ ���� "������ ����"
 Sound.Play(3);
 //������������� "������"
 BoomStop;
 //������������� ������ ������
 TimerDownStop;
 FEditBoxActive:=False;
 ZeroGravity:=False;
 //
 Timers:=False;
 //���������� �������� ������
 Reset;
 //������ �� ���������
 IsCreating:=False;
 //������ �����������
 FigureEnable:=False;
 //������� ��� ��� ������� ������
 ChangeBackground(0);
 //������� ��� �������
 ClearAll;
 //��������� ���� - "���� ����"
 GameState:=gsPlay;
 //������ ������ ��� (�������� ������ � ��������� �� ����)
 StepDown;
 //��������� ������ ������
 TimerDownStart;
 //
 Timers:=True;
 //������ "����" �������
 ArrayOfButtons[1].Enable:=True;
 //��������������� ����� �� ������
 ArrayOfButtons[1].Text:='���������';
 //���� ������ �� ����������� ���������� ��������� (������ ������� � ������� =))
 if FirstUpGold then
  begin
   Hint.Show('������ ��������', '', '������ �� ��� | ������ ������� ���� | ��� �� ��������', 5, 5);
  end;
end;

procedure TTetrisGame.StopGame;
var ScoreTop:Byte;
begin
 if ExecutingBonus then
  begin
   Hint.Show('���������', '', ' |�����������|�����', 3, 0);
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
       Text:='���������';
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
 //���� ��� �� ������ - �������
 if (GameState = gsStop) or (GameState = gsNone) then Exit;
 //���� "���� ��������"
 Sound.Play(1);
 //������������� ������ ������
 TimerDownStop;
 //
 Timers:=False;
 //������ "����" �� �������
 ArrayOfButtons[1].Enable:=False;
 //����� ����. - �����
 InfoMode:=imInfoText;
 //��������� ���� - "���� ��������"
 DrawingFigureClose(gsStop);
 //�������� ������ - ���
 IsCreating:=False;
 //���� ������ - ���
 FigureEnable:=False;
 //������� ����������� ����
 DeleteSaved;
 //������������ ��������� ������
 DeactivateAllBonuses;
 //������� ���� � ���� ��� ����� ����� ������
 if Statistics.CheckScore(ToScore) then
  begin
   FEditBoxActive:=True;
   while FEditBoxActive and (not Shutdowning) do Application.ProcessMessages;
   if FEditBoxText <> '' then
    begin
     ScoreTop:=Statistics.InsertTheBest(FEditBoxText, ToScore);
     if ScoreTop = 1 then
      Hint.Show('���!', '1', '�� ���������|����� ������|� ������|1 �����', 5, 0)
     else Hint.Show('�������', IntToStr(ScoreTop), '�� ������|� �������|������ �������', 5, 0);
    end;
  end;
 //���������� ������ �� �����
 ShowButtons;
end;

procedure TTetrisGame.PauseGame;
var spd:Byte;
begin
 //���������� �����
 //if DebugEnabled then DrawBMP.SaveToFile(ProgramPath + ScrnFN);
 //
 if ExecutingBonus and (not FPauseTutorial) then
  begin
   Hint.Show('���������', '', ' |�����������|�����', 3, 0);
   Exit;
  end
 else
  if FPauseTutorial then
   while ExecutingBonus do
    Application.ProcessMessages;
 //���������
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
    //������� ����� ����
    NewGame;
    //���� ������ �� ������ - ��������
    if not FButtonsHided then HideButtons(True);
    //������� ���� � ����
    MoveMouse;
    //��������� ���������� ����
    CanBeContinue:=False;
    //�������
    Exit;
   end;
  gsPlay:
   begin
    if FPauseTutorial then
     begin
      //���� "�����"
      Sound.Play(3);
      //��������� ���� - �����
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
      //���� "�����"
      Sound.Play(3);
      //��������� ���� - �����
      GameState:=gsPause;
      if FButtonsHided then ShowButtons;
      //���. ����. - �����
      OldIM:=InfoMode;
      InfoMode:=imInfoText;
     end;
   end;
  gsPause:
   begin
    FEditBoxActive:=False;
    //���� "������ �� �����"
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
    //����� ����. ����������
    InfoMode:=OldIM;
    //��������� ���� - "���� ����"
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
 //������������ ���
 Result:=False;
 CloseGhost:=False;
 if ATop > Rows then
  begin
   Ghost:=False;
   Result:=True;
   Exit;
  end;
 //������ �� ������� � ������� ����������� ������
 for R:=ATop to ATop + (GlSize - 1) do
  begin
   //���� ����� �� ������� - �������
   if R > Rows then Break;
   for C:=ALeft to ALeft + (GlSize - 1) do
    begin
     //���� ����� �� ������� - ��������� ����
     if C >= Cols + 1 then Break;
     //���� ������ 0 - ���������� ��������
     if C <= 0 then Continue;
     //���� ������ ������ - ���������� ��������
     if TetArray[R, C].State = bsEmpty then Continue;
     //���� ��������� ������ ������� �� ������� - ������������, �������
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
       //���� ��������� ������ ������� �� ������� - ������������, �������
       if R + 1 > Rows then
        begin
         Result:=True;
         Break;
        end;
       //���� ���� ����������� - ������������ - �������
       if MainTet[R, C].State <> bsEmpty then begin Result:=True; Break; end;
       //���� � ��������� ������ ������ �� ����� - ������������ - �������
       if MainTet[R + 1, C].State <> bsEmpty then begin Result:=True; Break; end;
      end;
    end;
  end;
 if CloseGhost then Ghost:=False;
end;

function TTetrisGame.CheckCollision(TetArray:TTetArray; ATop:Byte; IsShade:Boolean):Boolean;
begin
 //�������� �� ������������ �� ������� ��������� ������� ������
 Result:=CheckCollision(TetArray, ATop, LeftPos, IsShade);
end;

function TTetrisGame.CheckCollision(TetArray:TTetArray; IsShade:Boolean):Boolean;
begin
 //�������� �� ������������ �� ������ ������� ������
 Result:=CheckCollision(TetArray, TopPos, IsShade);
end;

function TTetrisGame.WidthOfFigure(AFigure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //������ ������ - ������� (����� � ������) �������� ������
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    //���� ������� �� ������ ����� ��� � ������
    if AFigure.Elements[R, C].State <> bsEmpty then if Result < C then Result:=C;
    //���� ������ ��� GlSize - ��� ������ ���������� ���� - �������
    if Result = GlSize then Exit;
   end;
end;

function TTetrisGame.HeightOfFigure(AFigure:TFigure):Byte;
var R, C:Byte;
begin
 Result:=0;
 //������ ������ - ������� (������ � �����) �������� ������
 for R:=1 to GlSize do
  for C:=1 to GlSize do
   begin
    //���� ������� �� ������ ����� ��� � ������
    if AFigure.Elements[R, C].State <> bsEmpty then if Result < R then Result:=R;
    //���� ������ ��� GlSize - ��� ������ ���������� ���� - �������
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
 //���� �������� ������
 IsCreating:=True;
 //���� ��� ���� ������, ������� ���. ���� � ����. �����
 if FigureEnable then Merger;
 //��������� �������� ����������� �����
 ExecutingDelete;
 //���� �� ������� ���������� ������ - �������� ������
 while WidthOfFigure(NextFigure) <= 0 do CreateNextFigure;
 //������ - ������������� ������
 CurFigure:=NextFigure;
 Statistics.Append.Figure(1);
 //���� ��������� ����
 if CreatedBoss then
  begin
   //���� ����
   IsTheBoss:=True;
   //���� "����"
   Sound.Play(14);
  end //���� �� ��� - ����� ���
 else IsTheBoss:=False;
 //���� ��������� ����� - ���� "�����"
 if CreateBonus(CurFigure) then
  begin
   Sound.Play(12);
   Event(eventTutorial, eventBonus, 0);
  end;
 //������� ������������� ������
 CreateNextFigure;
 //���� ������� ������ 10, �� ������ �� ������ ����
 if FLevel < 10 then L:=(Cols div 2) - (WidthOfFigure(CurFigure) div 2)
 //���� �� ������, ���� ����� 10, �� � ��������� �����
 else L:=Random(Cols - (WidthOfFigure(CurFigure) - 1));
 for C:=1 to GlSize do
  for R:=1 to GlSize do
   begin
    //���� ��� ��������� ������, ��� ����������
    if (CurFigure.Elements[R, C].State <> bsEmpty) and (MainTet[R, C + L].State <> bsEmpty) then
     begin
      //"������"
      Boom(10, 300);
      //���� ����
      StopGame;
      //�������
      Exit;
     end;
    //��������� ������� ������ � ����. ����
    MoveTet[R, C + L]:=CurFigure.Elements[R, C];
   end;
 //������ - 1
 TopPos:=1;
 //��������� ����� - ��������� ������ + 1
 LeftPos:=L + 1;
 //���� ������� ������������
 if CheckCollision(MoveTet, False) then
  begin
   //���
   Boom(10, 300);
   //���� ����
   StopGame;
   //�������
   Exit;
  end;
 //������ ����
 FigureEnable:=True;
 //�������� ��������
 IsCreating:=False;
 //��������� ����
 Shade.Update;
 //���������� ���� ������� ������ "����"
 //ResetForceDown;
end;

procedure TTetrisGame.Move(Bottom:Byte);
var C, R, ABonuses:Byte;
    UpsGold:Word;
begin
 //������ - 0
 UpsGold:=0;
 //������� - 0
 ABonuses:=0;
 //�������� �������� �� ������ Bottom
 AnimateDelete(Bottom);
 //
 Wait(100);
 //������� ������ � ��������� �������, ������ � ��������� �����
 for C:=1 to Cols do
  begin
   //���� ��� �����
   if MainTet[Bottom, C].State in [bsBonus, bsBonusTiming] then
    begin
     //���� ��������� ����� �� 1 �� 3 �� ����� 1, �� ���������� ������, � ��������� ������ ��� �������� ��������
     if Random(3) + 1 <> 1 then Inc(UpsGold, Random(86) + 15) else Inc(ABonuses);
     //255 ����� �� �����
     UpScore(255);
    end;
   //���������� �������
   MainTet[Bottom, C].State:=bsEmpty;
  end;
 //��������� ������ �� ������ � �� ������ �� ������� (5 * �������)
 if UpsGold > 0 then Sound.Play(9);
 UpGold(UpsGold + 5 * FLevel);
 //���� "�������� �����"
 Sound.Play(2);
 //"������"
 Boom(5, 300);
 //������� ���� ���� � ������� ������� ������
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
 //��������� ����
 Shade.Update;
 //���� �������� ������ - ��������� ���������
 if ABonuses > 0 then for R:=1 to ABonuses do ExecuteRandomBonus(tbCare);
end;

procedure TTetrisGame.RotateGameFigure(OnSentry:Boolean);
var C, R, W:Byte;
    Figure:TFigure;
    ChngTet:TTetArray;
begin
 //���� ���� �� ���� - �������
 if GameState <> gsPlay then Exit;
 //���� �������� ��� �������� ������ - �������
 if IsWait or IsCreating then Exit;
 //�������� ���������� ������
 Figure:=RotateFigure(CurFigure, OnSentry);
 //������ ������ ������
 W:=WidthOfFigure(Figure);
 //���� ������ ������ ���� ����� 0 - ������� (��� ���� �� ��������, �� ��� ��)
 if W <= 0 then Exit;
 //���� ������� ��������� ������� ��-�� ������ - �������
 if LeftPos + (W - 1) >= Cols + 1 then Exit;
 //������� ���� ��� ���������
 ClrChng(ChngTet);
 //��������� ���������� ������ � ���� ��� ���������
 for C:=1 to GlSize do
  for R:=1 to GlSize do
   begin
    if Figure.Elements[R, C].State = bsEmpty then Continue;
    if (TopPos + R - 1 > FRows) or (LeftPos + C - 1 > FCols) then Exit;
    ChngTet[TopPos + R - 1, LeftPos + C - 1]:=Figure.Elements[R, C];
   end;
 //���� �� ���������� ������������ � ��������
 if not CheckCollision(ChngTet, False) then
  begin
   //���� "��������� ������"
   Sound.Play(11);
   //�������� ������ ������������
   MoveTet:=ChngTet;
   //������ ������� ������ �� ���������� (��� �������)
   CurFigure:=Figure;
   //��������� ����
   Shade.Update;
  end;
end;

function TTetrisGame.DeleteFilled(Row:Byte):Byte;
var C, R:Byte;
    Missed:Boolean;
begin
 //������� ����� - 0
 Result:=0;
 //���� ���������� ������ ��� ������ - �������
 if Row < 1 then Exit;
 //���� �� ������� � �������
 for R:=Row downto 1 do
  begin
   //��� ������
   Missed:=False;
   //���� �� ��������
   for C:=1 to Cols do
    begin
     //���� ������� - ����
     if MainTet[R, C].State = bsEmpty then
      begin
       //���� ������
       Missed:=True;
       //��������� ����
       Break;
      end;
    end;
   //���� ��� ������
   if not Missed then
    begin
     //������� ������ � ������� ����
     Move(R);
     //����������� ���-�� ��������� �����
     Inc(Result);
     //����������� ���-�� ��������� ����� �� ���-�� ��������� ����� ����������� �������, ������� ����� ��������� ������������ ������
     Inc(Result, DeleteFilled(R));
     //�������
     Exit;
    end;
  end;
end;

procedure TTetrisGame.StepUp;
var C, R, AForceDown:Byte;
    Chng:TTetArray;
begin
 //���� �� ���� ���� - �������
 if GameState <> gsPlay then Exit;
 //���� �������� ��� �������� ������ - �������
 if IsWait or IsCreating then Exit;
 //���� ��� ������ - �������
 if not FigureEnable then NewFigure;
 //���� ���� �������� � ������� ����� ����
 if CheckLine then
  begin
   //���
   Boom(10, 300);
   //���� ����
   StopGame;
   //�������
   Exit;
  end;
 //��������� ���� ������� ������ "�����"
 AForceDown:=GameKeys[FKeyIDUP].ForceDown;
 //AForceUP:=ForceUp;
 WasGhostColl:=False;
 Chng:=MoveTet;
 //������� ������ ���� � ������� ����
 for R:=GlFVRw to Rows do
  for C:=1 to Cols do
   begin
    if R = Rows then Chng[R, C].State:=bsEmpty
    else Chng[R, C]:=Chng[R + 1, C];
   end;
 if TopPos - 1 < GlFVRw then Exit;
 if CheckCollision(Chng, TopPos - 1, False) then Exit;
 //���� ���� ������������
 if CheckCollision(MoveTet, False) then
  begin
   //�������� 300 ����. (���������� ������)
   Wait(300);
   //������� ����� ������
   NewFigure;
   //����������� ���� �� �������: 10 + (������� * 100)
   UpScore(10 + (FLevel * 100));
   //���� ��� ��� ���� - ����������� ��� ���� �� �������: 1000 + (������� * 100)
   if IsTheBoss then UpScore(1000 + (FLevel * 100));
   //�������
   Exit;
  end;
 //������� ������ ���� � ������� ����
 for R:=GlFVRw to Rows do
  for C:=1 to Cols do
   begin
    if R = Rows then MoveTet[R, C].State:=bsEmpty
    else MoveTet[R, C]:=MoveTet[R + 1, C];
   end;
 //��������� ������
 Dec(TopPos);
 //���� ���� ������������
 if CheckCollision(MoveTet, False) or WasGhostColl or (TopPos - 1 < GlFVRw) then
  begin
   WasGhostColl:=False;
   //���� ��� ���� ���� "���� �����������", ���� ��� "������ ������������"
   if IsTheBoss then Sound.Play(15) else Sound.Play(5);
   //���� ������ ������� �����
   if AForceDown > 30 then
    begin
     //���� ��� ���� - ��� 1 ���� ��� ��� 2
     if IsTheBoss then Boom(6, 400) else Boom(3, 300);
    end
   else //���� �� ���
    begin
     //���� ��� ���� - ��� 1 ���� ��� ��� 2
     if IsTheBoss then Boom(3, 300) else Boom(2, 100);
    end;
  end;
end;

procedure TTetrisGame.StepDown;
var C, R, AForceDown:Byte;
begin
 //���� �� ���� ���� - �������
 if GameState <> gsPlay then Exit;
 //���� �������� ��� �������� ������ - �������
 if IsWait or IsCreating then Exit;
 //���� ��� ������ - �������
 if not FigureEnable then NewFigure;
 //���� ���� �������� � ������� ����� ����
 if CheckLine then
  begin
   //���
   Boom(10, 300);
   //���� ����
   StopGame;
   //�������
   Exit;
  end;
 WasGhostColl:=False; 
 //���� ���� ������������
 if CheckCollision(MoveTet, False) then
  begin
   //�������� 300 ����. (���������� ������)
   Wait(300);
   //������� ����� ������
   NewFigure;
   //����������� ���� �� �������: 10 + (������� * 100)
   UpScore(10 + (FLevel * 100));
   //���� ��� ��� ���� - ����������� ��� ���� �� �������: 1000 + (������� * 100)
   if IsTheBoss then UpScore(1000 + (FLevel * 100));
   //�������
   Exit;
  end;
 //��������� ���� ������� ������ "����"
 AForceDown:=GameKeys[FKeyIDDown].ForceDown;
 //������� ������ ���� � ������� ����
 for R:=Rows downto 1 do
  for C:=1 to Cols do
   begin
    if R = 1 then MoveTet[1, C].State:=bsEmpty
    else MoveTet[R, C]:=MoveTet[R - 1, C];
   end;
 //��������� ������
 Inc(TopPos);
 //���� ���� ������������
 if CheckCollision(MoveTet, False) or WasGhostColl then
  begin
   WasGhostColl:=False;
   //���� ��� ���� ��� ������� ����� "������", ���� ������� > 30% � ������ ���������
   if (IsTheBoss or MarshMode) and (AForceDown > 30) and (TopPos + HeightOfFigure(CurFigure) <= Rows) then
    begin
     //������� ������ ��� �� ���� ������� ����
     for R:=Rows downto 2 do
      for C:=1 to Cols do MoveTet[R, C]:=MoveTet[R - 1, C];
     for C:=1 to Cols do MoveTet[1, C].State:=bsEmpty;
     //��������� ������
     Inc(TopPos);
    end;
   //���� ��� ���� ���� "���� �����������", ���� ��� "������ ������������"
   if IsTheBoss then Sound.Play(15) else Sound.Play(5);
   //���� ������ ������� ����
   if AForceDown > 30 then
    begin
     //���� ��� ���� - ��� 1 ���� ��� ��� 2
     if IsTheBoss then Boom(6, 400) else Boom(3, 300);
    end
   else //���� �� ���
    begin
     //���� ��� ���� - ��� 1 ���� ��� ��� 2
     if IsTheBoss then Boom(3, 300) else Boom(2, 100);
    end;
  end;
end;

procedure TTetrisGame.ExecutingDelete;
var Dels:Byte;
begin
 //������� � �������� ���-�� ������ ��� ��������� �����
 Dels:=DeleteFilled(Rows);
 //���� ������� ��������� �����
 if Dels > 0 then
  begin
   //�������� ���-�� ��������� �����
   LinesUp(Dels);
   //�������� ���� �� ������� ���-�� ����� * (������� + �������� + (0..14))
   UpScore(Lines * (FLevel + GetSpeed + Random(15)));
  end;
end;

procedure TTetrisGame.StepLeft;
var C, R:Byte;
    ABoom:Boolean;
begin
 //���� �� ���� ���� = �������
 if GameState <> gsPlay then Exit;
 //���� �������� ��� ���� �������� ������ - �������
 if IsWait or IsCreating then Exit;
 //������ "���" - ���
 ABoom:=False;
 //� ������ ������ ��������� ����������� �� �������� ����� � ������� � ��������� ���� ���-�� ������
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
 //���� �� �������� ������ (��������)
 for R:=TopPos to TopPos + (GlSize - 1) do
  begin
   //���� ������ ����� �� ������� - ��������� ��������
   if R > Rows then Break;
   //���� �� �������� ������
   for C:=LeftPos to LeftPos + (GlSize - 1) do
    begin
     //��������� �������
     if (C < 1) or (C > Cols) then Continue;
     //� ���� �� �����
     if MoveTet[R, C].State <> bsEmpty then
      begin
       //������� ����� �������������� � ��������
       MoveTet[R, C - 1]:=MoveTet[R, C];
       //������� ����������
       MoveTet[R, C].State:=bsEmpty;
      end;
    end;
  end;
 //���� �� ����� �������� ��������� ������������� ������� ���, ������ ���
 if ABoom then
  begin
   //���� "������ �� �����"
   Sound.Play(7);
   //���� ������ ������� ����� ������ ���
   if GameKeys[FKeyIDLeft].ForceDown > 0 then Boom(2, 50);
  end;
 //��������� ��������� �� X
 Dec(LeftPos);
 //��������� ����
 Shade.Update;
end;

procedure TTetrisGame.StepRight;
var C, R:Byte;
    ABoom:Boolean;
begin
 //���������� �������� ����� (������� ���-��� ���� + �� -)
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
 //���� ������ ������� ���� - �������
 if GameKeys[FKeyIDDown].ForceDown > 0 then Exit;
 //���� ��������� ���������� - �������
 if ZeroGravity then Exit;
 //������� ������ ����
 try
  StepDown;
 except
  MessageBox(0, '', '������!', MB_OK);
 end;
end;

procedure TTetrisGame.TimerUpValuesTimer(Sender: TObject);
begin
 //��������� ��������� �������� (���� � ������) (��� ��������)
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
 //��������� ���
 if FBoom > 0 then Dec(FBoom);
 //���� �����, ����������� �������� ���������
 if TimerBoom.Interval > 10 then TimerBoom.Interval:=TimerBoom.Interval - 10;
 //���� "������" ������ 1
 if FBoom <= 1 then
  begin
   //"������" ��������
   DoBoom:=False;
   //������������� ������ "������"
   TimerBoom.Enabled:=False;
   //��������� �������� - 0
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
   //����������� ��� ����� ����
   Inc(BGStep);
   //���� ��������� ���
   if BGStep >= Count then
    begin
     //������������� ������
     TimerBG.Enabled:=False;
     //�������
     Exit;
    end;
   //���� �� "�������" ������� �������� �������
   for Y:= 0 to BackGroundDraw.Height - 1 do
    begin
     //������� �������� �������
     P0:=BackGroundDraw.ScanLine[Y];
     //������� ������� �������
     P1:=BackgroundOne.ScanLine[Y];
     //������� ������� �������
     P2:=BackgroundTwo.ScanLine[Y];
     //������ ��������� "�����" ������� � ������� ������� � ������� � ����������� �� ���� BGStep
     for x:=0 to (BackgroundDraw.Width * 3) - 1 do P0^[X]:=Round((P1^[X] * (Count - BGStep) + P2^[x] * BGStep) / Count);
    end;
  end;
end;

procedure TTetrisGame.TimerBonusTimer(Sender: TObject);
begin
 if not AlreadyShownButtons then ShowButtons;
 //���� ������ 0 �� ������������ � �� ���� �� ���� �������� - ����������
 if (GameState in [gsNone, gsStop, gsPause]) and (not ArrayOfPanels[0].Visible) and (not ArrayOfPanels[0].WasShown) then ArrayOfPanels[0].Show;
 //���� ���� ���� - ��������� ����� �������� ���������
 if (GameState = gsPlay) and (not IsWait) then StepDownBonuses;
 //����������� ���-�� ������������ ������
 FPS:=FFPS;
 //�������� ������� ������
 FFPS:=0;
end;

procedure TTetrisGame.TimerAnalysisTimer(Sender: TObject);
begin
 if GameState <> gsPlay then Exit;
 MoveMouse;
 if CalcBrokenBonus > BadGameBonusCount then
  begin
   Hint.Show('���, ���', '', '�� �������!|������� �����|������������|�������.', 20, 0);
   ExecuteRandomBonus(tbBad);
  end;
end;

procedure TTetrisGame.TimerAnimateFramesTimer(Sender: TObject);
begin
 //��������� ���� ��������
 Bitmaps.NextFrame;
end;

procedure TTetrisGame.Draw;
var C:Byte;
begin
 //���� ���� ������������� - �������
 if Creating then Exit;
 //���� ��� ���� ��������� - �������
 if Drawing then Exit;
 //���� ����� �� ������ - �������
 //if not Assigned(DrawBMP) then Exit;
 //�������� ������ - ������ � ����������� �������
 //FCanvas:=TDirect2DCanvas.Create(FDrawCanvas, Rect(0, 0, FieldWidth, FieldHeight));
 with Canvas, Bitmaps do
  begin
   //�������� ���������
   Drawing:=True;
   //BeginDraw;
   //��������� ��������� ���� � ��������� ��������
   //���� �� ������������ �������������� ����������
   if not ForcedCoordinates then
    begin
     //���� "������"
     if DoBoom then
      begin
       //������� ��������� ���� ���������� ���� (�� ����� ������ ��������)
       SLeft:=SWidth + Random(FBoom);
       STop:=SWidth + Random(FBoom);
      end
     else //���� �� ���
      begin
       //�������� ���� (����� - ������ �������� ������, ������ - ������ �������� ������)
       SLeft:=SWidth;
       STop:=SWidth;
      end;
    end
   else //���� �� ������������ �������������� ���������
    begin
     //������������� ������������� ����������
     SLeft:=ForcedCoord.X;
     STop:=ForcedCoord.Y;
    end;

   /////////////////////////////////////////////////////////////////////////////.............
   //� ����������� �� ��������� ���� ������ ������� �� ������������� � � ������������ �������
   /////////////////////////////////////////////////////////////////////////////.............

   case GameState of
    gsNone:
     begin
      //������� �������
      Redraw.Background;
      //������ ���. � ������
      Redraw.InfoPanels;
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
      //����������
      Draw(SLeft, STop, Poly);
      //�������������� ���.
      Redraw.Stared;
     end;
    gsPause:
     begin
      //������� �������
      Redraw.Background;
      Redraw.Scale(SLeft);
      //����� �������� ���� � �����������
      Redraw.Field(SLeft, STop);
      //������ ���. � ������
      Redraw.InfoPanels;
      //������ � ���. ��������
      Redraw.LastBonuses(SLeft);
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
      //����������
      Draw(SLeft, STop, Poly);
      //�����
      if FPauseTutorial then Draw(0, TutorialPos, TutorialImg)
      else Draw(21, 94, Pause);
     end;
    gsPlay:
     begin
      //������� �������
      Redraw.Background;
      Redraw.Scale(SLeft);
      //����� �������� ���� � �����������
      Redraw.Field(SLeft, STop);
      //���� ����������� �����-����, ������ ����������� ������� ������
      if ExecutingBonus then if Length(ArrayOfBonuses) > 0 then for C:= 0 to Length(ArrayOfBonuses) - 1 do ArrayOfBonuses[C].PaintGraphics;
      //��������� ����������� ���������
      for C:=1 to Rows do if Assigned(ArrayOfClears[C]) then ArrayOfClears[C].Paint;
      //������ ���. � ������
      Redraw.InfoPanels;
      //������ � ���. ��������
      Redraw.LastBonuses(SLeft);
      //���� ����� ��������� ���� - ���������
      {if NeedShot then
       begin
        //��������� ��������� ���� � BMP
        Bitmaps.Saved.Canvas.Draw(0, 0, DrawBMP);
        NeedShot:=False;
       end; }
      //���� ��������� ��������� ������������� - ������ ���������� � ���. � ���������
      if DoDrawFigure <> dtNotWork then Draw(Bitmaps.FLeft, 0, EditInfo);
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
     end;
    gsStop:
     begin
      //������� �������
      Redraw.Background;
      //������ ���. � ������
      Redraw.InfoPanels;
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
      //����
      Redraw.Field(SLeft, STop);
      //����������
      Draw(SLeft, STop, Poly);
      //����������
      Redraw.Statistics;
      //����� ����
      Redraw.GameOver;
      if FEditBoxActive then Redraw.EditBox;
     end;
    gsDrawFigure:
     begin
      //������ ����������� ������ ���� (����� �� ��������� ���������)
      Redraw.SavedBG;
      //���� ��������� ��������� ������������� - ������ ���������� � ���. � ���������
      if DoDrawFigure <> dtNotWork then Draw(Bitmaps.FLeft, 0, EditInfo);
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
     end;
    gsShutdown:
     begin
      //������� �������
      Redraw.Background;
      //������ ���. � ������
      Redraw.InfoPanels;
      //���������� � ��������� ������
      Redraw.NextFigure(340, SHeight);
      //����
      Redraw.Field(SLeft, STop);
      //����������
      Draw(SLeft, STop, Poly);
      //����� ����
      Redraw.Save;
     end;
   end;

   /////////////////////////////////////////////////////////////////////////////
   //����������, ���. ������ � ��������
   /////////////////////////////////////////////////////////////////////////////

   //���� ����� �������� ��������� - ������
   if DrawAni then
    begin
     if PtInRect(RectForChangeMode, Mouse) then
      StretchDraw(Rect(323, 188, 326+ Animations[AniID, AniNum].Width, 191 + Animations[AniID, AniNum].Height), Animations[AniID, AniNum])
     else
      StretchDraw(Rect(325, 190, 325 + Animations[AniID, AniNum].Width, 190 + Animations[AniID, AniNum].Height), Animations[AniID, AniNum])
     //Draw(325, 190, Animations[AniID, AniNum]);
    end;
   //������ ����������
   if Length(ArrayOfButtons) > 0 then for C:=0 to Length(ArrayOfButtons) - 1 do ArrayOfButtons[C].Paint;
   //���. ���. ������
   if Length(ArrayOfPanels) > 0 then for C:=0 to Length(ArrayOfPanels) - 1 do ArrayOfPanels[C].Paint;
   //���������
   if Self.Hint.Visible then Self.Hint.Paint;

   /////////////////////////////////////////////////////////////////////////////
   //������ � ���������� ����������
   /////////////////////////////////////////////////////////////////////////////

   //TextOut(5, 5, Format('�������� ����������: %d ����.', [GetTickCount - TM]));
   //���� ������� ��������
   if DebugEnabled then
    begin
     //������ ������� ������� ��������
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
     //����� ��� ���
     Font.Assign(FontTextAutor);
     //���������� ���
     TextOut(5, 5, Format('FPS: %d', [FPS]));
     TextOut(5, 15, Format('FKeyIDUP: %d', [GameKeys[FKeyIDUP].ForceDown]));
     TextOut(5, 25, Format('FKeyIDDown: %d', [GameKeys[FKeyIDDown].ForceDown]));
     TextOut(5, 35, Format('FKeyIDLeft: %d', [GameKeys[FKeyIDLeft].ForceDown]));
     TextOut(5, 45, Format('FKeyIDRight: %d', [GameKeys[FKeyIDRight].ForceDown]));

    end;
   TextOut(5, 5, Format('FPS: %d', [FPS]));
   //������
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
   //����� ���������
   /////////////////////////////////////////////////////////////////////////////


   //��������� ������
   //EndDraw;
   //FDrawCanvas.CopyRect(FDrawCanvas.ClipRect, DrawBMP.Canvas, FDrawCanvas.ClipRect);
   //FDrawCanvas.StretchDraw(FDrawCanvas.ClipRect, DrawBMP);
   BitBlt(FDrawCanvas.Handle, 0, 0, FDrawCanvas.ClipRect.Width, FDrawCanvas.ClipRect.Height, DrawBMP.Canvas.Handle, 0, 0, SRCCOPY);
   //FDrawCanvas.Draw(0, 0, DrawBMP);
   //����������� ���-�� ������������ ������
   Inc(FFPS);
  end;
 //��������� ��������
 Drawing:=False;
end;

//////////////////////////////////////TSound////////////////////////////////////

function TSound.GetVolume:Byte;
var Vol:single;
begin
 //������ ��������� ������
 BASS_ChannelGetAttribute(Sounds[0], BASS_ATTRIB_VOL, Vol);
 //��������� � ���������� ���
 Result:=Round(Vol * 100);
end;

procedure TSound.SetVolume(Value:Byte);
var i:Byte;
begin
 BASS_SetVolume(Value/100);
 //��������� ������� ���������
 if Value > 100 then Value:=100;
 //������������� ��������� ��� ��� �������
 for i:=0 to Length(Sounds) - 1 do
  BASS_ChannelSetAttribute(Sounds[i], BASS_ATTRIB_VOL, Value/100);
end;

function TSound.AddStream(FileName:TFileName; Channel:Boolean):Word;
begin
 //��������� �����
 SetLength(Sounds, Length(Sounds) + 1);
 //������� �����
 Sounds[Length(Sounds) - 1]:=CreateStream(FileName, Channel);
 //��������� - ������� � �������
 Result:=Length(Sounds) - 1;
end;

function TSound.CreateStream(FileName:string; Channel:Boolean):Cardinal;
begin
 //���� ������, ������� �������� �������
 if Channel then Result:=BASS_SampleLoad(False, PAnsiChar(AnsiString(FileName)), 0, 0, 3, BASS_SAMPLE_OVER_POS)
 //� ��������� ������ �������� �����
 else Result:=BASS_StreamCreateFile(False, PAnsiChar(AnsiString(FileName)), 0, 0, 0);
end;

constructor TSound.Create;
begin
 inherited Create;
 //������� ������ �� ����������� ������
 //�������� ����
 FOwner:=AOwner;
 //������� - ����� � ���������
 Bitmaps:=AOwner.Bitmaps;
 //���-�� ������ - 0
 SetLength(Sounds, 0);
 //�������������� ����
 FEnable:=BASS_Init(-1, 44100, 0, Application.Handle, nil) and (HIWORD(BASS_GetVersion) = BASSVERSION);
 //���� ���� �� ��������������� - ������� (��� ������ ��������� ������ ������ � �� ��� ����� ������������ �� ���������)
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
 //����������� ��������� - 30
 Volume:=30;
end;

procedure TSound.Stop(MSTREAM:Cardinal);
begin
 //������������� ����� MSTREAM
 BASS_ChannelStop(MSTREAM);
end;

procedure TSound.Stop(ID:Byte);
begin
 //���� ��� ����� - �������
 if not Enable then Exit;
 //���� �� ��� ��� �����  - �������
 if ID < 100 then Exit;
 //�������� �� ��������� ������
 BASS_ChannelStop(Sounds[ID - 100]);
end;

procedure TSound.Play(ID:Byte);
begin
 //������������� ������ 100 �������� �����, ������ - �������� �������
 //����� ����� ���������� � �������������� ������ ��� ��� ����������
 //������� ����� ��������������� �� ������ � � �� ����������
 //��� ������������ ����� ��� ����� - ���������� 100 � ID-� �����

 //�������� ����� �������� �������� 
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
 //���� ��� ����� - �������
 if not Enable then Exit;
 //���� ������ ���� ����� 100 - ��������� �����
 if ID >= 100 then BASS_ChannelPlay(Sounds[ID - 100], True)
 //���� �� ���, ��������� ���� � ���. �����
 else BASS_ChannelPlay(BASS_SampleGetChannel(Sounds[ID], False), False);
end;

procedure TSound.PlaySound_2(MSTREAM:Cardinal);
begin
 //���� ��� ����� - �������
 if not Enable then Exit;
 //�������� �� ������������ ������ � ������������
 BASS_ChannelPlay(MSTREAM, True);
end;

procedure TSound.PlaySound(MSTREAM:Cardinal);
begin
 //���� ��� ����� - �������
 if not Enable then Exit;
 //�������� �� ����������� ������������ �������
 BASS_ChannelPlay(BASS_SampleGetChannel(MSTREAM, False), True);
end;

///////////////////////////////////TBitmaps/////////////////////////////////////

function TBitmaps.GetAnimate:Byte;
begin
 //������� �� ��������
 Result:=AniID;
end;

procedure TBitmaps.SetAnimate(Value:Byte);
begin
 //���� �������� ���� ����� - �������
 if GetAnimate = Value then Exit;
 //��������� ����� ��������
 AniID:=Value;
 //����� ����� �� ������
 AniNum:=1;
end;

procedure TBitmaps.NextFrame;
begin
 ///////////////////////////////////////
 //��������� ���� �������
 Inc(CurNum);
 //���� �� ��������� ��� ����� �� ������ - ���������� �� ������
 if CurNum >= Length(Cursor) then CurNum:=0;
 ///////////////////////////////////////
 ///////////////////////////////////////
 //����������� ���� �������� ��������� ��������
 Inc(BonusAni);
 //���� �� ��������� ��� ����� �� ������ - ���������� �� ������
 if BonusAni >= Length(AniBonus) then BonusAni:=0;
 ///////////////////////////////////////
 //////////////////////////////////////
 //����������� ���� �������� ��������� ��������
 Inc(BonusAniTime);
 //���� �� ��������� ��� ����� �� ������ - ���������� �� ������
 if BonusAniTime >= Length(AniBonusTime) then BonusAniTime:=0;
 //////////////////////////////////////
 ///////////////////////////////////////
 //����������� ���� �������� ���������
 Inc(AniNum);
 //���� �� ��������� ��� ����� �� ������
 if AniNum > 8 then
  begin
   //���������� �� ������
   AniNum:=1;
   //�������� ����������� (�����������) ��������
   AniID:=1;
  end;
 //////////////////////////////////////
end;

procedure TBitmaps.LoadFigures(FArray:TArrayOfFigure; SW, SH:Byte);
var i, ACount:Byte;
    DLL:Cardinal;
begin
 //���� ����� ������ ��� 15 ��������� ������, ���� �� ��� ��������� 15
 ACount:=Owner.Max(Length(FArray), GlLvls);
 //������ ����. ��������� ����� ����� ���-�� ������. ���������
 DLL:=LoadLibrary(PChar(FPath + TetDll));
 SetLength(Figures, ACount);
 for i:=0 to ACount - 1 do
  begin
   //������� ����. ������
   Figures[i]:=TPNGObject.Create;
   //���� ���� ���� - ���������
   try
    Figures[i].LoadFromResourceName(DLL, 'Figure_'+IntToStr(i + 1));
   except
   end;
   //���� ������ ����
   if Figures[i].Empty then
    begin
     //������ ������ ����
     Figures[i]:=TPNGObject.CreateBlank(COLOR_RGB, 16, SW + 1, SH + 1);
     //���� �����
     Figures[i].Canvas.Pen.Color:=$00949494;
     //��������� ���� �������
     Figures[i].Canvas.Brush.Color:=RGB(Random(255), Random(255), Random(255));
     //������ ������������� �� ���� ���. ������
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
 //������ � ����������� ��������
 FOwner:=AOwner;
 FPath:=Path;
 AniNum:=1;
 AniID:=1;
 BGStep:=1;
 DLL:=LoadLibrary(PChar(FPath + TetDll));
 TMP:=TPNGObject.Create;
 TMP.LoadFromResourceName(DLL, 'FLS9');
 //�������� ������
 DrawAni:=True;
 //�������� �������������� ���������
 if TMP.Width = 880 then
  begin
   //TMP:=CreatePNG(Path + 'FLS9.png');
   for i:=0 to 9 do
    for j:=0 to 7 do Animations[i + 1, j + 1]:=CreateFrom(j * 110, i * 128, 110, 128, TMP);
  end
  //���� ���, �������������� ��������� - ���
 else DrawAni:=False;
 TMP.LoadFromResourceName(DLL, 'sbonus');
 //�������� ������ ������
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
 //�������� ������ ������ � ��������
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
 //�������� �������
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

 //�������� ������� ��������
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

 //��������� �������� ����������� ��������
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
 //������ ���� �� ����������� ����
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
 //��������� ������� (������ ��� ������ - ������)
 FBlink:=Value;
 //���� ����� ���� �� ������
 if not FBlink then
  begin
   //��������������� �������� ������
   Over:=FOver;
   Normal:=FNormal;
  end;
end;

procedure TExtButton.SetEnable(Value:Boolean);
begin
 FEnable:=Value;
 //� ����������� �� ��������� ������ ���������� ������
 case FButtonState of
  bsNormal,
  bsDown:Font.Style:=[];
  //���� ���� �����, ���� ������ �������� - ���� - ������ � ������� ���� �� ��������
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
 //����������� ������� +\- 2 �������
 //���������� ������ - ���� �������
 Result:=CreateRectRgn(0, 0, Image.Width, Image.Height);
 //���� �� �����-�� ������� ������� ������� ������ 0 - �������
 if (Image.Width <= 0) or (Image.Height <= 0) then Exit;
 //����������� ���. � ����. �������� ������ ��� �������� ������ � ������
 MinLeft:=Image.Width;
 MaxLeft:=0;
 MinTop:=Image.Height;
 MaxTop:=0;
 //���� �� �������
 for y:= 0 to Image.Height - 1 do
  begin
   //������� ���� - ���� ������� �������
   CurrentColor:=Image.Canvas.Pixels[0, y];
   //���-�� �������� � ��� - 1
   ConsecutivePixels:=1;
   //���� ������ ...
   for x:= 0 to Image.Width - 1 do
    begin
     //��������� ����� ������, ����� �������, ����� ����� � ����� ������ ����� �������
     if Image.Canvas.Pixels[x, y] <> clWhite then
      begin
       if MinLeft > x then MinLeft:=x;
       if MinTop  > y then MinTop :=y;
       if MaxLeft < x then MaxLeft:=x;
       if MaxTop  < y then MaxTop :=y;
      end;
     //���� �������
     CurrentPixel:=Image.Canvas.Pixels[x, y];
     //���� ���� ��� ��, ��� � ������ - ����������� ��� ��������
     if CurrentColor = CurrentPixel then Inc(ConsecutivePixels)
     else //���� �� ����� �� ���������
      begin
       //���� ���� ����� - ������ ������ ��������
       if CurrentColor = clWhite then
        begin
         //����������� (��������) ��� ��������� ������ � �������� ���������� ��������� ����� ��������
         CombineRgn(Result, Result, CreateRectRgn(x - ConsecutivePixels, y, x, y + 1), RGN_DIFF);
        end;
       //������� ���� - ���� �������� �������
       CurrentColor:=CurrentPixel;
       //���-�� �������� � ��� - 1
       ConsecutivePixels:=1;
      end;
    end;
   //���� ���. ���� - ����� � ���-�� �������� � ��� ������ 0
   if (CurrentColor = clWhite) and (ConsecutivePixels > 0) then
    begin
     //����������� (��������) ��� ��������� ������ � �������� ���������� ��������� ����� �������� �� ���� ������ �������
     CombineRgn(Result, Result, CreateRectRgn((Image.Width - 1) - ConsecutivePixels, y, Image.Width - 1, y + 1), RGN_DIFF);
    end;
  end;
 FRect:=Rect(MinLeft, MinTop, MaxLeft, MaxTop);
 //������ � ...
 Width:=Abs(MinLeft - MaxLeft);
 //������ �������
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
 //������� �������
 ProgramPath:=ExtractFilePath(ParamStr(0));

end.
