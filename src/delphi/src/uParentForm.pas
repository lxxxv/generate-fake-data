unit uParentForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  uhandler_thread, uOperator, uTypeRepository;

const
  RESULT_FILENAME : string = 'result.datasets';

type
  TParentForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Fprogressposition : longint;
    Fmaxrow           : longint;
    FfileInfolist     : TfileInfoObjectList;
  public
    { Public declarations }

    property fileInfolist     : TfileInfoObjectList read FfileInfolist;

    property progressposition : longint             read Fprogressposition write Fprogressposition;
    property maxrow           : longint             read Fmaxrow           write Fmaxrow;
  end;

var
  ParentForm: TParentForm;

implementation

{$R *.dfm}

procedure TParentForm.FormCreate(Sender: TObject);
begin
  self.Fprogressposition        := 0;
  self.Fmaxrow                  := 0;
  self.FfileInfolist            := TfileInfoObjectList.create;
end;

procedure TParentForm.FormDestroy(Sender: TObject);
begin
  self.FfileInfolist.free;
end;

end.
