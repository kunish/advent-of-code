-- dirs: 1=right, 2=down, 3=left, 4=up
local DR = { [1] = 0, [2] = 1, [3] = 0, [4] = -1 }
local DC = { [1] = 1, [2] = 0, [3] = -1, [4] = 0 }

local function solve(grid, sr, sc, sdir)
  local R = #grid
  local C = #grid[1]
  local visited = {}
  local function vkey(r, c, d)
    return r .. ',' .. c .. ',' .. d
  end
  local energized = {}
  local q = {}
  local qh = 1
  local qt = 1
  q[1] = { sr, sc, sdir }
  qt = 2

  while qh < qt do
    local cur = q[qh]
    qh = qh + 1
    local r, c, d = cur[1], cur[2], cur[3]
    if r < 1 or r > R or c < 1 or c > C then
      -- skip
    else
      local vk = vkey(r, c, d)
      if not visited[vk] then
        visited[vk] = true
        energized[r .. ',' .. c] = true
        local ch = grid[r]:sub(c, c)
        if ch == '.' then
          q[qt] = { r + DR[d], c + DC[d], d }
          qt = qt + 1
        elseif ch == '|' then
          if d == 2 or d == 4 then
            q[qt] = { r + DR[d], c + DC[d], d }
            qt = qt + 1
          else
            q[qt] = { r - 1, c, 4 }
            qt = qt + 1
            q[qt] = { r + 1, c, 2 }
            qt = qt + 1
          end
        elseif ch == '-' then
          if d == 1 or d == 3 then
            q[qt] = { r + DR[d], c + DC[d], d }
            qt = qt + 1
          else
            q[qt] = { r, c - 1, 3 }
            qt = qt + 1
            q[qt] = { r, c + 1, 1 }
            qt = qt + 1
          end
        elseif ch == '/' then
          local nd
          if d == 1 then
            nd = 4
          elseif d == 2 then
            nd = 3
          elseif d == 3 then
            nd = 2
          else
            nd = 1
          end
          q[qt] = { r + DR[nd], c + DC[nd], nd }
          qt = qt + 1
        elseif ch == '\\' then
          local nd
          if d == 1 then
            nd = 2
          elseif d == 2 then
            nd = 1
          elseif d == 3 then
            nd = 4
          else
            nd = 3
          end
          q[qt] = { r + DR[nd], c + DC[nd], nd }
          qt = qt + 1
        end
      end
    end
  end

  local cnt = 0
  for _ in pairs(energized) do
    cnt = cnt + 1
  end
  return cnt
end

return function(path)
  local lines = readLines(path)
  local grid = lines
  local R = #grid
  local C = #grid[1]

  local p1 = solve(grid, 1, 1, 1)

  local p2 = 0
  local r = 1
  while r <= R do
    local a = solve(grid, r, 1, 1)
    local b = solve(grid, r, C, 3)
    if a > p2 then
      p2 = a
    end
    if b > p2 then
      p2 = b
    end
    r = r + 1
  end
  local c = 1
  while c <= C do
    local a = solve(grid, 1, c, 4)
    local b = solve(grid, R, c, 2)
    if a > p2 then
      p2 = a
    end
    if b > p2 then
      p2 = b
    end
    c = c + 1
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
