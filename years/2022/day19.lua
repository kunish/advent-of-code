return function(path)
  local lines = readLines(path)
  local blueprints = {}

  for i = 1, #lines do
    local line = lines[i]
    local id,
      oo,
      oc,
      oob_o,
      oob_c,
      og_o,
      og_ob = line:match(
      '^Blueprint (%d+): Each ore robot costs (%d+) ore%. Each clay robot costs (%d+) ore%. Each obsidian robot costs (%d+) ore and (%d+) clay%. Each geode robot costs (%d+) ore and (%d+) obsidian%.$'
    )
    blueprints[#blueprints + 1] = {
      id = tonumber(id),
      ore_ore = tonumber(oo),
      clay_ore = tonumber(oc),
      obs_ore = tonumber(oob_o),
      obs_clay = tonumber(oob_c),
      geo_ore = tonumber(og_o),
      geo_obs = tonumber(og_ob),
    }
  end

  local function max_geodes(bp, time_limit)
    local max_ore = math.max(bp.ore_ore, bp.clay_ore, bp.obs_ore, bp.geo_ore)
    local memo = {}

    local function dfs(t, ore, clay, obs, geo, r_ore, r_clay, r_obs, r_geo)
      ore = math.min(ore, max_ore * 2)
      clay = math.min(clay, bp.obs_clay * 2)
      obs = math.min(obs, bp.geo_obs * 2)

      local key = string.format(
        '%d|%d|%d|%d|%d|%d|%d|%d|%d',
        t,
        ore,
        clay,
        obs,
        geo,
        r_ore,
        r_clay,
        r_obs,
        r_geo
      )
      if memo[key] then
        return memo[key]
      end

      if t <= 0 then
        memo[key] = geo
        return geo
      end

      local mx = -1

      if ore >= bp.geo_ore and obs >= bp.geo_obs then
        local v = dfs(
          t - 1,
          ore - bp.geo_ore + r_ore,
          clay + r_clay,
          obs - bp.geo_obs + r_obs,
          geo + r_geo,
          r_ore,
          r_clay,
          r_obs,
          r_geo + 1
        )
        if v > mx then
          mx = v
        end
        memo[key] = mx
        return mx
      end

      local w = dfs(t - 1, ore + r_ore, clay + r_clay, obs + r_obs, geo + r_geo, r_ore, r_clay, r_obs, r_geo)
      if w > mx then
        mx = w
      end

      if r_obs < bp.geo_obs and ore >= bp.obs_ore and clay >= bp.obs_clay then
        local v = dfs(
          t - 1,
          ore - bp.obs_ore + r_ore,
          clay - bp.obs_clay + r_clay,
          obs + r_obs,
          geo + r_geo,
          r_ore,
          r_clay,
          r_obs + 1,
          r_geo
        )
        if v > mx then
          mx = v
        end
      end

      if r_clay < bp.obs_clay and ore >= bp.clay_ore then
        local v = dfs(
          t - 1,
          ore - bp.clay_ore + r_ore,
          clay + r_clay,
          obs + r_obs,
          geo + r_geo,
          r_ore,
          r_clay + 1,
          r_obs,
          r_geo
        )
        if v > mx then
          mx = v
        end
      end

      if r_ore < max_ore and ore >= bp.ore_ore then
        local v = dfs(
          t - 1,
          ore - bp.ore_ore + r_ore,
          clay + r_clay,
          obs + r_obs,
          geo + r_geo,
          r_ore + 1,
          r_clay,
          r_obs,
          r_geo
        )
        if v > mx then
          mx = v
        end
      end

      memo[key] = mx
      return mx
    end

    return dfs(time_limit, 0, 0, 0, 0, 1, 0, 0, 0)
  end

  local part1 = 0
  for i = 1, #blueprints do
    local g = max_geodes(blueprints[i], 24)
    part1 = part1 + blueprints[i].id * g
  end
  print(string.format('Part 1: %d', part1))

  local part2 = 1
  local limit = math.min(3, #blueprints)
  for i = 1, limit do
    part2 = part2 * max_geodes(blueprints[i], 32)
  end
  print(string.format('Part 2: %d', part2))
end
