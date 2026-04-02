local function day17(path)
  local lines = readLines(path)
  local steps = tonumber(lines[1] or '0')

  local pos = 0
  local buf = { 0 }
  for i = 1, 2017 do
    pos = (pos + steps) % #buf + 1
    table.insert(buf, pos + 1, i)
  end
  local after_2017 = nil
  for i = 1, #buf do
    if buf[i] == 2017 then
      after_2017 = buf[i + 1]
      break
    end
  end

  local pos2 = 0
  local size = 1
  local after_zero = nil
  for i = 1, 50000000 do
    pos2 = (pos2 + steps) % size + 1
    if pos2 == 1 then
      after_zero = i
    end
    size = size + 1
  end

  print(string.format('Part 1: %d', after_2017 or -1))
  print(string.format('Part 2: %d', after_zero or -1))
end

return function(path)
  return day17(path)
end
