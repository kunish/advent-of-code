local function parse_weights(lines)
  local w = {}
  for i, line in ipairs(lines) do
    w[i] = assert(tonumber(line))
  end
  return w
end

local function sum(t)
  local s = 0
  for _, v in ipairs(t) do
    s = s + v
  end
  return s
end

local function product(t)
  local p = 1
  for _, v in ipairs(t) do
    p = p * v
  end
  return p
end

---Can multiset `weights` be split into `parts` groups each summing to `target`?
local function can_partition(weights, target, parts)
  if parts == 1 then
    return sum(weights) == target
  end
  if sum(weights) ~= target * parts then
    return false
  end

  local n = #weights
  local used = {}

  local function dfs(sum_left, start)
    if sum_left == 0 then
      local rest = {}
      for i = 1, n do
        if not used[i] then
          rest[#rest + 1] = weights[i]
        end
      end
      return can_partition(rest, target, parts - 1)
    end
    for i = start, n do
      if not used[i] and sum_left >= weights[i] then
        used[i] = true
        if dfs(sum_left - weights[i], i + 1) then
          return true
        end
        used[i] = false
      end
    end
    return false
  end

  return dfs(target, 1)
end

---Minimum quantum entanglement: fewest packages in group 1, then lowest QE.
local function best_qe(weights, target, groups)
  local n = #weights

  for k = 1, n do
    local best = nil
    local used = {}

    local function dfs_first(sum_left, start, left_k, chosen)
      if sum_left == 0 and left_k == 0 then
        local rest = {}
        for i = 1, n do
          if not used[i] then
            rest[#rest + 1] = weights[i]
          end
        end
        if can_partition(rest, target, groups - 1) then
          local qe = product(chosen)
          if best == nil or qe < best then
            best = qe
          end
        end
        return
      end
      if sum_left < 0 or left_k < 0 then
        return
      end
      for i = start, n do
        if not used[i] and sum_left >= weights[i] then
          used[i] = true
          chosen[#chosen + 1] = weights[i]
          dfs_first(sum_left - weights[i], i + 1, left_k - 1, chosen)
          chosen[#chosen] = nil
          used[i] = false
        end
      end
    end

    dfs_first(target, 1, k, {})
    if best ~= nil then
      return best
    end
  end

  error('no valid partition')
end

local function day24(path)
  local lines = readLines(path)
  local weights = parse_weights(lines)
  table.sort(weights, function(a, b)
    return a > b
  end)

  local total = sum(weights)
  local p1 = best_qe(weights, total // 3, 3)
  local p2 = best_qe(weights, total // 4, 4)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day24(path)
end
