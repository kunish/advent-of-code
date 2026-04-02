local function day24(path)
  local lines = readLines(path)
  local comps = {}
  for _, line in ipairs(lines) do
    local a, b = line:match('^(%d+)/(%d+)$')
    if a then
      comps[#comps + 1] = { tonumber(a), tonumber(b) }
    end
  end

  local used = {}
  local best_strength = 0
  local best_len = 0
  local best_len_strength = 0

  local function dfs(port, strength, depth)
    if strength > best_strength then
      best_strength = strength
    end
    if depth > best_len then
      best_len = depth
      best_len_strength = strength
    elseif depth == best_len and strength > best_len_strength then
      best_len_strength = strength
    end

    for i = 1, #comps do
      if not used[i] then
        local a, b = comps[i][1], comps[i][2]
        if a == port or b == port then
          used[i] = true
          local other = (a == port) and b or a
          dfs(other, strength + a + b, depth + 1)
          used[i] = false
        end
      end
    end
  end

  dfs(0, 0, 0)

  print(string.format('Part 1: %d', best_strength))
  print(string.format('Part 2: %d', best_len_strength))
end

return function(path)
  return day24(path)
end
