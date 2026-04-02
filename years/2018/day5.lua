local function react_len(s)
  local stack = {}
  local sp = 0
  local n = #s
  for i = 1, n do
    local ch = s:sub(i, i)
    if sp > 0 then
      local top = stack[sp]
      if top ~= ch and top:lower() == ch:lower() then
        sp = sp - 1
      else
        sp = sp + 1
        stack[sp] = ch
      end
    else
      sp = 1
      stack[sp] = ch
    end
  end
  return sp
end

local function day5(path)
  local lines = readLines(path)
  local s = lines[1] or ''
  s = s:gsub('%s', '')

  local part1 = react_len(s)

  local best = #s
  for code = string.byte('a'), string.byte('z') do
    local lo = string.char(code)
    local up = string.upper(lo)
    local t = {}
    local ti = 0
    for i = 1, #s do
      local ch = s:sub(i, i)
      if ch ~= lo and ch ~= up then
        ti = ti + 1
        t[ti] = ch
      end
    end
    local s2 = table.concat(t)
    local len = react_len(s2)
    if len < best then
      best = len
    end
  end
  local part2 = best

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day5(path)
end
