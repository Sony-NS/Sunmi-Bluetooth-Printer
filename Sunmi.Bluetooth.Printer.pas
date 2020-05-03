(*
   CreatedAt: 2020-04-30 @ Jatinangor, Sumedang, Jawa Barat
   CreatedBy: Sony NS
   Description: sunmi v1 bluetooth printer
     java source: https://github.com/shangmisunmi/SunmiPrinterDemo
 *)

unit Sunmi.Bluetooth.Printer;

interface

uses
  System.SysUtils, System.Classes, System.Bluetooth, System.Bluetooth.Components;

const
  UUID = '{00001101-0000-1000-8000-00805F9B34FB}';
  SunmiPrinterAddress = '00:11:22:33:44:55';
  MaxCharInLine = 32;

type
  EBluetoothPrinter = class(Exception);

  TBluetoothPrinter = class(TBluetooth)
  private
    FSocket: TBluetoothSocket;
    FPrinterName: String;
    function ConnectByAddress(ADeviceAddress: String): Boolean;
    function GetDeviceByAddress(ADeviceAddress: String): TBluetoothDevice;
  public
    procedure SetBoldOn;
    procedure SetBoldOff;
    procedure Gogo;

    procedure NextLine(ALineNumber: Integer);
    procedure PaperCut;
    procedure PaperHalfCutting;
    procedure PrintQRCode(ABarcode: String);
    procedure PrinterInitialization;
    procedure PrinterOff;
    procedure PrinterOn;
    procedure SendText(AString: String);
    procedure SendWrapText(AString: String);
    procedure SetAlignCenter;
    procedure SetAlignLeft;
  published
    property PrinterName: string read FPRinterName write FPrinterName;
  end;

implementation

uses Sunmi.ESC.Utils;

{ TBluetoothPrinter }

function TBluetoothPrinter.ConnectByAddress(ADeviceAddress: String): Boolean;
var LDevice: TBluetoothDevice;
begin
  LDevice := GetDeviceByAddress(ADeviceAddress);
  if LDevice <> nil then
  begin
    FSocket := lDevice.CreateClientSocket(StringToGUID(UUID), False);
    if FSocket <> nil then
    begin
      FSocket.Connect;
      Result:= FSocket.Connected;
    end else
      raise EBluetoothPrinter.Create('Can`t connect to printer.');
  end else
    raise EBluetoothPrinter.CreateFmt('Printer "%s" not found.', [ADeviceAddress]);
end;

function TBluetoothPrinter.GetDeviceByAddress(ADeviceAddress: String): TBluetoothDevice;
var LDevice: TBluetoothDevice;
begin
  Result := nil;

  for LDevice in Self.PairedDevices do
  begin
    if LDevice.Address = ADeviceAddress then
    begin
      FPrinterName:= LDevice.DeviceName;
      Result:= LDevice;
      if LDevice.Address = ADeviceAddress then
         break;
    end;
  end;
end;

procedure TBluetoothPrinter.Gogo;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.Gogo);
  end;
end;

procedure TBluetoothPrinter.NextLine(ALineNumber: Integer);
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.NextLine(ALineNumber));
  end;
end;

procedure TBluetoothPrinter.PaperCut;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.CutPaper);
  end;
end;

procedure TBluetoothPrinter.PaperHalfCutting;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.UnCutPaperOnLeft);
  end;
end;

procedure TBluetoothPrinter.PrintQRCode(ABarcode: String);
begin
  SetAlignCenter;
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.GetPrintQRCode(ABarcode, 8, 3));
  end;
  SendText(ABarcode);
end;

procedure TBluetoothPrinter.PrinterInitialization;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.InitPrinter);
  end;
end;

procedure TBluetoothPrinter.PrinterOff;
begin
  if (FSocket <> nil)and(FSocket.Connected) then
     FSocket.Close;
end;

procedure TBluetoothPrinter.PrinterOn;
var LDevice: TBluetoothDevice;
begin
  LDevice := GetDeviceByAddress(SunmiPrinterAddress);
  if LDevice <> nil then
  begin
    FSocket := LDevice.CreateClientSocket(StringToGUID(UUID), True);
    if FSocket <> nil then
    begin
      FSocket.Connect;
    end else
      raise EBluetoothPrinter.Create('Can`t connect to printer.');
  end else
   raise EBluetoothPrinter.CreateFmt('Printer "%s" not found.', [SunmiPrinterAddress]);
end;

procedure TBluetoothPrinter.SendText(AString: String);
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TEncoding.UTF8.GetBytes(AString + #13#10));
  end;
end;

procedure TBluetoothPrinter.SendWrapText(AString: String);
var LList: TStrings;
    LStr: String;
    LI: Integer;
begin
  LList:= TStringList.Create;
  try
    LList.Add(WrapText(AString, #13#10, [' ', '-'], MaxCharInLine));
    for LI:= 0 to (LList.Count-1) do
      SendText(LList[LI]);
  finally
    LList.Free;
  end;
end;

procedure TBluetoothPrinter.SetAlignCenter;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.AlignCenter);
  end;
end;

procedure TBluetoothPrinter.SetAlignLeft;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.AlignLeft);
  end;
end;

procedure TBluetoothPrinter.SetBoldOff;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.BoldOff);
  end;
end;

procedure TBluetoothPrinter.SetBoldOn;
begin
  if FSocket.Connected then
  begin
    FSocket.SendData(TSunmiEsc.BoldOn);
  end;
end;

end.
