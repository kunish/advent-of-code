local intcode = dofile('years/2019/intcode.lua')

local function beam(mem, x, y)
  local vm = intcode.new(intcode.copy(mem))
  vm:run()
  vm:push_input(x)
  vm:push_input(y)
  return vm.output_queue[1] or 0
end

local function day19(path)
  local lines = readLines(path)
  local mem = intcode.parse(lines[1] or '')

  local cnt = 0
  for y = 0, 49 do
    for x = 0, 49 do
      if beam(mem, x, y) == 1 then
        cnt = cnt + 1
      end
    end
  end

  local xl = 0
  local answer2 = nil
  for y = 2, 500000 do
    if beam(mem, xl, y) == 0 then
      local limit = xl + y + 10
      while xl < limit and beam(mem, xl, y) == 0 do
        xl = xl + 1
      end
      if beam(mem, xl, y) == 0 then
        xl = 0
        goto continue
      end
    end
    while xl > 0 and beam(mem, xl - 1, y) == 1 do
      xl = xl - 1
    end
    if y >= 99 and beam(mem, xl + 99, y - 99) == 1 then
      answer2 = xl * 10000 + (y - 99)
      break
    end
    ::continue::
  end

  print(string.format('Part 1: %d', cnt))
  print(string.format('Part 2: %d', answer2 or -1))
end

return function(p)
  return day19(p)
end
