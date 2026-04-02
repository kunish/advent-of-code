local function reverse_segment(list, pos0, len)
  local n = #list
  for k = 0, len // 2 - 1 do
    local ia = pos0 + k
    local ib = pos0 + len - 1 - k
    local a = ia % n + 1
    local b = ib % n + 1
    list[a], list[b] = list[b], list[a]
  end
end

local function make_list(n)
  local t = {}
  for i = 1, n do
    t[i] = i - 1
  end
  return t
end

local function knot_sparse(lengths, rounds)
  local list = make_list(256)
  local pos = 0
  local skip = 0
  for _ = 1, rounds do
    for _, L in ipairs(lengths) do
      reverse_segment(list, pos, L)
      pos = (pos + L + skip) % 256
      skip = skip + 1
    end
  end
  return list
end

local function dense_hash(list)
  local out = {}
  for b = 0, 15 do
    local x = 0
    for j = 1, 16 do
      x = x ~ list[b * 16 + j]
    end
    out[b + 1] = x
  end
  return out
end

local function to_hex(bytes)
  local parts = {}
  for i, v in ipairs(bytes) do
    parts[i] = string.format('%02x', v)
  end
  return table.concat(parts)
end

local function day10(path)
  local lines = readLines(path)
  local line = lines[1] or ''

  local lengths1 = {}
  for x in line:gmatch('%d+') do
    lengths1[#lengths1 + 1] = tonumber(x)
  end
  local list1 = knot_sparse(lengths1, 1)
  local part1 = list1[1] * list1[2]

  local lengths2 = {}
  for i = 1, #line do
    lengths2[#lengths2 + 1] = string.byte(line, i)
  end
  local suffix = { 17, 31, 73, 47, 23 }
  for _, v in ipairs(suffix) do
    lengths2[#lengths2 + 1] = v
  end
  local list2 = knot_sparse(lengths2, 64)
  local dense = dense_hash(list2)
  local part2 = to_hex(dense)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day10(path)
end
