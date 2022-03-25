program GenerateFakeData;

uses
  Vcl.Forms,
  uGenerateFakeDataForm in 'src\uGenerateFakeDataForm.pas' {GenerateFakeDataForm},
  uhandler_thread in 'src\uhandler_thread.pas',
  uoverridedic in 'src\uoverridedic.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGenerateFakeDataForm, GenerateFakeDataForm);
  Application.Run;
end.
