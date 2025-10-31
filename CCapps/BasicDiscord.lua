local url = "http://mb-factors.gl.at.ply.gg:22538"

-- HTTP headers
local headers = {
  ["Content-Type"] = "application/json"
}
msgs = nil

function BetterError(text)
  sx,sy = term.getCursorPos()
  term.setCursorPos(24,1)
  term.setTextColor(colors.red)
  term.setBackgroundColor(colors.lightGray)
  term.write(text)
  term.setCursorPos(sx,sy)
end

-- Example embed (not used)
--[[
local embeds = {
  {
    ["title"]="Embed TEST",
    ["description"]="this is the discription",
    ["fields"]={
      { ["name"]="Field Test", ["value"]="Test Value" }
    }
  }
}

-- Example poll
local poll = {
  ["question"]={["text"]="Is Austin Gay?"},
  ["answers"]={{["poll_media"]={["text"]="Yes"}},{["poll_media"]={["text"]="No"}}}
}
]]
local poll
-- UI logic
running = true
local clickListeners = {}

--eventHandeler
eventHandeler = {}
eventHandeler.timers = {}

function eventHandeler.addEvent(eventNAME,func,defult)
  if not eventHandeler[eventNAME] then
    eventHandeler[eventNAME] = {}
  end
  eventHandeler[eventNAME].func = func
  if defult then
    eventHandeler[eventNAME].defult = func
  end
  return eventNAME
end
eventHandeler.addEvent('timer',function(p1)
    if eventHandeler.timers[p1] then
        eventHandeler.timers[p1]()
        table.remove(eventHandeler.timers,p1)
    end
end,true)
function eventHandeler.addTimer(length,func)
    eventHandeler.timers[os.startTimer(length)] = func
end
printList = nil
function printList(list, indent)
  local lines = {}
  lines[1] = '{'
  local Uindent = indent .. '  '

  for i, v in pairs(list) do
    local line = Uindent
    local moreLines = nil


    line = line .. i .. ': '

    if type(v) == 'table' then
      moreLines = printList(v, Uindent)
      line = line .. moreLines[1]
    elseif type(v) == 'string' then
      line = line .. '"' .. v .. '"'
    elseif type(v) == 'number' then
      line = line .. v
    else
      line = line .. tostring(v)
    end

    lines[#lines + 1] = line

    if moreLines then
      for j = 2, #moreLines do
        lines[#lines + 1] = moreLines[j]
      end
    end
  end

  lines[#lines + 1] = indent .. '}'
  return lines
end

extraDebugInfo = {}
function eventHandeler.debug()
  local lines = printList({msgs,extraDebugInfo}, '')
  local file = fs.open('hookDebug.txt', "w")
  for i = 1, #lines do
    file.writeLine(lines[i])
  end
  file.close()
end
function eventHandeler.tick()
  local event,p1,p2,p3,p4 = os.pullEventRaw()
  a = eventHandeler[event]
  if a and a.func then
    a.func(p1,p2,p3,p4)
  else
    --error(event,3)
  end
  eventHandeler.debug()
end
function eventHandeler.removeEvent(eventNAME)
  if not eventHandeler[eventNAME] then
    error('Event No Eixsty. EVENT:'..eventNAME,2)
  end
  eventHandeler[eventNAME].func = eventHandeler[eventNAME].defult
  if not eventHandeler[eventNAME].defult then
    eventHandeler[eventNAME] = {}
  end
end


function clickListenerFunction(p1,p2,p3)
  local a = clickListeners[p2]
  if not a then
    a = {}
  end
  local b = a[p3]
  if b then
    b()
  end
end
eventHandeler.addEvent("mouse_click",clickListenerFunction,true)
eventHandeler.addEvent("terminate",function() running = false end,true)


function Button(x,y,backColor,textColor,text,func)
  term.setCursorPos(x,y)
  term.setBackgroundColor(backColor)
  term.setTextColor(textColor)
  term.write(text)
  for i=x,x+#text-1 do
    if not clickListeners[i] then
      clickListeners[i] = {}
    end
    clickListeners[i][y] = func
  end
end

textBox = {}
textBox.Events = {}
textBox.functions = {}
textBox.finishFunc = {}
textBox.CText = ''
textBox.Values = {}
textBox.Values['username'] = 'Mr.Tester'
textBox.Values['channel'] = 'chat'
textBox.currentId = nil


function textBox.new(x,y,length,id,enterFunc)
  local function getText()
    textBox.CText = textBox.Values[id]
    textBox.finishFunc[id] = enterFunc
    if not textBox.finishFunc[id] then
      textBox.finishFunc[id] = function() end
    end
    term.setCursorBlink(true)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    if #textBox.CText >=length-1 then
      term.setCursorPos(x,y)
      sub = #textBox.CText-length
      sub = sub+2
      term.write(string.sub(textBox.CText,sub))
      term.write(" ")
      term.setCursorPos(x+length-1,y)
    else
      term.setCursorPos(x+#textBox.CText,y)
    end
    textBox.currentId = id
    function textBox.functions.mouse_click(p1,p2,p3)
      if p3 ~= y or p2 < x or p2 > x+length then
        for i,v in pairs(textBox.Events) do
          eventHandeler.removeEvent(v)
          table.remove(textBox.Events,i)
        end
        if #textBox.CText >= length-1 then
          term.setCursorPos(x,y)
          term.write(string.sub(textBox.CText,1,length-3).."...")
        end
        term.setCursorBlink(false)
        textBox.Values[textBox.currentId] = textBox.CText
        textBox.finishFunc[textBox.currentId]()
      end
    end
    function textBox.functions.char(p1)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        if #textBox.CText >= length-1 then
            sub = #textBox.CText-length
            sub = sub+3
            textBox.CText = textBox.CText..p1
        else
            sub = 0
            textBox.CText = textBox.CText..p1
        end
        term.setCursorPos(x,y)
        term.write(string.sub(textBox.CText,sub))
    end
    function textBox.functions.key(p1)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
      if p1 == keys.backspace and #textBox.CText > 0 then
        textBox.CText = textBox.CText:sub(1, #textBox.CText-1)
        term.setCursorPos(x, y)
        if #textBox.CText >= length-1 then
          sub = #textBox.CText-length
          sub = sub+2
          term.write(string.sub(textBox.CText,sub))
          term.setCursorPos(x + length-1, y)
        else
          term.write(textBox.CText .. string.rep(" ", length - #textBox.CText))
          term.setCursorPos(x + #textBox.CText, y)
        end
      elseif p1 == keys.enter then
        textBox.functions.mouse_click(-10,-10,-10)
      end
    end

    textBox.Events[#textBox.Events+1] = eventHandeler.addEvent('key',textBox.functions.key)
    textBox.Events[#textBox.Events+1] = eventHandeler.addEvent('mouse_click',textBox.functions.mouse_click)
    textBox.Events[#textBox.Events+1] = eventHandeler.addEvent('char',textBox.functions.char)


  end
  Button(x,y,colors.gray,colors.white,string.rep(" ",length),getText)
  if textBox.Values[id] then
    term.setCursorPos(x,y)
    term.write(textBox.Values[id])
  else
    textBox.Values[id] = ''
  end
end


-- Initialize terminal
function mainLoad()
  clickListeners = {}
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  term.setTextColor(colors.black)
  local width,height = term.getSize()
  term.setPaletteColor(colors.pink,0.4,0.4,0.4)
  term.setPaletteColor(colors.magenta,0.35,0.35,0.35)

  term.setBackgroundColor(colors.pink)
  for i=2,height-1 do
    term.setCursorPos(1,i)
    term.blit(string.rep(' ',width),string.rep('6',width),string.rep('6',width-1)..'7')
  end

  --Escape
  Button(width, 1,colors.red,colors.white,'X',function() running = false end)

  -- Username field
  term.setCursorPos(1, height)
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.black)
  term.write('Username:')
  textBox.new(10, height, 15, 'username')

  -- Message field
  term.setCursorPos(26, height)
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.black)
  term.write('msg:')
  textBox.new(30, height, 15, 'text')

  --channel field
  term.setCursorPos(1, 1)
  term.setBackgroundColor(colors.pink)
  term.setTextColor(colors.black)
  term.write('channel:')
  textBox.new(9, 1, 15, 'channel')

  --Send Button
  Button(width-3, height, colors.green,colors.white,'SEND', function()
    local text = textBox.Values['text'] or ""
    local username = textBox.Values['username'] or "Bot"
    local channel = textBox.Values['channel'] or "chat"
    local content = {
      ["message"] = text,
      ["username"] = username,
      ["channel"] = channel,
      --["embeds"] = embeds,
      --["poll"] = poll,
    }
    term.setCursorPos(width-13, 1)
    term.setBackgroundColor(colors.gray)
    term.write("Sending      ")
    local json = textutils.serializeJSON(content)
    local success, err, response = http.post(url, json, headers)

    -- Feedback
    if success then
      term.setCursorPos(width-13, 1)
      term.setBackgroundColor(colors.green)
      term.write("Message sent!")
    else
      term.setCursorPos(width-13, 1)
      term.setBackgroundColor(colors.red)
      term.write("Send failed! ")
      term.setCursorPos(width-20, 2)
      if err then
        term.write(err)
      end
      term.setCursorPos(width-20, 3)
      if response then
        file = fs.open('ERROR.txt','w')
        file.write(response.readAll())
        file.close()
      end
    end
  end)
end
mainLoad()
width,height = term.getSize()
scroll = {}
msgs = {}
visMsgs = {}
scrollBarY = 0              -- top of scrollbar
scrollBarH = height - 2      -- height of scrollbar
function loadMsgs()
  
  sx,sy = term.getCursorPos()
  scroll = {}
  channel = textBox.Values['channel']
  channelMsgs = msgs[channel]
  count = #channelMsgs
  if count > (height-2)*2 then
      count = (height-2)*2
  end
  drawCount = count
  if drawCount > height-2 then
    drawCount = height-2
  end
  scrollBarH = (height-2)-(count-height-2)
  extraDebugInfo.scrollBarH = scrollBarH
  
  drawScrollBar()
  
  
  for i=2,height-1 do
    term.setCursorPos(1,i)
    term.blit(string.rep(' ',width-1),string.rep('6',width-1),string.rep('6',width-1))
  end
  term.setBackgroundColor(colors.pink)
  for i=1, drawCount do
      term.setCursorPos(1,height-i)
      msg = channelMsgs[(#channelMsgs-i+1)-scrollBarY]
      if #msg['message'] >= width then
        scroll[height-i] = 0
      end
      local text = msg['username']..": "..msg['message']
      visMsgs[height-i] = text
      term.write(string.sub(text..string.rep(' ',width),1,width-1))
  end
  eventHandeler.addTimer(1,timerF)
  term.setCursorPos(sx,sy)
end
textBox.finishFunc['channel'] = function()
  scrollBarY = 0
  loadMsgs()
end

function drawScrollBar()
    local bottom = height - 1
    local top = 2
    for i = top, bottom do
        -- bottom-aligned scroll thumb
        if i > bottom - scrollBarY - scrollBarH and i <= bottom - scrollBarY then
            term.setBackgroundColor(colors.magenta)
        else
            term.setBackgroundColor(colors.gray)
        end
        term.setCursorPos(width, i)
        term.write(" ")
    end
end

function tablesEqual(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end

    for k, v in pairs(a) do
        if not tablesEqual(v, b[k]) then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end

    return true
end

function deepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

get_url = url..'?a='..math.random()

function onGetResponse(result,_,err)
  local sx,sy = term.getCursorPos()
  if err then 
      error(err)
  end
  if result then
      msgs = result.readAll()
      msgs = textutils.unserialiseJSON(msgs)
      

      equal = tablesEqual(msgs, oldMsgs)
      
      if not equal then
          scrollBarY = 0
          loadMsgs()
      end
      oldMsgs = deepCopy(msgs)
  end
  get_url = url..'?a='..math.random()
  http.request(get_url)
end
function http_s(p1,p2,p3)
  if p1 == get_url then
    onGetResponse(p2)
  end
end
function http_e(p1,p2,p3)
  if p1 == get_url then
    onGetResponse(nil,p2,p3)
  end
end
eventHandeler.addEvent('http_success',http_s)
eventHandeler.addEvent('http_failure',http_e)
oldMsgs = {}
function timerF()
    local sx,sy = term.getCursorPos()
    result,err,E = http.get(url..'?a='..math.random())
    if err then 
        BetterError(err)
    end
    if result then
        msgs = result.readAll()
        msgs = textutils.unserialiseJSON(msgs)
        

        equal = tablesEqual(msgs, oldMsgs)
        
        if not equal then
            scrollBarY = 0
            loadMsgs()
        end
        oldMsgs = deepCopy(msgs)
    end
end
eventHandeler.addTimer(1,timerF)
--http.request(get_url)



eventHandeler.addEvent('mouse_scroll',function(dir,x,y)
    if y > 1 and y < height then
        if x < width then
            currMsg = visMsgs[y]
            if #currMsg >= width then
                currScroll = scroll[y]
                currScroll = currScroll+dir
                if currScroll < 0 then
                    currScroll = 0
                elseif  currScroll-1 > #currMsg - width then
                    currScroll = (#currMsg - width)+1
                end
                scroll[y] = currScroll
                term.setCursorPos(1,y)
                local text = currMsg
                text = string.sub(text,currScroll+1,width+currScroll-1)
                term.setBackgroundColor(colors.pink)
                term.setTextColor(colors.white)
                term.write(text)
            end
        else
            scrollBarY = scrollBarY+dir
            if scrollBarY+scrollBarH > height-2 then
              scrollBarY=(height-2)-scrollBarH
            elseif scrollBarY < 0 then
              scrollBarY = 0
            else
              loadMsgs()
              drawScrollBar()
            end
        end
    end
end)
-- Main event loop
while running do
  eventHandeler.tick()
end

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
