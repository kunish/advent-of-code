return function(path)
  local lines = readLines(path)

  local function parse_point(line)
    local x, y = line:match('^(%d+),(%d+)$')
    return tonumber(x), tonumber(y)
  end

  local pts = {}
  for i = 1, #lines do
    local x, y = parse_point(lines[i])
    pts[#pts + 1] = { x, y }
  end

  local function rect_area(a, b)
    local x1, y1, x2, y2 = a[1], a[2], b[1], b[2]
    return (math.abs(x2 - x1) + 1) * (math.abs(y2 - y1) + 1)
  end

  local part1 = 0
  for i = 1, #pts do
    for j = i + 1, #pts do
      local a = rect_area(pts[i], pts[j])
      if a > part1 then
        part1 = a
      end
    end
  end

  local function point_on_edge(px, py, x1, y1, x2, y2)
    local mix, mx = x1, x2
    if x1 > x2 then
      mix, mx = x2, x1
    end
    local miy, my = y1, y2
    if y1 > y2 then
      miy, my = y2, y1
    end
    return mix <= px and px <= mx and miy <= py and py <= my
  end

  local function point_in_poly(px, py, poly)
    local n = #poly
    for i = 1, n do
      local j = i % n + 1
      local x1, y1 = poly[i][1], poly[i][2]
      local x2, y2 = poly[j][1], poly[j][2]
      if point_on_edge(px, py, x1, y1, x2, y2) then
        return true
      end
    end
    local crossings = 0
    for i = 1, n do
      local j = i % n + 1
      local x1, y1 = poly[i][1], poly[i][2]
      local x2, y2 = poly[j][1], poly[j][2]
      if y1 ~= y2 then
        local ymin, ymax = y1, y2
        if y1 > y2 then
          ymin, ymax = y2, y1
        end
        if px < x1 and ymin < py and py <= ymax then
          crossings = crossings + 1
        end
      end
    end
    return crossings % 2 == 1
  end

  local function rect_in_poly(c1, c2, poly)
    local rx1, ry1, rx2, ry2 = c1[1], c1[2], c2[1], c2[2]
    if rx1 > rx2 then
      rx1, rx2 = rx2, rx1
    end
    if ry1 > ry2 then
      ry1, ry2 = ry2, ry1
    end
    local corners = {
      { rx1, ry1 },
      { rx2, ry1 },
      { rx2, ry2 },
      { rx1, ry2 },
    }
    for i = 1, 4 do
      if not point_in_poly(corners[i][1], corners[i][2], poly) then
        return false
      end
    end

    local n = #poly
    for i = 1, n do
      local j = i % n + 1
      local px1, py1 = poly[i][1], poly[i][2]
      local px2, py2 = poly[j][1], poly[j][2]
      local pxa, pxb = px1, px2
      if px1 > px2 then
        pxa, pxb = px2, px1
      end
      local pya, pyb = py1, py2
      if py1 > py2 then
        pya, pyb = py2, py1
      end
      if pxa < rx2 and rx1 < pxb and pya < ry2 and ry1 < pyb then
        return false
      end
    end

    if rx2 - rx1 > 1 and ry2 - ry1 > 1 then
      local inner = {
        { rx1 + 1, ry1 + 1 },
        { rx2 - 1, ry1 + 1 },
        { rx2 - 1, ry2 - 1 },
        { rx1 + 1, ry2 - 1 },
      }
      for i = 1, 4 do
        if not point_in_poly(inner[i][1], inner[i][2], poly) then
          return false
        end
      end
    end
    return true
  end

  local part2 = 0
  for i = 1, #pts do
    for j = i + 1, #pts do
      local a = rect_area(pts[i], pts[j])
      if a > part2 and rect_in_poly(pts[i], pts[j], pts) then
        part2 = a
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
