local function all_zero(seq)
  for i = 1, #seq do
    if seq[i] ~= 0 then
      return false
    end
  end
  return true
end

local function extrapolate_next(seq)
  if all_zero(seq) then
    return 0
  end
  local d = {}
  for i = 1, #seq - 1 do
    d[i] = seq[i + 1] - seq[i]
  end
  return seq[#seq] + extrapolate_next(d)
end

local function extrapolate_prev(seq)
  if all_zero(seq) then
    return 0
  end
  local d = {}
  for i = 1, #seq - 1 do
    d[i] = seq[i + 1] - seq[i]
  end
  return seq[1] - extrapolate_prev(d)
end

local function parse_line(line)
  local t = {}
  for n in line:gmatch('%-?%d+') do
    t[#t + 1] = tonumber(n)
  end
  return t
end

local function day9(path)
  local lines = readLines(path)
  local p1, p2 = 0, 0
  for i = 1, #lines do
    if lines[i] ~= '' then
      local seq = parse_line(lines[i])
      p1 = p1 + extrapolate_next(seq)
      p2 = p2 + extrapolate_prev(seq)
    end
  end
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day9(p)
end
