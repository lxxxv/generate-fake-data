unit uGenerateFakeDataForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  uhandler_thread;


const
  RESULT_FILENAME : string = 'result.datasets';

type
  Texceptcheckmode = (eckselctfile, ectexecute);
  Texceptcheckmodes = set of Texceptcheckmode;
  Tfileformat = (ffjson);
  TfileType   = (ftline, ftarray);

  Tlongintdynamicarray = array of longint;

  TfileInfo = class
  public
    Ffilenamepath : string;
    Fschema       : string;
    Frows         : longint
  end;


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
    progress: TProgressBar;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFileSelectClick(Sender: TObject);
    procedure cbFormatKeyPress(Sender: TObject; var Key: Char);
    procedure edtrowsKeyPress(Sender: TObject; var Key: Char);
    procedure cbTypeKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    Fposition       : longint;
    Fprogresstimer  : ttimer;
    Fmaxrow         : longint;
    FfileInfolist   : TObjectList<TfileInfo>;
    procedure ontimer(Sender: TObject);

    procedure Test;
    function execept_check(_exceptcheckmodes : Texceptcheckmodes): boolean;
    function select_files: boolean;
    function execute: boolean;
    function check_max_rows: boolean;
    function getrandomvalue(const _createrows: longint; const _datasetrows: longint): Tlongintdynamicarray;

    function getjsonschemas(_fileInfolist: TObjectList<TfileInfo>): string;
    function getreplacestring(const _idx: longint): string;


    procedure onthread(_thread: Tanonymousthread; _parentdata : TObject);
    procedure onthreadend(_thread: Tanonymousthread);
  public
    { Public declarations }
  end;

var
  GenerateFakeDataForm: TGenerateFakeDataForm;

implementation

{$R *.dfm}

procedure TGenerateFakeDataForm.btnExecuteClick(Sender: TObject);
begin
  if self.execept_check([eckselctfile, ectexecute]) then
  begin
    self.execute;
  end;
end;

procedure TGenerateFakeDataForm.btnFileSelectClick(Sender: TObject);
begin
  if self.execept_check([eckselctfile]) then
  begin
    self.select_files;
    self.check_max_rows;
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

function TGenerateFakeDataForm.check_max_rows: boolean;
var
  idx : longint;
begin
  idx := 0;
  while idx < self.FfileInfolist.Count do
  begin
    if strtoint(self.edtrows.Text) <= self.FfileInfolist[idx].Frows then
    begin
      self.edtrows.Text := inttostr(self.FfileInfolist[idx].Frows);
      self.Fmaxrow      := self.FfileInfolist[idx].Frows;
    end;
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

function TGenerateFakeDataForm.execept_check(_exceptcheckmodes : Texceptcheckmodes): boolean;
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

    if self.FfileInfolist.Count = 0 then
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
var
  panonymousthread : uhandler_thread.Tanonymousthread;
begin
  //
  // 변환 시작.
  //

  self.Fposition    := 0;
  self.progress.Min := 0;
  self.progress.Max := StrToInt(self.edtrows.Text) * self.FfileInfolist.Count;

  panonymousthread := uhandler_thread.Tanonymousthread.create(nil, self.onthread, self.onthreadend);
  panonymousthread.start;
end;

procedure TGenerateFakeDataForm.FormCreate(Sender: TObject);
begin
  self.edtresultfolderpath.Text := extractfilepath(paramstr(0));
  self.Fmaxrow                  := 0;
  self.Fposition                := 0;
  self.edtrows.Text             := inttostr(self.Fmaxrow);
  self.FfileInfolist            := TObjectList<TfileInfo>.create;
  self.Fprogresstimer           := ttimer.Create(nil);

  self.Fprogresstimer.Enabled   := false;
  self.Fprogresstimer.OnTimer   := ontimer;
  self.Fprogresstimer.Interval  := 200;

  {$IFDEF TEST}
  self.Test;
  self.execute;
  {$ENDIF}
end;

procedure TGenerateFakeDataForm.FormDestroy(Sender: TObject);
begin
  self.Fprogresstimer.free;
  self.FfileInfolist.Free;
end;

function TGenerateFakeDataForm.getrandomvalue(const _createrows, _datasetrows: longint): Tlongintdynamicarray;
var
  ranbuffer : Tlongintdynamicarray;

  idx : longint;
  idxbuffer : longint;
  randomidx : longint;
  maxcounter : longint;
begin
  //
  // 사용자가 요청한 생성 row 갯수가 dataset 파일들의 row보다 더 클 수 있다.
  // 이 경우 row 갯수 그대로 난수를 만들게 되면 out of bount가 날수 있기 때문에
  // dataset 파일의 최대 길이만큼 난수를 세트로 생성한다.
  //

  setlength(result, _createrows);
  ZeroMemory(@result[0], Length(result) * sizeof(result[0]));

  setlength(ranbuffer, _datasetrows);
  ZeroMemory(@ranbuffer[0], Length(ranbuffer) * sizeof(result[0]));

  idx := 0;
  randomidx  := 0;
  maxcounter := 0;
  while idx < _createrows do
  begin
    if maxcounter = 0 then
    begin
      idxbuffer := 0;
      while idxbuffer < _datasetrows do
      begin
        ranbuffer[idxbuffer] := idxbuffer;
        inc(idxbuffer);
      end;
      maxcounter := _datasetrows;
    end;

    randomidx := Random(maxcounter);

    result[idx] := ranbuffer[randomidx];

    dec(maxcounter);

    ranbuffer[randomidx] := ranbuffer[maxcounter];

    inc(idx);
  end;
end;

function TGenerateFakeDataForm.getreplacestring(const _idx: longint): string;
begin
  result := IntToStr((_idx+1) * 111) + '+_+_';
end;

procedure TGenerateFakeDataForm.onthread(_thread: Tanonymousthread; _parentdata: TObject);
var
  fileformat : Tfileformat;
  fileType   : TfileType;

  savefilepath : string;

  makeJsonFile : tproc;
begin
  _thread.synchronize
  (
    procedure()
    begin
      self.Fprogresstimer.Enabled := true;
    end
  );

  makeJsonFile := procedure ()
  var
    idx : longint;
    psavefile : tstringlist;
    schemas   : string;
    pushdata  : string;

    idxran : longint;
    pfileInfo : TfileInfo;
    pdatasetfile : tstringlist;

    maxrow   : longint;
    datasetrow : longint;

    randomvalue : tlongintdynamicarray;
  begin
    maxrow      := StrToInt(self.edtrows.Text);

//    {$IFDEF TEST}
//    maxrow := 10;
//    {$ENDIF}

    schemas := self.getjsonschemas(self.FfileInfolist);
    psavefile := tstringlist.Create;
    try
      try
        //
        // json 구조화 먼저 생성
        //
        idx := 0;
        while idx < maxrow do
        begin
          case fileType of
            ftline  : pushdata := '{"row":' + inttostr(idx+1) + schemas;
            ftarray :
            begin
              if idx = 0 then
              begin
                pushdata := '{"data":[' + '{"row":' + inttostr(idx+1) + schemas;
              end else
              begin
                pushdata := ',' + '{"row":' + inttostr(idx+1) + schemas;
              end;
            end;
          end;

          psavefile.Add(pushdata);

          inc(idx);
        end;

        idx := 0;
        while idx < self.FfileInfolist.Count do
        begin
          pfileInfo   := self.FfileInfolist[idx];
          datasetrow  := pfileinfo.Frows;

//          {$IFDEF TEST}
//          datasetrow := 15;
//          {$ENDIF}

          randomvalue := self.getrandomvalue(maxrow, datasetrow);

          pdatasetfile := tstringlist.Create;
          pdatasetfile.LoadFromFile(pfileInfo.Ffilenamepath, TEncoding.UTF8);
          idxran := 0;
          while idxran < maxrow do
          begin
            psavefile.Strings[idxran] := StringReplace
            (
              psavefile.Strings[idxran]
              , self.getreplacestring(idx)
              , pdatasetfile.Strings[randomvalue[idxran]]
              , [rfreplaceall]
            );

            inc(self.Fposition);

            inc(idxran);
          end;
          pdatasetfile.free;

          inc(idx);
        end;

        case fileType of
          ftline  : ;
          ftarray : psavefile.Add(']}');
        end;
      except

      end;
    finally
      psavefile.SaveToFile(savefilepath + RESULT_FILENAME, TEncoding.UTF8);
      psavefile.free;
    end;
  end;

  //
  // 파일 생성 시작.
  //
  savefilepath := IncludeTrailingPathDelimiter(self.edtresultfolderpath.Text);
  fileformat   := Tfileformat(self.cbFormat.ItemIndex);
  fileType     := TfileType(self.cbType.ItemIndex);
  case fileformat of
    ffjson: makeJsonFile;
  end;
end;

procedure TGenerateFakeDataForm.onthreadend(_thread: Tanonymousthread);
begin
  _thread.synchronize
  (
    procedure()
    begin
      self.progress.Position := self.progress.Max;

      self.Fprogresstimer.Enabled := false;
      MessageBox(self.handle, '완료', pchar(self.Caption), MB_OK);
    end
  );
end;

procedure TGenerateFakeDataForm.ontimer(Sender: TObject);
begin
  self.Fprogresstimer.Enabled := false;

  self.progress.Position := self.Fposition;

  self.Fprogresstimer.Enabled := true;
end;

function TGenerateFakeDataForm.getjsonschemas(_fileInfolist: TObjectList<TfileInfo>): string;
var
  idx : longint;

  temp : string;
begin
  temp := '';

  idx := 0;
  while idx < _fileInfolist.Count do
  begin
    if idx = 0 then
    begin
      temp := format('"%s":"%s"', [_fileInfolist[idx].Fschema, self.getreplacestring(idx)]);
    end else
    begin
      temp := temp + ',' + format('"%s":"%s"', [_fileInfolist[idx].Fschema, self.getreplacestring(idx)]);
    end;

    inc(idx);
  end;

  //
  // 앞에 row 번호 적용해주기 위해
  //
  result := temp + '}';
end;

function TGenerateFakeDataForm.select_files: boolean;
var
  pFileOpenDialog : TFileOpenDialog;
  pFileTypeItem : TFileTypeItem;
  idx : longint;
  pfileInfo : TfileInfo;
  pstringlist : tstringlist;
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
        self.FfileInfolist.Clear;

        idx := 0;
        while idx < pFileOpenDialog.Files.Count do
        begin
          pfileInfo := TfileInfo.Create;
          self.FfileInfolist.Add(pfileInfo);

          pfileInfo.Ffilenamepath := pFIleOpenDialog.Files.Strings[idx];
          pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

          pstringlist := tstringlist.Create;
          pstringlist.LoadFromFile(pfileInfo.Ffilenamepath, Tencoding.UTF8);
          pfileInfo.Frows := pstringlist.Count;
          pstringlist.free;

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

procedure TGenerateFakeDataForm.Test;
var
  pfileInfo : TfileInfo;
begin
  {$IFDEF TEST}
  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\bitcoinaddress.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 500;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\domainname.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\emailaddress.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\filename.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\fullname.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\guid.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\ipv4.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 26;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\mimetype.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\phonenumber.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 1000000;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\streetaddress.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  pfileInfo := TfileInfo.Create;
  self.FfileInfolist.Add(pfileInfo);
  pfileInfo.Frows         := 333;
  pfileInfo.Ffilenamepath := 'D:\project\__lxxxv__\generate-fake-data\resource\timezone.dataset';
  pfileInfo.Fschema       := StringReplace(ExtractFileName(pfileInfo.Ffilenamepath), '.dataset', '', [rfReplaceAll]);

  self.check_max_rows;
  self.edtrows.Text       := '100000';
  {$ENDIF}
end;

end.
