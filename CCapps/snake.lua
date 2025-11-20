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
start = {math.floor(width/2),math.floor((height*2)/3)}
snakeblocks = {start,start,start}
dx = 0
dy = 0
Ndx = 0
Ndy = 0
appleX,appleY = math.random(2,width-1),math.random(1,(height*2)-9)
debug = ''

function refreshDraw()
  screenLib.clear()
  -- border
  for i=1, width do
    screenLib.setPixel(i,1,'1')
    screenLib.setPixel(i,(height*2)-9,'1')
  end
  for i=1, (height*2)-9 do
    screenLib.setPixel(1,i,'1')
    screenLib.setPixel(width,i,'1')
  end
  -- snake
  for i,v in pairs(snakeblocks) do
    screenLib.setPixel(v[1],v[2],'5')
  end
  -- apple
  screenLib.setPixel(appleX,appleY,'e')
end

function quitGame()
  os.queueEvent('exit')
end

function menu(V)
  title = 'Place Holder'
  local options = {{'exit',quitGame}}
  if V == 1 then
    title = 'Game Over'
    options = {{'exit',quitGame}}
  end
  term.setCursorPos((width/2)-(#title/2),3)
  term.write(title)
  local selected = 1
  while true do
    e,p1,p2,p3 = os.pullEvent()
    for i,v in pairs(options) do
      local name = v[1]
      if i == selected then
        name = '['..name..']'
      end
      term.setCursorPos((width/2)-(#name/2),3+i)
      term.write(name)
    end
    if e == 'key' then
      if p1 == 257 then
        options[selected][2]()
      end
    elseif e == 'exit' then
      os.queueEvent('exit')
      break
    end
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
    if x == appleX and y == appleY then
      appleX,appleY = math.random(2,width-1),math.random(1,(height*2)-9)
    else
      table.remove(snakeblocks,#snakeblocks)
    end
    if x == 1 or x == width then
      menu(1)
    end
    if y == 1 or y == (height*2)-9 then
      menu(1)
    end
    table.insert(snakeblocks,1,{x,y})

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
  elseif e == 'exit' then
    break
  end
end
