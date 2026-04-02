local function code_memory_delta(line)
  -- line is like "...." with surrounding quotes
  local mem = 0
  local i = 2
  local last = #line - 1
  while i <= last do
    if line:sub(i, i) ~= '\\' then
      mem = mem + 1
      i = i + 1
    else
      local n = line:sub(i + 1, i + 1)
      if n == '\\' or n == '"' then
        mem = mem + 1
        i = i + 2
      elseif n == 'x' then
        mem = mem + 1
        i = i + 4
      else
        mem = mem + 1
        i = i + 2
      end
    end
  end
  return #line - mem
end

local function encoded_minus_code(line)
  local enc = 2
  for j = 1, #line do
    local c = line:sub(j, j)
    if c == '"' or c == '\\' then
      enc = enc + 2
    else
      enc = enc + 1
    end
  end
  return enc - #line
end

local function day8(path)
  local lines = readLines(path)
  local part1 = 0
  local part2 = 0
  for _, line in ipairs(lines) do
    if line ~= '' then
      part1 = part1 + code_memory_delta(line)
      part2 = part2 + encoded_minus_code(line)
    end
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day8(path)
end
