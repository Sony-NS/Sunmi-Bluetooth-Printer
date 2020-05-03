unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Sunmi.Bluetooth.Printer, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListBox;

type
  TFMain = class(TForm)
    btnConnect: TButton;
    btnPrint: TButton;
    btnCutter: TButton;
    meEvent: TMemo;
    btnHalfCut: TButton;
    procedure btnConnectClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCutterClick(Sender: TObject);
    procedure btnHalfCutClick(Sender: TObject);
  private
    { Private declarations }
    FPrinter: TBluetoothPrinter;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses
  System.Bluetooth;

procedure TFMain.btnConnectClick(Sender: TObject);
begin
  FPrinter.PrinterOn;
  if (FPrinter.PrinterName <> '') then
      meEvent.Lines.Add('Printer Name: '+FPrinter.PrinterName);
end;

procedure TFMain.btnCutterClick(Sender: TObject);
begin
  FPrinter.PaperCut;
end;

procedure TFMain.btnHalfCutClick(Sender: TObject);
begin
  FPrinter.PaperHalfCutting;
end;

procedure TFMain.btnPrintClick(Sender: TObject);
begin
  FPrinter.SetAlignCenter;
  FPrinter.SetBoldOn;
  FPrinter.SendText('TIKET PARKIR');
  FPrinter.SetBoldOff;
  FPrinter.SendText('CrossoverLab.,');
  FPrinter.SendText('Jl. Kol. Ahmad Syam - Jatinangor');
  FPrinter.SetAlignLeft;
  FPrinter.SendText('No. Tiket : 002/3');
  FPrinter.SendText('Waktu     :'+ FormatDateTime('DD/MM/YYYY HH:mm:ss', Now));
  FPrinter.NextLine(1);
  FPrinter.PrintQRCode('Terima kasih telah menggunakan  Sistem Parkir');
  FPrinter.NextLine(1);
  FPrinter.SendText('PASTIKAN KENDARAAN ANDA TERKUNCI');
  FPrinter.SendWrapText('JAGA TIKET PARKIR ANDA JANGAN SAMPAI HILANG');
  FPrinter.NextLine(3);
  FPrinter.PaperCut;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  FPrinter:= TBluetoothPrinter.Create(nil);
  FPrinter.Enabled := True;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  FPrinter.PrinterOff;
  FPrinter.Destroy;
end;

end.
