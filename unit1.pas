unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    customersLabel: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    revenueLabel: TLabel;
    expansesLabel: TLabel;
    avarageLabel: TLabel;
    resultLabel: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

type
  sales=record
    code: integer;
    sold: integer;
  end;

  ln=record
    norp: char;
    id: integer;
    code: integer;
    quantity: integer;
    price: real;
  end;


var
  Form1: TForm1;
  stats_file: textfile;
  db: array of ln;
  unique: array of sales;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var avarage, revenue, expanses, result: real;
  lines, i, y, customers, idaside: integer;
  ch: char;
  chfield: string;
begin
   Memo1.clear;
   Memo2.clear;
   customers:=0;
   revenue:=0;
   expanses:=0;
   avarage:=0;
   result:=0;
   idaside:=0;
   for i:=1 to 90 do begin
    db[i].code:=0;
    unique[i].code:=0;
   end;


   try
      assignfile(stats_file, 'STATISTIKY.txt');
      reset(stats_file);                            // path \\comenius\public\market\tima\
   except on E: EInOutError do begin
       label3.caption:=('Pri načítavaní súboru došlo k chybe: '+ E.ClassName+ '/'+ E.Message);
       exit;
   end;
   end;
      readln(stats_file, lines);                   //ziskaj kolko ma subor riadkov
      label3.caption:='';
      for i:=1 to lines do begin              //while not eof?
       read(stats_file, db[i].norp);
       read(stats_file,ch);                     //je ;
       read(stats_file, ch);
       while ch<>';' do begin              //id
           chfield:=chfield+ch;
           read(stats_file, ch);
       end;
       db[i].id:=strtoint(chfield);
       read(stats_file,ch);
       chfield:='';
       while ch<>';' do begin              //code
           chfield:=chfield+ch;
           read(stats_file, ch);
       end;
       db[i].code:=strtoint(chfield);
       read(stats_file,ch);
       chfield:='';
       while ch<>';' do begin              //quantity
           chfield:=chfield+ch;
           read(stats_file, ch);
       end;
       db[i].quantity:=strtoint(chfield);
       chfield:='';
       readln(stats_file, db[i].price);
       chfield:='';
   end;

   closefile(stats_file);

  for i:=1 to lines do begin
      if db[i].norp = 'P' then begin
          //aktualne id rovnake ako minule
          db[1].id:=idaside;
          if idaside<>db[i].id then begin
            idaside:=db[i].id;
            inc(customers);
          end;
          revenue:=revenue+(db[i].quantity*db[i].price);
          for y:=1 to lines do begin
           if unique[y].code=db[i].code then begin
              unique[y].sold:=unique[y].sold+1; //* db[i].quantity
              Break;
           end
           else if unique[y].code=0 then begin
               unique[y].code:=db[i].code;
               unique[y].sold:=1;
               Break;
           end;
       end;
      end
      else begin
          expanses:=expanses+(db[i].quantity*db[i].price);
      end;
  end;

  FOR i := 1 TO lines DO
      FOR y := i+1 to 10 DO
          IF unique[i].sold < unique[y].sold THEN begin
             //swap
             idaside:=unique[i].code;
             unique[i].code:=unique[y].code;
             unique[y].code:=idaside;

             idaside:=unique[i].sold;
             unique[i].sold:=unique[y].sold;
             unique[y].sold:=idaside;
          end;

  avarage:=revenue / customers; //delene pocet rovnakych id
  avarage:=roundto(avarage, -2);
  result:=revenue-expanses;
  if result < 0 then resultLabel.font.color:=clRed
  else resultLabel.font.color:=clGreen;
  //output
  customersLabel.caption:=inttostr(customers);
  avarageLabel.caption:=floattostr(avarage)+'€';
  revenueLabel.caption:=floattostr(revenue)+'€';
  expansesLabel.caption:=floattostr(expanses)+'€';
  resultLabel.caption:=floattostr(result)+'€';

  memo1.clear;
  memo2.clear;

  for i:=1 to 10 do
      Memo1.append(inttostr(i)+'. '+inttostr(unique[i].code)+' '+inttostr(unique[i].sold));
  y:=1;
  for i:=lines downto 0 do
      if unique[i].code <> 0 then begin

      Memo2.append(inttostr(y)+'. '+inttostr(unique[i].code)+' '+inttostr(unique[i].sold));
      inc(y);
      if y>10 then break;
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   setlength(db, 90);
   setlength(unique, 90);
end;

end.

