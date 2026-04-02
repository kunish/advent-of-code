local function day5(path)
  local lines = readLines(path)
  local start_moves = 1
  for i = 1, #lines do
    if lines[i] == '' then
      start_moves = i + 1
      break
    end
  end

  local crate_end = start_moves - 2
  local num_line = lines[crate_end]
  local nstacks = 0
  for _ in num_line:gmatch('%d+') do
    nstacks = nstacks + 1
  end

  local stacks = {}
  for c = 1, nstacks do
    stacks[c] = {}
  end

  for row = crate_end - 1, 1, -1 do
    local line = lines[row]
    for col = 1, nstacks do
      local pos = 1 + 4 * (col - 1)
      if line:sub(pos, pos) == '[' then
        local ch = line:sub(pos + 1, pos + 1)
        local st = stacks[col]
        st[#st + 1] = ch
      end
    end
  end

  local function copy_stacks()
    local out = {}
    for c = 1, nstacks do
      out[c] = {}
      local src = stacks[c]
      for j = 1, #src do
        out[c][j] = src[j]
      end
    end
    return out
  end

  local function apply_moves(s, part1_mode)
    for m = start_moves, #lines do
      local line = lines[m]
      local n, from, to = line:match('move (%d+) from (%d+) to (%d+)')
      n = tonumber(n)
      from = tonumber(from)
      to = tonumber(to)
      local src = s[from]
      local dst = s[to]
      local chunk = {}
      for k = 1, n do
        chunk[k] = table.remove(src)
      end
      if part1_mode then
        for k = 1, n do
          dst[#dst + 1] = chunk[k]
        end
      else
        for k = n, 1, -1 do
          dst[#dst + 1] = chunk[k]
        end
      end
    end
  end

  local s1 = copy_stacks()
  apply_moves(s1, true)
  local top1 = {}
  for c = 1, nstacks do
    local st = s1[c]
    top1[c] = st[#st] or ''
  end

  local s2 = copy_stacks()
  apply_moves(s2, false)
  local top2 = {}
  for c = 1, nstacks do
    local st = s2[c]
    top2[c] = st[#st] or ''
  end

  print(string.format('Part 1: %s', table.concat(top1)))
  print(string.format('Part 2: %s', table.concat(top2)))
end

return function(p)
  return day5(p)
end
