-- Run every solver in years/<year>/day*.lua for a year range; report success / errors.
-- Does not verify answers against known-good values — only that the script runs without error.
-- Usage: lua run_all.lua [from_year] [to_year]
-- Defaults: 2015 2025

local runner = require('runner')

local from_year = tonumber(arg[1]) or 2015
local to_year = tonumber(arg[2]) or 2025

local ok = 0
local missing_input = 0
local not_impl = 0
local other_err = 0

local function try_run(year, day)
  local input_path = string.format('inputs/%d/day%d.txt', year, day)
  local f = io.open(input_path, 'r')
  if not f then
    missing_input = missing_input + 1
    return
  end
  f:close()

  local err
  local good, result = pcall(function()
    return runner.run(year, day, input_path)
  end)
  if good then
    ok = ok + 1
    return
  end
  err = tostring(result)
  if err:find('not implemented yet') then
    not_impl = not_impl + 1
  else
    other_err = other_err + 1
    io.stderr:write(string.format('Error %d/%d: %s\n', year, day, err))
  end
end

for year = from_year, to_year do
  for day = 1, 25 do
    try_run(year, day)
  end
end

print(
  string.format(
    'OK: %d | missing input: %d | not implemented: %d | other errors: %d',
    ok,
    missing_input,
    not_impl,
    other_err
  )
)
