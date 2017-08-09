unit PMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, pngimage, ExtCtrls, StdCtrls, Spin;

type
  TFormMain = class(TForm)
    XPManifest: TXPManifest;
    SpinEditFPS: TSpinEdit;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    SpinEditLines: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Bevel3: TBevel;
    Label5: TLabel;
    EditSimple: TEdit;
    CheckBoxDebug: TCheckBox;
    Bevel4: TBevel;
    Label6: TLabel;
    CheckBoxSound: TCheckBox;
    Bevel5: TBevel;
    ImageTopFooter: TImage;
    Label7: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    ButtonDefault: TButton;
    ButtonReset: TButton;
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonDefaultClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure SpinEditFPSChange(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
  private
    { Private declarations }
  public
   procedure SetDefault;
   procedure LoadSets;
   procedure SaveSets;
  end;

var
  FormMain: TFormMain;

implementation
 uses IniFiles;

{$R *.dfm}

procedure TFormMain.ButtonCancelClick(Sender: TObject);
begin
 if ButtonApply.Enabled then
  case MessageBox(Handle, 'Сохранить изменения?', '', MB_ICONINFORMATION or MB_YESNOCANCEL) of
   ID_CANCEL:Exit;
   ID_YES:SaveSets;
  end;
 Application.Terminate;
end;

procedure TFormMain.SetDefault;
begin
 SpinEditFPS.Value:=180;
 SpinEditLines.Value:=20;
 CheckBoxDebug.Checked:=False;
 CheckBoxSound.Checked:=True;
 EditSimple.Text:='';
 ButtonApply.Enabled:=True;
 ButtonReset.Enabled:=True;
end;

procedure TFormMain.LoadSets;
var Ini:TIniFile;
begin
 if not FileExists(ExtractFilePath(ParamStr(0)) + 'Config.ini') then
  begin
   SetDefault;
   Exit;
  end;
 Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
 EditSimple.Text:=Ini.ReadString('Tetris', 'Password', '');
 SpinEditFPS.Value:=Ini.ReadInteger('Tetris', 'FPS', 180);
 SpinEditLines.Value:=Ini.ReadInteger('Tetris', 'LinesForLevel', 20);
 CheckBoxDebug.Checked:=Ini.ReadBool('Tetris', 'Debug', False);
 CheckBoxSound.Checked:=Ini.ReadBool('Tetris', 'Sound', True);
 if (SpinEditFPS.Value < 20) or (SpinEditFPS.Value > 1000) then SpinEditFPS.Value:=180;
 if (SpinEditLines.Value < 20) or (SpinEditLines.Value > 1000) then SpinEditLines.Value:=20;
 Ini.Free;
 ButtonApply.Enabled:=False;
 ButtonReset.Enabled:=False;
end;

procedure TFormMain.SaveSets;
var Ini:TIniFile;
begin
 if not FileExists(ExtractFilePath(ParamStr(0)) + 'Config.ini') then
  begin
   try
    FileClose(FileCreate(ExtractFilePath(ParamStr(0)) + 'Config.ini'));
   except
    MessageBox(Application.Handle, 'Ошибка создания файла.', '', MB_ICONSTOP or MB_OK);
    Exit;
   end;
  end;
 Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
 Ini.WriteString('Tetris', 'Password', EditSimple.Text);
 Ini.WriteInteger('Tetris', 'FPS', SpinEditFPS.Value);
 Ini.WriteInteger('Tetris', 'LinesForLevel', SpinEditLines.Value);
 Ini.WriteBool('Tetris', 'Debug', CheckBoxDebug.Checked);
 Ini.WriteBool('Tetris', 'Sound', CheckBoxSound.Checked);
 Ini.Free;
 ButtonApply.Enabled:=False;
 ButtonReset.Enabled:=False;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 LoadSets;
end;

procedure TFormMain.ButtonDefaultClick(Sender: TObject);
begin
 if MessageBox(Handle, 'Вы уверены, что хотите установить параметры поумолчанию?', '', MB_ICONQUESTION or MB_YESNO) <> ID_YES then Exit;
 SetDefault;
end;

procedure TFormMain.ButtonApplyClick(Sender: TObject);
begin
 SaveSets;
end;

procedure TFormMain.SpinEditFPSChange(Sender: TObject);
begin
 ButtonApply.Enabled:=True;
 ButtonReset.Enabled:=True;
end;

procedure TFormMain.ButtonResetClick(Sender: TObject);
begin
 if MessageBox(Handle, 'Вы уверены, что хотите сбросить параметры?', '', MB_ICONQUESTION or MB_YESNO) <> ID_YES then Exit;
 LoadSets;
end;

end.
