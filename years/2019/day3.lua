local function parse_wire(s)
  local segs = {}
  for seg in string.gmatch(s, '[^,]+') do
    local d = seg:sub(1, 1)
    local n = tonumber(seg:sub(2))
    segs[#segs + 1] = { d, n }
  end
  return segs
end

local function walk_wire(segs, on_step)
  local x, y = 0, 0
  local steps = 0
  local si = 1
  while si <= #segs do
    local d, n = segs[si][1], segs[si][2]
    local dx, dy = 0, 0
    if d == 'R' then
      dx = 1
    elseif d == 'L' then
      dx = -1
    elseif d == 'U' then
      dy = 1
    elseif d == 'D' then
      dy = -1
    end
    local k = 1
    while k <= n do
      x = x + dx
      y = y + dy
      steps = steps + 1
      on_step(x, y, steps)
      k = k + 1
    end
    si = si + 1
  end
end

local function day3(path)
  local lines = readLines(path)
  local w1 = parse_wire(lines[1] or '')
  local w2 = parse_wire(lines[2] or '')

  local seen = {}
  walk_wire(w1, function(x, y, st)
    local key = x .. ',' .. y
    if seen[key] == nil then
      seen[key] = st
    end
  end)

  local best_md = nil
  local best_steps = nil

  walk_wire(w2, function(x, y, st)
    local key = x .. ',' .. y
    local prev = seen[key]
    if prev ~= nil then
      local md = math.abs(x) + math.abs(y)
      if best_md == nil or md < best_md then
        best_md = md
      end
      local total = prev + st
      if best_steps == nil or total < best_steps then
        best_steps = total
      end
    end
  end)

  print(string.format('Part 1: %d', best_md or 0))
  print(string.format('Part 2: %d', best_steps or 0))
end

return function(path)
  return day3(path)
end
