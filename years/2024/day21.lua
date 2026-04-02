return function(path)
  local lines = readLines(path)

  -- (x, y) column, row; y down
  local num_kp = {
    ['7'] = { 0, 0 },
    ['8'] = { 1, 0 },
    ['9'] = { 2, 0 },
    ['4'] = { 0, 1 },
    ['5'] = { 1, 1 },
    ['6'] = { 2, 1 },
    ['1'] = { 0, 2 },
    ['2'] = { 1, 2 },
    ['3'] = { 2, 2 },
    ['nul'] = { 0, 3 },
    ['0'] = { 1, 3 },
    ['A'] = { 2, 3 },
  }

  local dir_kp = {
    ['nul'] = { 0, 0 },
    ['^'] = { 1, 0 },
    ['A'] = { 2, 0 },
    ['<'] = { 0, 1 },
    ['v'] = { 1, 1 },
    ['>'] = { 2, 1 },
  }

  local function key_at(kp, x, y)
    for k, p in pairs(kp) do
      if p[1] == x and p[2] == y then
        return k
      end
    end
    return nil
  end

  local function paths_between(kp, a, b)
    if a == b then
      return { '' }
    end
    local x1, y1 = kp[a][1], kp[a][2]
    local x2, y2 = kp[b][1], kp[b][2]
    local dx, dy = x2 - x1, y2 - y1
    local h = (dx > 0) and string.rep('>', dx) or string.rep('<', -dx)
    local v = (dy > 0) and string.rep('v', dy) or string.rep('^', -dy)

    local function ok(seq)
      local x, y = x1, y1
      for i = 1, #seq do
        local c = seq:sub(i, i)
        if c == '^' then
          y = y - 1
        elseif c == 'v' then
          y = y + 1
        elseif c == '<' then
          x = x - 1
        elseif c == '>' then
          x = x + 1
        end
        if key_at(kp, x, y) == 'nul' then
          return false
        end
      end
      return x == x2 and y == y2
    end

    local out = {}
    local function add(s)
      if ok(s) then
        out[#out + 1] = s
      end
    end
    add(h .. v)
    add(v .. h)
    return out
  end

  local memo = {}
  local function press_len(seq, depth)
    if depth == 0 then
      return #seq
    end
    local mk = seq .. '\0' .. depth
    if memo[mk] then
      return memo[mk]
    end
    local total = 0
    local pos = 'A'
    for i = 1, #seq do
      local ch = seq:sub(i, i)
      local ps = paths_between(dir_kp, pos, ch)
      local best = math.huge
      for j = 1, #ps do
        local p = ps[j] .. 'A'
        local v = press_len(p, depth - 1)
        if v < best then
          best = v
        end
      end
      total = total + best
      pos = ch
    end
    memo[mk] = total
    return total
  end

  local function code_len(code, depth)
    local total = 0
    local pos = 'A'
    for i = 1, #code do
      local ch = code:sub(i, i)
      local ps = paths_between(num_kp, pos, ch)
      local best = math.huge
      for j = 1, #ps do
        local p = ps[j] .. 'A'
        local v = press_len(p, depth)
        if v < best then
          best = v
        end
      end
      total = total + best
      pos = ch
    end
    return total
  end

  local function numeric_part(code)
    return tonumber(code:match('(%d+)'))
  end

  local p1, p2 = 0, 0
  for _, code in ipairs(lines) do
    if #code > 0 then
      memo = {}
      p1 = p1 + code_len(code, 2) * numeric_part(code)
      memo = {}
      p2 = p2 + code_len(code, 25) * numeric_part(code)
    end
  end

  print(string.format('Part 1: %.0f', p1))
  print(string.format('Part 2: %.0f', p2))
end
