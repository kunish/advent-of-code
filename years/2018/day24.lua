local function parse_mods(s)
  local weak, immune = {}, {}
  if not s or s == '' then
    return weak, immune
  end
  for ch in s:gmatch('([^;]+)') do
    local chunk = ch:match('^%s*(.-)%s*$')
    local wlist = chunk:match('weak to (.+)')
    if wlist then
      for tw in wlist:gmatch('([^,]+)') do
        local t = tw:match('^%s*(.-)%s*$')
        if t and t ~= '' then
          weak[t] = true
        end
      end
    end
    local ilist = chunk:match('immune to (.+)')
    if ilist then
      for ti in ilist:gmatch('([^,]+)') do
        local t = ti:match('^%s*(.-)%s*$')
        if t and t ~= '' then
          immune[t] = true
        end
      end
    end
  end
  return weak, immune
end

local function parse_line(line, army)
  local units, hp, mods, atk, atype, ini =
    line:match('^(%d+) units each with (%d+) hit points %((.+)%) with an attack that does (%d+) (%a+) damage at initiative (%d+)')
  if not units then
    units, hp, atk, atype, ini = line:match('^(%d+) units each with (%d+) hit points with an attack that does (%d+) (%a+) damage at initiative (%d+)')
    mods = ''
  end
  if not units then
    return nil
  end
  local weak, immune = parse_mods(mods)
  return {
    army = army,
    units = tonumber(units),
    hp = tonumber(hp),
    atk = tonumber(atk),
    atype = atype,
    ini = tonumber(ini),
    weak = weak,
    immune = immune,
  }
end

local function effective_power(g)
  return g.units * g.atk
end

local function damage_to(attacker, defender)
  if defender.immune[attacker.atype] then
    return 0
  end
  local m = 1
  if defender.weak[attacker.atype] then
    m = 2
  end
  return effective_power(attacker) * m
end

local function clone_groups(groups, boost)
  local out = {}
  for i = 1, #groups do
    local g = groups[i]
    local atk = g.atk
    if g.army == 'immune' then
      atk = atk + boost
    end
    out[i] = {
      army = g.army,
      units = g.units,
      hp = g.hp,
      atk = atk,
      atype = g.atype,
      ini = g.ini,
      weak = g.weak,
      immune = g.immune,
    }
  end
  return out
end

local function fight(groups)
  while true do
    local alive = {}
    for i = 1, #groups do
      if groups[i].units > 0 then
        alive[#alive + 1] = groups[i]
      end
    end
    local has_i, has_n = false, false
    for i = 1, #alive do
      if alive[i].army == 'immune' then
        has_i = true
      else
        has_n = true
      end
    end
    if not has_i or not has_n then
      break
    end

    table.sort(alive, function(a, b)
      local pa, pb = effective_power(a), effective_power(b)
      if pa ~= pb then
        return pa > pb
      end
      return a.ini > b.ini
    end)

    local used = {}
    local targets = {}
    for ai = 1, #alive do
      local att = alive[ai]
      local best = nil
      local best_dmg = 0
      for di = 1, #alive do
        local def = alive[di]
        if def.army ~= att.army and not used[def] then
          local dmg = damage_to(att, def)
          if dmg > 0 then
            if best == nil or dmg > best_dmg then
              best_dmg = dmg
              best = def
            elseif dmg == best_dmg then
              if effective_power(def) > effective_power(best) then
                best = def
              elseif effective_power(def) == effective_power(best) and def.ini > best.ini then
                best = def
              end
            end
          end
        end
      end
      if best and best_dmg > 0 then
        targets[att] = best
        used[best] = true
      end
    end

    table.sort(alive, function(a, b)
      return a.ini > b.ini
    end)

    local dealt = false
    for ai = 1, #alive do
      local att = alive[ai]
      local def = targets[att]
      if def and att.units > 0 and def.units > 0 then
        local dmg = damage_to(att, def)
        local kills = dmg // def.hp
        if kills > def.units then
          kills = def.units
        end
        if kills > 0 then
          dealt = true
        end
        def.units = def.units - kills
      end
    end

    if not dealt then
      return nil
    end
  end

  local sum = 0
  for i = 1, #groups do
    if groups[i].units > 0 then
      sum = sum + groups[i].units
    end
  end
  return sum
end

local function parse_input(lines)
  local groups = {}
  local army = nil
  for i = 1, #lines do
    local ln = lines[i]
    if ln:match('^Immune System:') then
      army = 'immune'
    elseif ln:match('^Infection:') then
      army = 'infection'
    elseif army and ln ~= '' then
      local g = parse_line(ln, army)
      if g then
        groups[#groups + 1] = g
      end
    end
  end
  return groups
end

local function day24(path)
  local lines = readLines(path)
  local base = parse_input(lines)

  local part1 = fight(clone_groups(base, 0))
  if part1 == nil then
    part1 = 0
  end

  local lo, hi = 0, 100000
  local part2 = nil
  while lo <= hi do
    local mid = (lo + hi) // 2
    local g = clone_groups(base, mid)
    local alive = fight(g)
    local immune_win = true
    for i = 1, #g do
      if g[i].army == 'infection' and g[i].units > 0 then
        immune_win = false
        break
      end
    end
    if alive and immune_win then
      part2 = alive
      hi = mid - 1
    else
      lo = mid + 1
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day24(path)
end
