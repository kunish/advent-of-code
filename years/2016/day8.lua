local ocr = require('ocr')
local rows, cols = 6, 50

local function day8(path)
  local lines = readLines(path)
  local g = {}
  for r = 1, rows do
    g[r] = {}
    for c = 1, cols do
      g[r][c] = false
    end
  end

  for _, line in ipairs(lines) do
    local a, b = line:match('^rect (%d+)x(%d+)$')
    if a then
      a, b = tonumber(a), tonumber(b)
      for r = 1, b do
        for c = 1, a do
          g[r][c] = true
        end
      end
    else
      local y, by = line:match('^rotate row y=(%d+) by (%d+)$')
      if y then
        y, by = tonumber(y) + 1, tonumber(by) % cols
        local row = g[y]
        local tmp = {}
        for c = 1, cols do
          tmp[c] = row[((c - 1 - by) % cols) + 1]
        end
        for c = 1, cols do
          row[c] = tmp[c]
        end
      else
        local x, bx = line:match('^rotate column x=(%d+) by (%d+)$')
        if x then
          x, bx = tonumber(x) + 1, tonumber(bx) % rows
          local tmp = {}
          for r = 1, rows do
            tmp[r] = g[((r - 1 - bx) % rows) + 1][x]
          end
          for r = 1, rows do
            g[r][x] = tmp[r]
          end
        end
      end
    end
  end

  local lit = 0
  for r = 1, rows do
    for c = 1, cols do
      if g[r][c] then
        lit = lit + 1
      end
    end
  end

  local pic = {}
  for r = 1, rows do
    local row = {}
    for c = 1, cols do
      row[c] = g[r][c] and '#' or '.'
    end
    pic[r] = table.concat(row)
  end

  print(string.format('Part 1: %d', lit))
  print(string.format('Part 2: %s', ocr.decode_fixed(pic, 5)))
end

return function(path)
  return day8(path)
end
