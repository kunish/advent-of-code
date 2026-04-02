local function caught(delay, depth, range)
  if range <= 0 then
    return false
  end
  local period = (range == 1) and 1 or (2 * (range - 1))
  return (delay + depth) % period == 0
end

local function day13(path)
  local lines = readLines(path)
  local layers = {}

  for _, line in ipairs(lines) do
    if line ~= '' then
      local d, r = line:match('^(%d+):%s*(%d+)$')
      if d and r then
        layers[tonumber(d)] = tonumber(r)
      end
    end
  end

  local part1 = 0
  for depth, range in pairs(layers) do
    if caught(0, depth, range) then
      part1 = part1 + depth * range
    end
  end

  local delay = 0
  while true do
    local ok = true
    for depth, range in pairs(layers) do
      if caught(delay, depth, range) then
        ok = false
        break
      end
    end
    if ok then
      break
    end
    delay = delay + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', delay))
end

return function(path)
  return day13(path)
end
