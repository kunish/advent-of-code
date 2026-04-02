local function day15(path)
  local lines = readLines(path)
  local discs = {}
  for _, line in ipairs(lines) do
    local num, positions, start = line:match('Disc #(%d+) has (%d+) positions; at time=0, it is at position (%d+)')
    if num then
      discs[#discs + 1] = {
        positions = tonumber(positions),
        start = tonumber(start),
      }
    end
  end

  local function first_time(extra)
    local dlist = {}
    for i = 1, #discs do
      dlist[i] = discs[i]
    end
    if extra then
      dlist[#dlist + 1] = { positions = 11, start = 0 }
    end

    local t = 0
    while true do
      local ok = true
      for i = 1, #dlist do
        local d = dlist[i]
        local pos = (d.start + t + i) % d.positions
        if pos ~= 0 then
          ok = false
          break
        end
      end
      if ok then
        return t
      end
      t = t + 1
    end
  end

  local p1 = first_time(false)
  local p2 = first_time(true)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day15(path)
end
