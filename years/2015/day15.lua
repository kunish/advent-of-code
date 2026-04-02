local function parse_line(line)
  -- Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
  local name, cap, dur, fla, tex, cal =
    line:match('^(%w+): capacity ([%-%d]+), durability ([%-%d]+), flavor ([%-%d]+), texture ([%-%d]+), calories ([%-%d]+)')
  return {
    name = name,
    capacity = tonumber(cap),
    durability = tonumber(dur),
    flavor = tonumber(fla),
    texture = tonumber(tex),
    calories = tonumber(cal),
  }
end

local function max0(x)
  return math.max(0, x)
end

local function score(ing, amounts, use_calories, target_cal)
  local cap, dur, fla, tex, cal = 0, 0, 0, 0, 0
  for i = 1, #ing do
    local a = amounts[i]
    cap = cap + ing[i].capacity * a
    dur = dur + ing[i].durability * a
    fla = fla + ing[i].flavor * a
    tex = tex + ing[i].texture * a
    cal = cal + ing[i].calories * a
  end
  if use_calories and cal ~= target_cal then
    return -1
  end
  return max0(cap) * max0(dur) * max0(fla) * max0(tex)
end

local function day15(path)
  local lines = readLines(path)
  local ing = {}
  for _, line in ipairs(lines) do
    if line ~= '' then
      ing[#ing + 1] = parse_line(line)
    end
  end
  local n = #ing
  assert(n == 4, 'expected 4 ingredients')
  local best1 = 0
  local best2 = 0
  for a = 0, 100 do
    for b = 0, 100 - a do
      for c = 0, 100 - a - b do
        local d = 100 - a - b - c
        local amounts = { a, b, c, d }
        local s1 = score(ing, amounts, false, 0)
        if s1 > best1 then
          best1 = s1
        end
        local s2 = score(ing, amounts, true, 500)
        if s2 > best2 then
          best2 = s2
        end
      end
    end
  end
  print(string.format('Part 1: %d', best1))
  print(string.format('Part 2: %d', best2))
end

return function(path)
  return day15(path)
end
