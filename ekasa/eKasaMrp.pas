unit eKasaMrp;

interface

uses
  uEkasa, uEkasaPrinters;

function eKasaMrpInit: boolean;
function eKasaMrpWork(action: TEkasaActions): string;
function baseUrl(): string;

var
  EKASA: TEKASA;

implementation

uses
  uEkasaHelper, uSettings, IdURI;

function init_eKasaMrp: integer;
begin
  result := 0;
  isEkasaInit := true;
  if EKASA = nil then
    EKASA := TEKASA.Create();
end;

function eKasaMrpInit: boolean;
begin
  if not isEkasaInit then
  begin
    init_eKasaMrp;
  end;
  result := isEkasaInit;
end;

function eKasaMrpWork(action: TEkasaActions): string;
var
  url, s, ss: string;
begin
  result := '';
  if not eKasaMrpInit then
    exit;

  url := baseUrl();
  case action of
    actState:
      begin
        url := url + '/state';
        result := EKASA.get(url);
      end;
    actSettingsGet:
      begin
        url := url + '/settings';
        result := EKASA.get(url);
      end;
    actSettingsPost:
      begin
        url := url + '/settings';
        result := EKASA.post(url, reqData);
      end;
    actCopyLast:
      begin
        url := url + '/receipt/last/copy';
        result := EKASA.get(url);
      end;
    actReceipt:
      begin
        url := url + '/receipt';
        result := EKASA.post(url, reqData);
      end;
    actReceiptStateId:
      begin
        url := url + '/receipt/state/' + reqId;
        result := EKASA.get(url);
      end;
    actCopyByUuid:
      begin
        url := url + '/receipt/copy';
        s := paramByName('uuid', reqParams);
        if (s <> '') then
          url := url + '?uuid=' + s;
        result := EKASA.get(url);
      end;
    actCopyById:
      begin
        url := url + '/receipt/copy/' + reqId;
        result := EKASA.get(url);
      end;
    actLocationGps:
      begin
        url := url + '/location/gps';
        result := EKASA.post(url, reqData);
      end;
    actLocationAddress:
      begin
        url := url + '/location/physicaladdress';
        result := EKASA.post(url, reqData);
      end;
    actLocationOther:
      begin
        url := url + '/location/other';
        result := EKASA.post(url, reqData);
      end;
    actReport:
      begin
        ss := '';
        url := url + '/report';
        s := paramByName('datetimefrom', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'datetimefrom=' + s;
        end;
        s := paramByName('datetimeto', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'datetimeto=' + s;
        end;
        s := paramByName('show', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'show=' + s;
        end;
        if (ss = '') then
          result := '{"errorCode":500,"error":"Chýba niektorý z parametrov [datetimefrom,datetimeto] filtra"}'
        else
        begin
          url := url + ss;
          result := EKASA.get(url);
        end;
      end;
    actUnsent:
      begin
        ss := '';
        url := url + '/unsent';
        s := paramByName('datetimefrom', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'datetimefrom=' + s;
        end;
        s := paramByName('datetimeto', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'datetimeto=' + s;
        end;
        s := paramByName('numberfrom', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'numberfrom=' + s;
        end;
        s := paramByName('numberto', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'numberto=' + s;
        end;
        s := paramByName('print', reqParams);
        if (s <> '') then
        begin
          if (ss = '') then
            ss := '?'
          else
            ss := ss + '&';
          ss := ss + 'print=' + s;
        end;
        if (ss = '') then
          result := '{"errorCode":500,"error":"Chýba niektorý z parametrov [datetimefrom,datetimeto,numberfrom,numberto] filtra"}'
        else
        begin
          url := url + ss;
          result := EKASA.get(url);
        end;
      end;
    actSendunsent:
      begin
        url := url + '/sendunsent';
        result := EKASA.get(url);
      end;
    actPrncdkick:
      begin
        url := url + '/prn/cdkick';
        result := EKASA.get(url);
      end;
    actPrnfreeprint:
      begin
        url := url + '/prn/freeprint';
        result := EKASA.post(url, reqData);
      end;
    actSenderror:
      begin
        url := url + '/senderror';
        result := EKASA.get(url);
      end;
    actExamplereceipt:
      begin
        url := url + '/examplereceipt';
        result := EKASA.get(url);
      end;
    actSelectpayments:
      begin
        url := url + '/selectpayments';
        s := paramByName('purpose', reqParams);
        if (s <> '') then
          url := url + '?purpose=' + s;
        url := TIdURI.URLEncode(url);
        result := EKASA.get(url);
      end;

  end;

end;

function baseUrl(): string;
begin
  result := 'http://' + fSettings.s['ekasa.hostAddress'] + '/api';
end;

end.
