local function dragon_step(a)
  local b = {}
  for i = #a, 1, -1 do
    b[#b + 1] = a[i] == '1' and '0' or '1'
  end
  local out = {}
  for i = 1, #a do
    out[i] = a[i]
  end
  out[#a + 1] = '0'
  local base = #a + 1
  for i = 1, #b do
    out[base + i] = b[i]
  end
  return out
end

local function fill_disk(init, disk_len)
  local cur = {}
  for i = 1, #init do
    cur[i] = init:sub(i, i)
  end
  while #cur < disk_len do
    cur = dragon_step(cur)
  end
  local out = {}
  for i = 1, disk_len do
    out[i] = cur[i]
  end
  return out
end

local function checksum_bits(bits)
  local cur = bits
  while #cur % 2 == 0 do
    local nxt = {}
    local n = #cur / 2
    for i = 1, n do
      local a, b = cur[2 * i - 1], cur[2 * i]
      nxt[i] = (a == b) and '1' or '0'
    end
    cur = nxt
  end
  return table.concat(cur)
end

local function day16(path)
  local lines = readLines(path)
  local init = (lines[1] or ''):gsub('%s+', '')

  local bits272 = fill_disk(init, 272)
  local p1 = checksum_bits(bits272)
  print(string.format('Part 1: %s', p1))

  local bits356 = fill_disk(init, 35651584)
  local p2 = checksum_bits(bits356)
  print(string.format('Part 2: %s', p2))
end

return function(path)
  return day16(path)
end
