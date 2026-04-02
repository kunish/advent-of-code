local function day10(path)
  local lines = readLines(path)

  local cycle = 0
  local x = 1
  local part1 = 0
  local crt = {}

  local function advance_one()
    cycle = cycle + 1
    if cycle <= 220 and (cycle - 20) % 40 == 0 then
      part1 = part1 + cycle * x
    end
    local col = (cycle - 1) % 40
    local row = (cycle - 1) // 40
    if row <= 5 then
      local rowt = crt[row + 1]
      if not rowt then
        rowt = {}
        crt[row + 1] = rowt
      end
      if col >= x - 1 and col <= x + 1 then
        rowt[col + 1] = '#'
      else
        rowt[col + 1] = '.'
      end
    end
  end

  for i = 1, #lines do
    local line = lines[i]
    if line == 'noop' then
      advance_one()
    else
      local v = tonumber(line:match('addx%s+([%-%d]+)'))
      advance_one()
      advance_one()
      x = x + v
    end
  end

  local ocr = require('ocr')
  local out = {}
  for r = 1, 6 do
    local rowt = crt[r] or {}
    local chars = {}
    for c = 1, 40 do
      chars[c] = rowt[c] or '.'
    end
    out[r] = table.concat(chars)
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %s', ocr.decode(out)))
end

return function(p)
  return day10(p)
end
