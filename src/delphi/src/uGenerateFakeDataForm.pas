unit uGenerateFakeDataForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TGenerateFakeDataForm = class(TForm)
    btnExecute: TButton;
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GenerateFakeDataForm: TGenerateFakeDataForm;

implementation

{$R *.dfm}

procedure TGenerateFakeDataForm.btnExecuteClick(Sender: TObject);
var
  pFileOpenDialog : TFileOpenDialog;
  pFileTypeItem : TFileTypeItem;
begin
  pFileOpenDialog := TFileOpenDialog.Create(nil);
  try
    pFileOpenDialog.Title := 'dataset';
    pFileOpenDialog.Options := pFileOpenDialog.Options + [fdoAllowMultiSelect];
    pFileOpenDialog.DefaultFolder := ExtractFilePath(ParamStr(0));
    pFileTypeItem := pFileOpenDialog.FileTypes.Add;
    pFileTypeItem.DisplayName := 'dataset';
    pFileTypeItem.FileMask := '*.'+pFileTypeItem.DisplayName;
    if pFileOpenDialog.Execute then
    begin

    end;
  finally
    pFileOpenDialog.free;
  end;
end;

end.
