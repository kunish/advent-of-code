local intcode = require('years.2019.intcode')

local function day5(path)
  local lines = readLines(path)
  local prog = intcode.parse(lines[1] or '')

  local outs1 = intcode.run(intcode.copy(prog), { 1 })
  local outs2 = intcode.run(intcode.copy(prog), { 5 })

  print(string.format('Part 1: %d', outs1[#outs1]))
  print(string.format('Part 2: %d', outs2[#outs2]))
end

return function(path)
  return day5(path)
end
