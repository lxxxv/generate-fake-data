program GenerateFakeData;

uses
  Vcl.Forms,
  uGenerateFakeDataForm in 'src\uGenerateFakeDataForm.pas' {GenerateFakeDataForm},
  uhandler_thread in 'src\uhandler_thread.pas',
  uoverridedic in 'src\uoverridedic.pas',
  uParentForm in 'src\uParentForm.pas' {ParentForm},
  uOperator in 'src\uOperator.pas',
  uTestForm in 'src\uTestForm.pas' {TestForm},
  uTypeRepository in 'src\uTypeRepository.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;

  {$IFDEF  TEST}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
  {$ELSE}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGenerateFakeDataForm, GenerateFakeDataForm);
  Application.Run;
  {$ENDIF}
end.
