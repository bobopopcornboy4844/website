local url = "https://discord.com/api/webhooks/1427513159094239336/oHYi80LlgIkDErJoMqvl8FqN6NWKPjPBRR8lxKtO2xDDyN6VBAHwu6jKoSBPkkVspsce"

if #fs.find('avatar.txt') < 1 then
  file = fs.open('avatar.txt','w')
  file.write('http://www.breadduck.online/duck-bread.jpg')
  file.close()
end
file = fs.open('avatar.txt','r')
avatar = file.readAll()
file.close()

local headers = {
  ["Content-Type"] = "application/json"
}


term.setBackgroundColor(colors.gray)
term.clear()
width,height = term.getSize()

term.setBackgroundColor(colors.lightGray)
for y=1,10 do
  term.setCursorPos(width/2-10,height/2-5+y)
  term.write(string.rep(" ",20))
end
term.setCursorPos(width/2-3,height/2+4)
term.setBackgroundColor(colors.green)
term.write('SEND')
term.setBackgroundColor(colors.lightGray)
term.setCursorPos(width/2-10,height/2-3)
term.write('Username:')
term.setBackgroundColor(colors.gray)
term.write(string.rep(' ',10))
term.setBackgroundColor(colors.lightGray)
term.setCursorPos(width/2-5,height/2-1)
term.write('msg:')
term.setBackgroundColor(colors.gray)
term.write(string.rep(' ',10))

username = ""
text = ""
currentFeild = 0

function string.replace(string,i1,new)
  letters = {}
  for i=1,#string do
    v = string.sub(string,i,i)
    letters[i] = v
  end
  letters[i1] = new
  return table.concat(letters)
end

term.setCursorBlink(false)
while true do
  event,p1,p2,p3 = os.pullEvent()
  if event == "mouse_click" then
    term.setCursorBlink(false)
    currentFeild = 0
    if p3 == math.floor(height/2+4) then --send button
      if p2 >= math.floor(width/2-3) and p2 <= math.floor(width/2) then
        term.setCursorBlink(false)
        content = {
          ["content"] = text,
          ["username"] = username
        }
        if avatar then
          content["avatar_url"] = avatar
        end
        local json = textutils.serializeJSON(content)
        local success, b, response = http.post(url, json, headers)
      end
    end
    if p3 == math.floor(height/2-3) then --username type feild
      if p2 >= math.floor(width/2-1) and p2 <= math.floor(width/2+8) then
        currentFeild = 1
        term.setCursorBlink(true)
        local x = p2
        if x > math.floor(width/2-1)+#username then
          x = math.floor(width/2-1)+#username
        end
        term.setCursorPos(x,p3)
      end
    end
    if p3 == math.floor(height/2-1) then --msg type feild
      if p2 >= math.floor(width/2-1) and p2 <= math.floor(width/2+8) then
        currentFeild = 2
        term.setCursorBlink(true)
        local x = p2
        if x > math.floor(width/2-1)+#text then
          x = math.floor(width/2-1)+#text
        end
        term.setCursorPos(x,p3)
      end
    end
  end
  if event == "char" then
    if currentFeild == 1 then
      if #username < 10 then
        x,y = term.getCursorPos()
        x = x-math.floor(width/2-1)+1
        username = string.replace(username,x,p1)
        term.write(p1)
      end
    elseif currentFeild == 2 then
      if #text < 10 then
        x,y = term.getCursorPos()
        x = x-math.floor(width/2-1)+1
        text = string.replace(text,x,p1)
        term.write(p1)
      end
    end
  end
  if event == "key" then
    if currentFeild == 1 then
      if p1 == 259 then
        if #username > 0 then
        username = string.sub(username,1,#username-1)
        term.setCursorPos(math.floor(width/2-1)+#username,math.floor(height/2-3))
        term.write(" ")
        term.setCursorPos(math.floor(width/2-1)+#username,math.floor(height/2-3))
        end
      end
    elseif currentFeild == 2 then
      if p1 == 259 then
        if #text > 0 then
        text = string.sub(text,1,#text-1)
        term.setCursorPos(math.floor(width/2-1)+#text,math.floor(height/2-1))
        term.write(" ")
        term.setCursorPos(math.floor(width/2-1)+#text,math.floor(height/2-1))
        end
      end
    end
  end
end
url = 'http://www.breadduck.online/DiscordBotCC.lua'
text = http.get(url).readAll()
load(text)()
