local function sum_numbers_regex(s)
  local total = 0
  for n in s:gmatch('%-?%d+') do
    total = total + tonumber(n)
  end
  return total
end

-- Recursive descent JSON parser; returns tagged values: { 'array', ... } or { 'object', map = { [k]=v } }
local function parse_json(s)
  local pos = 1
  local len = #s

  local function skip_ws()
    while pos <= len do
      local c = s:sub(pos, pos)
      if c == ' ' or c == '\t' or c == '\n' or c == '\r' then
        pos = pos + 1
      else
        break
      end
    end
  end

  local parse_value

  local function parse_string()
    assert(s:sub(pos, pos) == '"', 'expected "')
    pos = pos + 1
    local out = {}
    while pos <= len do
      local c = s:sub(pos, pos)
      if c == '"' then
        pos = pos + 1
        return table.concat(out)
      elseif c == '\\' then
        pos = pos + 1
        local esc = s:sub(pos, pos)
        pos = pos + 1
        out[#out + 1] = esc
      else
        out[#out + 1] = c
        pos = pos + 1
      end
    end
    error('unterminated string')
  end

  local function parse_number()
    local start = pos
    if s:sub(pos, pos) == '-' then
      pos = pos + 1
    end
    while pos <= len do
      local c = s:sub(pos, pos)
      if c >= '0' and c <= '9' then
        pos = pos + 1
      else
        break
      end
    end
    return tonumber(s:sub(start, pos - 1))
  end

  function parse_value()
    skip_ws()
    local c = s:sub(pos, pos)
    if c == '{' then
      pos = pos + 1
      skip_ws()
      local map = {}
      if s:sub(pos, pos) == '}' then
        pos = pos + 1
        return { 'object', map = map }
      end
      while true do
        skip_ws()
        local key = parse_string()
        skip_ws()
        assert(s:sub(pos, pos) == ':', 'expected :')
        pos = pos + 1
        local val = parse_value()
        map[key] = val
        skip_ws()
        local sep = s:sub(pos, pos)
        if sep == '}' then
          pos = pos + 1
          break
        elseif sep == ',' then
          pos = pos + 1
        else
          error('bad object')
        end
      end
      return { 'object', map = map }
    elseif c == '[' then
      pos = pos + 1
      skip_ws()
      local arr = { 'array' }
      if s:sub(pos, pos) == ']' then
        pos = pos + 1
        return arr
      end
      while true do
        arr[#arr + 1] = parse_value()
        skip_ws()
        local sep = s:sub(pos, pos)
        if sep == ']' then
          pos = pos + 1
          break
        elseif sep == ',' then
          pos = pos + 1
        else
          error('bad array')
        end
      end
      return arr
    elseif c == '"' then
      return parse_string()
    elseif c == '-' or (c >= '0' and c <= '9') then
      return parse_number()
    elseif s:sub(pos, pos + 3) == 'true' then
      pos = pos + 4
      return true
    elseif s:sub(pos, pos + 4) == 'false' then
      pos = pos + 5
      return false
    elseif s:sub(pos, pos + 3) == 'null' then
      pos = pos + 4
      return nil
    else
      error('parse error at ' .. pos)
    end
  end

  skip_ws()
  local v = parse_value()
  skip_ws()
  assert(pos > len, 'trailing data')
  return v
end

local function sum_no_red(v)
  local ty = type(v)
  if ty == 'number' then
    return v
  elseif ty == 'string' or ty == 'boolean' or v == nil then
    return 0
  end
  if type(v) == 'table' and v[1] == 'object' then
    for _, child in pairs(v.map) do
      if child == 'red' then
        return 0
      end
    end
    local s = 0
    for _, child in pairs(v.map) do
      s = s + sum_no_red(child)
    end
    return s
  elseif type(v) == 'table' and v[1] == 'array' then
    local s = 0
    for i = 2, #v do
      s = s + sum_no_red(v[i])
    end
    return s
  end
  return 0
end

local function day12(path)
  local lines = readLines(path)
  local raw = table.concat(lines, '')
  local part1 = sum_numbers_regex(raw)
  local tree = parse_json(raw)
  local part2 = sum_no_red(tree)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day12(path)
end
