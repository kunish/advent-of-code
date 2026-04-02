local function is_symbol(c)
  if c == '.' or c == nil then
    return false
  end
  if c >= '0' and c <= '9' then
    return false
  end
  return true
end

local function day3(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = #lines[1]
  local grid = {}
  for r = 1, rows do
    grid[r] = {}
    for c = 1, cols do
      grid[r][c] = lines[r]:sub(c, c)
    end
  end

  local nums = {}
  for r = 1, rows do
    local c = 1
    while c <= cols do
      local ch = grid[r][c]
      if ch >= '0' and ch <= '9' then
        local start_c = c
        local val = 0
        while c <= cols and grid[r][c] >= '0' and grid[r][c] <= '9' do
          val = val * 10 + (grid[r][c]:byte() - 48)
          c = c + 1
        end
        nums[#nums + 1] = { r = r, c1 = start_c, c2 = c - 1, v = val }
      else
        c = c + 1
      end
    end
  end

  local part1 = 0
  local sym_adj = {}
  for _, n in ipairs(nums) do
    local ok = false
    local seen_star = {}
    for r = n.r - 1, n.r + 1 do
      for cc = n.c1 - 1, n.c2 + 1 do
        if r >= 1 and r <= rows and cc >= 1 and cc <= cols then
          if is_symbol(grid[r][cc]) then
            ok = true
            local skey = r * 65536 + cc
            if not seen_star[skey] then
              seen_star[skey] = true
              if not sym_adj[skey] then
                sym_adj[skey] = {}
              end
              sym_adj[skey][#sym_adj[skey] + 1] = n.v
            end
          end
        end
      end
    end
    if ok then
      part1 = part1 + n.v
    end
  end

  local part2 = 0
  for key, list in pairs(sym_adj) do
    local r = math.floor(key / 65536)
    local cc = key % 65536
    if grid[r][cc] == '*' and #list == 2 then
      part2 = part2 + list[1] * list[2]
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day3(p)
end
