return function(path)
  local lines = readLines(path)
  local towels = {}
  for t in lines[1]:gmatch('[^, ]+') do
    if #t > 0 then
      towels[#towels + 1] = t
    end
  end

  local designs = {}
  local blank
  for i = 2, #lines do
    if lines[i] == '' then
      blank = i
      break
    end
  end
  for i = (blank or 1) + 1, #lines do
    if #lines[i] > 0 then
      designs[#designs + 1] = lines[i]
    end
  end
  if not blank then
    designs = {}
    for i = 2, #lines do
      if #lines[i] > 0 then
        designs[#designs + 1] = lines[i]
      end
    end
  end

  local memo = {}
  local function count_ways(s, start)
    if start > #s then
      return 1
    end
    local mk = start
    if memo[mk] then
      return memo[mk]
    end
    local total = 0
    for ti = 1, #towels do
      local t = towels[ti]
      if start + #t - 1 <= #s and s:sub(start, start + #t - 1) == t then
        total = total + count_ways(s, start + #t)
      end
    end
    memo[mk] = total
    return total
  end

  local p1, p2 = 0, 0
  for di = 1, #designs do
    memo = {}
    local w = count_ways(designs[di], 1)
    if w > 0 then
      p1 = p1 + 1
    end
    p2 = p2 + w
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %.0f', p2))
end
