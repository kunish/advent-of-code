local intcode = dofile('years/2019/intcode.lua')

local function run_spring(mem, script)
  local vm = intcode.new(intcode.copy(mem))
  local inputs = {}
  for i = 1, #script do
    inputs[#inputs + 1] = script:byte(i, i)
  end
  local ii = 1
  vm:run()
  while not vm.halted do
    if vm.waiting_for_input then
      if ii > #inputs then
        error('day21: out of input')
      end
      vm:push_input(inputs[ii])
      ii = ii + 1
    else
      vm:run()
    end
  end
  local last = 0
  for j = 1, #vm.output_queue do
    local v = vm.output_queue[j]
    if v > 127 then
      last = v
    end
  end
  return last
end

local function day21(path)
  local lines = readLines(path)
  local mem = intcode.parse(lines[1] or '')

  local p1_script = table.concat({
    'OR A T',
    'AND B T',
    'AND C T',
    'NOT T J',
    'AND D J',
    'WALK',
    '',
  }, '\n')

  local p2_script = table.concat({
    'OR A T',
    'AND B T',
    'AND C T',
    'NOT T J',
    'AND D J',
    'OR E T',
    'OR H T',
    'AND T J',
    'AND J T',
    'RUN',
    '',
  }, '\n')

  local p1 = run_spring(mem, p1_script)
  local p2 = run_spring(mem, p2_script)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day21(p)
end
