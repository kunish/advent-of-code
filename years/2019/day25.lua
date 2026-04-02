local intcode = dofile('years/2019/intcode.lua')

local BAD = {
  ['giant electromagnet'] = true,
  ['molten lava'] = true,
  ['infinite loop'] = true,
  ['escape pod'] = true,
  ['photons'] = true,
}

local DIRS = { 'north', 'south', 'east', 'west' }
local OPP = { north = 'south', south = 'north', east = 'west', west = 'east' }

local function drain(vm)
  local t = {}
  while vm:has_output() do
    local v = vm:pop_output()
    if v < 256 then
      t[#t + 1] = string.char(v)
    end
  end
  return table.concat(t)
end

local function run_in(vm)
  repeat
    vm:run()
  until vm.halted or (vm.waiting_for_input and #vm.input_queue == 0)
end

local function send(vm, s)
  local q = vm.input_queue
  for i = 1, #s do
    q[#q + 1] = s:byte(i, i)
  end
  run_in(vm)
end

local function room_title(buf)
  return buf:match('== ([^=]+) ==')
end

local function parse_items(buf)
  local items = {}
  local on = false
  for line in buf:gmatch('[^\r\n]+') do
    if line:find('Items here:') then
      on = true
    elseif on then
      if not line:find('^%-') then
        break
      end
      local it = line:match('^%- (.+)$')
      if it then
        items[#items + 1] = it
      end
    end
  end
  return items
end

local function move(vm, dir)
  send(vm, dir .. '\n')
  local last_big = nil
  for j = 1, #vm.output_queue do
    local v = vm.output_queue[j]
    if v > 127 then
      last_big = v
    end
  end
  local ascii = drain(vm)
  return ascii, last_big
end

local et = {}

--- `buf` is current room text; omit on first call (read from vm).
--- Returns the room description buffer after returning to this level (so caller knows current room).
local function dfs_collect(vm, inv, buf)
  if not buf then
    run_in(vm)
    buf = drain(vm)
  end
  local title = room_title(buf) or '?'
  if not et[title] then
    et[title] = {}
  end
  for _, it in ipairs(parse_items(buf)) do
    if not BAD[it] then
      send(vm, 'take ' .. it .. '\n')
      drain(vm)
      inv[#inv + 1] = it
    end
  end
  for _, d in ipairs(DIRS) do
    if not et[title][d] then
      et[title][d] = true
      local out = move(vm, d)
      if not out:find("You can't") and not out:find('ejected') then
        buf = dfs_collect(vm, inv, out)
        local back_out = move(vm, OPP[d])
        buf = back_out
      end
    end
  end
  return buf
end

local cp_path = {}
local ct = {}
local checkpoint_buf = nil

local function doors_from(buf)
  local d = {}
  local on = false
  for line in buf:gmatch('[^\r\n]+') do
    if line:find('Doors here lead:') then
      on = true
    elseif on then
      if not line:find('^%-') then
        break
      end
      local dir = line:match('^%-%s*(%a+)%s*$')
      if dir then
        d[#d + 1] = dir
      end
    end
  end
  return d
end

local function dfs_checkpoint(vm, buf)
  if not buf then
    run_in(vm)
    buf = drain(vm)
  end
  if buf:find('Security Checkpoint') then
    checkpoint_buf = buf
    return true
  end
  local title = room_title(buf) or '?'
  if not ct[title] then
    ct[title] = {}
  end
  for _, d in ipairs(DIRS) do
    if not ct[title][d] then
      ct[title][d] = true
      local out = move(vm, d)
      if not out:find("You can't") then
        cp_path[#cp_path + 1] = d
        if dfs_checkpoint(vm, out) then
          return true
        end
        cp_path[#cp_path] = nil
        move(vm, OPP[d])
      end
    end
  end
  return false
end

local function brute_force(vm, items, entry_dir, cp_buf)
  local n = math.min(#items, 10)
  if n < #items then
    local t = {}
    for i = 1, n do
      t[i] = items[i]
    end
    items = t
  end
  local back = OPP[entry_dir]
  local try_dirs = {}
  local avail = doors_from(cp_buf or '')
  if #avail == 0 then
    for i = 1, #DIRS do
      local d = DIRS[i]
      if d ~= back then
        try_dirs[#try_dirs + 1] = d
      end
    end
  else
    for i = 1, #avail do
      local d = avail[i]
      if d ~= back then
        try_dirs[#try_dirs + 1] = d
      end
    end
  end
  local last_buf = cp_buf or ''
  for mask = 0, (1 << n) - 1 do
    -- After ejection, items sit on the floor; next mask must take them before drop/take again.
    for _, it in ipairs(parse_items(last_buf)) do
      send(vm, 'take ' .. it .. '\n')
      drain(vm)
    end
    for i = 1, n do
      send(vm, 'drop ' .. items[i] .. '\n')
      drain(vm)
    end
    for i = 1, n do
      if ((mask >> (i - 1)) & 1) == 1 then
        send(vm, 'take ' .. items[i] .. '\n')
        drain(vm)
      end
    end
    for ti = 1, #try_dirs do
      local out, big = move(vm, try_dirs[ti])
      last_buf = out
      if big then
        return big
      end
      -- Title may use a Unicode hyphen; match success text instead of "Pressure-Sensitive".
      if out:find('Analysis complete') and not out:find('Alert!') then
        local best = 0
        for m in out:gmatch('(%d+)') do
          local x = tonumber(m)
          if x and x > best then
            best = x
          end
        end
        if best > 100000 then
          return best
        end
      end
      if out:find('Hot Chocolate') or (room_title(out) and not out:find('Security Checkpoint') and not out:find('Pressure-Sensitive')) then
        send(vm, OPP[try_dirs[ti]] .. '\n')
        drain(vm)
      end
    end
  end
  return nil
end

local function day25(path)
  local lines = readLines(path)
  local mem = intcode.parse(lines[1] or '')

  local inv = {}
  et = {}
  local vm = intcode.new(intcode.copy(mem))
  local at_buf = dfs_collect(vm, inv, nil)

  cp_path = {}
  ct = {}
  local answer = 0
  if dfs_checkpoint(vm, at_buf) then
    local entry = #cp_path > 0 and cp_path[#cp_path] or 'south'
    answer = brute_force(vm, inv, entry, checkpoint_buf) or 0
  end

  print(string.format('Part 1: %d', answer))
  print('Part 2: (none)')
end

return function(p)
  return day25(p)
end
