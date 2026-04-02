local function parse_boss(lines)
  local hp, dmg, armor = 0, 0, 0
  for _, line in ipairs(lines) do
    local n = tonumber(line:match('%d+'))
    if line:find('Hit Points') then
      hp = n
    elseif line:find('Damage') then
      dmg = n
    elseif line:find('Armor') then
      armor = n
    end
  end
  return hp, dmg, armor
end

local weapons = {
  { cost = 8, dmg = 4, arm = 0 },
  { cost = 10, dmg = 5, arm = 0 },
  { cost = 25, dmg = 6, arm = 0 },
  { cost = 40, dmg = 7, arm = 0 },
  { cost = 74, dmg = 8, arm = 0 },
}

local armors = {
  { cost = 0, dmg = 0, arm = 0 },
  { cost = 13, dmg = 0, arm = 1 },
  { cost = 31, dmg = 0, arm = 2 },
  { cost = 53, dmg = 0, arm = 3 },
  { cost = 75, dmg = 0, arm = 4 },
  { cost = 102, dmg = 0, arm = 5 },
}

local rings = {
  { cost = 25, dmg = 1, arm = 0 },
  { cost = 50, dmg = 2, arm = 0 },
  { cost = 100, dmg = 3, arm = 0 },
  { cost = 20, dmg = 0, arm = 1 },
  { cost = 40, dmg = 0, arm = 2 },
  { cost = 80, dmg = 0, arm = 3 },
}

local function player_wins(player_hp, player_dmg, player_arm, boss_hp, boss_dmg, boss_arm)
  local php, bhp = player_hp, boss_hp
  while true do
    bhp = bhp - math.max(1, player_dmg - boss_arm)
    if bhp <= 0 then
      return true
    end
    php = php - math.max(1, boss_dmg - player_arm)
    if php <= 0 then
      return false
    end
  end
end

local function day21(path)
  local lines = readLines(path)
  local boss_hp, boss_dmg, boss_arm = parse_boss(lines)

  local min_win = math.huge
  local max_lose = -1

  local function consider(cost, pdmg, parm)
    if player_wins(100, pdmg, parm, boss_hp, boss_dmg, boss_arm) then
      if cost < min_win then
        min_win = cost
      end
    else
      if cost > max_lose then
        max_lose = cost
      end
    end
  end

  for _, w in ipairs(weapons) do
    for _, a in ipairs(armors) do
      local base_cost = w.cost + a.cost
      local base_dmg = w.dmg + a.dmg
      local base_arm = w.arm + a.arm

      consider(base_cost, base_dmg, base_arm)

      for i = 1, #rings do
        local ri = rings[i]
        consider(base_cost + ri.cost, base_dmg + ri.dmg, base_arm + ri.arm)
        for j = i + 1, #rings do
          local rj = rings[j]
          consider(base_cost + ri.cost + rj.cost, base_dmg + ri.dmg + rj.dmg, base_arm + ri.arm + rj.arm)
        end
      end
    end
  end

  print(string.format('Part 1: %d', min_win))
  print(string.format('Part 2: %d', max_lose))
end

return function(path)
  return day21(path)
end
