unit uoverridedic;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.SyncObjs, System.Generics.Collections, System.Generics.Defaults;

type
  Tref_easydic_to_list = reference to procedure(_list : tlist<system.tobject>);
  Tref_easydic_to_item = reference to procedure(const _idx: longint; const _count: longint; _object: system.tobject; var _is_cancel: boolean);

  Tparent_dic<tkey, tvalue> = class;
  Tparent_objectdic<tkey, tobject> = class;

  Tobject_easydic = class;
  Tlongint_easydic = class;
  Tint64_easydic = class;
  Tstring_easydic = class;

  //
  // parent
  //
  Tparent_dic<tkey, tvalue> = class(TObjectDictionary<tkey,tvalue>)
  private
    Fis_auto_free_key   : Boolean; //key 자동 free mode냐? key가 object일때.
    Fis_auto_free_value : boolean; //item 자동 free mode냐? item이 object일때.
  public
    constructor create(const _is_auto_free_key: Boolean; const _is_auto_free_value: Boolean);
    destructor destroy; override;
  public
    procedure get_items(_ref_easydic_to_list : Tref_easydic_to_list); overload; virtual; abstract;
    procedure get_items(_ref_easydic_to_item : Tref_easydic_to_item); overload; virtual; abstract;
    function  get_item(const _id: tkey): system.tobject; overload; virtual; abstract;
    function  get_item(const _id: tkey; _compare_object_name: string): system.tobject; overload; virtual; abstract;
    function  isexists(const _id: tkey):boolean; virtual; abstract;
    function  add(const _id: tkey; const _value: tvalue): Boolean; virtual;
  public
    property is_auto_free_key   : Boolean read Fis_auto_free_key;
    property is_auto_free_value : boolean read Fis_auto_free_value;
  end;

  //
  // parent object
  //
  Tparent_objectdic<tkey, tobject> = class(Tparent_dic<tkey,system.tobject>)
  public
    constructor create(const _is_auto_free_value: Boolean);
    destructor destroy; override;
  public
    procedure get_items(_ref_easydic_to_list : Tref_easydic_to_list); overload; virtual;
    procedure get_items(_ref_easydic_to_item : Tref_easydic_to_item); overload; virtual;
    function  get_item(const _id: tkey): system.tobject; overload; virtual;
    function  get_item(const _id: tkey; _compare_object_name: string): system.tobject; overload; virtual;
    function  isexists(const _id: tkey):boolean; virtual;
  end;

  //
  // obejct key type
  //
  Tobject_easydic = class(Tparent_objectdic<system.tobject,system.tobject>)
  end;

  //
  // longint key type
  //
  Tlongint_easydic = class(Tparent_objectdic<longint,system.tobject>)
  end;

  //
  // int64 key type
  //
  Tint64_easydic = class(Tparent_objectdic<int64,system.tobject>)
  end;

  //
  // string key type
  // 문자열은 lowercase를 해야 해서 재정의 해준다.
  //
  Tstring_easydic = class(Tparent_objectdic<string,system.tobject>)
  public
    function  get_item(const _id: string): system.tobject; overload; override;
    function  get_item(const _id: string; _compare_object_name: string): system.tobject; overload; override;
    function  isexists(const _id: string):boolean; override;
    function  add(const _id: string; const _value: system.tobject): Boolean; override;
  end;


implementation

{ Tparent_dic<tkey, tvalue> }

function Tparent_dic<tkey, tvalue>.add(const _id: tkey; const _value: tvalue): Boolean;
var
  find_value : tvalue;
  ret : boolean;
begin
  ret := self.TryGetValue(_id, find_value);
  if ret then
  begin
    //
    // 중복 데이터 있다.
    //
    result := false;
  end else
  begin
    inherited Add(_id, _value);
    result := true;
  end;
end;

constructor Tparent_dic<tkey, tvalue>.create(const _is_auto_free_key: Boolean; const _is_auto_free_value: Boolean);
begin
  self.Fis_auto_free_key   := _is_auto_free_key;
  self.Fis_auto_free_value := _is_auto_free_value;

  if _is_auto_free_key and _is_auto_free_value then
  begin
    inherited create([doOwnsKeys, doOwnsValues]);
  end else
  begin
    if _is_auto_free_key then
    begin
      inherited create([doOwnsKeys]);
    end else
    if _is_auto_free_value then
    begin
      inherited create([doOwnsValues]);
    end else
    begin
      inherited create();
    end;
  end;
end;

destructor Tparent_dic<tkey, tvalue>.destroy;
begin

  inherited;
end;


{ Tparent_objectdic<tkey, tobject> }

constructor Tparent_objectdic<tkey, tobject>.create(const _is_auto_free_value: Boolean);
begin
  inherited create(False, _is_auto_free_value);
end;

destructor Tparent_objectdic<tkey, tobject>.destroy;
begin

  inherited;
end;

function Tparent_objectdic<tkey, tobject>.get_item(const _id: tkey; _compare_object_name: string): system.tobject;
var
  pobject : system.tobject;
begin
  pobject := self.get_item(_id);
  if assigned(pobject) then
  begin
    if comparetext(pobject.ClassName, _compare_object_name) = 0 then
    begin
      result := pobject;
    end else
    begin
      MessageBox(0, pchar(pobject.ClassName + ' ' + _compare_object_name), '', 0);
    end;
  end else
  begin
    result := pobject;
  end;
end;

function Tparent_objectdic<tkey, tobject>.get_item(const _id: tkey): system.tobject;
var
  pobject : system.tobject;
  ret : boolean;
begin
  result := nil;
  ret := self.TryGetValue(_id, pobject);
  if ret then
  begin
    result := pobject;
  end;
end;

procedure Tparent_objectdic<tkey, tobject>.get_items(_ref_easydic_to_item: Tref_easydic_to_item);
var
  Key       : tkey;
  idx       : longint;
  dic_count : longint;
  is_cancel : boolean;
begin
  if Assigned(_ref_easydic_to_item) then
  begin
    is_cancel := false;
    dic_count := self.Count;
    idx := 0;
    for Key in self.Keys do
    begin
      _ref_easydic_to_item(idx, dic_count, self.Items[Key], is_cancel);
      idx := idx + 1;
      if is_cancel then
      begin
        exit;
      end;
    end;
  end;
end;

procedure Tparent_objectdic<tkey, tobject>.get_items(_ref_easydic_to_list: Tref_easydic_to_list);
var
  plist : tlist<system.tobject>;
  Key : tkey;
begin
  if Assigned(_ref_easydic_to_list) then
  begin
    plist := tlist<system.tobject>.create;
    for Key in self.Keys do
    begin
      plist.add(self.Items[Key]);
    end;
    _ref_easydic_to_list(plist);
    plist.free
  end;
end;

function Tparent_objectdic<tkey, tobject>.isexists(const _id: tkey): boolean;
var
  pobject : system.tobject;
begin
  result := self.TryGetValue(_id, pobject);
end;

{ Tstring_easydic }

function Tstring_easydic.add(const _id: string; const _value: system.tobject): Boolean;
var
  id : string;
begin
  id := LowerCase(_id);
  result := inherited add(id, _value);
end;

function Tstring_easydic.get_item(const _id: string; _compare_object_name: string): system.tobject;
var
  id : string;
begin
  id := LowerCase(_id);
  result := inherited get_item(id, _compare_object_name);
end;

function Tstring_easydic.get_item(const _id: string): system.tobject;
var
  id : string;
begin
  id := LowerCase(_id);
  result := inherited get_item(id);
end;

function Tstring_easydic.isexists(const _id: string): boolean;
var
  id : string;
begin
  id := LowerCase(_id);
  result := inherited isexists(id);
end;

end.
