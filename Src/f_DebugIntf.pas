unit f_DebugIntf;

interface

uses
  SysUtils;

const
  RETURN_FAIL     = -1;
  RETURN_SUCC     =  0;
  RETURN_NotFound =  1;

  {������� ��Ϣ Ĭ��}
  ERRORCODE_MSG   = 1;
  {������� �ļ�}
  ERRORCODE_FILE  = 2;
  {������� �쳣��Ϣ}
  ERRORCODE_EXCEPTION = -1;
  {������� ��ʼ��}
  ERRORCODE_BASE      = 1000000;

  ERRORMSG_FMT = 'ϵͳ����ʧ�ܣ�����ϵ�����̡��������[%d]';

  LOGHELPER_CLASSNAME  = '_com.servyou.servcie.loghelperclass';

  FMT_DATETIME = 'yyyy-mm-dd hh:nn:ss';
  FMT_DATE     = 'yyyy-mm-dd';
  FMT_TIME     = 'hh:nn:ss';

type
  PIDebugger = ^IDebugger;

  {$IF not Declared(UnicodeString)}
  UnicodeString = WideString;
  {$IFEND}
  PUnicodeChar  = PWideChar;

  PLogHelperPack = ^TLogHelperPack;
  TLogHelperPack = record
    Loaded: Boolean;
    DebugerDestroyed: PBoolean;
    Debugger: PIDebugger;
    NewErrorInfo: Pointer;
  end;

  // �������Ϣ����
  TCnMsgType = (
    cmtInformation,
    cmtWarning,
    cmtError,
    cmtSeparator,
    cmtEnterProc,
    cmtLeaveProc,
    cmtTimeMarkStart,
    cmtTimeMarkStop,
    cmtMemoryDump,
    cmtException,
    cmtObject,
    cmtComponent,
    cmtCustom,
    cmtSystem
    );
  TCnMsgTypes = set of TCnMsgType;

  TOnOutputMsgProc = procedure (const AMsg: PAnsiChar; Size: Integer; const ATag: PAnsiChar;
      ALevel, AIndent: Integer; AType: TCnMsgType; ThreadID: Cardinal; CPUPeriod: Int64;
      var AHandled: Boolean) of object;

  {������Ϣ}
  IErrorInfo = interface
  ['{F7216B6D-6B8C-41AC-AA7A-D9FAC65CCB4F}']
    function  GetCode: Integer;
    function  GetMsg: WideString;
    function  GetMsgP: PWideChar;
    procedure SetCode(const Value: Integer);
    procedure SetMsg(const Value: WideString);

    {�ӿ�ʵ�ֶ���}
    function  Implementor: TObject;
    procedure Assign(Source: IErrorInfo);
    
    {���}
    procedure Clear;
    {���´�����Ϣ}
    procedure UpdateError(const ACode: Integer; const AMsg: WideString = '');
    procedure UpdateErrorFmt(const ACode: Integer; const AMsg: WideString;
      Args: array of const);
    {Ĭ�ϵ���ʾ����}
    function  ShowMsgOrFile: WideString;

    procedure AddMsg(const AMsg: WideString; const ADelimiter: WideString = ';'); overload;
    procedure AddMsg(const AMsg: PAnsiChar; const ADelimiter: WideString = ';'); overload;

    {����}
    property Code: Integer read GetCode write SetCode;
    {��Ϣ}
    property Msg:  WideString read GetMsg write SetMsg;
    {��Ϣ ָ������}
    property MsgP: PWideChar read GetMsgP;
  end;

  {* �������ӿ�}
  IDebugger = interface ['{58D16229-D65F-4693-BEA3-29BD8E9ECAD9}']
    function  GetLogEnable: Boolean; 
    function  GetActive: Boolean;
    function  GetAutoStart: Boolean;
    function  GetDumpFileName: WideString;
    function  GetDefaultTag: WideString;
    function  GetDefaultLevel: Integer;
    function  GetDumpToFile: Boolean;
    function  GetUseAppend: Boolean;
    function  GetOnOutputMsg: TOnOutputMsgProc;
    procedure SetLogEnable(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    procedure SetDumpFileName(const Value: WideString);
    procedure SetDumpToFile(const Value: Boolean);
    procedure SetDefaultTag(const Value: WideString);
    procedure SetDefaultLevel(const Value: Integer);
    procedure SetAutoStart(const Value: Boolean);
    procedure SetUseAppend(const Value: Boolean);
    procedure SetOnOutputMsg(const Value: TOnOutputMsgProc);

    {* ���������� }
    procedure StartDebugViewer;

    {* ���� CPU ���ڼ�ʱ == Start == }
      // ����������ʹ�þֲ��ַ��������������Խ�С�������Ƽ�ʹ��
    procedure StartTimeMark(const ATag: Integer; const AMsg: WideString = ''); overload;
    procedure StopTimeMark(const ATag: Integer; const AMsg: WideString = ''); overload;
      // ��������������ʹ���� Delphi �ַ��������ϴ󣨼������Ҹ� CPU ���ڣ�
    procedure StartTimeMark(const ATag: WideString; const AMsg: WideString = ''); overload;
    procedure StopTimeMark(const ATag: WideString; const AMsg: WideString = ''); overload;
    {* ���� CPU ���ڼ�ʱ == End == }

    {* Log ϵ��������� == Start == }
    procedure LogSeparator;
    procedure LogEnter(const AProcName: WideString; const ATag: WideString = ''); overload;
    procedure LogLeave(const AProcName: WideString; const ATag: WideString = ''); overload;
    procedure LogEnter(const AProcName: PAnsiChar; const ATag: PAnsiChar = nil); overload;
    procedure LogLeave(const AProcName: PAnsiChar; const ATag: PAnsiChar = nil); overload;
      // ���⸨�����������
    procedure Log(const AMsg: PAnsiChar; const ATag: PAnsiChar = nil; const ALevel: Integer = 0); overload;
    procedure Log(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0); overload;
    procedure LogWarning(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure LogError(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure LogException(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure LogLastError(const ATag: WideString = ''; const ALevel: Integer = 0);
    {* Log ϵ��������� == End == }

    {* Trace ϵ��������� == Start == }
    procedure TraceSeparator;
    procedure TraceEnter(const AProcName: WideString; const ATag: WideString = ''); overload;
    procedure TraceLeave(const AProcName: WideString; const ATag: WideString = ''); overload;
    procedure TraceEnter(const AProcName: PAnsiChar; const ATag: PAnsiChar = nil); overload;
    procedure TraceLeave(const AProcName: PAnsiChar; const ATag: PAnsiChar = nil); overload;

      // ���⸨�����������
    procedure Trace(const AMsg: PAnsiChar; const ATag: PAnsiChar = nil; const ALevel: Integer = 0); overload;
    procedure Trace(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0); overload;
    procedure TraceWarning(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure TraceError(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure TraceException(const AMsg: WideString; const ATag: WideString = ''; const ALevel: Integer = 0);
    procedure TraceLastError(const ATag: WideString = ''; const ALevel: Integer = 0);
    {* Trace ϵ��������� == End == }

    {Log�����Ƿ����}
    property LogEnable: Boolean read GetLogEnable write SetLogEnable;
    {* �Ƿ�ʹ�ܣ�Ҳ�����Ƿ������Ϣ}
    property Active: Boolean read GetActive write SetActive;
    {* �Ƿ��Զ����� Viewer}
    property AutoStart: Boolean read GetAutoStart write SetAutoStart;

    {* �Ƿ�������Ϣͬʱ������ļ�}
    property DumpToFile: Boolean read GetDumpToFile write SetDumpToFile;
    {* ������ļ���}
    property DumpFileName: WideString read GetDumpFileName write SetDumpFileName;
    {* Ĭ��Tag}
    property DefaultTag: WideString read GetDefaultTag write SetDefaultTag;
    {* Ĭ��Tag}
    property DefaultLevel: Integer read GetDefaultLevel write SetDefaultLevel;
    {* ÿ������ʱ������ļ��Ѵ��ڣ��Ƿ�׷�ӵ��������ݺ�����д}
    property UseAppend: Boolean read GetUseAppend write SetUseAppend;
    {��־����¼�}
    property OnOutputMsg: TOnOutputMsgProc read GetOnOutputMsg write SetOnOutputMsg;
  end;

  {������Ϣ}
  TErrorInfo = class(TInterfacedObject, IErrorInfo)
  private
    FCode: Integer;
    FMsg: WideString;
  protected
    function  GetCode: Integer;
    function  GetMsg: WideString;
    function  GetMsgP: PWideChar;
    procedure SetCode(const Value: Integer);
    procedure SetMsg(const Value: WideString);
  public
    function  Implementor: TObject;
    
    {���}
    procedure Clear;
    {���´�����Ϣ}
    procedure UpdateError(const ACode: Integer; const AMsg: WideString = '');
    procedure UpdateErrorFmt(const ACode: Integer; const AMsg: WideString;
      Args: array of const);
    {Ĭ�ϵ���ʾ����}
    function ShowMsgOrFile: WideString;

    procedure Assign(Source: IErrorInfo);

    procedure AddMsg(const AMsg: WideString; const ADelimiter: WideString = ';'); overload;
    procedure AddMsg(const AMsg: PAnsiChar; const ADelimiter: WideString = ';'); overload;
  end;

{$IFNDEF LOGHELPER}
const
  DLL_LogHelper = 'LogHelper.dll';
var
  varDefaultTag: UnicodeString = '';

{�������Ƿ����}
function  DebugerCanUse: Boolean;
function  Debugger: PIDebugger;
function  LogEnable: Boolean;

function NewErrorInfo: IErrorInfo;

function  LoadLogHelper(ADllPath: UnicodeString = DLL_LogHelper): Boolean;
procedure UnloadLogHelper;

procedure StartTimeMark(const ATag: Integer; const AMsg: UnicodeString = ''); overload;
procedure StartTimeMark(const ATag: UnicodeString; const AMsg: UnicodeString = ''); overload;
procedure StopTimeMark(const ATag: Integer; const AMsg: UnicodeString = ''); overload;
procedure StopTimeMark(const ATag: UnicodeString; const AMsg: UnicodeString = ''); overload;

procedure Log(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogSQL(const ASQL: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogSeparator;
procedure LogWarning(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogWarningFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogError(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogErrorFmt(const AMsg: UnicodeString;  Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogException(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogExceptionFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure LogEnter(const AProcName: UnicodeString; ATag: UnicodeString = '');
procedure LogLeave(const AProcName: UnicodeString; ATag: UnicodeString = '');
procedure LogLastError(const AError: IErrorInfo; ATag: UnicodeString = ''; const ALevel: Integer = 0);

procedure TraceSQLError(const ASQL: UnicodeString; AError: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure Trace(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceSeparator;
procedure TraceWarning(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceWarningFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceError(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceErrorFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceException(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceExceptionFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
procedure TraceEnter(const AProcName: UnicodeString; ATag: UnicodeString = '');
procedure TraceLeave(const AProcName: UnicodeString; ATag: UnicodeString = '');
procedure TraceLastError(const AError: IErrorInfo; ATag: UnicodeString = ''; const ALevel: Integer = 0);
{$ENDIF}

{��ǰģ���·��}
function CurrentModulePath: UnicodeString;
{��ǰӦ�ó����·��}
function CurrentAppPath: UnicodeString;
{��ǰӦ�ó����ļ���}
function CurrentAppFileName: UnicodeString;
{��ȡϵͳ������Ϣ}
function SysLastErrorMsg: UnicodeString;

implementation

uses
{$IFDEF LOGHELPER}
  f_DebugImpl;
{$ELSE}
  Windows;
{$ENDIF}

var
  varCurrentModuleName: UnicodeString;

{$IFNDEF LOGHELPER}
type
  TDebuggerProc = function : PIDebugger; stdcall;
  TNewErrorInfoProc = function : IErrorInfo; stdcall;
  
var
  varLogHelperPack: TLogHelperPack;
  varLock: TRTLCriticalSection;
  varDLLHandle: THandle = 0;
  varDllPath: UnicodeString = '';
  varWC: TWndClassA;
  isHost: Boolean = False;
  varDebugerDestroyed: Boolean = False;

function Debugger: PIDebugger;
begin
  if (varLogHelperPack.Debugger = nil) and (not varLogHelperPack.Loaded) then
  begin
    if GetClassInfoA(HInstance, LOGHELPER_CLASSNAME, varWC) then
    begin
      varLogHelperPack.DebugerDestroyed :=  TLogHelperPack(varWC.lpfnWndProc^).DebugerDestroyed;
      varLogHelperPack.Debugger := TLogHelperPack(varWC.lpfnWndProc^).Debugger;
      varDefaultTag := varLogHelperPack.Debugger.DefaultTag;
      isHost := False;
    end;
    varLogHelperPack.Loaded := True;
  end;

  if (varLogHelperPack.DebugerDestroyed <> nil) and (not varLogHelperPack.DebugerDestroyed^) then
    Result := varLogHelperPack.Debugger
  else
    Result := nil;
end;

function  DebugerCanUse: Boolean;
begin
  Result := Debugger <> nil;
end;

function  LoadLogHelper(ADllPath: UnicodeString = DLL_LogHelper): Boolean;
var
  sDllPath: UnicodeString;
  LDebuggerProc: TDebuggerProc;
  LNewErrorInfo: TNewErrorInfoProc;
begin
  Result := False;
  try
    if (not GetClassInfoA(HInstance, LOGHELPER_CLASSNAME, varWC)) then
    begin
      //����
      if not FileExists(ADllPath) then
        Exit;
      ADllPath := Trim(ADllPath);
      if SameText(varDllPath, ADllPath) then
      begin
        Result := True;
        Exit;
      end;            
      sDllPath := ADllPath;
      varDLLHandle := LoadLibraryW(PUnicodeChar(sDllPath));
      if varDLLHandle < 32 then Exit;
      varDllPath := ADllPath;
      
      @LDebuggerProc := GetProcAddress(varDLLHandle, 'Debugger_B25A21B15478');
      if @LDebuggerProc = nil then
        Exit;
      @LNewErrorInfo := GetProcAddress(varDLLHandle, 'NewErrorInfo_B25A21B15478');

      varLogHelperPack.DebugerDestroyed := @varDebugerDestroyed;
      varLogHelperPack.Debugger := LDebuggerProc;
      varLogHelperPack.NewErrorInfo := @LNewErrorInfo;
      varDefaultTag := varLogHelperPack.Debugger.DefaultTag;

      //ע��
      FillChar(varWC, SizeOf(varWC), 0);
      varWC.lpszClassName := LOGHELPER_CLASSNAME;
      varWC.style         := CS_GLOBALCLASS;
      varWC.hInstance     := hInstance;
      varWC.lpfnWndProc   := @varLogHelperPack;
      if RegisterClassA(varWC)=0 then
      begin
        MessageBox(0, 'ע����־�������ʧ�ܣ�', '��־����', 0);
        Halt;
      end;

      isHost := True;
    end
    else
    begin
      varLogHelperPack.DebugerDestroyed := TLogHelperPack(varWC.lpfnWndProc^).DebugerDestroyed;
      varLogHelperPack.Debugger := TLogHelperPack(varWC.lpfnWndProc^).Debugger;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[LoadServiceLibrary]'+E.Message));
    end
  end;
end;

procedure UnloadLogHelper;
begin
  try
    if isHost then
    begin
      if varDLLHandle > 0 then
        FreeLibrary(varDLLHandle);
      varDLLHandle := 0;
      
      UnregisterClassA(LOGHELPER_CLASSNAME, HInstance);

      if varLogHelperPack.DebugerDestroyed <> nil then
        varLogHelperPack.DebugerDestroyed := nil;
      isHost := False;
    end;
    varLogHelperPack.Debugger := nil;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[UnloadServiceLibrary]'+E.Message));
    end
  end;
end;

function  LogEnable: Boolean;
begin
  Result := DebugerCanUse and Debugger.LogEnable;
end;

procedure StartTimeMark(const ATag: Integer; const AMsg: UnicodeString = ''); overload;
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    Debugger.StartTimeMark(ATag, AMsg);
  end;
end;

procedure StartTimeMark(const ATag: UnicodeString; const AMsg: UnicodeString = ''); overload;
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    Debugger.StartTimeMark(ATag, AMsg);
  end;
end;

procedure StopTimeMark(const ATag: Integer; const AMsg: UnicodeString = ''); overload;
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    Debugger.StopTimeMark(ATag, AMsg);
  end;
end;

procedure StopTimeMark(const ATag: UnicodeString; const AMsg: UnicodeString = ''); overload;
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    Debugger.StopTimeMark(ATag, AMsg);
  end;
end;

procedure Log(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.Log(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;
procedure LogFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.Log(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;
procedure LogSQL(const ASQL: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.Log(Format('SQL:%s', [StringReplace(ASQL, #13#10, ' ', [rfReplaceAll])]),
      ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogSeparator;
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
    Debugger.LogSeparator;
end;

procedure LogWarning(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogWarning(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogWarningFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogWarning(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogError(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogError(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogErrorFmt(const AMsg: UnicodeString;  Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogError(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogException(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogException(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogExceptionFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogException(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel);
  end;
end;

procedure LogEnter(const AProcName: UnicodeString; ATag: UnicodeString = '');
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogEnter(AProcName, ATag+'[' + varCurrentModuleName +']');
  end;
  StartTimeMark(AProcName);
end;

procedure LogLeave(const AProcName: UnicodeString; ATag: UnicodeString = '');
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogLeave(AProcName, ATag+'[' + varCurrentModuleName +']');
  end;
  StopTimeMark(AProcName);
end;

procedure LogLastError(const AError: IErrorInfo; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then  Exit;
  if Debugger.LogEnable then
  begin
    if ATag = '' then ATag := varDefaultTag;
    Debugger.LogError(Format('[%d]%s', [AError.Code, AError.Msg]), ATag+'[' + varCurrentModuleName +']');
  end;
end;

procedure _NativeTrace(const ALog: UnicodeString);
var
  f: textfile;
  sLogFile: UnicodeString;
begin
  EnterCriticalSection(varLock);
  try
    if {$WARNINGS OFF} DebugHook = 1 {$WARNINGS ON} then
      OutputDebugStringW(PUnicodeChar(ALog))
    else
    try                    
      sLogFile := ChangeFileExt(ParamStr(0), '_' + DateToStr(Now) + '.log');
      ForceDirectories(ExtractFilePath(sLogFile));
      AssignFile(f, sLogFile);
      try
        if FileExists(sLogFile) then
          Append(f)
        else
          Rewrite(f);
        Writeln(f, Format('��%s��%s', [DateTimeToStr(Now), ALog]));
      finally
        CloseFile(f);
      end;
    except
      on e: Exception do
      begin
        OutputDebugString(PChar('[_NativeTrace]'+e.Message));
      end;
    end;
  finally
    LeaveCriticalSection(varLock);
  end;
end;

procedure TraceSQLError(const ASQL: UnicodeString; AError: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then
  begin
    TraceError(Format('��%s��:%s', [StringReplace(ASQL, #13#10, ' ', [rfReplaceAll]), AError]));
    Exit;
  end;
  if ATag = '' then ATag := varDefaultTag;
  Debugger.TraceError(Format('��%s��:%s', [StringReplace(ASQL, #13#10, ' ', [rfReplaceAll]), AError]),
    ATag+'[' + varCurrentModuleName +']', ALevel);
end;

procedure Trace(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + AMsg);
    Exit;
  end;
  if ATag = '' then ATag := varDefaultTag;
  if AMsg[1] = '[' then
    Debugger.TraceException(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel)
  else
    Debugger.Trace(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
end;
procedure TraceFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + Format(AMsg, Args));
    Exit;
  end;
  
  if ATag = '' then ATag := varDefaultTag;
  if AMsg[1] = '[' then
    Debugger.TraceException(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel)
  else
    Debugger.Trace(Format(AMsg, Args), ATag+'[' + varCurrentModuleName +']', ALevel);
end;
procedure TraceSeparator;
begin
  if not DebugerCanUse then
  begin
    _NativeTrace('==============================================================');
    Exit;
  end;
  Debugger.TraceSeparator;
end;
procedure TraceWarning(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if ATag = '' then ATag := varDefaultTag;
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[Warning]'+  AMsg);
    Exit;
  end;
  Debugger.TraceWarning(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
end;

procedure TraceWarningFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  TraceWarning(Format(AMsg, Args), ATag, ALevel);
end;

procedure TraceError(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if ATag = '' then ATag := varDefaultTag;
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[Error]' + AMsg);
    Exit;
  end;
  
  Debugger.TraceError(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
end;

procedure TraceErrorFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  TraceError(Format(AMsg, Args), ATag, ALevel);
end;

procedure TraceException(const AMsg: UnicodeString; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if ATag = '' then ATag := varDefaultTag;
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[Exception]'+  AMsg);
    Exit;
  end;
  Debugger.TraceException(AMsg, ATag+'[' + varCurrentModuleName +']', ALevel);
end;

procedure TraceExceptionFmt(const AMsg: UnicodeString; Args: array of const; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  TraceException(Format(AMsg, Args), ATag, ALevel);
end;

procedure TraceEnter(const AProcName: UnicodeString; ATag: UnicodeString = '');
begin
  if ATag = '' then ATag := varDefaultTag;
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[�������]' + AProcName);
    Exit;
  end;
  
  Debugger.TraceEnter(AProcName, ATag+'[' + varCurrentModuleName +']');
end;
procedure TraceLeave(const AProcName: UnicodeString; ATag: UnicodeString = '');
begin
  if ATag = '' then ATag := varDefaultTag;

  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[�뿪����]' + AProcName);
    Exit;
  end;

  Debugger.TraceLeave(AProcName, ATag+'[' + varCurrentModuleName +']');
end;

procedure TraceLastError(const AError: IErrorInfo; ATag: UnicodeString = ''; const ALevel: Integer = 0);
begin
  if ATag = '' then ATag := varDefaultTag;
  if not DebugerCanUse then
  begin
    _NativeTrace(ATag+'[' + varCurrentModuleName +']' + '[Error]' + Format('[%d]%s', [AError.Code, AError.Msg]));
    Exit;
  end;

  Debugger.TraceError(Format('[%d]%s', [AError.Code, AError.Msg]), ATag+'[' + varCurrentModuleName +']', ALevel);
end;

function NewErrorInfo: IErrorInfo;
begin
  if (varLogHelperPack.NewErrorInfo = nil) and (not varLogHelperPack.Loaded) then
  begin
    if GetClassInfoA(HInstance, LOGHELPER_CLASSNAME, varWC) then
    begin
      varLogHelperPack.DebugerDestroyed :=  TLogHelperPack(varWC.lpfnWndProc^).DebugerDestroyed;
      varLogHelperPack.NewErrorInfo := TLogHelperPack(varWC.lpfnWndProc^).NewErrorInfo;
      varDefaultTag := varLogHelperPack.Debugger.DefaultTag;
      isHost := False;
    end;
    varLogHelperPack.Loaded := True;
  end;

  if (varLogHelperPack.DebugerDestroyed <> nil) and (not varLogHelperPack.DebugerDestroyed^)
    and (varLogHelperPack.NewErrorInfo <> nil) then
    Result := TNewErrorInfoProc(varLogHelperPack.NewErrorInfo)()
  else
    Result := TErrorInfo.Create;
end;
{$ENDIF}

function CurrentModulePath: UnicodeString;
begin
  Result := ExtractFilePath(GetModuleName(HInstance));
end;

function CurrentAppPath: UnicodeString;
begin
  Result := ExtractFilePath(CurrentAppFileName);
end;

function CurrentAppFileName: UnicodeString;
begin
  Result := ParamStr(0);
end;

function SysLastErrorMsg: UnicodeString;
begin
  Result := '['+IntToStr(GetLastError)+']'+SysErrorMessage(GetLastError);
end;

{ TErrorInfo }

procedure TErrorInfo.AddMsg(const AMsg: PAnsiChar; const ADelimiter: WideString);
begin
{$WARNINGS OFF}
  if FMsg = '' then
    FMsg := AMsg
  else
    FMsg := FMsg + ADelimiter + AMsg;
{$WARNINGS ON}
end;

procedure TErrorInfo.AddMsg(const AMsg: WideString; const ADelimiter: WideString);
begin
  if FMsg = '' then
    FMsg := AMsg
  else
    FMsg := FMsg + ADelimiter + AMsg;
end;

procedure TErrorInfo.Assign(Source: IErrorInfo);
begin
  FCode := Source.Code;
  FMsg := Source.Msg;
end;

procedure TErrorInfo.Clear;
begin
  FCode := ERRORCODE_MSG;
  FMsg := '';
end;

function TErrorInfo.GetCode: Integer;
begin
  Result := FCode;
end;

function TErrorInfo.GetMsg: WideString;
begin
  Result := FMsg;
end;

function TErrorInfo.GetMsgP: PUnicodeChar;
begin
  Result := PUnicodeChar(FMsg)
end;

function TErrorInfo.Implementor: TObject;
begin
  Result := Self;
end;

procedure TErrorInfo.SetCode(const Value: Integer);
begin
  FCode := Value;
end;

procedure TErrorInfo.SetMsg(const Value: WideString);
begin
  FMsg := Value;
end;

function TErrorInfo.ShowMsgOrFile: WideString;
begin
  Result := '';

  if (FCode >= ERRORCODE_BASE) or (FMsg = '') then
  begin
    Result := Format(ERRORMSG_FMT, [FCode]);
  end
  else
    Result := FMsg;
end;

procedure TErrorInfo.UpdateError(const ACode: Integer;
  const AMsg: WideString);
begin
  FCode := ACode;
  FMsg := AMsg;
  {$IFNDEF LOGHELPER}
  if FMsg <> EmptyStr then Log('UpdateError:' + FMsg);
  {$ELSE}
  if FMsg <> EmptyStr then f_DebugImpl.Debugger_B25A21B15478.Log('UpdateError:' + FMsg);
  {$ENDIF}
end;

procedure TErrorInfo.UpdateErrorFmt(const ACode: Integer;
  const AMsg: WideString; Args: array of const);
begin
  UpdateError(ACode, WideFormat(AMsg, Args));
end;

initialization
  varCurrentModuleName := ExtractFileName(GetModuleName(HInstance));

{$IFNDEF LOGHELPER}
  varLogHelperPack.Loaded := True;
  varLogHelperPack.DebugerDestroyed := nil;
  varLogHelperPack.Debugger := nil;
  varLogHelperPack.Loaded := False;
  InitializeCriticalSection(varLock);
  if GetClassInfoA(SysInit.HInstance, LOGHELPER_CLASSNAME, varWC) then
  begin
    varLogHelperPack.DebugerDestroyed := TLogHelperPack(varWC.lpfnWndProc^).DebugerDestroyed;
    varLogHelperPack.Debugger := TLogHelperPack(varWC.lpfnWndProc^).Debugger;
    isHost := False;
  end
  else
  begin
    LoadLogHelper();
  end;
{$ENDIF}

finalization
{$IFNDEF LOGHELPER}
  UnloadLogHelper;
  DeleteCriticalSection(varLock);
{$ENDIF}


end.

