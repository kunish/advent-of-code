return function(path)
  local lines = readLines(path)
  local grid_start = 1
  local moves = {}
  local blank = nil
  for i = 1, #lines do
    if lines[i] == '' then
      blank = i
      break
    end
  end
  assert(blank, 'expected blank line')

  local grid_lines = {}
  for i = 1, blank - 1 do
    grid_lines[#grid_lines + 1] = lines[i]
  end
  for i = blank + 1, #lines do
    for j = 1, #lines[i] do
      moves[#moves + 1] = lines[i]:sub(j, j)
    end
  end

  local function gps_sum(boxes)
    local s = 0
    for k, _ in pairs(boxes) do
      local r, c = k:match('^(%d+),(%d+)$')
      s = s + 100 * (tonumber(r) - 1) + (tonumber(c) - 1)
    end
    return s
  end

  -- Part 1
  do
    local rows = #grid_lines
    local cols = #grid_lines[1]
    local robot_r, robot_c
    local boxes = {}
    local walls = {}
    for r = 1, rows do
      local line = grid_lines[r]
      for c = 1, cols do
        local ch = line:sub(c, c)
        local key = r .. ',' .. c
        if ch == '#' then
          walls[key] = true
        elseif ch == 'O' then
          boxes[key] = true
        elseif ch == '@' then
          robot_r, robot_c = r, c
        end
      end
    end

    local dr = { ['^'] = -1, v = 1, ['<'] = 0, ['>'] = 0 }
    local dc = { ['^'] = 0, v = 0, ['<'] = -1, ['>'] = 1 }

    for mi = 1, #moves do
      local m = moves[mi]
      local rr = robot_r + dr[m]
      local cc = robot_c + dc[m]
      local nk = rr .. ',' .. cc
      if walls[nk] then
        -- blocked
      elseif not boxes[nk] then
        robot_r, robot_c = rr, cc
      else
        local er, ec = rr, cc
        while boxes[er .. ',' .. ec] do
          er = er + dr[m]
          ec = ec + dc[m]
        end
        if walls[er .. ',' .. ec] then
          -- entire chain blocked
        else
          boxes[rr .. ',' .. cc] = nil
          boxes[er .. ',' .. ec] = true
          robot_r, robot_c = rr, cc
        end
      end
    end

    print(string.format('Part 1: %d', gps_sum(boxes)))
  end

  -- Part 2: wide grid
  do
    local rows = #grid_lines
    local cols = #grid_lines[1]
    local robot_r, robot_c
    local boxes = {} -- left cell of each box "r,c"
    local walls = {}
    for r = 1, rows do
      local line = grid_lines[r]
      for c = 1, cols do
        local ch = line:sub(c, c)
        if ch == '#' then
          walls[r .. ',' .. (2 * c - 1)] = true
          walls[r .. ',' .. (2 * c)] = true
        elseif ch == 'O' then
          boxes[r .. ',' .. (2 * c - 1)] = true
        elseif ch == '@' then
          robot_r, robot_c = r, 2 * c - 1
        end
      end
    end

    local function box_at(r, c)
      return boxes[r .. ',' .. c] or boxes[r .. ',' .. (c - 1)]
    end
    local function wall_at(r, c)
      return walls[r .. ',' .. c]
    end

    local dr = { ['^'] = -1, v = 1, ['<'] = 0, ['>'] = 0 }
    local dc = { ['^'] = 0, v = 0, ['<'] = -1, ['>'] = 1 }

    for mi = 1, #moves do
      local m = moves[mi]
      local rr = robot_r + dr[m]
      local cc = robot_c + dc[m]
      if wall_at(rr, cc) then
        -- blocked
      elseif not box_at(rr, cc) then
        robot_r, robot_c = rr, cc
      else
        local lr, lc
        if boxes[rr .. ',' .. cc] then
          lr, lc = rr, cc
        else
          lr, lc = rr, cc - 1
        end
        local to_push = { { lr, lc } }
        local seen = { [lr .. ',' .. lc] = true }
        local qi = 1
        local blocked = false
        while qi <= #to_push and not blocked do
          local br, bc = to_push[qi][1], to_push[qi][2]
          qi = qi + 1
          local nr = br + dr[m]
          local nc = bc + dc[m]
          if wall_at(nr, nc) or wall_at(nr, nc + 1) then
            blocked = true
          else
            for _, check_c in ipairs({ nc, nc + 1 }) do
              if box_at(nr, check_c) then
                local bl_r, bl_c
                if boxes[nr .. ',' .. check_c] then
                  bl_r, bl_c = nr, check_c
                else
                  bl_r, bl_c = nr, check_c - 1
                end
                local k = bl_r .. ',' .. bl_c
                if not seen[k] then
                  seen[k] = true
                  to_push[#to_push + 1] = { bl_r, bl_c }
                end
              end
            end
          end
        end
        if not blocked then
          for j = #to_push, 1, -1 do
            local br, bc = to_push[j][1], to_push[j][2]
            boxes[br .. ',' .. bc] = nil
            boxes[(br + dr[m]) .. ',' .. (bc + dc[m])] = true
          end
          robot_r, robot_c = rr, cc
        end
      end
    end

    local s2 = 0
    for k, _ in pairs(boxes) do
      local r, c = k:match('^(%d+),(%d+)$')
      s2 = s2 + 100 * (tonumber(r) - 1) + (tonumber(c) - 1)
    end
    print(string.format('Part 2: %d', s2))
  end
end
