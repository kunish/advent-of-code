local function key(x, y)
  return x .. ',' .. y
end

local function day3(path)
  local lines = readLines(path)
  local s = lines[1] or ''

  local function count_houses(movers)
    local visited = {}
    local xs, ys = {}, {}
    for m = 1, movers do
      xs[m], ys[m] = 0, 0
    end
    visited[key(0, 0)] = true
    local count = 1
    local turn = 1
    for i = 1, #s do
      local c = s:sub(i, i)
      local x, y = xs[turn], ys[turn]
      if c == '^' then
        y = y + 1
      elseif c == 'v' then
        y = y - 1
      elseif c == '>' then
        x = x + 1
      elseif c == '<' then
        x = x - 1
      end
      xs[turn], ys[turn] = x, y
      local k = key(x, y)
      if not visited[k] then
        visited[k] = true
        count = count + 1
      end
      turn = turn % movers + 1
    end
    return count
  end

  print(string.format('Part 1: %d', count_houses(1)))
  print(string.format('Part 2: %d', count_houses(2)))
end

return function(path)
  return day3(path)
end
