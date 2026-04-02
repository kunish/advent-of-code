local function parse_banks(line)
  local banks = {}
  for x in line:gmatch('%d+') do
    banks[#banks + 1] = tonumber(x)
  end
  return banks
end

local function banks_key(banks)
  return table.concat(banks, ',')
end

local function redistribute(banks)
  local max_i, max_v = 1, banks[1]
  for i = 2, #banks do
    if banks[i] > max_v then
      max_i, max_v = i, banks[i]
    end
  end
  banks[max_i] = 0
  local idx = max_i
  for _ = 1, max_v do
    idx = idx % #banks + 1
    banks[idx] = banks[idx] + 1
  end
end

local function day6(path)
  local lines = readLines(path)
  local banks = parse_banks(lines[1] or '')
  local seen = {}
  local k0 = banks_key(banks)
  seen[k0] = 0
  local step = 0

  while true do
    redistribute(banks)
    step = step + 1
    local k = banks_key(banks)
    if seen[k] then
      print(string.format('Part 1: %d', step))
      print(string.format('Part 2: %d', step - seen[k]))
      return
    end
    seen[k] = step
  end
end

return function(path)
  return day6(path)
end
