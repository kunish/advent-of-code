return function(path)
  local line = readLines(path)[1]
  local start = {}
  local n = 0
  for num in string.gmatch(line, '(%d+)') do
    n = n + 1
    start[n] = tonumber(num)
  end

  local function play(until_turn)
    local last_turn = {}
    local turn = 1
    local last = 0
    local i = 1
    while i < n do
      local v = start[i]
      last_turn[v] = turn
      turn = turn + 1
      i = i + 1
    end
    last = start[n]
    while turn < until_turn do
      local prev = last_turn[last]
      last_turn[last] = turn
      if prev then
        last = turn - prev
      else
        last = 0
      end
      turn = turn + 1
    end
    return last
  end

  print(string.format('Part 1: %d', play(2020)))
  print(string.format('Part 2: %d', play(30000000)))
end
