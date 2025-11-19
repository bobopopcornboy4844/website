if not fs.exists("libs/screen.lua") then
  responce,err,errR = http.get('http://breadduck.online/CClibs/screen.lua')
  if err or errR then
    error("NO FIND")
  end
  file = fs.open('libs/screen.lua','w')
  file.write(responce.readAll())
  file.close()
end
if not fs.exists("libs/screen.lua") then
  error("NO FINDy")
end
require('libs/screen')

refresh = 0.2
start = {math.floor(width/2),height}
snakeblocks = {start,start,start}
dx = 0
dy = 0
Ndx = 0
Ndy = 0
debug = ''

function refreshDraw()
  screenLib.clear()
  for i,v in pairs(snakeblocks) do
    screenLib.setPixel(v[1],v[2],'5')
  end
end

timer = os.startTimer(refresh)
while true do
  refreshDraw()
  screenLib.draw()
  term.setCursorPos(1,1)
  term.write(debug)
  e,p1,p2,p3 = os.pullEvent()
  if e == 'timer' then
    timer = os.startTimer(refresh)
    dx = Ndx
    dy = Ndy
    x = snakeblocks[1][1]+dx
    y = snakeblocks[1][2]+dy
    debug = '{'..x..','..y..'}'
    table.insert(snakeblocks,1,{x,y})
    table.remove(snakeblocks,#snakeblocks)
  elseif e == 'key' then
    if p1 == 262 then
      if dx ~= -1 then
        Ndx = 1
        Ndy = 0
      end
    elseif p1 == 263 then
      if dx ~= 1 then
        Ndx = -1
        Ndy = 0
      end
    elseif p1 == 264 then
      if dy ~= -1 then
        Ndy = 1
        Ndx = 0
      end
    elseif p1 == 265 then
      if dy ~= 1 then
        Ndy = -1
        Ndx = 0
      end
    else
      debug = tostring(p1)
    end
  end
end
