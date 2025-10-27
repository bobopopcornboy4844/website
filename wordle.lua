wordUrl = 'https://raw.githubusercontent.com/PateronLLC/Wordle-Plus/refs/heads/main/wordlist_10000.txt'
result,err,result = http.get(wordUrl)
if result then
  file = fs.open('words.txt','w')
  file.write(result.readAll())
  file.close()
end
if err then
  error(err)
end
words = {}
wordsINDEXED = {}
file = fs.open('words.txt','r')
line = file.readLine()
while line do
  words[line] = #line
  wordsINDEXED[#wordsINDEXED+1] = line
  line = file.readLine()
end
file.close()
width,height = term.getSize()
midleX = math.floor(width/2)
midleY = math.floor(height/2)
word = ""
term.clear()
current = 1
chosenWord = 'a'
while #chosenWord ~= 5 do
  chosenWord = wordsINDEXED[math.random(1,#wordsINDEXED)]
end
letters = {}
for i=1,5 do
  letters[string.sub(chosenWord,i,i)] = true
end
while true do
  term.setCursorPos(midleX,midleY)
  term.setBackgroundColor(colors.black)
  while true do
    event,p1,p2 = os.pullEvent()
    if event == 'char' then
      if #word < 5 then
        word = word..p1
      end
    elseif event == 'key' then
      if p1 == keys.enter then
        if words[word] and words[word] == 5 then
          break
        end
      elseif p1 == keys.backspace then
        word = string.sub(word,1,#word-1)
      end
    end
    term.setCursorPos(midleX-5,midleY-(3-current)*2)
    for i=1,#word do
      term.write(' ')
      term.write(string.sub(word,i,i))
      term.write(' ')
    end
    term.write(string.rep(" ",(5-#word)*2))
  end
  term.setCursorPos(midleX-5,midleY-(3-current)*2)
  for i=1,#word do
    cor = colors.gray
    if string.sub(word,i,i) == string.sub(chosenWord,i,i) then
      cor = colors.green
    elseif letters[string.sub(word,i,i)] then
      cor = colors.yellow
    end
    term.setBackgroundColor(cor)
    term.write(' ')
    term.write(string.sub(word,i,i))
    term.write(' ')
  end
  word = ''
  current = current + 1
  if current > 7 then
    term.setCursorPos(1,1)
    print(chosenWord)
    break
  end
end
