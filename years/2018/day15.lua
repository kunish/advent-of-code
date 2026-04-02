local function parse_grid(lines)
  local rows = {}
  local h = #lines
  local w = 0
  for r = 1, h do
    w = math.max(w, #lines[r])
  end
  for r = 1, h do
    local row = {}
    local ln = lines[r]
    for c = 1, w do
      row[c] = ln:sub(c, c)
    end
    rows[r] = row
  end
  return rows, h, w
end

local function sort_units_reading(units)
  table.sort(units, function(a, b)
    if a.r ~= b.r then
      return a.r < b.r
    end
    return a.c < b.c
  end)
end

local function occupied_by_other(units, r, c, self_id)
  for i = 1, #units do
    local u = units[i]
    if u.hp > 0 and u.id ~= self_id and u.r == r and u.c == c then
      return true
    end
  end
  return false
end

local READ_DIRS = { { -1, 0 }, { 0, -1 }, { 0, 1 }, { 1, 0 } }

local function bfs_dist_from(grid, h, w, units, self_id, sr, sc)
  local dist = {}
  local q = {}
  local qh, qt = 1, 0
  local function push(r, c, d)
    local key = r * 65536 + c
    if dist[key] then
      return
    end
    dist[key] = d
    qt = qt + 1
    q[qt] = { r = r, c = c }
  end
  push(sr, sc, 0)
  while qh <= qt do
    local cur = q[qh]
    qh = qh + 1
    local ck = cur.r * 65536 + cur.c
    local d0 = dist[ck]
    for d = 1, 4 do
      local nr = cur.r + READ_DIRS[d][1]
      local nc = cur.c + READ_DIRS[d][2]
      if nr >= 1 and nr <= h and nc >= 1 and nc <= w then
        if grid[nr][nc] ~= '#' and not occupied_by_other(units, nr, nc, self_id) then
          push(nr, nc, d0 + 1)
        end
      end
    end
  end
  return dist
end

local function bfs_dist_to(grid, h, w, units, self_id, sr, sc, tr, tc)
  local dist = {}
  local q = {}
  local qh, qt = 1, 0
  local function push(r, c, d)
    local key = r * 65536 + c
    if dist[key] then
      return
    end
    dist[key] = d
    qt = qt + 1
    q[qt] = { r = r, c = c }
  end
  push(sr, sc, 0)
  while qh <= qt do
    local cur = q[qh]
    qh = qh + 1
    if cur.r == tr and cur.c == tc then
      return dist[cur.r * 65536 + cur.c]
    end
    local ck = cur.r * 65536 + cur.c
    local d0 = dist[ck]
    for d = 1, 4 do
      local nr = cur.r + READ_DIRS[d][1]
      local nc = cur.c + READ_DIRS[d][2]
      if nr >= 1 and nr <= h and nc >= 1 and nc <= w then
        if grid[nr][nc] ~= '#' and not occupied_by_other(units, nr, nc, self_id) then
          push(nr, nc, d0 + 1)
        end
      end
    end
  end
  return nil
end

local function simulate(lines, elf_power)
  local grid, h, w = parse_grid(lines)
  local next_id = 1
  local units = {}
  local start_elves = 0
  for r = 1, h do
    for c = 1, w do
      local ch = grid[r][c]
      if ch == 'E' or ch == 'G' then
        if ch == 'E' then
          start_elves = start_elves + 1
        end
        units[#units + 1] = {
          kind = ch,
          r = r,
          c = c,
          hp = 200,
          id = next_id,
          ap = (ch == 'E') and elf_power or 3,
        }
        next_id = next_id + 1
      end
    end
  end

  local rounds = 0
  while true do
    sort_units_reading(units)
    local saw_turn = false
    for ti = 1, #units do
      local u = units[ti]
      if u.hp <= 0 then
        goto continue
      end

      local enemies = {}
      for j = 1, #units do
        local v = units[j]
        if v.hp > 0 and v.kind ~= u.kind then
          enemies[#enemies + 1] = v
        end
      end
      if #enemies == 0 then
        local hp_sum = 0
        for j = 1, #units do
          if units[j].hp > 0 then
            hp_sum = hp_sum + units[j].hp
          end
        end
        local elf_survive = 0
        for j = 1, #units do
          if units[j].hp > 0 and units[j].kind == 'E' then
            elf_survive = elf_survive + 1
          end
        end
        return rounds, hp_sum, elf_survive == start_elves
      end

      local adjacent = false
      for j = 1, #enemies do
        local v = enemies[j]
        if math.abs(u.r - v.r) + math.abs(u.c - v.c) == 1 then
          adjacent = true
          break
        end
      end

      if not adjacent then
        local attack_cells = {}
        local seen = {}
        for j = 1, #enemies do
          local v = enemies[j]
          for d = 1, 4 do
            local ar = v.r + READ_DIRS[d][1]
            local ac = v.c + READ_DIRS[d][2]
            if ar >= 1 and ar <= h and ac >= 1 and ac <= w then
              if grid[ar][ac] ~= '#' and not occupied_by_other(units, ar, ac, u.id) then
                local key = ar * 65536 + ac
                if not seen[key] then
                  seen[key] = true
                  attack_cells[#attack_cells + 1] = { r = ar, c = ac }
                end
              end
            end
          end
        end

        if #attack_cells > 0 then
          local dist_u = bfs_dist_from(grid, h, w, units, u.id, u.r, u.c)
          local best_target = nil
          local best_td = math.huge
          for ai = 1, #attack_cells do
            local ac = attack_cells[ai]
            local key = ac.r * 65536 + ac.c
            local d = dist_u[key]
            if d then
              if not best_target or d < best_td or (d == best_td and (ac.r < best_target.r or (ac.r == best_target.r and ac.c < best_target.c))) then
                best_td = d
                best_target = ac
              end
            end
          end
          if best_target then
            local tr, tc = best_target.r, best_target.c
            local step_cell = nil
            for nd = 1, 4 do
              local nr = u.r + READ_DIRS[nd][1]
              local nc = u.c + READ_DIRS[nd][2]
              if nr >= 1 and nr <= h and nc >= 1 and nc <= w then
                if grid[nr][nc] ~= '#' and not occupied_by_other(units, nr, nc, u.id) then
                  local d2 = bfs_dist_to(grid, h, w, units, u.id, nr, nc, tr, tc)
                  if d2 ~= nil and d2 == best_td - 1 then
                    step_cell = { r = nr, c = nc }
                    break
                  end
                end
              end
            end
            if step_cell then
              u.r, u.c = step_cell.r, step_cell.c
            end
          end
        end
      end

      local target = nil
      for j = 1, #units do
        local v = units[j]
        if v.hp > 0 and v.kind ~= u.kind then
          if math.abs(u.r - v.r) + math.abs(u.c - v.c) == 1 then
            if not target or v.hp < target.hp then
              target = v
            elseif v.hp == target.hp then
              if v.r < target.r or (v.r == target.r and v.c < target.c) then
                target = v
              end
            end
          end
        end
      end
      if target then
        target.hp = target.hp - u.ap
      end

      ::continue::
    end

    local i = 1
    while i <= #units do
      if units[i].hp <= 0 then
        table.remove(units, i)
      else
        i = i + 1
      end
    end

    rounds = rounds + 1
  end
end

local function day15(path)
  local lines = readLines(path)
  local r1, hp1 = simulate(lines, 3)
  local part1 = r1 * hp1

  local lo, hi = 4, 200
  local best_score = nil
  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    local rr, hp, elves_ok = simulate(lines, mid)
    if elves_ok then
      best_score = rr * hp
      hi = mid - 1
    else
      lo = mid + 1
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', best_score))
end

return function(path)
  return day15(path)
end
