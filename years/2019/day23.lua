local intcode = dofile('years/2019/intcode.lua')

local N = 50

local function day23(path)
  local lines = readLines(path)
  local base = intcode.parse(lines[1] or '')

  local vms = {}
  local queues = {}
  for a = 0, N - 1 do
    local vm = intcode.new(intcode.copy(base))
    vm:run()
    vm:push_input(a)
    vms[a + 1] = vm
    queues[a + 1] = {}
  end

  local nat_x, nat_y
  local part1
  local last_y0
  local part2

  while not part2 do
    local idle = true

    for i = 1, N do
      local vm = vms[i]
      while not vm.halted and not vm.waiting_for_input do
        vm:run()
      end
      while vm:has_output() do
        idle = false
        local dest = vm:pop_output()
        local x = vm:pop_output()
        local y = vm:pop_output()
        if dest == 255 then
          nat_x, nat_y = x, y
          if not part1 then
            part1 = y
          end
        else
          local q = queues[dest + 1]
          q[#q + 1] = x
          q[#q + 1] = y
        end
      end
    end

    for i = 1, N do
      local vm = vms[i]
      if vm.waiting_for_input then
        local q = queues[i]
        if #q >= 2 then
          idle = false
          vm:push_input(q[1])
          vm:push_input(q[2])
          table.remove(q, 1)
          table.remove(q, 1)
        else
          vm:push_input(-1)
        end
      end
    end

    if idle and nat_x then
      if last_y0 ~= nil and nat_y == last_y0 then
        part2 = nat_y
        break
      end
      last_y0 = nat_y
      local q0 = queues[1]
      q0[#q0 + 1] = nat_x
      q0[#q0 + 1] = nat_y
    end
  end

  print(string.format('Part 1: %d', part1 or -1))
  print(string.format('Part 2: %d', part2 or -1))
end

return function(p)
  return day23(p)
end
