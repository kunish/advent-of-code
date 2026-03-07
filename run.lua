local runner = require('runner')

local year = tonumber(arg[1])
local day = tonumber(arg[2])

if not year or not day then
  print('Usage: lua run.lua <year> <day> [input_path]')
  os.exit(1)
end

local input_path = arg[3]
runner.run(year, day, input_path)
