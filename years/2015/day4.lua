-- Brute-forces MD5(prefix..n). Subprocess `md5` per candidate is too slow for
-- millions of iterations; use pure Lua (years/2015/md5.lua).
local md5 = dofile('years/2015/md5.lua')

local function day4(path)
  local lines = readLines(path)
  local key = (lines[1] or ''):match('^%s*(.-)%s*$') or ''

  local function find_with_prefix(prefix)
    local n = 1
    while true do
      local h = md5.sumhexa(key .. tostring(n))
      if h:sub(1, #prefix) == prefix then
        return n
      end
      n = n + 1
    end
  end

  print(string.format('Part 1: %d', find_with_prefix('00000')))
  print(string.format('Part 2: %d', find_with_prefix('000000')))
end

return function(path)
  return day4(path)
end
