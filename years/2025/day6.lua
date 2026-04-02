return function(path)
  local lines = readLines(path)

  local function reduce_op(op, t)
    local acc = t[1]
    for i = 2, #t do
      if op == '+' then
        acc = acc + t[i]
      else
        acc = acc * t[i]
      end
    end
    return acc
  end

  local nrow = #lines - 1
  local width = 0
  for r = 1, nrow do
    if #lines[r] > width then
      width = #lines[r]
    end
  end

  local nums = {}
  for r = 1, nrow do
    local row = {}
    for n in lines[r]:gmatch('%d+') do
      row[#row + 1] = tonumber(n)
    end
    nums[#nums + 1] = row
  end

  local ncols = #nums[1]
  local groups = {}
  for c = 1, ncols do
    local col = {}
    for r = 1, #nums do
      col[#col + 1] = nums[r][c]
    end
    groups[#groups + 1] = col
  end

  local syms = {}
  for s in lines[#lines]:gmatch('%S+') do
    syms[#syms + 1] = s
  end

  local part1 = 0
  for i = 1, #groups do
    local op = syms[i] == '+' and '+' or '*'
    part1 = part1 + reduce_op(op, groups[i])
  end

  local function col_chars(ci)
    local col = {}
    for r = 1, nrow do
      local line = lines[r]
      local ch = ' '
      if ci <= #line then
        ch = string.sub(line, ci, ci)
      end
      col[#col + 1] = ch
    end
    return col
  end

  local function all_space(col)
    for i = 1, #col do
      if col[i] ~= ' ' then
        return false
      end
    end
    return true
  end

  local cols = {}
  for ci = 1, width do
    cols[#cols + 1] = col_chars(ci)
  end

  for i = 1, #cols // 2 do
    cols[i], cols[#cols - i + 1] = cols[#cols - i + 1], cols[i]
  end

  local p2groups = {}
  local idx = 1
  while idx <= #cols do
    while idx <= #cols and all_space(cols[idx]) do
      idx = idx + 1
    end
    if idx > #cols then
      break
    end
    local block = {}
    while idx <= #cols and not all_space(cols[idx]) do
      block[#block + 1] = cols[idx]
      idx = idx + 1
    end
    local nums_g = {}
    for j = 1, #block do
      local s = ''
      for k = 1, #block[j] do
        s = s .. block[j][k]
      end
      nums_g[#nums_g + 1] = tonumber(s)
    end
    p2groups[#p2groups + 1] = nums_g
  end

  local rsym = {}
  for i = 1, #syms do
    rsym[i] = syms[#syms - i + 1]
  end

  local part2 = 0
  for i = 1, #p2groups do
    local op = rsym[i] == '+' and '+' or '*'
    part2 = part2 + reduce_op(op, p2groups[i])
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
