program ParamTetris;

uses
  Forms,
  PMain in 'PMain.pas' {FormMain};

{$R ParamTetris.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
