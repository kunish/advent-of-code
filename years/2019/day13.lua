local intcode = require('years.2019.intcode')

local function day13(path)
  local lines = readLines(path)
  local base = intcode.parse(lines[1] or '')

  local mem1 = intcode.copy(base)
  local outs1 = intcode.run(mem1, {})
  local blocks = 0
  local i = 1
  while i + 2 <= #outs1 do
    if outs1[i + 2] == 2 then
      blocks = blocks + 1
    end
    i = i + 3
  end

  local mem2 = intcode.copy(base)
  mem2[0] = 2
  local state = intcode.new(mem2)
  local ball_x, paddle_x = 0, 0
  local score = 0
  local buf = {}

  while true do
    local ev = intcode.step(state)
    if ev == 'in' then
      local inp = 0
      if ball_x < paddle_x then
        inp = -1
      elseif ball_x > paddle_x then
        inp = 1
      end
      intcode.apply_input(state, inp)
    elseif type(ev) == 'table' and ev[1] == 'out' then
      buf[#buf + 1] = ev[2]
      if #buf == 3 then
        local x, y, t = buf[1], buf[2], buf[3]
        buf = {}
        if x == -1 and y == 0 then
          score = t
        else
          if t == 3 then
            paddle_x = x
          elseif t == 4 then
            ball_x = x
          end
        end
      end
    elseif ev == 'halt' then
      break
    end
  end

  print(string.format('Part 1: %d', blocks))
  print(string.format('Part 2: %d', score))
end

return function(path)
  return day13(path)
end
