unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls;

type

  { TForm2 }
  player = record
    Name: string[25];
    score: string [25];
  end;

  {****t* score/TForm2
* NAME
* TForm2
* USAGE
* Объект форму 2
* SYNOPSIS
* :TForm2
* EXAMPLE
* exemple:TForm2;
 ****}
  TForm2 = class(TForm)
    Label1: TLabel;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    procedure BS_sort;
    procedure SaveStringGrid(StringGrid: TStringGrid);
    procedure LoadStringGrid(StringGrid: TStringGrid);
    procedure Slipknot4(o4ivment:integer);
  end;

var
  Form2: TForm2;

implementation

uses unit1,unit3;

{$R *.lfm}

{ TForm2 }

{****p* score/TForm2.FormCreate
* NAME
* TForm2.FormCreate
* USAGE
* Процедура обновления счета
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TForm2.FormCreate(Sender: TObject);
* EXAMPLE
*  FormCreate(self);
****}
procedure TForm2.FormCreate(Sender: TObject);
begin
  LoadStringGrid(StringGrid1);
end;

{****p* score/TForm2.BS_sort
* NAME
* TForm2.BS_sort
* USAGE
* Процедура сортировки счета
* SYNOPSIS
*  TForm2.BS_sort;
* EXAMPLE
*  BS_sort(self);
****}
procedure TForm2.BS_sort;
var
  cik1, cik2, last: integer;
  Count: array[1..2] of string;
  n_izm: boolean;
begin
  repeat
    n_izm := True;
    for cik1 := 2 to 5 do
    begin
      if (StringGrid1.Cells[2, cik1] = '') and
        (StringGrid1.Cells[2, cik1 + 1] <> '') then
      begin
        n_izm := False;
        for cik2 := 1 to 2 do
        begin
          Count[cik2] := StringGrid1.Cells[cik2, cik1 + 1];
          StringGrid1.Cells[cik2, cik1 + 1] := StringGrid1.Cells[cik2, cik1];
          StringGrid1.Cells[cik2, cik1] := Count[cik2];
        end;
      end;
    end;
  until n_izm;
  for cik1 := 1 to 6 do
    if StringGrid1.Cells[2, cik1] <> '' then
      last := cik1;
  repeat
    n_izm := True;
    for cik1 := 1 to last - 1 do
    begin
      if (StrToInt(StringGrid1.Cells[2, cik1]) <
        StrToInt(StringGrid1.Cells[2, cik1 + 1])) then
      begin
        n_izm := False;
        for cik2 := 1 to 2 do
        begin
          Count[cik2] := StringGrid1.Cells[cik2, cik1 + 1];
          StringGrid1.Cells[cik2, cik1 + 1] := StringGrid1.Cells[cik2, cik1];
          StringGrid1.Cells[cik2, cik1] := Count[cik2];
        end;
      end;
    end;
  until n_izm;
end;

{****p* score/TForm2.SaveStringGrid
* NAME
* TForm2.SaveStringGrid
* USAGE
* Процедура сохранения счета
* INPUTS
* таблица для сохранения
* StringGrid: TStringGrid;
* SYNOPSIS
*  TForm2.SaveStringGrid(StringGrid: TStringGrid);
* EXAMPLE
*  SaveStringGrid(StringGrid1);
****}
procedure TForm2.SaveStringGrid(StringGrid: TStringGrid);
var
  f: file of player;
  i: integer;
  one_pay: player;
begin
   {$I-}
  AssignFile(f, 'score.sav');
  Rewrite(f);
   {$I+}
  if IOresult <> 0 then
  begin
    ShowMessage('ERRoR Save');
  end
  else
  begin
    with StringGrid do
    begin
      for i := 1 to 5 do
      begin
        one_pay.Name := Cells[1, i];
        one_pay.score := Cells[2, i];
    {$I-}
        Write(F, one_pay);
    {$I+}
        if IOresult <> 0 then
          ShowMessage('ERRoR Save');
      end;
    end;
    CloseFile(F);
  end;
end;

{****p* score/TForm2.LoadStringGrid
* NAME
* TForm2.LoadStringGrid
* USAGE
* Процедура загрузки счета
* INPUTS
* таблица для загрузки
* StringGrid: TStringGrid;
* SYNOPSIS
*  TForm2.LoadStringGrid(StringGrid: TStringGrid);
* EXAMPLE
*  LoadStringGrid(StringGrid1);
****}
procedure TForm2.LoadStringGrid(StringGrid: TStringGrid);
var
  f: file of player;
  i, j: integer;
  strtemp: player;
begin
 {$I-}
  AssignFile(f, 'score.sav');
  Reset(f);
 {$I+}
  if IOresult <> 0 then
  begin
    for i := 1 to 2 do
      for j := 1 to 5 do
        StringGrid.Cells[i, j] := '';
  end
  else
  begin
    with StringGrid do
    begin
      for i := 1 to 5 do
      begin
    {$I-}
        Read(f, strtemp);
    {$I+}
        if IOresult <> 0 then
        begin
          ShowMessage('ERRoR Save');
          Close;
        end;
        Cells[1, i] := strtemp.Name;
        Cells[2, i] := strtemp.score;
      end;
    end;
    CloseFile(f);
  end;
end;

{****p* Slipknot/TForm2.Slipknot4
* NAME
* TForm2.Slipknot4
* USAGE
* Процедура проверки Slipknot
* INPUTS
* очки
* x, y: extended;
* o4ivment:integer;
* SYNOPSIS
* TForm2.Slipknot4(o4ivment:integer);
* EXAMPLE
* Slipknot4(1488);
 ****}
procedure TForm2.Slipknot4(o4ivment:integer);
begin
    if (o4ivment > 66600) then
    begin
      showmessage('Achievement unlocked "Slipknot".');
      Brush.Bitmap := TBitMap.Create;
      Disturbed.img := brush.Bitmap.CreateIntfImage;
      Disturbed.img.LoadFromFile('.\img\666.bmp');
      Slipknot.Brush.Bitmap := TBitMap.Create;
      Slipknot.Brush.Bitmap.LoadFromIntfImage(Disturbed.img);
      Slipknot.ShowModal;
    end;
end;

end.
