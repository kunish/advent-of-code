local function sign(n)
  if n > 0 then
    return 1
  end
  if n < 0 then
    return -1
  end
  return 0
end

local function follow(hx, hy, tx, ty)
  local dx = hx - tx
  local dy = hy - ty
  if math.abs(dx) <= 1 and math.abs(dy) <= 1 then
    return tx, ty
  end
  return tx + sign(dx), ty + sign(dy)
end

local function day9(path)
  local lines = readLines(path)

  local function simulate(nk)
    local knots = {}
    for k = 1, nk do
      knots[k] = { 0, 0 }
    end
    local seen = {}
    local function key(x, y)
      return tostring(x) .. ',' .. tostring(y)
    end
    seen[key(0, 0)] = true

    for li = 1, #lines do
      local line = lines[li]
      local dir, steps = line:match('(%a) (%d+)')
      steps = tonumber(steps)
      for _ = 1, steps do
        local hx = knots[1][1]
        local hy = knots[1][2]
        if dir == 'R' then
          hx = hx + 1
        elseif dir == 'L' then
          hx = hx - 1
        elseif dir == 'U' then
          hy = hy + 1
        else
          hy = hy - 1
        end
        knots[1][1] = hx
        knots[1][2] = hy
        for k = 2, nk do
          local px, py = follow(knots[k - 1][1], knots[k - 1][2], knots[k][1], knots[k][2])
          knots[k][1] = px
          knots[k][2] = py
        end
        local tx = knots[nk][1]
        local ty = knots[nk][2]
        seen[key(tx, ty)] = true
      end
    end
    local cnt = 0
    for _ in pairs(seen) do
      cnt = cnt + 1
    end
    return cnt
  end

  print(string.format('Part 1: %d', simulate(2)))
  print(string.format('Part 2: %d', simulate(10)))
end

return function(p)
  return day9(p)
end
