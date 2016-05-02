unit Unit1;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Math, IntfGraphics, Menus;

type
{****t* Engine/TBall
* NAME
* TBall
* USAGE
* Объект описывающий шар
* INPUTS
* координаты центра шара
* x, y: extended;
* текущее изменения координат
* dx, dy: extended;
* SYNOPSIS
* :TBall
* EXAMPLE
* exemple:TBall;
 ****}

  TBall = record
    x, y: extended; //координаты центра шара
    dx, dy: extended; // текущее изменения координат
    r, d: float; //radius,diameter
  end;
  {****t* Engine/TLine
  * NAME
  * TLine
  * USAGE
  * Объект описывающий линию
  * INPUTS
  * координаты  концов  линии
  *  x1, y1, x2, y2: longint;
  * очки заработанные за  столкновение с  этой линией.
  * score: integer;
  * SYNOPSIS
  * :TLine
  * EXAMPLE
  * exemple:TLine;
   ****}
  TLine = record
    x1, y1, x2, y2: longint;    //координаты  концов  линии
    power: extended; //энергия  которую  передаем  шару  при столкновении
    ugol: extended; //угол  прибавляемый к   углу  отскока
    score: integer;  //очки заработанные за  столкновение с  этой линией
  end;

  { TDisturbed }

  {****t* Engine/TDisturbed
  * NAME
  * TDisturbed
  * USAGE
  * Объект описывающий всю форму
  * SYNOPSIS
  * :TDisturbed
  * EXAMPLE
  * exemple:TDisturbed;
   ****}
  TDisturbed = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox2: TPaintBox;
    Shape1: TShape;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Label3Click(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    {private declaration}
  public
    Sh_data: TBall; //шар
    CountLine: integer; //кол-во линий
    Lines: array[0..100] of TLine;//массив линий
    img: TLazIntfImage;
    score, best_score: longint; //очки
    scopuli: boolean;
    lf_bt, rg_bt: real; // углы поворота левого и правого  битка
    lf_dx, rg_dx: real; // скорость левого и правого битков
    procedure AddLine(scr, power, ugol, x1, y1, x2, y2: longint); //добавление линии
    procedure RollBall; // процедура движения шара
    procedure DrawTable; // рисование стола
    procedure Init; // расстановка линий  и шара
    procedure ColorOfPowe(i: integer);
    procedure left_bitok;
    procedure right_bitok;
    procedure Interceptor(n: integer);
    function InterceptorCircleLine(cx, cy, radius, p1x, p1y, p2x,
      p2y: extended): boolean;
    function GetAngle(x1, y1, x2, y2: extended): extended;  //получаем угол
    function SizeTwoDot(x1, y1, x2, y2: extended): real; //получаем растояние
  end;

var
  Disturbed: TDisturbed;

implementation

uses unit2;

{$R *.lfm}

{ TDisturbed }
const
  Grav_acel = 0.01981;

{****p* logic/TDisturbed.Timer1Timer
* NAME
* TDisturbed.Timer1Timer
* USAGE
* Процедура таймера
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TDisturbed.Timer1Timer(Sender: TObject);
* EXAMPLE
*  Timer1Timer(self);
****}
procedure TDisturbed.Timer1Timer(Sender: TObject);
begin
  RollBall;
  left_bitok;
  right_bitok;
end;

{****p* logic/TDisturbed.AddLine
* NAME
* TDisturbed.AddLine
* USAGE
* Процедура добавления линии
* INPUTS
* счет, сила, угол, точки начала и конца линии.
* (scr, power, ugol, x1, y1, x2, y2: longint);
* SYNOPSIS
*  TDisturbed.AddLine(scr, power, ugol, x1, y1, x2, y2: longint);
* EXAMPLE
*  AddLine(0,0,0,0,0,1,1);
 ****}
procedure TDisturbed.AddLine(scr, power, ugol, x1, y1, x2, y2: longint);
begin
  Inc(CountLine);
  Lines[CountLine].x1 := x1;
  Lines[CountLine].x2 := x2;
  Lines[CountLine].y1 := y1;
  Lines[CountLine].y2 := y2;
  Lines[CountLine].score := round(scr);
  Lines[CountLine].power := power;
  Lines[CountLine].ugol := ugol;
end;

{****p* logic/TDisturbed.RollBall
* NAME
* TDisturbed.RollBall
* USAGE
* Процедура перемешения шара
* SYNOPSIS
*  TDisturbed.RollBall;
* EXAMPLE
*  RollBall;
 ****}
procedure TDisturbed.RollBall;
var
  i: integer;
begin
  if sh_data.dx>5 then sh_data.dx := 5;
  if sh_data.dy>5 then sh_data.dy := 5;
  scopuli := True;
  Paintbox2.Canvas.Pen.color := clwhite;
  for i := 0 to countLine do
    Interceptor(i);
  if scopuli then
  begin
    sh_data.x := sh_data.x + sh_data.dx;
    sh_data.y := sh_data.y + sh_data.dy;
    Shape1.Top := round(sh_data.y);
    Shape1.Left := round(sh_data.x);
  end;
  sh_data.dy := sh_data.dy + Grav_acel;
end;

{****p* graph/TDisturbed.DrawTable
* NAME
* TDisturbed.DrawTable
* USAGE
* Процедура прорисовки стола
* SYNOPSIS
*  TDisturbed.DrawTable;
* EXAMPLE
*  DrawTable;
 ****}
procedure TDisturbed.DrawTable;
var
  i: integer;
begin
  for i := 0 to countline do
  begin
    with PaintBox2.canvas do
    begin
      ColorOfPowe(i);
      Line(Lines[i].x1, Lines[i].y1, Lines[i].x2, Lines[i].y2);
    end;
  end;
end;

{****p* logic/TDisturbed.Init
* NAME
* TDisturbed.Init
* USAGE
* Процедура инициализации
* SYNOPSIS
*  TDisturbed.Init;
* EXAMPLE
*  Init;
 ****}
procedure TDisturbed.Init;
begin
  score := 0;
  label2.Caption := IntToStr(score);
  countline := -1;
  sh_data.dx := 0;
  sh_data.dy := 0;
  lf_bt := 30;
  rg_bt := 150;
  lf_dx := 0;
  rg_dx := 0;

  addline(500, 666, 0, 135, 571, 165, 580);
  addline(500, 666, 0, 215, 580, 245, 571);
  addline(100, 0, 0, 0, 540, 132, 570);
  addline(100, 0, 0, 248, 570, 376, 540);

  addline(0, -1, 0, 378, 580, 400, 580);
  addline(0, -1, 0, 0, 598, 398, 598);

  addline(100, 0, 0, 0, 2, 400, 2);
  addline(100, 0, 0, 398, 0, 398, 600);
  addline(100, 0, 0, 2, 0, 2, 600);
  addline(100, 0, 0, 377, 65, 377, 600);

  addline(100, 0, 0, 275, 490, 320, 470);
  addline(100, 0, 0, 320, 470, 320, 420);
  addline(250, 100, 0, 275, 490, 320, 420);

  addline(100, 0, 0, 105, 490, 60, 470);
  addline(100, 0, 0, 60, 470, 60, 420);
  addline(250, 100, 0, 105, 490, 60, 420);

  {addline(100, 0, 0, 275, 515, 345, 483);
  addline(100, 0, 0, 345, 483, 345, 410);
  addline(100, 0, 0, 105, 515, 35, 483);
  addline(100, 0, 0, 35, 483, 35, 410);}

  addline(100, 0, 0, 400, 60, 375, 30);
  addline(100, 0, 0, 375, 30, 325, 0);

  addline(100, 0, 0, 40, 100, 70, 130);
  addline(100, 0, 0, 70, 130, 100, 100);
  addline(100, 0, 0, 100, 100, 70, 70);
  addline(100, 0, 0, 70, 70, 40, 100);

  addline(100, 0, 0, 240, 100, 270, 130);
  addline(100, 0, 0, 270, 130, 300, 100);
  addline(100, 0, 0, 300, 100, 270, 70);
  addline(100, 0, 0, 270, 70, 240, 100);

  addline(100, 0, 0, 125, 200, 225, 200);
  addline(100, 0, 0, 225, 200, 225, 300);
  addline(100, 0, 0, 225, 300, 125, 300);
  addline(100, 0, 0, 125, 300, 125, 200);

  addline(100, 0, 0, 0, 60, 25, 30);
  addline(100, 0, 0, 25, 30, 75, 0);

  sh_data.x := 383;
  sh_data.y := 567;
end;

{****p* graph/TDisturbed.ColorOfPowe
* NAME
* TDisturbed.ColorOfPowe
* USAGE
* Процедура для определения цвета линии
* INPUTS
* Номер линии.
* i: integer;
* SYNOPSIS
*  TDisturbed.ColorOfPowe(i: integer);
* EXAMPLE
*  ColorOfPowe(5);
 ****}
procedure TDisturbed.ColorOfPowe(i: integer);
begin
  with PaintBox2.canvas do
  begin
    if ((Lines[i].power >= 500)) then
    begin
      pen.color := clRed;
      pen.Width := 5;
    end;
    if (Lines[i].power > 0) and (Lines[i].power < 500) then
    begin
      pen.color := clBlue;
      pen.Width := 5;
    end;
    if Lines[i].power = 0 then
    begin
      pen.color := clGreen;
      pen.Width := 4;
    end;
    if Lines[i].power < 0 then
    begin
      pen.Color := $3AA3AA3A;
      pen.Width := 4;
    end;
  end;
end;

{****p* graph/TDisturbed.left_bitok
* NAME
* TDisturbed.left_bitok
* USAGE
* Процедура управления левым битком
* SYNOPSIS
*  TDisturbed.left_bitok;
* EXAMPLE
*  left_bitok;
 ****}
procedure TDisturbed.left_bitok;
begin
  lf_dx := lf_dx + 0.5;
  lf_bt := lf_bt + lf_dx;
  if lf_bt > 30 then
  begin
    lf_bt := 30;
    lf_dx := 0;
  end;
  if lf_bt < -25 then
  begin
    lf_bt := -25;
    lf_dx := 0;
  end;
  ColorOfPowe(0);
  if (round(Lines[0].y1) <> (round(Lines[0].y2 + 35 * sin(rg_bt * pi / 180)))) then
    Paintbox2.Invalidate;
  Lines[0].x2 := round(Lines[0].x1 + 35 * cos(lf_bt * pi / 180));
  Lines[0].y2 := round(Lines[0].y1 + 35 * sin(lf_bt * pi / 180));
  PaintBox2.canvas.Line(Lines[0].x1, Lines[0].y1, Lines[0].x2, Lines[0].y2);
end;

{****p* graph/TDisturbed.right_bitok
* NAME
* TDisturbed.right_bitok
* USAGE
* Процедура управления левым битком
* SYNOPSIS
*  TDisturbed.right_bitok;
* EXAMPLE
*  right_bitok;
 ****}
procedure TDisturbed.right_bitok;
begin
  rg_dx := rg_dx - 0.5;
  rg_bt := rg_bt + rg_dx;
  if rg_bt > 205 then
  begin
    rg_bt := 205;
    rg_dx := 0;
  end;
  if rg_bt < 150 then
  begin
    rg_bt := 150;
    rg_dx := 0;
  end;
  ColorOfPowe(0);
  if (round(Lines[1].y1) <> (round(Lines[1].y2 + 35 * sin(rg_bt * pi / 180)))) then
    Paintbox2.Invalidate;
  Lines[1].x1 := round(Lines[1].x2 + 35 * cos(rg_bt * pi / 180));
  Lines[1].y1 := round(Lines[1].y2 + 35 * sin(rg_bt * pi / 180));
  PaintBox2.canvas.Line(Lines[1].x1, Lines[1].y1, Lines[1].x2, Lines[1].y2);
end;

{****p* logic/TDisturbed.Interceptor
* NAME
* TDisturbed.Interceptor
* USAGE
* Процедура упругого отскока
* INPUTS
* Номер линии.
* n: integer;
* SYNOPSIS
*  TDisturbed.Interceptor(n: integer);
* EXAMPLE
*  Interceptor(4);
 ****}
procedure TDisturbed.Interceptor(n: integer);
var
  a, b, y, c: extended;
  str: string;
begin
  if (InterceptorCircleLine(shape1.Left + 5, Shape1.Top + 5, Shape1.Height /
    2, Lines[n].x1, Lines[n].y1, Lines[n].x2, Lines[n].y2)) then
  begin
    Inc(score, Lines[n].score);
    label2.Caption := IntToStr(score);
    scopuli := False;
    if (SizeTwoDot(sh_data.x,sh_data.y,lines[n].x1,lines[n].y1)<7)
     or (SizeTwoDot(sh_data.x,sh_data.y,lines[n].x2,lines[n].y2)<7)
    then
    Begin
      sh_data.dx:=-sh_data.dx;
      sh_data.dy:=-sh_data.dy;
    end else
    Begin
    a := GetAngle(sh_data.x, sh_data.y,sh_data.x+sh_data.dx, sh_data.y+sh_data.dy);
    b := GetAngle(Lines[n].x1, Lines[n].y1, Lines[n].x2, Lines[n].y2);
    y := 2 * b - a;
    c := (Sqrt(Sqr(Sh_data.dx) + sqr(Sh_data.dy)))*0.99;
     sh_data.dx := c * cos(y * pi / 180);  //высчитываем  приращения  для  движения
     sh_data.dy := c * sin(y * pi / 180);
    end;
    if Lines[n].power < 0 then
    begin
      Timer1.Enabled := False;
      ShowMessage('You lose');
      Form2.Slipknot4(score);
      str := InputBox('Сохранение игрока', 'Введите ваше имя :', 'player1');
      Form2.StringGrid1.Cells[1, 6] := str;
      Form2.StringGrid1.Cells[2, 6] := IntToStr(score);
      Form2.BS_sort;
      Form2.SaveStringGrid(Form2.StringGrid1);
      init;
    end;
    if (sh_data.dx > -0.2) and (sh_data.dx < 0) then
      sh_data.dx := -0.2;
    if (sh_data.dx < 0.2) and (sh_data.dx > 0) then
      sh_data.dx := 0.2;
    if (sh_data.dy < 0.2) and (sh_data.dy > 0) then
      sh_data.dy := 0.2;
    sh_data.x := sh_data.x + sh_data.dx;  //и сразу  двигаем  шар
    sh_data.y := sh_data.y + sh_data.dy;
    shape1.Top := round(sh_data.y);
    shape1.Left := round(sh_data.x);
  end;
end;

{****f* logic/TDisturbed.InterceptorCircleLine
* NAME
* TDisturbed.InterceptorCircleLine
* USAGE
* Процедура для проверки пересечения линии
* INPUTS
* cx, cy: extended; координаты центра шара
* radius :extended; радиус
* p1x, p1y, p2x, p2y: extended; координаты начала и конца линии
* SYNOPSIS
*  TDisturbed.InterceptorCircleLine(cx, cy, radius, p1x, p1y, p2x, p2y: extended): boolean;
* EXAMPLE
* InterceptorCircleLine(0,0,0,0,0,0,0);
 ****}
function TDisturbed.InterceptorCircleLine(cx, cy, radius, p1x, p1y, p2x,
  p2y: extended): boolean;
var
  dx, dy, a, b, c, x01, x02, y01, y02: extended;
begin
  radius := radius * 1.1;
  x01 := p1x - cx;
  y01 := p1y - cy;
  x02 := p2x - cx;
  y02 := p2y - cy;
  dx := x02 - x01;
  dy := y02 - y01;

  a := dx * dx + dy * dy;
  b := 2.0 * (x01 * dx + y01 * dy);
  c := x01 * x01 + y01 * y01 - radius * radius;
  if (-b < 0) then
    Result := (c < 0)
  else if (-b < (2.0 * a)) then
    Result := (4.0 * a * c - b * b < 0)
  else
    Result := (a + b + c < 0);
end;

{****f* logic/TDisturbed.GetAngle
* NAME
* TDisturbed.GetAngle
* USAGE
* Процедура для получения угла относительно горизонтали
* INPUTS
* x1, y1, x2, y2: single; координаты начала и конца линии
* SYNOPSIS
*  TDisturbed.GetAngle(x1, y1, x2, y2: single): single;
* EXAMPLE
*  GetAngle(0,0,0,0);
 ****}
function TDisturbed.GetAngle(x1, y1, x2, y2: extended): extended;
begin
  GetAngle := (ArcTan2(y2 - y1, x2 - x1)) * 180 / pi;
end;

{****f* logic/TDisturbed.SizeTwoDot
* NAME
* TDisturbed.SizeTwoDot
* USAGE
* Процедура для получения длины линии
* INPUTS
* x1, y1, x2, y2: extended; координаты начала и конца линии
* SYNOPSIS
*  TDisturbed.SizeTwoDot(x1, y1, x2, y2: extended): real;
* EXAMPLE
*  SizeTwoDot(0,0,0,0);
 ****}
function TDisturbed.SizeTwoDot(x1, y1, x2, y2: extended): real;
begin
  Result := Sqrt(sqr(x1 - x2) + sqr(y1 - y2));
end;

{****p* graph/TDisturbed.FormCreate
* NAME
* TDisturbed.FormCreate
* USAGE
* Процедура создания формы
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TDisturbed.FormCreate(Sender: TObject);
* EXAMPLE
*  FormCreate(self);
 ****}
procedure TDisturbed.FormCreate(Sender: TObject);
begin
  sh_data.d := Shape1.Width;
  sh_data.r := Shape1.Width / 2;
  Init;
  Shape1.Top := round(sh_data.y);
  Shape1.Left := round(sh_data.x);
  Brush.Bitmap := TBitMap.Create;
  img := brush.Bitmap.CreateIntfImage;
  img.LoadFromFile('.\img\back.bmp');
  Brush.Bitmap.LoadFromIntfImage(img);
  Paintbox2.Canvas.Brush.Bitmap := TBitMap.Create;
  Paintbox2.Canvas.Brush.Bitmap.LoadFromIntfImage(img);
end;

{****p* logic/TDisturbed.FormCloseQuery
* NAME
* TDisturbed.FormCloseQuery
* USAGE
* Процедура быстрого закрытия программы
* INPUTS
* Sender: TObject;
* CanClose: boolean; можем закрыть или нет
* SYNOPSIS
*  TDisturbed.FormCloseQuery(Sender: TObject; var CanClose: boolean);
* EXAMPLE
*  FormCloseQuery(self,true);
 ****}
procedure TDisturbed.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Timer1.Enabled := False;
  CanClose := MessageDlg('Вы хотите закрыть игру?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;
  if not (canclose) then
    Timer1.Enabled := True;
end;

{****p* logic/TDisturbed.FormDestroy
* NAME
* TDisturbed.FormDestroy
* USAGE
* Процедура закрытия программы
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TDisturbed.FormDestroy(Sender: TObject);
* EXAMPLE
*  FormDestroy(self);
 ****}
procedure TDisturbed.FormDestroy(Sender: TObject);
begin
  Brush.Bitmap.Destroy;
end;

{****p* logic/TDisturbed.FormKeyDown
* NAME
* TDisturbed.FormKeyDown
* USAGE
* Процедура перехвата нажатия клавиш
* INPUTS
* Sender: TObject;
* Key: word; номер нажатой кнопки
* SYNOPSIS
*  TDisturbed.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
* EXAMPLE
*  FormKeyDown(self,13,bt,ssShift);
 ****}
procedure TDisturbed.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if key = 32 then //start(space)
  begin
    if not (Timer1.Enabled) then
    begin
      Timer1.Enabled := True;
      sh_data.dx := 0;
      sh_data.dy := -5.15;
    end;
  end;
  if key = 37 then //left bitok
  begin
    lf_dx := -5;
  end;
  if key = 39 then //right bitok
  begin
    rg_dx := 5;
  end;
  if key = 27 then //exit (esc)
  begin
    Close;
  end;
end;

{****p* score/TDisturbed.Label3Click
* NAME
* TDisturbed.Label3Click
* USAGE
* Процедура отображения счета
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TDisturbed.Label3Click(Sender: TObject);
* EXAMPLE
*  Label3Click(self);
 ****}
procedure TDisturbed.Label3Click(Sender: TObject);
var
  game_stop: boolean;
begin
  game_stop := Timer1.Enabled;
  Timer1.Enabled := False;
  form2.ShowModal;
  Timer1.Enabled := game_stop;
end;

{****p* graph/TDisturbed.PaintBox2Paint
* NAME
* TDisturbed.PaintBox2Paint
* USAGE
* Процедура рисовки стола при обновлении канвы
* INPUTS
* Sender: TObject;
* SYNOPSIS
*  TDisturbed.PaintBox2Paint(Sender: TObject);
* EXAMPLE
*  PaintBox2Paint(self);
 ****}
procedure TDisturbed.PaintBox2Paint(Sender: TObject);
begin
  DrawTable;
end;

end.
