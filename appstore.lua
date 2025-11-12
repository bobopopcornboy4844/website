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
  lines[i] = {{v.name,"Size:"..v.size.." DOWNLOAD"},{string.rep()}}
  downloads[i] = v.download_url
end

function draw()
  width,height = term.getSize()
  term.clear()
  for i,v in pairs(lines) do
    term.setCursorPos(1,i)
    term.write(v[1])
    term.setCursorPos(width-#v[2],i)
    term.write(v[2])
  end
end

while true do
  e,p1,p2,p3 = os.pullEvent()
  draw()
end
