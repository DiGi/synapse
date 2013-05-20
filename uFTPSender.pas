unit uFTPSender;

interface

uses Classes, ftpsend;

type
  TFTPSender = class(TFTPSend)
  public
    function StoreStream(const FileName: string; const SourceStream: TStream): Boolean;
  end;

implementation

uses
  SysUtils;

{ TFTPSender }

function TFTPSender.StoreStream(const FileName: string; const SourceStream: TStream): Boolean;
var
  RestoreAt: Int64;
  StorSize: Int64;
begin
  Result := False;
  RestoreAt := 0;
  if not DataSocket then
    Exit;
  if FBinaryMode then
    FTPCommand('TYPE I')
  else
    FTPCommand('TYPE A');
  StorSize := SourceStream.Size;
  if not FCanResume then
    RestoreAt := 0;
  if (StorSize > 0) and (RestoreAt = StorSize) then
  begin
    Result := True;
    Exit;
  end;
  if RestoreAt > StorSize then
    RestoreAt := 0;
  FTPCommand('ALLO ' + IntToStr(StorSize - RestoreAt));
  if FCanResume then
    if (FTPCommand('REST ' + IntToStr(RestoreAt)) div 100) <> 3 then
      Exit;
  SourceStream.Position := RestoreAt;
  if (FTPCommand('STOR ' + FileName) div 100) <> 1 then
    Exit;
  Result := DataWrite(SourceStream);
end;

end.
