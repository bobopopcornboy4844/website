number_curr = ''
number_AN   = tostring(math.random(1,999999))
color = colors.black
count  = 0
countT = 0
time = 0
function draw()
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1,1)
  term.write(number_AN)
  term.setCursorPos(1,2)
  term.write(number_curr)
  term.setCursorPos(1,3)
  term.setBackgroundColor(color)
  term.write(' ')
end

timer_id = os.startTimer(1)

while true do
  draw()
  color = colors.black
  EventArgsFull = table.pack(os.pullEventRaw())
  event = EventArgsFull[1]
  if event == 'key' then
    if EventArgsFull[2] >= 320 and EventArgsFull[2] < 330 then
      number_curr = number_curr..(EventArgsFull[2]-320)
      count = count + 1
      countT = countT + 1
      if number_AN == number_curr then
        number_curr = ''
        number_AN = tostring(math.random(1,999999))
        number_AN = string.rep('0',6 - #number_AN)..number_AN
        color = colors.green
      elseif string.sub(number_AN,1,#number_curr) ~= number_curr then
        number_curr = string.sub(number_curr,1,#number_curr - 1)
        color = colors.red
        count = count - 1
      end
    end
  elseif event == 'timer' then
    timer_id = os.startTimer(1)
    time = time + 1
    if time == 60 then
      break
    end
  elseif event == 'terminate' then
    break
  end
end
term.clear()
term.setCursorPos(1,1)
term.write(count)
term.setCursorPos(1,2)
term.write(countT)
term.setCursorPos(1,3)
term.write(time)
term.setCursorPos(1,5)
accute = ((count/countT)*100)
accute = accute*100
accute = math.floor(accute)/100
term.write(accute..'%')
term.setCursorPos(1,6)
time = time/60
time = time*100
time = math.floor(time)
time = time/100
term.write(time..'m')
