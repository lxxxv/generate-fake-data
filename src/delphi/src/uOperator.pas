unit uOperator;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, uoverridedic, uTypeRepository;


type
  TOperator = class
  private
    class function get_overlap_random
    (
      _startoffset : longint;
      _ranbuffer   : Tlongintdynamicarray;
      _target      : Tlongintdynamicarray
    ): longint; overload;
  public
    //
    // 중복 제거된 난수 생성 함수
    //
    class function get_overlap_random(const _range: longint): Tlongintdynamicarray; overload;
    //
    // 그룹별 중복 제거된 난수 생성 함수
    // _group : 10, _range : 300 이라 가정할때 전체 300 길이만큼 배열을 가지고 10개씩 그룹지어서 난수를 생성하라.
    //
    class function get_overlap_random_group(const _group: longint; const _range: longint): Tlongintdynamicarray;
    //
    // 선택한 파일을 담는 함수
    //
    class function push_fileinfo(const _filepath: string; _targetList: TfileInfoObjectList): longint;
    //
    //
    //
    class function get_row_replace_string(const _idx: longint): string;
    //
    //
    //
    class function get_jsonschemas(_targetList: TfileInfoObjectList): string;
    //
    //
    //
    class function get_max_rows(_targetList: TfileInfoObjectList): longint;
  end;

implementation

class function TOperator.get_jsonschemas(_targetList: TfileInfoObjectList): string;
var
  idx : longint;

  temp : string;
begin
  temp := '';

  idx := 0;
  while idx < _targetList.Count do
  begin
    if idx = 0 then
    begin
      temp := format('"%s":"%s"', [_targetList[idx].schema, uOperator.TOperator.get_row_replace_string(idx)]);
    end else
    begin
      temp := temp + ',' + format('"%s":"%s"', [_targetList[idx].schema, uOperator.TOperator.get_row_replace_string(idx)]);
    end;

    inc(idx);
  end;

  //
  // 앞에 row 번호 적용해주기 위해 중괄호는 비워두었다.
  //
  result := temp + '}';
end;

class function TOperator.get_max_rows(_targetList: TfileInfoObjectList): longint;
var
  idx : longint;
  maxrow : longint;
begin
  maxrow := 0;

  idx := 0;
  while idx < _targetList.Count do
  begin
    if maxrow <= _targetList[idx].rows then
    begin
      maxrow := _targetList[idx].rows;
    end;
    inc(idx);
  end;

  result := maxrow;
end;

class function TOperator.get_overlap_random(const _range: longint): Tlongintdynamicarray;
var
  range : longint;
  ret : longint;
  ranbuffer : Tlongintdynamicarray;
begin
  range := _range;

  setlength(result, range);
  ZeroMemory(@result[0], range * sizeof(result[0]));

  setlength(ranbuffer, range);
  ZeroMemory(@ranbuffer[0], range * sizeof(ranbuffer[0]));

  ret := get_overlap_random(0, ranbuffer, result);
end;

class function TOperator.get_overlap_random
(
  _startoffset : longint;
  _ranbuffer   : Tlongintdynamicarray;
  _target      : Tlongintdynamicarray
): longint;
var
  ranrange    : longint;
  targetrange : longint;

  idx : longint;
  randomidx : longint;
  maxrange : longint;

  {$IFDEF TEST}
  pdic : uoverridedic.Tlongint_easydic;
  pobject : tobject;
  {$ENDIF}
begin
  result := -1;

  ranrange    := length(_ranbuffer);
  targetrange := length(_target);

  if ranrange > 0 then
  begin
  end else
  begin
    exit;
  end;

  if targetrange > 0 then
  begin
  end else
  begin
    exit;
  end;

  idx := 0;
  while idx < ranrange do
  begin
    _ranbuffer[idx] := idx;
    inc(idx);
  end;

  maxrange  := ranrange;
  randomidx := 0;
  idx := 0;
  while idx < targetrange do
  begin
    randomidx := Random(maxrange);

    _target[idx+_startoffset] := _ranbuffer[randomidx];

    dec(maxrange);

    _ranbuffer[randomidx] := _ranbuffer[maxrange];

    if maxrange = 0 then
    begin
      break;
    end;

    inc(idx);
  end;

  {$IFDEF TEST}
  pdic := uoverridedic.Tlongint_easydic.create(True);
  maxrange  := ranrange;
  randomidx := 0;
  idx := 0;
  while idx < targetrange do
  begin
    if pdic.TryGetValue(_target[idx+_startoffset], pobject) then
    begin
      outputdebugstring(pchar('error : ' + IntToStr(_target[idx+_startoffset])));
    end else
    begin
      pdic.add(_target[idx+_startoffset], pobject);
    end;

    dec(maxrange);

    if maxrange = 0 then
    begin
      break;
    end;

    inc(idx);
  end;
  pdic.free;
  {$ENDIF}
end;

class function TOperator.get_overlap_random_group(const _group: longint; const _range: longint): Tlongintdynamicarray;
var
  ret : longint;
  ranbuffer : Tlongintdynamicarray;

  idx : longint;
begin
  setlength(result, _range);
  ZeroMemory(@result[0], _range * sizeof(result[0]));

  setlength(ranbuffer, _group);
  ZeroMemory(@ranbuffer[0], _group * sizeof(ranbuffer[0]));

  idx := 0;
  while idx < _range do
  begin
    ret := get_overlap_random(idx, ranbuffer, result);
    idx := idx + _group;
  end;
end;

class function TOperator.get_row_replace_string(const _idx: longint): string;
begin
  result := IntToStr((_idx+1) * 111) + '+_+_';
end;

class function TOperator.push_fileinfo(const _filepath: string; _targetList: TfileInfoObjectList): longint;
var
  pfileInfo   : TfileInfo;
  pstringlist : tstringlist;
begin
  result := -1;
  if FileExists(_filepath) then
  begin
  end else
  begin
    exit;
  end;

  if assigned(_targetList) then
  begin
  end else
  begin
    exit;
  end;

  pfileInfo := TfileInfo.Create;
  _targetList.Add(pfileInfo);

  pfileInfo.filenamepath := _filepath;
  pfileInfo.schema       := StringReplace(ExtractFileName(pfileInfo.filenamepath), '.dataset', '', [rfReplaceAll]);

  pstringlist := tstringlist.Create;
  try
    try
      pstringlist.LoadFromFile(pfileInfo.filenamepath, Tencoding.UTF8);
      pfileInfo.rows := pstringlist.Count;
    except
    end;
  finally
    pstringlist.free;
  end;
end;

function get_overlap_random(const _createrows: longint; const _datasetrows: longint): Tlongintdynamicarray;
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

end.
