local SIZE = 1000
local CELLS = SIZE * SIZE

local function parse_line(line)
  local x1, y1, x2, y2 =
    line:match('^turn on (%d+),(%d+) through (%d+),(%d+)$')
  if x1 then
    return 'on', tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
  end
  x1, y1, x2, y2 =
    line:match('^turn off (%d+),(%d+) through (%d+),(%d+)$')
  if x1 then
    return 'off', tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
  end
  x1, y1, x2, y2 =
    line:match('^toggle (%d+),(%d+) through (%d+),(%d+)$')
  if x1 then
    return 'toggle', tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
  end
  return nil
end

local function idx(x, y)
  return y * SIZE + x + 1
end

local function day6(path)
  local lines = readLines(path)

  local grid1 = {}
  local grid2 = {}
  for i = 1, CELLS do
    grid1[i] = 0
    grid2[i] = 0
  end

  for _, line in ipairs(lines) do
    local op, xa, ya, xb, yb = parse_line(line)
    if op then
      local x1 = math.min(xa, xb)
      local x2 = math.max(xa, xb)
      local y1 = math.min(ya, yb)
      local y2 = math.max(ya, yb)
      for y = y1, y2 do
        local base = y * SIZE
        for x = x1, x2 do
          local i = base + x + 1
          if op == 'on' then
            grid1[i] = 1
            grid2[i] = grid2[i] + 1
          elseif op == 'off' then
            grid1[i] = 0
            local v = grid2[i] - 1
            grid2[i] = v > 0 and v or 0
          else
            grid1[i] = 1 - grid1[i]
            grid2[i] = grid2[i] + 2
          end
        end
      end
    end
  end

  local part1 = 0
  local part2 = 0
  for i = 1, CELLS do
    if grid1[i] ~= 0 then
      part1 = part1 + 1
    end
    part2 = part2 + grid2[i]
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day6(path)
end
