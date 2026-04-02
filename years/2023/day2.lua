local function parse_game(line)
  local colon = line:find(':')
  local id = tonumber(line:match('Game (%d+)'))
  local rest = line:sub(colon + 1)
  local max_r, max_g, max_b = 0, 0, 0
  for part in rest:gmatch('[^;]+') do
    local r, g, b = 0, 0, 0
    for n, color in part:gmatch('(%d+) (%a+)') do
      local v = tonumber(n)
      if color == 'red' then
        r = v
      elseif color == 'green' then
        g = v
      elseif color == 'blue' then
        b = v
      end
    end
    if r > max_r then
      max_r = r
    end
    if g > max_g then
      max_g = g
    end
    if b > max_b then
      max_b = b
    end
  end
  return id, max_r, max_g, max_b
end

local function day2(path)
  local lines = readLines(path)
  local part1 = 0
  local part2 = 0
  for i = 1, #lines do
    local id, mr, mg, mb = parse_game(lines[i])
    if mr <= 12 and mg <= 13 and mb <= 14 then
      part1 = part1 + id
    end
    part2 = part2 + mr * mg * mb
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day2(p)
end
