unit snmpreq;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdSNMP, Data.DB, XMLIntf, XMLDoc,
  Data.Win.ADODB, Xml.xmldom;

type
  TForm1 = class(TForm)
    Button1: TButton;
    fileOpn: TFileOpenDialog;
    xmlFile: TXMLDocument;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SNMP: TIdSNMP;
  Idx: Integer;
  str, name, oid, valueType, filePath, lastOid: string;
  iNode: iXMLNode;
  i: integer = 0;
  dtOIDs: TDataSet;
implementation

{$R *.dfm}

procedure GetSNMPValue(const mibOID: string);
var upDownValue: string;
begin
    try
    SNMP := TIdSNMP.Create(nil);
    //Dane do po³¹czenia z SNMP
    snmp.Query.Host:='192.168.1.199';
    snmp.Query.Community := 'public';
    Snmp.Query.PDUType := PDUGetRequest;
    snmp.Query.MIBAdd(miboid,'');

    //Jeœli wys³ane query jest poprawne to zwróæ mi Reply
    if Snmp.SendQuery then
      begin;
        //ShowMessage('Iloœæ rekordów: ' + IntToStr(Snmp.Reply.ValueCount));
        //Jezeli SendQuery = true to dla kazdej odpowiedzi od snmp wyrzucic msgbox
        for Idx := 0 to Snmp.Reply.ValueCount - 1 do
          if snmp.Reply.Value[i] = '1' then
          begin
          updownvalue := 'up';
          end
          else if snmp.Reply.Value[i] = '2' then
          begin
          updownvalue := 'down';
          end
          else
          begin
            updownvalue := snmp.Reply.Value[i];
          end;

          ShowMessage('Reply:'+ sLineBreak +
          'name: '+ name + SlineBreak +
          'oid: ' + oid + SlineBreak +
          Snmp.reply.ValueOID[i] + ' ' + updownvalue);
      end
    else
      begin
      //Jesli SendQuery = false wyrzuc mi msgbox o b³êdzie
       ShowMessage('Wyst¹pi³ b³¹d podczas próby pobrania informacji o portach.');
       end;
    finally
      snmp.Free;
    end;
end;

procedure ProcessNode(Node : IXMLNode);
var cNode: iXMLNode;
begin
if Node = nil then Exit;
//Przypisanie atrybutow xml do zmiennej Node
if Node.Attributes['name']<>Null then
  name:=String(Node.Attributes['name']);

if Node.Attributes['oid']<>Null then
  oid:=String(Node.Attributes['oid']);

if Node.Attributes['valueType']<>Null then
  valueType:=String(Node.Attributes['valueType']);

  cNode := Node.ChildNodes.First;

  while cNode <> nil do
    begin
          if lastoid <> oid  then
          begin
            if oid <> '' then
            begin
              GetSNMPValue(oid);
            end;

            if oid = '' then
            begin
              lastoid := '.';
            end
            else
            begin
              lastoid := oid;
            end;
          end;
          ProcessNode(cNode);

    //przejscie do nastepnej pozycji w xmlu
    cNode := cNode.NextSibling;
    end;
end;

function GetXMLDoc(xmlFile: TXMLDocument): iXMLNode;
begin
//Wybór pliku do wczytania mibOID'ów
    with TFileOpenDialog.Create(nil) do
      try
        Title := 'Wybierz plik';
        Options := [fdoFileMustExist, fdoPathMustExist, fdoForceFileSystem];
        OkButtonLabel := 'Wybierz';
        DefaultFolder := filePath;
        FileName := filePath;
        if Execute then
          filePath := FileName
      finally
        Free;

    //Wczytanie mibOIDs z pliku xml
    xmlFile.LoadFromFile(filePath);
    xmlFile.Active := true;

    iNode:=xmlFile.DocumentElement.ChildNodes.First;

    result := iNode;
    end
end;

procedure CreateLog(str: string);
var filePath: string;
fLog: TextFile;
date: TDateTime;
begin
filepath:=ExpandFileName(GetCurrentDir + '\..\..\');
if FileExists(filePath+'\log.txt\') then
begin
    AssignFile(fLog, filepath+'\log.txt');
    Append(fLog)
end
   else
begin
    AssignFile(fLog, filepath+'\log.txt');
     Append(fLog);
end;
  date:=Now;
  WriteLn(fLog, str+' - '+DateToStr(date)+' '+TimeToStr(date));
  Flush(fLog);

  CloseFile(fLog);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    CreateLog('wywoluje okno dialogowe');
    iNode:= GetXMLDoc(xmlFile);

    name:='';
    oid:='';
    valueType:='';
    lastoid := '.';
    createlog('przypisuje wartosc do zmiennej iNode');
    while iNode <> nil do
    begin
    ProcessNode(iNode);
    iNode:=iNode.NextSibling;
    end;

    filePath := '';
end;
end.
