local MOD = 2147483647
local A_MUL = 16807
local B_MUL = 48271

local function day15(path)
  local lines = readLines(path)
  local a0 = tonumber(lines[1]:match('(%d+)') or '0')
  local b0 = tonumber(lines[2]:match('(%d+)') or '0')

  local a, b = a0, b0
  local p1 = 0
  for _ = 1, 40000000 do
    a = (a * A_MUL) % MOD
    b = (b * B_MUL) % MOD
    if (a & 0xffff) == (b & 0xffff) then
      p1 = p1 + 1
    end
  end

  a, b = a0, b0
  local p2 = 0
  for _ = 1, 5000000 do
    repeat
      a = (a * A_MUL) % MOD
    until a % 4 == 0
    repeat
      b = (b * B_MUL) % MOD
    until b % 8 == 0
    if (a & 0xffff) == (b & 0xffff) then
      p2 = p2 + 1
    end
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day15(path)
end
