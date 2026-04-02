local function rotate_left(s, n)
  local len = #s
  n = n % len
  if n == 0 then
    return s
  end
  return s:sub(n + 1) .. s:sub(1, n)
end

local function reverse_str(s)
  local t = {}
  for i = #s, 1, -1 do
    t[#t + 1] = s:sub(i, i)
  end
  return table.concat(t)
end

local function rotate_right(s, n)
  local len = #s
  n = n % len
  if n == 0 then
    return s
  end
  return s:sub(len - n + 1) .. s:sub(1, len - n)
end

local function rot_based_on_letter(s, letter)
  local i0 = s:find(letter, 1, true) - 1
  local r = 1 + i0 + (i0 >= 4 and 1 or 0)
  return rotate_right(s, r)
end

local function parse_ops(lines)
  local ops = {}
  for _, line in ipairs(lines) do
    line = line:gsub('%s+$', '')
    local a, b, c = line:match('^swap position (%d+) with position (%d+)$')
    if a then
      ops[#ops + 1] = { 'sp', tonumber(a) + 1, tonumber(b) + 1 }
    else
      a, b = line:match('^swap letter ([a-z]) with letter ([a-z])$')
      if a then
        ops[#ops + 1] = { 'sl', a, b }
      else
        a = line:match('^rotate left (%d+) step')
        if a then
          ops[#ops + 1] = { 'rl', tonumber(a) }
        else
          a = line:match('^rotate right (%d+) step')
          if a then
            ops[#ops + 1] = { 'rr', tonumber(a) }
          else
            a = line:match('^rotate based on position of letter ([a-z])$')
            if a then
              ops[#ops + 1] = { 'rb', a }
            else
              a, b = line:match('^reverse positions (%d+) through (%d+)$')
              if a then
                ops[#ops + 1] = { 'rev', tonumber(a) + 1, tonumber(b) + 1 }
              else
                a, b = line:match('^move position (%d+) to position (%d+)$')
                if a then
                  ops[#ops + 1] = { 'mv', tonumber(a) + 1, tonumber(b) + 1 }
                end
              end
            end
          end
        end
      end
    end
  end
  return ops
end

local function scramble(s, ops)
  for _, op in ipairs(ops) do
    local k = op[1]
    if k == 'sp' then
      local i, j = op[2], op[3]
      local ci, cj = s:sub(i, i), s:sub(j, j)
      if i < j then
        s = s:sub(1, i - 1) .. cj .. s:sub(i + 1, j - 1) .. ci .. s:sub(j + 1)
      elseif i > j then
        s = s:sub(1, j - 1) .. ci .. s:sub(j + 1, i - 1) .. cj .. s:sub(i + 1)
      end
    elseif k == 'sl' then
      local x, y = op[2], op[3]
      s = s:gsub(x, '\0'):gsub(y, x):gsub('\0', y)
    elseif k == 'rl' then
      s = rotate_left(s, op[2])
    elseif k == 'rr' then
      s = rotate_right(s, op[2])
    elseif k == 'rb' then
      s = rot_based_on_letter(s, op[2])
    elseif k == 'rev' then
      local i, j = op[2], op[3]
      if i > j then
        i, j = j, i
      end
      s = s:sub(1, i - 1) .. reverse_str(s:sub(i, j)) .. s:sub(j + 1)
    elseif k == 'mv' then
      local from, to_ = op[2], op[3]
      local ch = s:sub(from, from)
      local t = s:sub(1, from - 1) .. s:sub(from + 1)
      s = t:sub(1, to_ - 1) .. ch .. t:sub(to_)
    end
  end
  return s
end

local function next_perm(t)
  local n = #t
  local i = n
  while i > 1 and t[i - 1] >= t[i] do
    i = i - 1
  end
  if i == 1 then
    return false
  end
  local j = n
  while t[j] <= t[i - 1] do
    j = j - 1
  end
  t[i - 1], t[j] = t[j], t[i - 1]
  local a, b = i, n
  while a < b do
    t[a], t[b] = t[b], t[a]
    a, b = a + 1, b - 1
  end
  return true
end

return function(path)
  local lines = readLines(path)
  local ops = parse_ops(lines)

  print('Part 1: ' .. scramble('abcdefgh', ops))

  local target = 'fbgdceah'
  local letters = {}
  for i = 1, 8 do
    letters[i] = target:sub(i, i)
  end
  table.sort(letters)
  repeat
    local try = table.concat(letters)
    if scramble(try, ops) == target then
      print('Part 2: ' .. try)
      return
    end
  until not next_perm(letters)

  print('Part 2: (not found)')
end
