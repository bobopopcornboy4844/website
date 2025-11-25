require('libs/screen')

trueHeight = (height/2)*3

function LineLineIntersection(X1,Y1,X2,Y2,X3,Y3,X4,Y4)
  local t_top = ((X1-X3)*(Y3-Y4)) - ((Y1-Y3)*(X3-X4))
  local u_top = ((X1-X2)*(Y1-Y3)) - ((Y1-Y2)*(X1-X3))
  local t_bottom = ((X1-X2)*(Y3-Y4)) - ((Y1-Y2)*(X3-X4))
  local t = t_top/t_bottom
  local u = u_top/t_bottom
  if not (u and t) then
    error('g')
  end
  local ItX, ItY
  ItX = X1 + t*(X2-X1)
  ItY = Y1 + t*(Y2-Y1)
  return ItX,ItY,t,u
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

function calcRoom(lDir,room,tLIST,uLIST)
  for i,v in pairs(room) do
    local hitX,hitY,t,u = LineLineIntersection(x,y,x+math.cos(lDir),y+math.sin(lDir),  v[1],v[2],v[3],v[4])
    tLIST[#tLIST+1] = t
    uLIST[#tLIST] = u
  end
end

for i=1,16 do
  local gray = i/16
  if gray > 1 then
    gray = 0
  end
  term.setPaletteColor(2^(i-1),gray,gray,gray)
end

function draw()
  screenLib.clear()
  file = fs.open('debug.txt','w')
  for x=1,width do
    local lDir = dir-(fov/2)+x
    local tLIST = {}
    local uLIST = {}
    calcRoom(lDir,map[currentRoom],tLIST,uLIST)
    if #tLIST > 1 then
      local lowest = 99999999999
      local lowestID = 0
      for i,v in pairs(tLIST) do
        if v < lowest and v > 0 then
          local u = uLIST[i]
          if u > 0 and u < 1 then
            lowest = v
            lowestID = i
          end
        end
      end
      if lowestID ~= 0 then
        local lineHeight = lowest/2
        local color = uLIST[lowestID]
        color = color/(1/16)
        color = math.floor(color)
        color = 2 ^ color

        file.writeLine(lowest..' '..color)

        for y=1,lineHeight do
          screenLib.setPixel(x,y+(trueHeight/2)-(lineHeight/2),colors.toBlit(color))
        end
      end
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
    --debug = tostring(p1)
    if p1 == 262 then
      dir = dir + 1
    elseif p1 == 263 then
      dir = dir - 1
    end
    debug = tostring(dir)
  end
end
