return function(path)
  local lines = readLines(path)
  local i = 1
  local machines = {}

  while i <= #lines do
    local line = lines[i]
    if line and line:find('Button A') then
      local ax, ay = line:match('X%+(%d+),%s*Y%+(%d+)')
      local lineb = lines[i + 1]
      local bx, by = lineb:match('X%+(%d+),%s*Y%+(%d+)')
      local linep = lines[i + 2]
      local px, py = linep:match('X=(%d+),%s*Y=(%d+)')
      if ax and bx and px then
        machines[#machines + 1] = {
          ax = tonumber(ax),
          ay = tonumber(ay),
          bx = tonumber(bx),
          by = tonumber(by),
          px = tonumber(px),
          py = tonumber(py),
        }
      end
      i = i + 4
    else
      i = i + 1
    end
  end

  local part1, part2 = 0, 0
  for _, m in ipairs(machines) do
    local ax, ay, bx, by, px, py = m.ax, m.ay, m.bx, m.by, m.px, m.py
    local best = nil
    for a = 0, 100 do
      local rx = px - ax * a
      local ry = py - ay * a
      if bx ~= 0 and rx % bx == 0 then
        local b = rx / bx
        if b >= 0 and b <= 100 and b * by == ry then
          local cost = 3 * a + b
          if not best or cost < best then
            best = cost
          end
        end
      end
    end
    if best then
      part1 = part1 + best
    end

    local add = 10000000000000
    local ax, ay, bx, by = m.ax, m.ay, m.bx, m.by
    local px = m.px + add
    local py = m.py + add
    local det = ax * by - ay * bx
    if det ~= 0 then
      local numa = px * by - py * bx
      local numb = ax * py - ay * px
      if numa % det == 0 and numb % det == 0 then
        local a = numa / det
        local b = numb / det
        if a >= 0 and b >= 0 then
          part2 = part2 + 3 * a + b
        end
      end
    end
  end

  print('Part 1: ' .. string.format('%.0f', part1))
  print('Part 2: ' .. string.format('%.0f', part2))
end
