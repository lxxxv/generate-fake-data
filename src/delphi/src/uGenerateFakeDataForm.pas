unit uGenerateFakeDataForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  uhandler_thread, uParentForm, uOperator, uTypeRepository;

type
  TGenerateFakeDataForm = class(TParentForm)
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
    Fprogresstimer  : ttimer;

    procedure ontimer(Sender: TObject);

    function execept_check(_exceptcheckmodes : Texceptcheckmodes): boolean;

    function do_select_files: boolean;

    function execute: boolean;

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
    self.do_select_files;

    self.maxrow := uOperator.TOperator.get_max_rows(self.fileInfolist);
    self.edtrows.Text := inttostr(self.maxrow);
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
      if (strtointdef(self.edtrows.Text + Key, self.maxrow) < self.maxrow) then
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

    if self.fileInfolist.Count = 0 then
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
  ppropertiesinfo : Tpropertiesinfo;
begin
  //
  // 변환 시작.
  //

  self.progressposition := 0;
  self.progress.Min     := 0;
  self.progress.Max     := StrToInt(self.edtrows.Text) * self.fileInfolist.Count;

  ppropertiesinfo                := Tpropertiesinfo.create;
  ppropertiesinfo.savefolderpath := IncludeTrailingPathDelimiter(self.edtresultfolderpath.Text);
  ppropertiesinfo.fileformat     := Tfileformat(self.cbFormat.ItemIndex);
  ppropertiesinfo.fileType       := TfileType(self.cbType.ItemIndex);
  ppropertiesinfo.rows           := StrToInt(self.edtrows.Text);

  panonymousthread := uhandler_thread.Tanonymousthread.create(ppropertiesinfo, self.onthread, self.onthreadend);
  panonymousthread.start;
end;

procedure TGenerateFakeDataForm.FormCreate(Sender: TObject);
begin
  inherited;

  self.Fprogresstimer           := ttimer.Create(nil);
  self.Fprogresstimer.Enabled   := false;
  self.Fprogresstimer.OnTimer   := ontimer;
  self.Fprogresstimer.Interval  := 200;

  self.edtresultfolderpath.Text := extractfilepath(paramstr(0));
  self.edtrows.Text             := inttostr(self.maxrow);
end;

procedure TGenerateFakeDataForm.FormDestroy(Sender: TObject);
begin
  self.Fprogresstimer.free;

  inherited;
end;

procedure TGenerateFakeDataForm.onthread(_thread: Tanonymousthread; _parentdata: TObject);
var
  ppropertiesinfo : Tpropertiesinfo;

  fileformat : Tfileformat;
  fileType   : TfileType;

  savefolderpath : string;

  makeJsonFile : tproc;
begin
  if assigned(_parentdata) then
  begin

  end else
  begin
    exit;
  end;

  if _parentdata is Tpropertiesinfo then
  begin

  end else
  begin
    exit;
  end;

  ppropertiesinfo := Tpropertiesinfo(_parentdata);

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

    randomvalue : tlongintdynamicarray;
  begin
    schemas     := uOperator.TOperator.get_jsonschemas(self.fileInfolist);

    psavefile   := tstringlist.Create;
    try
      try
        //
        // json 구조화 먼저 생성
        //
        idx := 0;
        while idx < ppropertiesinfo.rows do
        begin
          case ppropertiesinfo.fileType of
            ftline  : pushdata := '{"row":"' + inttostr(idx+1) + '",' + schemas;
            ftarray :
            begin
              if idx = 0 then
              begin
                pushdata := '{"data":[' + '{"row":"' + inttostr(idx+1) + '",' + schemas;
              end else
              begin
                pushdata := ',' + '{"row":"' + inttostr(idx+1) + '",' + schemas;
              end;
            end;
          end;

          psavefile.Add(pushdata);

          inc(idx);
        end;

        idx := 0;
        while idx < self.fileInfolist.Count do
        begin
          pfileInfo   := self.fileInfolist[idx];

          randomvalue := uOperator.TOperator.get_overlap_random_group(pfileinfo.rows, ppropertiesinfo.rows);

          pdatasetfile := tstringlist.Create;
          pdatasetfile.LoadFromFile(pfileInfo.filenamepath, TEncoding.UTF8);
          idxran := 0;
          while idxran < ppropertiesinfo.rows do
          begin
            psavefile.Strings[idxran] := StringReplace
            (
              psavefile.Strings[idxran]
              , uOperator.TOperator.get_row_replace_string(idx)
              , pdatasetfile.Strings[randomvalue[idxran]]
              , [rfreplaceall]
            );

            progressposition := progressposition + 1;

            inc(idxran);
          end;
          pdatasetfile.free;

          inc(idx);
        end;

        case ppropertiesinfo.fileType of
          ftline  : ;
          ftarray : psavefile.Add(']}');
        end;
      except

      end;
    finally
      psavefile.SaveToFile(ppropertiesinfo.savefolderpath + RESULT_FILENAME, TEncoding.UTF8);
      psavefile.free;

      if assigned(_parentdata) then
      begin
        _parentdata.free;
      end;
    end;
  end;

  //
  // 파일 생성 시작.
  //
  case ppropertiesinfo.fileformat of
    ffjson: makeJsonFile;
  end;
end;

procedure TGenerateFakeDataForm.onthreadend(_thread: Tanonymousthread);
begin
  _thread.synchronize
  (
    procedure()
    begin
      self.Fprogresstimer.Enabled := false;

      self.progress.Position := self.progress.Max;

      MessageBox(self.handle, '완료', pchar(self.Caption), MB_OK);
    end
  );
end;

procedure TGenerateFakeDataForm.ontimer(Sender: TObject);
begin
  self.Fprogresstimer.Enabled := false;

  self.progress.Position := self.progressposition;

  self.Fprogresstimer.Enabled := true;
end;

function TGenerateFakeDataForm.do_select_files: boolean;
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
        self.fileInfolist.Clear;

        idx := 0;
        while idx < pFileOpenDialog.Files.Count do
        begin
          uOperator.TOperator.push_fileinfo(pFIleOpenDialog.Files.Strings[idx], self.fileInfolist);
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
