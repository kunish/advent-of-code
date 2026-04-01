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

---Download missing inputs for [from_year, to_year], days 1–25. Requires AOC_SESSION.
---@return number downloaded, number skipped_existing, table failed_list { "year/day", ... }
function M.prefetch_inputs(from_year, to_year)
  local downloaded = 0
  local skipped = 0
  local failed = {}

  for year = from_year, to_year do
    for day = 1, 25 do
      local path = string.format('inputs/%d/day%d.txt', year, day)
      local f = io.open(path, 'r')
      if f then
        f:close()
        skipped = skipped + 1
      elseif ensure_input(year, day, path) then
        downloaded = downloaded + 1
      else
        failed[#failed + 1] = string.format('%d/%d', year, day)
      end
    end
  end

  return downloaded, skipped, failed
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
