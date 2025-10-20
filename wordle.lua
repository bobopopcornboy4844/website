wordUrl = 'https://raw.githubusercontent.com/PateronLLC/Wordle-Plus/refs/heads/main/wordlist_10000.txt'
result,E,err = http.get(wordUrl)
if result then
  file = fs.open('words.txt')
  file.write(result.readAll())
  file.close()
end
