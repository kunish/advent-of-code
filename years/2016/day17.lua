local md5 = dofile('years/2015/md5.lua')

local function open_doors(passcode, path)
  local h = md5.sumhexa(passcode .. path)
  local u = string.byte(h, 1) >= string.byte('b')
  local d = string.byte(h, 2) >= string.byte('b')
  local l = string.byte(h, 3) >= string.byte('b')
  local r = string.byte(h, 4) >= string.byte('b')
  return u, d, l, r
end

return function(path)
  local lines = readLines(path)
  local passcode = lines[1]:gsub('%s+', '')

  local dirs = {
    { 0, -1, 'U' },
    { 0, 1, 'D' },
    { -1, 0, 'L' },
    { 1, 0, 'R' },
  }

  local head, tail = 1, 1
  local qx, qy, qs = { 0 }, { 0 }, { '' }
  local seen = { [''] = true }
  local shortest

  while head <= tail do
    local x, y, s = qx[head], qy[head], qs[head]
    head = head + 1
    if x == 3 and y == 3 then
      shortest = s
      break
    end
    local u, d, l, r = open_doors(passcode, s)
    for i = 1, 4 do
      local dx, dy, ch = dirs[i][1], dirs[i][2], dirs[i][3]
      local ok = (i == 1 and u) or (i == 2 and d) or (i == 3 and l) or (i == 4 and r)
      if ok then
        local nx, ny = x + dx, y + dy
        if nx >= 0 and nx <= 3 and ny >= 0 and ny <= 3 then
          local ns = s .. ch
          if not seen[ns] then
            seen[ns] = true
            tail = tail + 1
            qx[tail], qy[tail], qs[tail] = nx, ny, ns
          end
        end
      end
    end
  end

  local best = 0
  local function dfs(x, y, s)
    if x == 3 and y == 3 then
      if #s > best then
        best = #s
      end
      return
    end
    local u, d, l, r = open_doors(passcode, s)
    for i = 1, 4 do
      local dx, dy, ch = dirs[i][1], dirs[i][2], dirs[i][3]
      local ok = (i == 1 and u) or (i == 2 and d) or (i == 3 and l) or (i == 4 and r)
      if ok then
        local nx, ny = x + dx, y + dy
        if nx >= 0 and nx <= 3 and ny >= 0 and ny <= 3 then
          dfs(nx, ny, s .. ch)
        end
      end
    end
  end
  dfs(0, 0, '')

  print('Part 1: ' .. tostring(shortest))
  print('Part 2: ' .. tostring(best))
end
