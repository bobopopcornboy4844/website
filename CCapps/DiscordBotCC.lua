-- Load webhook URL from file
if not fs.exists("url.txt") then
  fs.open("uel.txt","w").close()
end

local file = fs.open("url.txt","r")
local url = file.readAll()
file.close()

if url == "" then
  error("url.txt is empty! Add your Discord webhook URL.")
end

-- Set up avatar
if #fs.find('avatar.txt') < 1 then
  file = fs.open('avatar.txt','w')
  file.write('http://www.breadduck.online/duck-bread.jpg')
  file.close()
end

file = fs.open('avatar.txt','r')
local avatar = file.readAll()
file.close()

-- HTTP headers
local headers = {
  ["Content-Type"] = "application/json"
}


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
local clickListeners = {}
local textBoxValues = {}

function Button(x,y,length,backColor,textColor,text,func)
  term.setCursorPos(x,y)
  term.setBackgroundColor(backColor)
  term.setTextColor(textColor)
  term.write(text)
  for i=x,x+length do
    if not clickListeners[i] then
      clickListeners[i] = {}
    end
    clickListeners[i][y] = func
  end
end

function textBox(x,y,length,id)
  if not textBoxValues[id] then
    textBoxValues[id] = ''
  end
  local function getText()
    local text = textBoxValues[id]
    term.setCursorBlink(true)
    term.setBackgroundColor(colors.gray)
    if #text >=length-1 then
      term.setCursorPos(x,y)
      sub = #text-length
      sub = sub+2
      term.write(string.sub(text,sub))
      term.write(" ")
      term.setCursorPos(x+length-1,y)
    else
      term.setCursorPos(x+#text,y)
    end
    while true do
      local ev,p1,p2,p3 = os.pullEvent()
      if ev == "mouse_click" then
        if p3 ~= y or p2 < x or p2 > x+length then
          break
        end
      elseif ev == "char" then
        if #text >= length-1 then
          term.setCursorPos(x,y)
          sub = #text-length
          sub = sub+3
          text = text..p1
          term.write(string.sub(text,sub))
        else
          term.write(p1)
          text = text..p1
        end
      elseif ev == "key" then
        if p1 == keys.backspace and #text > 0 then
          text = text:sub(1, #text-1)
          term.setCursorPos(x, y)
          if #text >= length-1 then
            sub = #text-length
            sub = sub+2
            term.write(string.sub(text,sub))
            term.setCursorPos(x + length-1, y)
          else
            term.write(text .. string.rep(" ", length - #text))
            term.setCursorPos(x + #text, y)
          end
        end
      end
    end
    if #text >= length-1 then
      term.setCursorPos(x,y)
      term.write(string.sub(text,1,length-3).."...")
    end
    term.setCursorBlink(false)
    textBoxValues[id] = text
  end

  Button(x,y,length,colors.gray,colors.white,string.rep(" ",length),getText)
end

-- Initialize terminal
function mainReload()
  term.setBackgroundColor(colors.gray)
  term.clear()
  term.setTextColor(colors.black)
  local width,height = term.getSize()

  -- Draw input panel
  term.setBackgroundColor(colors.lightGray)
  for y=1,10 do
    term.setCursorPos(math.floor(width/2-15), math.floor(height/2-5+y))
    term.write(string.rep(" ",30))
  end

  -- Username field
  term.setCursorPos(math.floor(width/2-15), math.floor(height/2-3))
  term.setBackgroundColor(colors.lightGray)
  term.write('Username:')
  textBox(math.floor(width/2-6), math.floor(height/2-3), 15, 'username')

  -- Message field
  term.setCursorPos(math.floor(width/2-10), math.floor(height/2-1))
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.black)
  term.write('msg:')
  term.setBackgroundColor(colors.gray)
  term.write(string.rep(' ',15))
  textBox(math.floor(width/2-6), math.floor(height/2-1), 15, 'text')

  if not poll then
    Button(math.floor(width/2-3), math.floor(height/2+2), 5,colors.green,colors.white,'+POLL', function()
      poll = {}
      clickListeners = {}
      term.setBackgroundColor(colors.gray)
      term.clear()
      term.setTextColor(colors.black)
      local width,height = term.getSize()
    end)
  end
  --Send Button
  Button(math.floor(width/2-3), math.floor(height/2+4), 4,colors.green,colors.white,'SEND', function()
    local text = textBoxValues['text'] or ""
    local username = textBoxValues['username'] or "Bot"
    local content = {
      ["content"] = text,
      ["username"] = username,
      ["avatar_url"] = avatar,
      --["embeds"] = embeds,
      ["poll"] = poll
    }

    local json = textutils.serializeJSON(content)
    local success, _, response = http.post(url, json, headers)

    -- Feedback
    if success then
      term.setCursorPos(math.floor(width/2-6), math.floor(height/2+6))
      term.setBackgroundColor(colors.green)
      term.write("Message sent!     ")
    else
      term.setCursorPos(math.floor(width/2-6), math.floor(height/2+6))
      term.setBackgroundColor(colors.red)
      term.write("Send failed!      ")
      term.setCursorPos(math.floor(width/2-6), math.floor(height/2+7))
      term.write(response.readAll())
    end
  end)
end
mainReload()

-- Main event loop
while true do
  local event,p1,p2,p3 = os.pullEvent()
  if event == "mouse_click" then
    local a = clickListeners[p2]
    if not a then
      a = {}
    end
    local b = a[p3]
    if b then
      b()
    end
  end
end
