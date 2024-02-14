unit payPackageUtils;

interface

type
  TPayPackage = (pckgNone, pckgFiskalPro, pckgElcomEuro, pckgBowa, pckgVaros,
    pckgUpos, pckgElcomEfox, pckgPosOld, pckgPosNew);

const
  C_PayPackageName: array [TPayPackage] of string = ('', 'FISKALPRO',
    'ELCOMEURO', 'BOWA', 'VAROS', 'UPOS', 'ELCOMEFOX', 'POSOLD', 'POSNEW');

function CheckInstalledPackage(PayPackage: TPayPackage;
  ShowErrMsg: boolean = false): boolean;

implementation

uses
  uCommon;

function CheckInstalledPackage(PayPackage: TPayPackage;
  ShowErrMsg: boolean = false): boolean;
var
  errMsg: string;
begin
  result := true; // CheckInstalledPackage(PayPackage, errMsg);
  if (not result or not Empty(errMsg)) and ShowErrMsg then
    Writeln('[ERROR] ' + errMsg);
end;

end.
