unit F_SysUtils;

interface

uses
  Windows;

function ParamStrW(): WideString;
function FileExistsW(szFileName: WideString): Boolean;
function IsManifestAvailableW(szFileName: WideString) : Boolean;
function Str2Int( S: PWideChar ): Integer;
function Int2Str(Value: Longint): Widestring;

implementation

function Str2Int( S: PWideChar ): Integer;
var M : Integer;
begin
   Result := 0;
   if S = '' then Exit; {>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>}
   M := 1;
   if  S^ = '-' then
   begin
       M := -1;
       Inc( S );
   end else
   if  S^ = '+' then
       Inc( S );
   while (S^>='0') and (S^<='9') do
   begin
       Result := Result * 10 + Integer( S^ ) - Integer( '0' );
       Inc( S );
   end;
   if  M < 0 then Result := -Result;
end;

function Int2Str(Value: Longint): Widestring;
var s:ShortString;
begin
 Str(Value, s);
 Result := Widestring(s);
end;

function ParamStrW(): WideString;
var
  lpBuffer: Array [0..MAX_PATH - 1] of WideChar;
begin
  GetModuleFileNameW(hInstance, lpBuffer, SizeOf(lpBuffer));
  Result := lpBuffer;
end;

function FileExistsW(szFileName: WideString): Boolean;
var
  Attributes : Cardinal;
begin
  Attributes := GetFileAttributesW(Pointer(szFileName));
  Result := (Attributes <> $FFFFFFFF) and (Attributes and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

function IsManifestAvailableW(szFileName: WideString) : Boolean;
const
  RT_MANIFEST = MAKEINTRESOURCE(24);
  function ManifestProc(LibMod: HMODULE; lpszType: PWideChar; lParam: LPARAM): BOOL; stdcall;
    begin
      Result := not(lpszType = PWideChar(RT_MANIFEST));
    end;
var
  LibMod: Thandle;
begin
  Result := FALSE;
  if not FileExistsW(szFileName) then
    Exit;
  Result := FileExistsW(szFileName + WideString('.manifest'));
  if not Result then
    begin
      LibMod := LoadLibraryW(PWideChar(szFileName));
      if LibMod <> 0 then
        Result := not EnumResourceTypesW(LibMod, @ManifestProc, 0);
    end;
end;

end.