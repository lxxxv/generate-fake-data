unit uGenerateFakeDataForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;


const
  RESULT_FILENAME : string = 'result.datasets';

type
  Texceptcheckmode = (eckselctfile, ectexecute);
  Texceptcheckmodes = set of Texceptcheckmode;
  Tfileformat = (ffjson);
  TfileType   = (ftline, ftarray);


  TGenerateFakeDataForm = class(TForm)
    btnExecute: TButton;
    edtresultfolderpath: TEdit;
    lblResultFolderPath: TLabel;
    lblRows: TLabel;
    lblFormat: TLabel;
    btnFileSelect: TButton;
    cbFormat: TComboBox;
    edtrows: TEdit;
    lblType: TLabel;
    cbType: TComboBox;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFileSelectClick(Sender: TObject);
    procedure cbFormatKeyPress(Sender: TObject; var Key: Char);
    procedure edtrowsKeyPress(Sender: TObject; var Key: Char);
    procedure cbTypeKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    Ffileselectlist : TStringList;
    Fmaxrow         : int64;
    function execeptcheck(_exceptcheckmodes : Texceptcheckmodes): boolean;
    function selectfiles: boolean;
    function execute: boolean;
    function checkmaxows: boolean;
  public
    { Public declarations }
    property fileselectlist : TStringList read Ffileselectlist;
  end;

var
  GenerateFakeDataForm: TGenerateFakeDataForm;

implementation

{$R *.dfm}

procedure TGenerateFakeDataForm.btnExecuteClick(Sender: TObject);
begin
  if self.execeptcheck([eckselctfile, ectexecute]) then
  begin
    self.execute;
  end;
end;

procedure TGenerateFakeDataForm.btnFileSelectClick(Sender: TObject);
begin
  if self.execeptcheck([eckselctfile]) then
  begin
    self.selectfiles;
    self.checkmaxows;
  end;
end;

procedure TGenerateFakeDataForm.cbFormatKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TGenerateFakeDataForm.cbTypeKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

function TGenerateFakeDataForm.checkmaxows: boolean;
var
  idx : longint;
  pstringlist : tstringlist;
begin
  idx := 0;
  while idx < self.Ffileselectlist.Count do
  begin
    pstringlist := tstringlist.Create;
    pstringlist.LoadFromFile(self.Ffileselectlist.Strings[idx], Tencoding.UTF8);
    if strtoint(self.edtrows.Text) <= pstringlist.Count then
    begin
      self.edtrows.Text := inttostr(pstringlist.Count);
      self.Fmaxrow      := pstringlist.Count;
    end;
    pstringlist.free;
    inc(idx);
  end;
end;

procedure TGenerateFakeDataForm.edtrowsKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key in ['0'..'9', #3, #8, #10, #13, #22]) then
  begin
    if (Key in [#8]) then
    begin
      if length(self.edtrows.Text) = 1 then
      begin
        Key := #0;
      end;
    end else
    begin
      if (strtointdef(self.edtrows.Text + Key, self.Fmaxrow) < self.Fmaxrow) then
      begin

      end else
      begin
        Key := #0;
      end;
    end;
  end else
  begin
    Key := #0;
  end;
end;

function TGenerateFakeDataForm.execeptcheck(_exceptcheckmodes : Texceptcheckmodes): boolean;
begin
  result := false;

  if eckselctfile in _exceptcheckmodes  then
  begin
    result := false;

    if directoryexists(self.edtresultfolderpath.Text) then
    begin
      result := true;
    end else
    begin
      //
      // 결과 파일 저장할 디렉토리 없음
      //
      Messagebox(self.handle, '결과 파일을 저장할 디렉토리가 정상적이지 않습니다.', pchar(self.Caption), MB_OK);
      exit;
    end;
  end;

  if ectexecute in _exceptcheckmodes  then
  begin
    result := false;

    if self.Ffileselectlist.Count = 0 then
    begin
      Messagebox(self.Handle, '조합할 데이터의 원본 dataset을 선택하여 주십시오.', pchar(self.Caption), MB_OK);
      exit;
    end else
    begin
      result := true;
    end;
  end;
end;

function TGenerateFakeDataForm.execute: boolean;
begin
  //
  // 변환 시작.
  //
  TThread.CreateAnonymousThread
  (
    procedure
    var
      idx : longint;
      pschemas : tstringlist;
      psavefilelist : tstringlist;

      fileformat : Tfileformat;
      fileType   : TfileType;

      makejson : tproc;
    begin
      makejson := procedure ()
      var
        idxsub : longint;
      begin
        case fileType of
          ftline: ;
          ftarray: psavefilelist.Add('[');
        end;

        idxsub := 0;
        while idx < self.Ffileselectlist.Count do
        begin
          inc(idxsub);
        end;

        case fileType of
          ftline: ;
          ftarray: psavefilelist.Add(']');
        end;
      end;


      //
      // json 키에 사용할 값을 가지고 온다.
      // 파일명을 스키마로 한다.
      //
      pschemas := tstringlist.create;
      psavefilelist := tstringlist.create;
      try
        idx := 0;
        while idx < self.Ffileselectlist.Count do
        begin
          pschemas.Add(StringReplace(ExtractFileName(self.Ffileselectlist.Strings[idx]), '.dataset', '', [rfReplaceAll]));
          inc(idx);
        end;

        //
        //
        //
        fileformat := Tfileformat(self.cbFormat.ItemIndex);
        fileType   := TfileType(self.cbType.ItemIndex);

        case fileformat of
          ffjson: makejson;
        end;

        psavefilelist.SaveToFile(self.edtresultfolderpath.Text + RESULT_FILENAME, TEncoding.UTF8);
      finally
        psavefilelist.free;
        pschemas.free;
      end;
    end
  ).Start;
end;

procedure TGenerateFakeDataForm.FormCreate(Sender: TObject);
begin
  self.Ffileselectlist          := TStringList.Create;
  self.edtresultfolderpath.Text := extractfilepath(paramstr(0));
  self.Fmaxrow                  := 0;
  self.edtrows.Text             := inttostr(self.Fmaxrow);
end;

procedure TGenerateFakeDataForm.FormDestroy(Sender: TObject);
begin
  self.Ffileselectlist.free;
end;

function TGenerateFakeDataForm.selectfiles: boolean;
var
  pFileOpenDialog : TFileOpenDialog;
  pFileTypeItem : TFileTypeItem;
  idx : longint;
begin
  result := false;

  pFileOpenDialog := TFileOpenDialog.Create(nil);
  try
    try
      pFileOpenDialog.Title := 'select multi datasets';
      pFileOpenDialog.Options := pFileOpenDialog.Options + [fdoAllowMultiSelect];
      pFileOpenDialog.DefaultFolder := ExtractFilePath(ParamStr(0));
      pFileTypeItem := pFileOpenDialog.FileTypes.Add;
      pFileTypeItem.DisplayName := 'dataset';
      pFileTypeItem.FileMask := '*.'+pFileTypeItem.DisplayName;

      if pFileOpenDialog.Execute then
      begin
        self.Ffileselectlist.clear;

        idx := 0;
        while idx < pFileOpenDialog.Files.Count do
        begin
          self.Ffileselectlist.Add(pFIleOpenDialog.Files.Strings[idx]);
          inc(idx);
        end;

        result := true;
      end;
    except

    end;
  finally
    pFileOpenDialog.free;
  end;
end;

end.
