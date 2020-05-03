program SunmiPrinterDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMain in 'UMain.pas' {FMain},
  Sunmi.Bluetooth.Printer in 'Sunmi.Bluetooth.Printer.pas',
  Sunmi.ESC.Utils in 'Sunmi.ESC.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
