local function parse_moon(line)
  local x, y, z = line:match('x=(%-?%d+),%s*y=(%-?%d+),%s*z=(%-?%d+)')
  return {
    p = { tonumber(x), tonumber(y), tonumber(z) },
    v = { 0, 0, 0 },
  }
end

local function energy(moons)
  local e = 0
  local i = 1
  while i <= #moons do
    local p, v = moons[i].p, moons[i].v
    local pe = math.abs(p[1]) + math.abs(p[2]) + math.abs(p[3])
    local ke = math.abs(v[1]) + math.abs(v[2]) + math.abs(v[3])
    e = e + pe * ke
    i = i + 1
  end
  return e
end

local function step(moons)
  local i = 1
  while i <= #moons do
    local j = i + 1
    while j <= #moons do
      local a, b = moons[i].p, moons[j].p
      local ax = 1
      while ax <= 3 do
        if a[ax] < b[ax] then
          moons[i].v[ax] = moons[i].v[ax] + 1
          moons[j].v[ax] = moons[j].v[ax] - 1
        elseif a[ax] > b[ax] then
          moons[i].v[ax] = moons[i].v[ax] - 1
          moons[j].v[ax] = moons[j].v[ax] + 1
        end
        ax = ax + 1
      end
      j = j + 1
    end
    i = i + 1
  end
  i = 1
  while i <= #moons do
    local ax = 1
    while ax <= 3 do
      moons[i].p[ax] = moons[i].p[ax] + moons[i].v[ax]
      ax = ax + 1
    end
    i = i + 1
  end
end

local function copy_state(moons)
  local t = {}
  local i = 1
  while i <= #moons do
    t[i] = {
      p = { moons[i].p[1], moons[i].p[2], moons[i].p[3] },
      v = { moons[i].v[1], moons[i].v[2], moons[i].v[3] },
    }
    i = i + 1
  end
  return t
end

local function axis_key(moons, ax)
  local s = {}
  local i = 1
  while i <= #moons do
    s[#s + 1] = tostring(moons[i].p[ax])
    s[#s + 1] = ','
    s[#s + 1] = tostring(moons[i].v[ax])
    s[#s + 1] = ';'
    i = i + 1
  end
  return table.concat(s)
end

local function gcd(a, b)
  while b ~= 0 do
    local t = a % b
    a = b
    b = t
  end
  return a
end

local function lcm(a, b)
  return a // gcd(a, b) * b
end

local function cycle_len(initial, ax)
  local m = copy_state(initial)
  local start = axis_key(m, ax)
  local steps = 0
  repeat
    step(m)
    steps = steps + 1
  until axis_key(m, ax) == start
  return steps
end

local function day12(path)
  local lines = readLines(path)
  local initial = {}
  local i = 1
  while i <= #lines do
    if lines[i] ~= '' then
      initial[#initial + 1] = parse_moon(lines[i])
    end
    i = i + 1
  end

  local sim = copy_state(initial)
  local s = 0
  while s < 1000 do
    step(sim)
    s = s + 1
  end
  local part1 = energy(sim)

  local cx = cycle_len(initial, 1)
  local cy = cycle_len(initial, 2)
  local cz = cycle_len(initial, 3)
  local part2 = lcm(lcm(cx, cy), cz)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day12(path)
end
