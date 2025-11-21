require('libs/screen')

function LineLineIntersection(X1,Y1,X2,Y2,X3,Y3,X4,Y4)
  local t_top = ((X1-X3)*(Y3-Y4)) - ((Y1-Y3)*(X3-X4))
  local t_bottom = ((X1-X2)*(Y3-Y4)) - ((Y1-Y2)*(X3-X4))
  local t = t_top/t_bottom
  local ItX, ItY
  ItX = X1 + t*(X2-X1)
  ItY = Y1 + t*(Y2-Y1)
  return ItX,ItY
end

function draw()
end

map = {
  {-15,20,15,20},
  {-15,20,-20,15},
  {-20,15,-20,-15},
}

x,y = 0,0

while true do
  e,p1 = os.pullEvent()
end
