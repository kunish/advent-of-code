local function fft_phase(input)
  local n = #input
  local out = {}
  for i = 1, n do
    local s = 0
    for j = 1, n do
      local pat_idx = math.floor(j / i) % 4
      local mul = ({ 0, 1, 0, -1 })[pat_idx + 1]
      s = s + input[j] * mul
    end
    out[i] = math.abs(s) % 10
  end
  return out
end

local function parse_digits(s)
  local t = {}
  for i = 1, #s do
    t[i] = tonumber(s:sub(i, i))
  end
  return t
end

local function digits_to_string(t, start_idx, len)
  local parts = {}
  for i = start_idx, start_idx + len - 1 do
    parts[#parts + 1] = tostring(t[i] or 0)
  end
  return table.concat(parts)
end

local function day16(path)
  local lines = readLines(path)
  local s = (lines[1] or ''):match('^%s*(.-)%s*$')
  local base = parse_digits(s)

  local a = {}
  for i = 1, #base do
    a[i] = base[i]
  end
  for _ = 1, 100 do
    a = fft_phase(a)
  end
  local p1 = digits_to_string(a, 1, 8)

  local offset = tonumber(s:sub(1, 7))
  local blen = #base
  local total = blen * 10000
  assert(offset >= total // 2, 'offset must be in second half for trick')

  local tail_len = total - offset
  local tail = {}
  for i = 1, tail_len do
    local src = ((offset + i - 1) % blen) + 1
    tail[i] = base[src]
  end

  for _ = 1, 100 do
    local acc = 0
    for i = tail_len, 1, -1 do
      acc = (acc + tail[i]) % 10
      tail[i] = acc
    end
  end

  local p2 = digits_to_string(tail, 1, 8)

  print(string.format('Part 1: %s', p1))
  print(string.format('Part 2: %s', p2))
end

return function(p)
  return day16(p)
end
