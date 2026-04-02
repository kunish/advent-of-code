local md5
if jit then
  md5 = dofile('md5_ffi.lua')
else
  md5 = dofile('years/2015/md5.lua')
end

local function day5(path)
  io.stdout:setvbuf('no')
  local lines = readLines(path)
  local doorid = (lines[1] or ''):match('^%s*(.-)%s*$') or ''

  local part1 = {}
  local slots = {}
  local i = 0
  while true do
    if #part1 >= 8 then
      local done = true
      for j = 0, 7 do
        if not slots[j] then
          done = false
          break
        end
      end
      if done then
        break
      end
    end
    local h = md5.sumhexa(doorid .. tostring(i))
    if h:sub(1, 5) == '00000' then
      if #part1 < 8 then
        part1[#part1 + 1] = h:sub(6, 6)
      end
      local pos = tonumber(h:sub(6, 6), 16)
      local ch = h:sub(7, 7)
      if pos ~= nil and pos >= 0 and pos <= 7 and slots[pos] == nil then
        slots[pos] = ch
      end
    end
    i = i + 1
  end

  local part2 = {}
  for j = 0, 7 do
    part2[j + 1] = slots[j] or '?'
  end

  print(string.format('Part 1: %s', table.concat(part1)))
  print(string.format('Part 2: %s', table.concat(part2)))
end

return function(path)
  return day5(path)
end
