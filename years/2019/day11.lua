local intcode = require('years.2019.intcode')

local function key(x, y)
  return x .. ',' .. y
end

local function run_robot(prog, start_white)
  local state = intcode.new(prog)
  local panels = {}
  local x, y = 0, 0
  local dir = 0
  local dx = { 0, 1, 0, -1 }
  local dy = { -1, 0, 1, 0 }
  if start_white then
    panels[key(0, 0)] = 1
  end

  local expect_color = true
  while true do
    local ev = intcode.step(state)
    if ev == 'in' then
      local c = panels[key(x, y)]
      if c == nil then
        c = 0
      end
      intcode.apply_input(state, c)
    elseif type(ev) == 'table' and ev[1] == 'out' then
      local v = ev[2]
      if expect_color then
        panels[key(x, y)] = v
        expect_color = false
      else
        if v == 0 then
          dir = (dir + 3) % 4
        else
          dir = (dir + 1) % 4
        end
        x = x + dx[dir + 1]
        y = y + dy[dir + 1]
        expect_color = true
      end
    elseif ev == 'halt' then
      break
    end
  end
  return panels
end

local function render(panels)
  local minx, maxx, miny, maxy = nil, nil, nil, nil
  for k, _ in pairs(panels) do
    local a, b = k:match('^(%-?%d+),(%-?%d+)$')
    a, b = tonumber(a), tonumber(b)
    if minx == nil or a < minx then
      minx = a
    end
    if maxx == nil or a > maxx then
      maxx = a
    end
    if miny == nil or b < miny then
      miny = b
    end
    if maxy == nil or b > maxy then
      maxy = b
    end
  end
  if minx == nil then
    return ''
  end
  local rows = {}
  local yy = miny
  while yy <= maxy do
    local row = {}
    local xx = minx
    while xx <= maxx do
      local c = panels[key(xx, yy)]
      if c == 1 then
        row[#row + 1] = '#'
      else
        row[#row + 1] = ' '
      end
      xx = xx + 1
    end
    rows[#rows + 1] = table.concat(row)
    yy = yy + 1
  end
  return table.concat(rows, '\n')
end

local function day11(path)
  local lines = readLines(path)
  local prog = intcode.parse(lines[1] or '')

  local p1 = run_robot(prog, false)
  local n1 = 0
  for _ in pairs(p1) do
    n1 = n1 + 1
  end

  local ocr = require('ocr')
  local p2 = run_robot(prog, true)
  local msg = render(p2)
  local msg_rows = {}
  for line in (msg .. '\n'):gmatch('([^\n]*)\n') do
    msg_rows[#msg_rows + 1] = line
  end

  print(string.format('Part 1: %d', n1))
  print(string.format('Part 2: %s', ocr.decode(msg_rows)))
end

return function(path)
  return day11(path)
end
