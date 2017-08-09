unit WorkWithRect;

interface
 uses Windows, Classes;


procedure Scale(var RRect:TRect; ScaleValue:Integer);
function Scaled(const RRect:TRect; ScaleValue:Integer):TRect;
function Rect(Position:TPoint; Height, Width:Word):TRect; overload;

implementation

procedure Scale(var RRect:TRect; ScaleValue:Integer);
begin
 with RRect do
  begin
   Top:=Top - ScaleValue;
   Left:=Left - ScaleValue;
   Right:=Right + ScaleValue;
   Bottom:=Bottom + ScaleValue;
  end;
end;

function Scaled(const RRect:TRect; ScaleValue:Integer):TRect;
var Tmp:TRect;
begin
 Tmp:=RRect;
 Scale(Tmp, ScaleValue);
 Result:=Tmp;
end;

function Rect(Position:TPoint; Height, Width:Word):TRect;
begin
 Result:=Classes.Rect(Position.X, Position.Y, Position.X + Width, Position.Y + Height);
end;

end.
 