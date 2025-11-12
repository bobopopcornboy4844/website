url = "https://api.github.com/repos/bobopopcornboy4844/website/contents/CCapps"
responce,code,error = http.get(url)
text = responce.readAll()
jsonSTUFF = textutils.unserialiseJSON(text)
lines = {}
downloads = {}
for i,v in pairs(jsonSTUFF) do
  lines[i] = {{v.name,"Size:"..v.size.." DOWNLOAD"},{string.rep("0",#v.name),string.rep("4",#tostring(v.size)+5).."055555555"}}
  downloads[i] = v.download_url
end

function draw()
  term.setBackgroundColor(colors.black)
  width,height = term.getSize()
  term.clear()
  term.setBackgroundColor(colors.gray)
  term.setCursorPos(1,2)
  term.write(string.rep(' ',width))
  term.setCursorPos(1,1)
  amountOfFreeSpace = fs.getFreeSpace('/')
  form = 'bytes'
  if amountOfFreeSpace/1000 >= 1 then
    amountOfFreeSpace = amountOfFreeSpace/1000
    form = "Kilobytes"
    if amountOfFreeSpace/1000 >= 1 then
      amountOfFreeSpace = amountOfFreeSpace/1000
      form = "Megabytes"
      if amountOfFreeSpace/1000 >= 1 then
        amountOfFreeSpace = amountOfFreeSpace/1000
        form = "Gigabyte"
        if amountOfFreeSpace/1000 >= 1 then
          amountOfFreeSpace = amountOfFreeSpace/1000
          form = "Terabyte"
          if amountOfFreeSpace/1000 >= 1 then
            amountOfFreeSpace = amountOfFreeSpace/1000
            form = "Petabyte"
          end
        end

      end
    end
  end
  amountOfFreeSpace = amountOfFreeSpace..form
  freeSpaceString = "free space:"..amountOfFreeSpace
  term.write(freeSpaceString)
  term.write(string.rep(' ',(width-1)-#freeSpaceString))
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.white)
  term.write('X')
  for i,v in pairs(lines) do
    term.setCursorPos(1,i+2)
    term.blit(v[1][1],v[2][1],string.rep('f',#v[1][1]))
    term.setCursorPos(width-#v[1][2]+1,i+2)
    term.blit(v[1][2],v[2][2],string.rep('f',#v[1][2]))
  end
end
function download(url,name)
  responce,error,errorResponce = http.get(url)
  term.setCursorPos(1,2)
  term.setBackgroundColor(colors.gray)
  if not responce then
    term.setTextColor(colors.red)
    term.write(error)
    term.write(' ')
    term.write(errorResponce)
  else
    term.setTextColor(colors.green)
    term.write('DOWNLOADED')
    file = fs.open(name,'w')
    file.write(responce.readAll())
    file.close()
  end
end

draw()
while true do
  e,p1,p2,p3 = os.pullEvent()
  if e == "mouse_click" then
    if p1 == 1 and p2 > width-9 and p3-2 <= #downloads and p3 > 2 then
      download(downloads[p3-2],lines[p3-2][1][1])
    elseif p1 == 1 and p2 == width and p3 == 1 then
      term.setBackgroundColor(colors.black)
      term.clear()
      break
    end
  elseif e == "mouse_up" then
  else
    draw()
  end
end
