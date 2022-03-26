unit uTestForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  uhandler_thread, uParentForm, uOperator, uTypeRepository;

type
  TTestForm = class(TParentForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    function execute: boolean;
    procedure onthread(_thread: Tanonymousthread; _parentdata : TObject);
    procedure onthreadend(_thread: Tanonymousthread);
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

{$R *.dfm}

function TTestForm.execute: boolean;
var
  panonymousthread : uhandler_thread.Tanonymousthread;
  ppropertiesinfo : Tpropertiesinfo;
begin
  //
  // 변환 시작.
  //

  ppropertiesinfo                := Tpropertiesinfo.create;
  ppropertiesinfo.savefolderpath := 'D:\project\__lxxxv__\generate-fake-data\';
  ppropertiesinfo.fileformat     := ffjson;
  ppropertiesinfo.fileType       := ftline;
  ppropertiesinfo.rows           := 100;

  panonymousthread := uhandler_thread.Tanonymousthread.create(ppropertiesinfo, self.onthread, self.onthreadend);
  panonymousthread.start;
end;

procedure TTestForm.FormCreate(Sender: TObject);
var
  str_ret : string;
  randomvalue : Tlongintdynamicarray;
begin
  inherited;

  randomvalue := uOperator.TOperator.get_overlap_random(30);
  randomvalue := uOperator.TOperator.get_overlap_random_group(10, 4);
  randomvalue := uOperator.TOperator.get_overlap_random_group(4, 10);

  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\bitcoinaddress.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\domainname.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\emailaddress.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\filename.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\fullname.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\guid.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\ipv4.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\mimetype.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\phonenumber.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\streetaddress.dataset', self.fileInfolist);
  uOperator.TOperator.push_fileinfo('D:\project\__lxxxv__\generate-fake-data\resource\timezone.dataset', self.fileInfolist); 

  str_ret := uOperator.TOperator.get_jsonschemas(self.fileInfolist);

  self.execute;

//  Application.Terminate;
end;

procedure TTestForm.FormDestroy(Sender: TObject);
begin
//
  inherited;
end;

procedure TTestForm.onthread(_thread: Tanonymousthread; _parentdata: TObject);
var
  ppropertiesinfo : Tpropertiesinfo;

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

procedure TTestForm.onthreadend(_thread: Tanonymousthread);
begin
  _thread.synchronize
  (
    procedure()
    begin
      MessageBox(self.handle, '완료', pchar(self.Caption), MB_OK);
    end
  );
end;

end.
