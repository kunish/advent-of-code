local intcode = require('years.2019.intcode')

local function day9(path)
  local lines = readLines(path)
  local prog = intcode.parse(lines[1] or '')
  local o1 = intcode.run(intcode.copy(prog), { 1 })
  local o2 = intcode.run(intcode.copy(prog), { 2 })
  print(string.format('Part 1: %d', o1[#o1]))
  print(string.format('Part 2: %d', o2[#o2]))
end

return function(path)
  return day9(path)
end
