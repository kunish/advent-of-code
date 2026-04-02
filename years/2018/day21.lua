local function day21(path)
  local lines = readLines(path)
  local seed, mul = 521363, 65899
  for _, ln in ipairs(lines) do
    local s = ln:match('seti (%d+) 7 5')
    if s then
      seed = tonumber(s)
    end
    local m = ln:match('muli 5 (%d+) 5')
    if m then
      mul = tonumber(m)
    end
  end

  local function next_r5(r5_prev)
    local r3 = r5_prev | 65536
    local r5 = seed
    while true do
      r5 = ((r5 + (r3 & 255)) * mul) & 16777215
      if 256 > r3 then
        return r5
      end
      r3 = r3 // 256
    end
  end

  local seen = {}
  local first = nil
  local last = nil
  local part2 = nil

  local r5 = 0
  while true do
    r5 = next_r5(r5)
    if seen[r5] then
      part2 = last
      break
    end
    seen[r5] = true
    if first == nil then
      first = r5
    end
    last = r5
  end

  print(string.format('Part 1: %d', first))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day21(path)
end
