unit uhandler_thread;

interface

uses
  {XE7 부터 병렬처리 가능함}
  {$IF DEFINED(VER280)
    OR DEFINED(VER290)
    OR DEFINED(VER300)
    OR DEFINED(VER310)
    OR DEFINED(VER320)
    OR DEFINED(VER330)}
  {$DEFINE UPTOXE7}
  {$ENDIF}

  {$IFDEF UPTOXE7}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.SyncObjs, System.Threading, System.Generics.Collections, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uoverridedic;
  {$ELSE}
  Windows, Messages, SysUtils, Variants, Classes,
  SyncObjs, Generics.Collections, Math,
  Graphics, Controls, Forms, Dialogs, uoverridedic;
  {$ENDIF}

const
  G_CREATE_SUSPENDED  : boolean = true;
  G_FREE_ON_TERMINATE : Boolean = true;

type
  Tthreadex = class;
  Tanonymousthread = class;
  Thandler_thread = class;
  Tthreadstate = (tsWait, tsStarted, tsEnded);

  {$IFDEF UPTOXE7}
  TThreadPool   = System.Threading.TThreadPool;
  Tparallel     = System.Threading.TParallel;
  TLoopState    = System.Threading.TParallel.TLoopState;
  TTask         = System.Threading.TTask;
  ITask         = System.Threading.ITask;
  TInterlocked  = System.SyncObjs.TInterlocked;
  Tarrayoftask  = array of ITask;
  {$ENDIF}

  // 싱글 쓰레드 실행 콜백 함수
  Tonthreadobject = procedure
  (
    _thread: Tanonymousthread;
    _parentdata : TObject
  ) of object;

  Tonthreadendobject = procedure
  (
    _thread: Tanonymousthread
  ) of object;

  Tthreadex = class(TThread)
  private
    Fanonymousthread: Tanonymousthread;
  protected
    procedure execute; override;
  public
    constructor create(_anonymousthread : Tanonymousthread); overload;
  end;

  // 쓰레드 사용시 이 클래스 사용
  Tanonymousthread = class
  private
    Fparentdata             : TObject;
    Fthreadex               : Tthreadex;

    Fonthreadobject         : Tonthreadobject;           //싱글
    Fonthreadendobject      : Tonthreadendobject;        //쓰레드 종료 시그널

    Fthreadstates           : Tthreadstate;
    Fthreadguid             : string;
    Fiscancel               : Boolean;

    function  createguid(): string;
    function  getiscancel() : Boolean;
    function  getthreadguid() : string;
    procedure setcancel(const _value : Boolean);
  public
    constructor create(_parentdata : TObject; _onthreadobject : Tonthreadobject); overload;
    constructor create(_parentdata : TObject; _onthreadobject : Tonthreadobject; _onthreadendobject: Tonthreadendobject); overload;
    destructor destroy; override;
  public
    procedure start;
    procedure sleep(Timeout: Integer);
    procedure synchronize(AThreadProc: TThreadProcedure);
  public
    property threadex               : Tthreadex                 read Fthreadex;
    property iscancel               : Boolean                   read getiscancel             write setcancel;
    property threadstates           : Tthreadstate              read Fthreadstates;
    property threadguid             : string                    read getthreadguid;
  end;


  // 쓰래드 핸들러. 취소할때 빼고는 신경쓰지 않아도 됨.
  // 취소하고 싶을때.
  // Thandler_thread.getobj.cancel(threadid)
  Thandler_thread = class
  private
    Fthreaddic : uoverridedic.Tstring_easydic;   //Tanonymousthread
    function isexists(const _threadguid: string): Tanonymousthread;
  public
    constructor create();
    destructor destroy; override;
    class function getobj: Thandler_thread;
    class function objfree: Boolean;
  public
    procedure clear();
    procedure cancel(const _threadguid: string);

    function  add(_anonymousthread : Tanonymousthread): Integer;
    function  del(const _threadguid: string): Integer;
  end;

implementation

var
  G_handler_thread : Thandler_thread;

{ Tanonymousthread }

constructor Tanonymousthread.create(_parentdata : TObject; _onthreadobject: Tonthreadobject);
begin
  self.Fparentdata        := _parentdata;
  self.Fonthreadobject    := _onthreadobject;
  self.Fonthreadendobject := nil;
  self.Fthreadstates      := tsWait;
  self.Fthreadguid        := createguid;
  self.Fiscancel          := false;

  self.Fthreadex := Tthreadex.create(self);

  Thandler_thread.getobj.add(self);
end;

constructor Tanonymousthread.create(_parentdata: TObject; _onthreadobject: Tonthreadobject; _onthreadendobject: Tonthreadendobject);
begin
  self.Fparentdata        := _parentdata;
  self.Fonthreadobject    := _onthreadobject;
  self.Fonthreadendobject := _onthreadendobject;
  self.Fthreadstates      := tsWait;
  self.Fthreadguid        := createguid;
  self.Fiscancel          := false;

  self.Fthreadex := Tthreadex.create(self);

  Thandler_thread.getobj.add(self);
end;

function Tanonymousthread.createguid: string;
var
  I: Integer;
  ASCII : Char;
  Key : string;
  IsChar : Boolean;
  IsUpper : Boolean;
begin
  Key := '';

  for I := 0 to 20 - 1 do
  begin
    IsChar := Boolean(RandomRange(0,2));
    if IsChar then
    begin
      ASCII := Char(RandomRange(97,122));
    end else
    begin
      ASCII := Char(RandomRange(48,58));
    end;
    Key := Key + ASCII;
  end;

  result := Key;
end;

destructor Tanonymousthread.destroy;
begin

  inherited;
end;

function Tanonymousthread.getiscancel: Boolean;
begin
  result := self.Fiscancel;
end;

function Tanonymousthread.getthreadguid: string;
begin
  result := self.Fthreadguid;
end;

procedure Tanonymousthread.setcancel(const _value: Boolean);
begin
  self.Fiscancel := _value;
end;

procedure Tanonymousthread.sleep(Timeout: Integer);
begin
  self.Fthreadex.Sleep(Timeout);
end;

procedure Tanonymousthread.start;
begin
  self.Fthreadex.Start;
end;

procedure Tanonymousthread.synchronize(AThreadProc: TThreadProcedure);
begin
  if Assigned(self.Fthreadex) then
  begin
    self.Fthreadex.Synchronize(self.Fthreadex, AThreadProc);
  end else
  begin
    //
    // 개발시 에러다 메시지박스로 알린다.
    //
    messagebox(0, pchar(format('%s.synchronize 1001', [self.ClassName])), '', 0);
  end;
end;

{ Thandler_thread }

function Thandler_thread.add(_anonymousthread: Tanonymousthread): Integer;
var
  panonymousthread: Tanonymousthread;
begin
  panonymousthread := self.isexists(_anonymousthread.threadguid);
  if Assigned(panonymousthread) then
  begin
    raise Exception.Create('alread thread execute');
  end else
  begin
    self.Fthreaddic.Add(_anonymousthread.threadguid, _anonymousthread);
  end;
end;

procedure Thandler_thread.cancel(const _threadguid: string);
var
  panonymousthread: Tanonymousthread;
begin
  panonymousthread := self.isexists(_threadguid);
  if Assigned(panonymousthread) then
  begin
    panonymousthread.iscancel := true;
  end;
end;

procedure Thandler_thread.clear;
var
  panonymousthread : Tanonymousthread;
begin
  self.Fthreaddic.get_items
  (
    procedure(const _idx: longint; const _count: longint; _object: system.tobject; var _is_cancel: boolean)
    begin
      if _object is Tanonymousthread then
      begin
        panonymousthread := Tanonymousthread(_object);
        panonymousthread.iscancel := True;
      end;
    end
  );

  self.Fthreaddic.Clear;
end;

constructor Thandler_thread.create;
begin
  inherited;

  self.Fthreaddic := uoverridedic.Tstring_easydic.create(true);
end;

function Thandler_thread.del(const _threadguid: string): Integer;
var
  panonymousthread: Tanonymousthread;
begin
  panonymousthread := self.isexists(_threadguid);
  if Assigned(panonymousthread) then
  begin
    self.Fthreaddic.Remove(_threadguid);
  end;
end;

destructor Thandler_thread.destroy;
begin
  self.clear;
  self.Fthreaddic.Free;
  self.Fthreaddic := nil;

  inherited;
end;

class function Thandler_thread.getobj: Thandler_thread;
begin
  if Assigned(G_handler_thread) then
  begin

  end else
  begin
    G_handler_thread := Thandler_thread.Create;
  end;

  result := G_handler_thread;
end;

function Thandler_thread.isexists(const _threadguid: string): Tanonymousthread;
begin
  result := Tanonymousthread(Fthreaddic.get_item(_threadguid));
end;

class function Thandler_thread.objfree: Boolean;
begin
  if Assigned(G_handler_thread) then
  begin
    G_handler_thread.Free;
    G_handler_thread := nil;
  end;

  result := true;
end;

{ Tthreadex }

constructor Tthreadex.create(_anonymousthread: Tanonymousthread);
begin
  inherited Create(G_CREATE_SUSPENDED);
  FreeOnTerminate := G_FREE_ON_TERMINATE;

  self.Fanonymousthread := _anonymousthread;
end;

procedure Tthreadex.execute;
begin
  self.Fanonymousthread.Fthreadstates := tsStarted;

  if Assigned(self.Fanonymousthread.Fonthreadobject) then
  begin
    self.Fanonymousthread.Fonthreadobject(self.Fanonymousthread, self.Fanonymousthread.Fparentdata);
  end;

  if Assigned(self.Fanonymousthread.Fonthreadendobject) then
  begin
    self.Fanonymousthread.Fonthreadendobject(self.Fanonymousthread);
  end;

  self.Fanonymousthread.Fthreadstates := tsEnded;
end;

initialization

finalization
  Thandler_thread.objfree;

end.

