local function split(s, sep)
  local t = {}
  for part in s:gmatch('[^' .. sep .. ']+') do
    t[#t + 1] = part
  end
  return t
end

local function parse_pat(s)
  return split(s, '/')
end

local function join_pat(rows)
  return table.concat(rows, '/')
end

local function flip_h(rows)
  local n = {}
  for _, row in ipairs(rows) do
    n[#n + 1] = row:reverse()
  end
  return n
end

local function rotate90(rows)
  local n = #rows
  local out = {}
  for c = 1, n do
    local s = {}
    for r = n, 1, -1 do
      s[#s + 1] = rows[r]:sub(c, c)
    end
    out[#out + 1] = table.concat(s)
  end
  return out
end

local function variants(rows)
  local seen = {}
  local keys = {}
  local function add(r)
    local k = join_pat(r)
    if not seen[k] then
      seen[k] = true
      keys[#keys + 1] = k
    end
  end

  local cur = rows
  for _ = 1, 4 do
    add(cur)
    add(flip_h(cur))
    cur = rotate90(cur)
  end
  return keys
end

local function day21(path)
  local lines = readLines(path)
  local rules = {}
  for _, line in ipairs(lines) do
    local a, b = line:match('^(%S+)%s+=>%s+(%S+)$')
    if a then
      local in_rows = parse_pat(a)
      for _, k in ipairs(variants(in_rows)) do
        rules[k] = b
      end
    end
  end

  local function enhance(rows)
    local n = #rows
    local sz = (n % 2 == 0) and 2 or 3
    local bc = n / sz
    local out_n = bc * (sz + 1)
    local out = {}
    for i = 1, out_n do
      out[i] = {}
    end

    for br = 0, bc - 1 do
      for bcol = 0, bc - 1 do
        local sub = {}
        for r = 1, sz do
          local line = rows[br * sz + r]
          local c0 = bcol * sz + 1
          sub[r] = line:sub(c0, c0 + sz - 1)
        end
        local key = join_pat(sub)
        local rep = rules[key]
        if not rep then
          error('missing rule for ' .. key)
        end
        local new_rows = parse_pat(rep)
        for r = 1, #new_rows do
          local orow = br * (#new_rows) + r
          local row = new_rows[r]
          for c = 1, #row do
            local ocol = bcol * (#new_rows) + c
            out[orow][ocol] = row:sub(c, c)
          end
        end
      end
    end

    local res = {}
    for r = 1, out_n do
      local s = {}
      for c = 1, out_n do
        s[c] = out[r][c]
      end
      res[r] = table.concat(s)
    end
    return res
  end

  local cur = parse_pat('.#./..#/###')

  local function count_on(rows)
    local t = 0
    for _, row in ipairs(rows) do
      for i = 1, #row do
        if row:sub(i, i) == '#' then
          t = t + 1
        end
      end
    end
    return t
  end

  local p1 = nil
  for i = 1, 18 do
    cur = enhance(cur)
    if i == 5 then
      p1 = count_on(cur)
    end
  end

  print(string.format('Part 1: %d', p1 or 0))
  print(string.format('Part 2: %d', count_on(cur)))
end

return function(path)
  return day21(path)
end
