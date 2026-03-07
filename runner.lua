local M = {}

local function ensure_input(year, day, path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end

  local session = os.getenv('AOC_SESSION')
  if not session or session == '' then
    return false
  end

  os.execute(string.format('mkdir -p %q', string.format('inputs/%d', year)))
  local cmd = string.format(
    "curl -fsSL --cookie 'session=%s' 'https://adventofcode.com/%d/day/%d/input' -o '%s'",
    session,
    year,
    day,
    path
  )

  local ok, _, code = os.execute(cmd)
  return ok == true or code == 0
end

function readLines(path)
  local lines = {}
  local i = 1
  for line in io.lines(path) do
    lines[i] = line
    i = i + 1
  end
  return lines
end

local function load_solver(year, day)
  local solver_path = string.format('years/%d/day%d.lua', year, day)
  local file = io.open(solver_path, 'r')
  if not file then
    return nil, solver_path
  end
  file:close()

  local chunk = assert(loadfile(solver_path))
  return chunk(), solver_path
end

function M.run_day(day, path)
  return M.run(2021, day, path)
end

function M.run(year, day, path)
  local input_path = path or string.format('inputs/%d/day%d.txt', year, day)
  if not ensure_input(year, day, input_path) then
    error(string.format('input file missing: %s (set AOC_SESSION to auto-download)', input_path))
  end

  local solver, solver_path = load_solver(year, day)
  if not solver then
    error(string.format('solver not found: %s', solver_path))
  end

  return solver(input_path)
end

return M
