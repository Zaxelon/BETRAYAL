unit Unit1;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Math, IntfGraphics;

type

  TBall = record
    x, y: extended; //координаты центра шара
    dx, dy: extended; // текущее изменения координат
    r, d: float; //radius,diameter
  end;

  TLine = record
    x1, y1, x2, y2: longint;    //координаты  концов  линии
    power: extended; //энергия  которую  передаем  шару  при столкновении
    ugol: extended; //угол  прибавляемый к   углу  отскока
    score: integer;  //очки заработанные за  столкновение с  этой линией
  end;

  { TForm1 }

  TForm1 = class(TForm)
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
    function InterceptorCircleLine(centerx, centery, radius, p1x, p1y,
      p2x, p2y: extended): boolean;
    function GetAngle(x1, y1, x2, y2: single): single; //получаем угол
    function SizeTwoDot(x1, y1, x2, y2: extended): real; //получаем растояние
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
const
  Grav_acel = 0.002181;
  Friction = 0.9998;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  RollBall;
  left_bitok;
  right_bitok;
end;

procedure TForm1.AddLine(scr, power, ugol, x1, y1, x2, y2: longint);
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

procedure TForm1.RollBall;
var
  i: integer;
begin
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
  sh_data.dx := sh_data.dx * Friction;
  sh_data.dy := sh_data.dy * Friction + Grav_acel;
end;

procedure TForm1.DrawTable;
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

procedure TForm1.Init;
begin
  score := 0;
  countline := -1;
  sh_data.dx := 0;
  sh_data.dy := 0;
  lf_bt := 30;
  rg_bt := 150;
  lf_dx := 0;
  rg_dx := 0;

  addline(500, 666, 0, 145, 570, 175, 580);
  addline(500, 666, 0, 205, 580, 235, 570);

  addline(0, -1, 0, 378, 580, 400, 580);
  addline(-10000, -100, 0, 0, 598, 398, 598);

  addline(100, 0, 0, 0, 2, 400, 2);
  addline(100, 0, 0, 398, 0, 398, 600);
  addline(100, 0, 0, 2, 0, 2, 600);

  addline(100, 0, 0, 377, 100, 377, 600);
  addline(100, 0, 0, 0, 540, 145, 570);
  addline(100, 0, 0, 235, 570, 376, 540);

  addline(100, 0, 0, 275, 490, 320, 470);
  addline(100, 0, 0, 320, 470, 320, 420);
  addline(250, 100, 0, 275, 490, 320, 420);

  addline(100, 0, 0, 105, 490, 60, 470);
  addline(100, 0, 0, 60, 470, 60, 420);
  addline(250, 100, 0, 105, 490, 60, 420);

  addline(100, 0, 0, 275, 515, 345, 483);
  addline(100, 0, 0, 345, 483, 345, 410);

  addline(100, 0, 0, 105, 515, 35, 483);
  addline(100, 0, 0, 35, 483, 35, 410);

  addline(100, 0, 0, 400, 60, 375, 30);
  addline(100, 0, 0, 375, 30, 325, 0);

  addline(100, 0, 0, 0, 60, 25, 30);
  addline(100, 0, 0, 25, 30, 75, 0);

  sh_data.x := 384;
  sh_data.y := 563;
end;

procedure TForm1.ColorOfPowe(i: integer);
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

procedure TForm1.left_bitok;
begin
  lf_dx := lf_dx + 1;
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

procedure TForm1.right_bitok;
begin
  rg_dx := rg_dx - 1;
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

procedure TForm1.Interceptor(n: integer);
var
  a, b, y, c: extended;
begin
  if (InterceptorCircleLine(shape1.Left + 5, Shape1.Top + 5, Shape1.Height / 2,
    Lines[n].x1, Lines[n].y1, Lines[n].x2, Lines[n].y2)) then
  begin
    Inc(score, Lines[n].score);
    label2.Caption := IntToStr(score);
    if score > best_score then
    begin
      best_score := score;
      label4.Caption := IntToStr(best_score);
    end;
    scopuli := False;
    a := GetAngle(0, 0, sh_data.dx, sh_data.dy);
    b := GetAngle(Lines[n].x1, Lines[n].y1, Lines[n].x2, Lines[n].y2);
    y := 2 * b - a + Lines[n].ugol;
    c := (Sqrt(Sqr(Sh_data.dx) + sqr(Sh_data.dy))) * 0.99;// + lines[n].power;
    if Lines[n].power < 0 then
    begin
      Timer1.Enabled := False;
      ShowMessage('You lose');
      init;
    end;
    if Lines[n].power = 666 then
      c := (Sqrt(Sqr(Sh_data.dx) + sqr(Sh_data.dy))) * 1.2;
    sh_data.dx := c * cos(y * pi / 180);  //высчитываем  приращения  для  движения
    sh_data.dy := c * sin(y * pi / 180);
    sh_data.x := sh_data.x + sh_data.dx;  //и сразу  двигаем  шар
    sh_data.y := sh_data.y + sh_data.dy;
    shape1.Top := round(sh_data.y);
    shape1.Left := round(sh_data.x);
  end;
end;

function TForm1.InterceptorCircleLine(centerx, centery, radius, p1x,
  p1y, p2x, p2y: extended): boolean;
var
  dx, dy, a, b, c, x01, x02, y01, y02: extended;
begin
  x01 := p1x - centerx;
  y01 := p1y - centery;
  x02 := p2x - centerx;
  y02 := p2y - centery;

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

function TForm1.GetAngle(x1, y1, x2, y2: single): single;
begin
  GetAngle := (ArcTan2(y2 - y1, x2 - x1)) * 180 / pi;
end;

function TForm1.SizeTwoDot(x1, y1, x2, y2: extended): real;
begin
  Result := Sqrt(sqr(x1 - x2) + sqr(y1 - y2));
end;

procedure TForm1.FormCreate(Sender: TObject);
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

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Timer1.Enabled := False;
  CanClose := MessageDlg('Вы хотите закрыть игру?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;
  if not (canclose) then
    Timer1.Enabled := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Brush.Bitmap.Destroy;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if key = 32 then //start(space)
  begin
    if not (Timer1.Enabled) then
    begin
      Timer1.Enabled := True;
      sh_data.dx := 0;
      sh_data.dy := -2.3;
    end;
  end;
  if key = 37 then //left bitok
  begin
    lf_dx := lf_dx - 15;
  end;
  if key = 39 then //right bitok
  begin
    rg_dx := rg_dx + 15;
  end;
  if key = 27 then //exit (esc)
  begin
    Close;
  end;
end;

procedure TForm1.PaintBox2Paint(Sender: TObject);
begin
  DrawTable;
end;

end.