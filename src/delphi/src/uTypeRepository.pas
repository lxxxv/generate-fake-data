unit uTypeRepository;

interface

uses
  System.Generics.Collections;

type
  Texceptcheckmode = (eckselctfile, ectexecute);
  Texceptcheckmodes = set of Texceptcheckmode;

  Tfileformat = (ffjson);
  TfileType   = (ftline, ftarray);

  Tlongintdynamicarray = array of longint;

  Tpropertiesinfo = class
  private
    Frows           : longint;
    Ffileformat     : Tfileformat;
    FfileType       : TfileType;
    Fsavefolderpath : string;
  public
    property rows           : longint     read Frows           write Frows;
    property fileformat     : Tfileformat read Ffileformat     write Ffileformat;
    property fileType       : TfileType   read FfileType       write FfileType;
    property savefolderpath : string      read Fsavefolderpath write Fsavefolderpath;
  end;

  TfileInfo = class
  private
    Ffilenamepath : string;
    Fschema       : string;
    Frows         : longint;
  public
    property filenamepath : string  read Ffilenamepath write Ffilenamepath;
    property schema       : string  read Fschema       write Fschema;
    property rows         : longint read Frows         write Frows;
  end;
  TfileInfoObjectList = class(TObjectList<TfileInfo>);

implementation

end.
