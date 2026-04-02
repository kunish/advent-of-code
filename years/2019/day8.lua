local W, H = 25, 6
local layer = W * H

local function day8(path)
  local lines = readLines(path)
  local s = lines[1] or ''
  local best_z = nil
  local best_layer = nil
  local idx = 1
  local li = 0
  while idx <= #s do
    local zc, oc, tc = 0, 0, 0
    local k = 1
    while k <= layer do
      local ch = string.sub(s, idx, idx)
      if ch == '0' then
        zc = zc + 1
      elseif ch == '1' then
        oc = oc + 1
      elseif ch == '2' then
        tc = tc + 1
      end
      idx = idx + 1
      k = k + 1
    end
    if best_z == nil or zc < best_z then
      best_z = zc
      best_layer = li
    end
    li = li + 1
  end

  -- recount part1 for that layer — simpler: second pass or store counts
  idx = 1
  li = 0
  local part1 = 0
  while idx <= #s do
    local zc, oc, tc = 0, 0, 0
    local k = 1
    while k <= layer do
      local ch = string.sub(s, idx, idx)
      if ch == '0' then
        zc = zc + 1
      elseif ch == '1' then
        oc = oc + 1
      elseif ch == '2' then
        tc = tc + 1
      end
      idx = idx + 1
      k = k + 1
    end
    if li == best_layer then
      part1 = oc * tc
      break
    end
    li = li + 1
  end

  local out = {}
  local p = 1
  while p <= layer do
    local li2 = 0
    idx = p
    while li2 * layer + p <= #s do
      local ch = string.sub(s, li2 * layer + p, li2 * layer + p)
      if ch ~= '2' then
        out[p] = ch
        break
      end
      li2 = li2 + 1
    end
    p = p + 1
  end

  local ocr = require('ocr')
  local rows = {}
  local y = 0
  while y < H do
    local row = {}
    local x = 0
    while x < W do
      local ch = out[y * W + x + 1]
      if ch == '1' then
        row[#row + 1] = '#'
      else
        row[#row + 1] = ' '
      end
      x = x + 1
    end
    rows[#rows + 1] = table.concat(row)
    y = y + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %s', ocr.decode(rows)))
end

return function(path)
  return day8(path)
end
