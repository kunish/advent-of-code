local function josephus_k2(n)
  local p = 1
  while p * 2 <= n do
    p = p * 2
  end
  return 2 * (n - p) + 1
end

-- Halving Josephus / "across the circle" (largest power of 3 <= n)
local function josephus_across(n)
  local u3 = 1
  while u3 * 3 <= n do
    u3 = u3 * 3
  end
  if n == u3 then
    return n
  end
  local threshold = u3 * 2
  if n <= threshold then
    return n - u3
  end
  return (n - u3) + (n - threshold)
end

return function(path)
  local lines = readLines(path)
  local n = tonumber(lines[1]:match('%d+'))

  print('Part 1: ' .. tostring(josephus_k2(n)))
  print('Part 2: ' .. tostring(josephus_across(n)))
end
