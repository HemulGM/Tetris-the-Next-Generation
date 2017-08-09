program Tetris;

{%File 'Ñapacities.txt'}
{%File 'Log.docx'}

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  TheTetris in 'TheTetris.pas',
  Load in 'Load.pas' {FormLoading},
  WorkWithRect in 'WorkWithRect.pas',
  PNGWork in 'PNGWork.pas';

{$R Tetris.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
