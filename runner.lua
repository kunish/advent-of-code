local M = {}
local unpack = table.unpack or unpack

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function curl_config_value(s)
  return tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"')
end

local function command_succeeded(ok, code)
  return ok == true or ok == 0 or code == 0
end

local function temporary_path()
  local p = io.popen('mktemp', 'r')
  if p then
    local path = p:read('*l')
    local ok, _, code = p:close()
    if command_succeeded(ok, code) and path and path ~= '' then
      return path
    end
  end

  return os.tmpname()
end

local function write_curl_session_config(session)
  if session:find('[\r\n]') then
    return nil
  end

  local path = temporary_path()
  local file = io.open(path, 'w')
  if not file then
    os.remove(path)
    return nil
  end

  file:write('header = "Cookie: session=', curl_config_value(session), '"\n')
  file:close()
  os.execute(string.format('chmod 600 %s', shell_quote(path)))

  return path
end

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

  local curl_config = write_curl_session_config(session)
  if not curl_config then
    return false
  end

  os.execute(string.format('mkdir -p %s', shell_quote(string.format('inputs/%d', year))))
  local url = string.format('https://adventofcode.com/%d/day/%d/input', year, day)
  local cmd =
    string.format('curl -fsSL --config %s -o %s %s', shell_quote(curl_config), shell_quote(path), shell_quote(url))

  local ok, _, code = os.execute(cmd)
  os.remove(curl_config)
  return command_succeeded(ok, code)
end

local function readLines(path)
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

  local env = setmetatable({ readLines = readLines }, { __index = _G })
  local chunk = assert(loadfile(solver_path, 't', env))
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

  local had_readLines = rawget(_G, 'readLines') ~= nil
  local previous_readLines = rawget(_G, 'readLines')
  _G.readLines = readLines

  local results = { pcall(solver, input_path) }

  if had_readLines then
    _G.readLines = previous_readLines
  else
    _G.readLines = nil
  end

  if not results[1] then
    error(results[2], 0)
  end

  table.remove(results, 1)
  return unpack(results)
end

return M
