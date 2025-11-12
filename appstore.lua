url = "https://api.github.com/repos/bobopopcornboy4844/website/contents/CCapps"
responce,code,error = http.get(url)
text = responce.readAll()
file = fs.open('debug.txt','w')
file.write(text)
file.close()
jsonSTUFF = textutils.unserialiseJSON(text)
lines = {}
downloads = {}
for i,v in pairs(jsonSTUFF) do
  lines[i] = {{v.name,"Size:"..v.size.." DOWNLOAD"},{string.rep("0",#v.name),string.rep("4",#tostring(v.size)+5).."055555555"}}
  downloads[i] = v.download_url
end

function draw()
  width,height = term.getSize()
  term.clear()
  for i,v in pairs(lines) do
    term.setCursorPos(1,i+1)
    term.blit(v[1][1],v[2][1],string.rep('f',#v[1][1]))
    term.setCursorPos(width-#v[1][2]+1,i+1)
    term.blit(v[1][2],v[2][2],string.rep('f',#v[1][2]))
  end
end
function download(url,name)
  responce,error,errorResponce = http.get(url)
  term.setCursorPos(1,1)
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
  if e == "mouse_click" and p1 == 1 and p2 > width-9 and p3-1 <= #downloads and p3 > 1  then
    download(downloads[p3-1],lines[p3-1][1][1])
  elseif e == "mouse_up" then
  else
    draw()
  end
end
