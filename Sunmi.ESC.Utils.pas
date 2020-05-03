(*
   CreatedAt: 2020-04-30 @ Jatinangor, Sumedang, Jawa Barat
   CreatedBy: Sony NS
   Description: sunmi v1 printer ESC command
     java source: https://github.com/shangmisunmi/SunmiPrinterDemo
 *)

unit Sunmi.ESC.Utils;

interface

uses Classes, SysUtils, Generics.Collections;

const
  ESC = $1B;// Escape
	FS  = $1C;// Text delimiter
	GS  = $1D;// Group separator
	DLE = $10;// data link escape
	EOT = $04;// End of transmission
	ENQ = $05;// Enquiry character
	SP  = $20;// Spaces
	HT  = $09;// Horizontal list
	LF  = $0A;//Print and wrap (horizontal orientation)
	CR  = $0D;// Home key
	FF  = $0C;// Carriage control (print and return to the standard mode (in page mode))
	CAN = $18;// Canceled (cancel print data in page mode)

type
  ESunmiEsc = class(Exception);

  TSunmiEsc = class
  private
    class function SetQRCodeSize(AModuleSize: Integer): TArray<Byte>;
    class function SetQRCodeErrorLevel(AErrorLevel: Integer): TArray<Byte>;
    class function GetBytesForPrintQRCode(ASingle: Boolean): TArray<Byte>;
    class function GetQCodeBytes(ABarcode: String): TArray<Byte>;
  public
    class function InitPrinter: TArray<Byte>;

    class function BoldOn: TArray<Byte>;
    class function BoldOff: TArray<Byte>;

    class function AlignLeft: TArray<Byte>;
    class function AlignCenter: TArray<Byte>;
    class function AlignRight: TArray<Byte>;

    class function Cutter: TArray<Byte>;
    class function CutPaper: TArray<Byte>;
    class function UnCutPaperOnLeft: TArray<Byte>;
    class function Gogo: TArray<Byte>;

    class function NextLine(ALineNumber: Integer): TArray<Byte>;
    class function SetDefaultLineSpace: TArray<Byte>;
    class function SetLineSpace(AHeight: Integer): TArray<Byte>;

    class function UnderlineWithOneDotWidthOn: TArray<Byte>;
    class function UnderlineWithTwoDotWidthOn: TArray<Byte>;
    class function UnderlineOff: TArray<Byte>;

    class function GetPrintQRCode(ABarcode: String; AModuleSize,
      AErrorLevel: Integer): TArray<Byte>;
  end;

implementation

{ TSunmiEsc }

class function TSunmiEsc.AlignCenter: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 97, 1); //ESC 97 1
  Result:= LByte;
end;

class function TSunmiEsc.AlignLeft: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 97, 0); //ESC 97 0
  Result:= LByte;
end;

class function TSunmiEsc.AlignRight: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 97, 2); //ESC 97 2
  Result:= LByte;
end;

class function TSunmiEsc.BoldOff: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 69, 0); //ESC 69 0
  Result:= LByte;
end;

class function TSunmiEsc.BoldOn: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 69, $FF); //ESC 69 0xF
  Result:= LByte;
end;

///
///  https://github.com/labibramadhan/cordova-sunmi-inner-printer/issues/13
///
class function TSunmiEsc.CutPaper: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1d, $56, $42, $00); //0x1d, 0x56, 0x42, 0x00
  Result:= LByte;
end;

///
///  SunmiPrinter Developer documentation1.1.181207.pdf - page #21
///
class function TSunmiEsc.UnCutPaperOnLeft: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1d, $56, $41, $00); //0x1d, 0x56, 0x41, 0x00
  Result:= LByte;
end;

///
/// https://github.com/shangmisunmi/SunmiPrinterDemo
///
class function TSunmiEsc.Cutter: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1d, $56, $01); //0x1d 0x56 0x01
  Result:= LByte;
end;

class function TSunmiEsc.GetPrintQRCode(ABarcode: String; AModuleSize,
  AErrorLevel: Integer): TArray<Byte>;
var LBuffer: TArray<Byte>;
begin
  LBuffer:= SetQRCodeSize(AModuleSize);
  try
    LBuffer:= LBuffer + SetQRCodeErrorLevel(AErrorLevel);
    LBuffer:= LBuffer + GetQCodeBytes(ABarcode);
    LBuffer:= LBuffer + GetBytesForPrintQRCode(True);
  except
    on e: exception do
      raise ESunmiEsc.CreateFmt('TSunmiEsc.GetPrintQRCode "%s"', [e.Message]);
  end;

  Result:= LBuffer;
end;

class function TSunmiEsc.Gogo: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1C, $28, $02, $00, $42, $31); //0x1C, 0x28, 0x4C, 0x02, 0x00, 0x42, 0x31
  Result:= LByte;
end;

class function TSunmiEsc.InitPrinter: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, $40); //ESC 0x40
  Result:= LByte;
end;

class function TSunmiEsc.NextLine(ALineNumber: Integer): TArray<Byte>;
var LByte: TArray<Byte>;
    LI: Integer;
begin
  LByte:= TBytes.Create();
  SetLength(LByte, ALineNumber);
  for LI:= 0 to (ALineNumber - 1) do
    LByte[LI]:= LF;

  Result:= LByte;
end;

class function TSunmiEsc.GetBytesForPrintQRCode(ASingle: Boolean): TArray<Byte>;
var LByte: TArray<Byte>;
begin
  if (ASingle) then
		LByte:= TArray<Byte>.Create($1D, $28, $6B, $03, $00, $31, $51, $30, $0A)
	else
    LByte:= TArray<Byte>.Create($1D, $28, $6B, $03, $00, $31, $51, $30);

  Result:= LByte;
end;

class function TSunmiEsc.SetDefaultLineSpace: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1B, $32); //0x1B, 0x32
  Result:= LByte;
end;

class function TSunmiEsc.SetLineSpace(AHeight: Integer): TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create($1B, $33, AHeight); //0x1B, 0x33, (byte) height
  Result:= LByte;
end;

///
/// code.getBytes("GB18030") konversi ke charset china
/// https://en.wikipedia.org/wiki/GB_18030
/// codepage: 54936
///

class function TSunmiEsc.GetQCodeBytes(ABarcode: String): TArray<Byte>;
var LBuffer: TList<Byte>;
    LByte: TArray<Byte>;
    LLen, LI, LCount: Integer;
begin
  LBuffer:= TList<Byte>.Create;
  try
    LByte:= TEncoding.GetEncoding(54936).GetBytes(ABarcode);
    LLen:= Length(LByte) + 3;
    if (LLen > 7092) then LLen:= 7092;

    LBuffer.Add($1D);
		LBuffer.Add($28);
		LBuffer.Add($6B);
		LBuffer.Add(byte(LLen));
		LBuffer.Add(byte(LLen shl 8));
		LBuffer.Add($31);
		LBuffer.Add($50);
		LBuffer.Add($30);

    if (Length(LByte) > LLen) then
        LCount:= LLen
    else
        LCount:= Length(LByte);
		for LI:= 0 to (LCount - 1) do
    begin
			LBuffer.Add(LByte[LI]);
		end;
  except
    on e: exception do
      raise ESunmiEsc.CreateFmt('TSunmiEsc.GetQCodeBytes "%s"', [e.Message]);
  end;
  Result:= LBuffer.ToArray;
end;

class function TSunmiEsc.SetQRCodeErrorLevel(AErrorLevel: Integer): TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(GS, $28, $6B, $03, $00, $31, $45, byte(48 + AErrorLevel));
  Result:= LByte;
end;

class function TSunmiEsc.SetQRCodeSize(AModuleSize: Integer): TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(GS, $28, $6B, $03, $00, $31, $43, byte(AModuleSize));
  Result:= LByte;
end;

class function TSunmiEsc.UnderlineOff: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 45, 0); //ESC 45 0
  Result:= LByte;
end;

class function TSunmiEsc.UnderlineWithOneDotWidthOn: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 45, 1); //ESC 45 1
  Result:= LByte;
end;

class function TSunmiEsc.UnderlineWithTwoDotWidthOn: TArray<Byte>;
var LByte: TArray<Byte>;
begin
  LByte:= TArray<Byte>.Create(ESC, 45, 2); //ESC 45 2
  Result:= LByte;
end;

end.
