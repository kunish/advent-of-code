local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

local function lcm(a, b)
  return (a // gcd(a, b)) * b
end

local function lcm_list(t)
  local x = t[1]
  for i = 2, #t do
    x = lcm(x, t[i])
  end
  return x
end

local function day8(path)
  local lines = readLines(path)
  local instr = lines[1]
  local ilen = #instr
  local net = {}
  for i = 3, #lines do
    local line = lines[i]
    if line ~= '' then
      local name, l, r = line:match('(%w+)%s*=%s*%((%w+),%s*(%w+)%)')
      if name then
        net[name] = { L = l, R = r }
      end
    end
  end

  local function steps_to_z(start, part2)
    local node = start
    local s = 0
    local pos = 1
    while true do
      if part2 then
        if node:sub(3, 3) == 'Z' then
          break
        end
      else
        if node == 'ZZZ' then
          break
        end
      end
      local dir = instr:sub(pos, pos)
      pos = pos + 1
      if pos > ilen then
        pos = 1
      end
      local nx = net[node]
      if dir == 'L' then
        node = nx.L
      else
        node = nx.R
      end
      s = s + 1
    end
    return s
  end

  local part1 = steps_to_z('AAA', false)

  local cycles = {}
  for k, _ in pairs(net) do
    if k:sub(3, 3) == 'A' then
      cycles[#cycles + 1] = steps_to_z(k, true)
    end
  end
  local part2 = lcm_list(cycles)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day8(p)
end
