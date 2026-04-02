return function(path)
  local lines = readLines(path)
  local rules = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    local id_s, rest = string.match(line, '^(%d+):%s*(.+)$')
    if not id_s then
      break
    end
    local id = tonumber(id_s)
    if string.sub(rest, 1, 1) == '"' then
      local ch = string.match(rest, '^"(.)"$')
      rules[id] = { type = 'lit', ch = ch }
    else
      local bar = string.find(rest, '|', 1, true)
      if bar then
        local left = string.sub(rest, 1, bar - 1)
        local right = string.sub(rest, bar + 1)
        local function nums(s)
          local t = {}
          for n in string.gmatch(s, '(%d+)') do
            t[#t + 1] = tonumber(n)
          end
          return t
        end
        rules[id] = { type = 'alt', left = nums(left), right = nums(right) }
      else
        local t = {}
        for n in string.gmatch(rest, '(%d+)') do
          t[#t + 1] = tonumber(n)
        end
        rules[id] = { type = 'seq', parts = t }
      end
    end
    i = i + 1
  end

  while i <= #lines and lines[i] == '' do
    i = i + 1
  end

  local messages = {}
  while i <= #lines do
    if lines[i] ~= '' then
      messages[#messages + 1] = lines[i]
    end
    i = i + 1
  end

  local s = ''
  local memo = {}
  local memo11 = {}

  local match, match8, match11, match_seq

  match = function(id, pos, p2)
    if pos > #s then
      return {}
    end
    if p2 and id == 8 then
      return match8(pos)
    end
    if p2 and id == 11 then
      return match11(pos)
    end
    local key = id .. ',' .. pos .. ',' .. (p2 and '1' or '0')
    if memo[key] then
      return memo[key]
    end
    local r = rules[id]
    local out = {}
    local function add_list(t)
      local k = 1
      while k <= #t do
        out[#out + 1] = t[k]
        k = k + 1
      end
    end

    if r.type == 'lit' then
      if string.sub(s, pos, pos) == r.ch then
        out[1] = pos + 1
      end
    elseif r.type == 'seq' then
      local ends = { pos }
      local pi = 1
      while pi <= #r.parts do
        local rid = r.parts[pi]
        local newends = {}
        local ei = 1
        while ei <= #ends do
          local e = ends[ei]
          local nxt = match(rid, e, p2)
          local ni = 1
          while ni <= #nxt do
            newends[#newends + 1] = nxt[ni]
            ni = ni + 1
          end
          ei = ei + 1
        end
        ends = newends
        pi = pi + 1
      end
      out = ends
    elseif r.type == 'alt' then
      local a = match_seq(r.left, pos, p2)
      local b = match_seq(r.right, pos, p2)
      add_list(a)
      add_list(b)
    end

    memo[key] = out
    return out
  end

  match_seq = function(parts, pos, p2)
    local ends = { pos }
    local pi = 1
    while pi <= #parts do
      local rid = parts[pi]
      local newends = {}
      local ei = 1
      while ei <= #ends do
        local e = ends[ei]
        local nxt = match(rid, e, p2)
        local ni = 1
        while ni <= #nxt do
          newends[#newends + 1] = nxt[ni]
          ni = ni + 1
        end
        ei = ei + 1
      end
      ends = newends
      pi = pi + 1
    end
    return ends
  end

  match8 = function(pos)
    local key = '8,' .. pos
    if memo[key] then
      return memo[key]
    end
    local res = {}
    local seen = {}
    local n42 = match(42, pos, true)
    local i = 1
    while i <= #n42 do
      local e = n42[i]
      if not seen[e] then
        seen[e] = true
        res[#res + 1] = e
      end
      local cont = match8(e)
      local j = 1
      while j <= #cont do
        local e2 = cont[j]
        if not seen[e2] then
          seen[e2] = true
          res[#res + 1] = e2
        end
        j = j + 1
      end
      i = i + 1
    end
    memo[key] = res
    return res
  end

  match11 = function(pos)
    local key = '11,' .. pos
    if memo11[key] then
      return memo11[key]
    end
    local seen = {}
    local res = {}
    local n42 = match(42, pos, true)
    local i = 1
    while i <= #n42 do
      local e1 = n42[i]
      local n31 = match(31, e1, true)
      local j = 1
      while j <= #n31 do
        local e2 = n31[j]
        if not seen[e2] then
          seen[e2] = true
          res[#res + 1] = e2
        end
        j = j + 1
      end
      local mid = match11(e1)
      local k = 1
      while k <= #mid do
        local em = mid[k]
        local n312 = match(31, em, true)
        local m = 1
        while m <= #n312 do
          local e2 = n312[m]
          if not seen[e2] then
            seen[e2] = true
            res[#res + 1] = e2
          end
          m = m + 1
        end
        k = k + 1
      end
      i = i + 1
    end
    memo11[key] = res
    return res
  end

  local function valid(msg, p2)
    s = msg
    memo = {}
    memo11 = {}
    local ends = match(0, 1, p2)
    local t = 1
    while t <= #ends do
      if ends[t] == #msg + 1 then
        return true
      end
      t = t + 1
    end
    return false
  end

  local p1 = 0
  local mi = 1
  while mi <= #messages do
    if valid(messages[mi], false) then
      p1 = p1 + 1
    end
    mi = mi + 1
  end

  local p2 = 0
  mi = 1
  while mi <= #messages do
    if valid(messages[mi], true) then
      p2 = p2 + 1
    end
    mi = mi + 1
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
