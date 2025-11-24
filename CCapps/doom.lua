require('libs/screen')

trueHeight = (height/2)*3

function LineLineIntersection(X1,Y1,X2,Y2,X3,Y3,X4,Y4)
  local t_top = ((X1-X3)*(Y3-Y4)) - ((Y1-Y3)*(X3-X4))
  local t_bottom = ((X1-X2)*(Y3-Y4)) - ((Y1-Y2)*(X3-X4))
  local t = t_top/t_bottom
  local ItX, ItY
  ItX = X1 + t*(X2-X1)
  ItY = Y1 + t*(Y2-Y1)
  return ItX,ItY,t
end


size = 20
corner = 11.5
currentRoom = 1
fov = width
dir = 0
x,y = 0,0
debug = ''

map = {
  {
    {-corner,size,corner,size},   --top
    {-size,corner,-size,-corner}, --left
    {size,corner,size,-corner},   --right
    {-corner,-size,corner,size},  --bottom

    {-size,corner,-corner,size},  --top    left
    {size,corner,corner,size},    --top    right
    {-corner,-size,-size,-corner},--bottom left
    {corner,-size,size,-corner},  --bottom right
  },
}

function calcRoom(lDir,room,listOfDIstances)
  for i,v in pairs(room) do
    local hitX,hitY,t = LineLineIntersection(x,y,x+math.sin(lDir),y+math.cos(lDir),  v[1],v[2],v[3],v[4])
    listOfDIstances[#listOfDIstances+1] = t
  end
end

function draw()
  screenLib.clear()
  file = fs.open('debug.txt','w')
  for x=1,width do
    local lDir = dir-(fov/2)+x
    local tLIST = {}
    calcRoom(lDir,map[currentRoom],tLIST)
    lowest = 99999999999
    lowestID = 1
    for i,v in pairs(tLIST) do
      if v < lowest and v > 0 then
        lowest = v
        lowestID = i
      end
    end
    file.writeLine(lowest)
    lineHeight = lowest/2

    for y=1,lineHeight do
      screenLib.setPixel(x,y+(trueHeight/2)-(lineHeight/2),'a')
    end
  end
  file.close()
  screenLib.draw()
  term.setCursorPos(1,1)
  term.setBackgroundColor(colors.black)
  term.write(debug)
end


while true do
  draw()
  e,p1 = os.pullEvent()
  if e == 'key' then
    debug = tostring(p1)
    if p1 == 262 then
      dir = dir + 1
    elseif p1 == 263 then
      dir = dir - 1
    end
  end
end
