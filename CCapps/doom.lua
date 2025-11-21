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
width,height = term.getSize()
x,y = LineLineIntersection(0,0,width,height,width,0,0,height)
p1 = {1,1}
p2 = {width,(height/2)*3}
p3 = {width,1}
p4 = {1,(height/2)*3}

function draw()
  screenLib.setPixel(p1[1],p1[2],'e')
  screenLib.setPixel(p2[1],p2[2],'e')
  screenLib.setPixel(p3[1],p3[2],'e')
  screenLib.setPixel(p4[1],p4[2],'e')
  x = math.floor(x)
  y = math.floor(y)
  screenLib.setPixel(x,y,'b')
  screenLib.draw()
end

current = 0

while true do
  x,y = LineLineIntersection(0,0,width,height,width,0,0,height)
  draw()
  EventParm = os.pullEvent()
  Event = EventParm[1]
  if Event == 'mouse_click' then
    if p1[1] == EventParm[3] and p1[2] == EventParm[4] then
      current = 1
    elseif p2[1] == EventParm[3] and p2[2] == EventParm[4] then
      current = 2
    elseif p3[1] == EventParm[3] and p3[2] == EventParm[4] then
      current = 3
    elseif p4[1] == EventParm[3] and p4[2] == EventParm[4] then
      current = 4
    end
  elseif Event == 'mouse_up' then
    current = 0
  elseif Event == 'mouse_drag' then
    if current > 0 then
      if current == 1 then
        p1[1] = EventParm[3]
        p1[2] = EventParm[4]
      elseif current == 2 then
        p2[1] = EventParm[3]
        p2[2] = EventParm[4]
      elseif current == 3 then
        p3[1] = EventParm[3]
        p3[2] = EventParm[4]
      elseif current == 4 then
        p4[1] = EventParm[3]
        p4[2] = EventParm[4]
      end
    end
  end
end
