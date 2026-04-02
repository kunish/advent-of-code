local function parse_boss(lines)
  local hp, dmg = 0, 0
  for _, line in ipairs(lines) do
    local n = tonumber(line:match('%d+'))
    if line:find('Hit Points') then
      hp = n
    elseif line:find('Damage') then
      dmg = n
    end
  end
  return hp, dmg
end

local function tick_effects(hp, mana, bhp, shield, poison, recharge)
  local armor = 0
  if poison > 0 then
    bhp = bhp - 3
    poison = poison - 1
  end
  if recharge > 0 then
    mana = mana + 101
    recharge = recharge - 1
  end
  if shield > 0 then
    armor = 7
    shield = shield - 1
  end
  return hp, mana, bhp, shield, poison, recharge, armor
end

local function min_mana(boss_hp, boss_dmg, hard)
  local best = math.huge

  local function dfs(hp, mana, bhp, shield, poison, recharge, spent, player_turn)
    if spent >= best then
      return
    end
    if bhp <= 0 then
      if spent < best then
        best = spent
      end
      return
    end

    if player_turn then
      if hard then
        hp = hp - 1
        if hp <= 0 then
          return
        end
      end
    end

    local armor
    hp, mana, bhp, shield, poison, recharge, armor = tick_effects(hp, mana, bhp, shield, poison, recharge)
    if bhp <= 0 then
      if spent < best then
        best = spent
      end
      return
    end

    if player_turn then
      if mana >= 53 then
        dfs(hp, mana - 53, bhp - 4, shield, poison, recharge, spent + 53, false)
      end
      if mana >= 73 then
        dfs(hp + 2, mana - 73, bhp - 2, shield, poison, recharge, spent + 73, false)
      end
      if mana >= 113 and shield == 0 then
        dfs(hp, mana - 113, bhp, 6, poison, recharge, spent + 113, false)
      end
      if mana >= 173 and poison == 0 then
        dfs(hp, mana - 173, bhp, shield, 6, recharge, spent + 173, false)
      end
      if mana >= 229 and recharge == 0 then
        dfs(hp, mana - 229, bhp, shield, poison, 5, spent + 229, false)
      end
    else
      local dmg = math.max(1, boss_dmg - armor)
      hp = hp - dmg
      if hp <= 0 then
        return
      end
      dfs(hp, mana, bhp, shield, poison, recharge, spent, true)
    end
  end

  dfs(50, 500, boss_hp, 0, 0, 0, 0, true)
  return best
end

local function day22(path)
  local lines = readLines(path)
  local boss_hp, boss_dmg = parse_boss(lines)

  print(string.format('Part 1: %d', min_mana(boss_hp, boss_dmg, false)))
  print(string.format('Part 2: %d', min_mana(boss_hp, boss_dmg, true)))
end

return function(path)
  return day22(path)
end
