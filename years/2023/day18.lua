local function parse_line_p1(line)
  local dir = line:sub(1, 1)
  local dist = tonumber(line:match('%d+', 2))
  local dr, dc = 0, 0
  if dir == 'U' then
    dr = -1
  elseif dir == 'D' then
    dr = 1
  elseif dir == 'L' then
    dc = -1
  elseif dir == 'R' then
    dc = 1
  end
  return dr, dc, dist
end

local function hex_val(ch)
  local b = ch:byte()
  if ch >= '0' and ch <= '9' then
    return b - ('0'):byte()
  end
  if ch >= 'a' and ch <= 'f' then
    return 10 + (b - ('a'):byte())
  end
  return 10 + (b - ('A'):byte())
end

local function parse_line_p2(line)
  local hstart = line:find('#')
  local hex = line:sub(hstart + 1)
  local dist = 0
  local i = 1
  while i <= 5 do
    dist = dist * 16 + hex_val(hex:sub(i, i))
    i = i + 1
  end
  local dcode = hex_val(hex:sub(6, 6))
  local dr, dc = 0, 0
  if dcode == 0 then
    dc = 1
  elseif dcode == 1 then
    dr = 1
  elseif dcode == 2 then
    dc = -1
  else
    dr = -1
  end
  return dr, dc, dist
end

local function lagoon(dr_dc_dist_fn, lines)
  local x = 0
  local y = 0
  local shoelace = 0
  local perimeter = 0
  local li = 1
  while li <= #lines do
    local line = lines[li]
    if line ~= '' then
      local dr, dc, dist = dr_dc_dist_fn(line)
      local nx = x + dc * dist
      local ny = y + dr * dist
      shoelace = shoelace + x * ny - nx * y
      perimeter = perimeter + dist
      x = nx
      y = ny
    end
    li = li + 1
  end
  local area = math.floor(math.abs(shoelace) / 2)
  return area + math.floor(perimeter / 2) + 1
end

return function(path)
  local lines = readLines(path)
  local p1 = lagoon(parse_line_p1, lines)
  local p2 = lagoon(parse_line_p2, lines)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
