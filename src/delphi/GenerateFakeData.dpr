program GenerateFakeData;

uses
  Vcl.Forms,
  uGenerateFakeDataForm in 'src\uGenerateFakeDataForm.pas' {GenerateFakeDataForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGenerateFakeDataForm, GenerateFakeDataForm);
  Application.Run;
end.
