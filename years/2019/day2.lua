local intcode = require('years.2019.intcode')

local function run_until_halt(mem)
  local vm = intcode.new(mem)
  while not vm.halted do
    local ev = intcode.step(vm)
    if ev == 'in' then
      error('day2: unexpected input wait')
    end
  end
  return vm.memory[0]
end

local function day2(path)
  local lines = readLines(path)
  local base = intcode.parse(lines[1] or '')

  local m1 = intcode.copy(base)
  m1[1] = 12
  m1[2] = 2
  local part1 = run_until_halt(m1)

  local part2 = 0
  local noun = 0
  while noun <= 99 do
    local verb = 0
    while verb <= 99 do
      local m = intcode.copy(base)
      m[1] = noun
      m[2] = verb
      if run_until_halt(m) == 19690720 then
        part2 = 100 * noun + verb
        noun = 100
        break
      end
      verb = verb + 1
    end
    noun = noun + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day2(path)
end
