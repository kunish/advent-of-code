return function(path)
  local lines = readLines(path)
  local rock = {}

  local function set_rock(x, y)
    rock[x .. ',' .. y] = true
  end

  local max_y = 0
  for li = 1, #lines do
    local line = lines[li]
    local pts = {}
    for sx, sy in line:gmatch('(%d+),(%d+)') do
      pts[#pts + 1] = { tonumber(sx), tonumber(sy) }
    end
    for pi = 2, #pts do
      local x0, y0 = pts[pi - 1][1], pts[pi - 1][2]
      local x1, y1 = pts[pi][1], pts[pi][2]
      if x0 == x1 then
        local lo = math.min(y0, y1)
        local hi = math.max(y0, y1)
        local yy = lo
        while yy <= hi do
          set_rock(x0, yy)
          if yy > max_y then
            max_y = yy
          end
          yy = yy + 1
        end
      else
        local lo = math.min(x0, x1)
        local hi = math.max(x0, x1)
        local xx = lo
        while xx <= hi do
          set_rock(xx, y0)
          if y0 > max_y then
            max_y = y0
          end
          xx = xx + 1
        end
      end
    end
  end

  local function run_part1()
    local sand = {}
    for k, v in pairs(rock) do
      sand[k] = v
    end
    local units = 0
    while true do
      local x, y = 500, 0
      while true do
        if y > max_y then
          print(string.format('Part 1: %d', units))
          return
        end
        local ny = y + 1
        if not sand[x .. ',' .. ny] then
          y = ny
        elseif not sand[(x - 1) .. ',' .. ny] then
          x, y = x - 1, ny
        elseif not sand[(x + 1) .. ',' .. ny] then
          x, y = x + 1, ny
        else
          break
        end
      end
      sand[x .. ',' .. y] = true
      units = units + 1
    end
  end

  local function run_part2()
    local floor_y = max_y + 2
    local sand = {}
    for k, v in pairs(rock) do
      sand[k] = v
    end
    local units = 0
    while true do
      local x, y = 500, 0
      if sand['500,0'] then
        print(string.format('Part 2: %d', units))
        return
      end
      while true do
        local ny = y + 1
        if ny == floor_y then
          break
        end
        if not sand[x .. ',' .. ny] then
          y = ny
        elseif not sand[(x - 1) .. ',' .. ny] then
          x, y = x - 1, ny
        elseif not sand[(x + 1) .. ',' .. ny] then
          x, y = x + 1, ny
        else
          break
        end
      end
      sand[x .. ',' .. y] = true
      units = units + 1
    end
  end

  run_part1()
  run_part2()
end
