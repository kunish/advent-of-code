local function parse_reactions(lines)
  local reactions = {}
  for _, line in ipairs(lines) do
    if line ~= '' then
      local left, right = line:match('^(.-)%s*=>%s*(.+)$')
      local out_n, out_c = right:match('^(%d+)%s+(%a+)$')
      out_n, out_c = tonumber(out_n), out_c
      local inputs = {}
      for qty, chem in left:gmatch('(%d+)%s+(%a+)') do
        inputs[#inputs + 1] = { qty = tonumber(qty), chem = chem }
      end
      reactions[out_c] = { yield = out_n, inputs = inputs }
    end
  end
  return reactions
end

local function ceil_div(a, b)
  return math.floor((a + b - 1) / b)
end

local function ore_for(reactions, surplus, chem, amount)
  if chem == 'ORE' then
    return amount
  end
  local s = surplus[chem] or 0
  if s >= amount then
    surplus[chem] = s - amount
    return 0
  end
  local need = amount - s
  surplus[chem] = 0
  local rx = reactions[chem]
  local y = rx.yield
  local times = ceil_div(need, y)
  local ore = 0
  for _, ing in ipairs(rx.inputs) do
    ore = ore + ore_for(reactions, surplus, ing.chem, ing.qty * times)
  end
  surplus[chem] = (surplus[chem] or 0) + times * y - need
  return ore
end

local function fuel_cost(reactions, fuel_amount)
  local surplus = {}
  return ore_for(reactions, surplus, 'FUEL', fuel_amount)
end

local function day14(path)
  local lines = readLines(path)
  local reactions = parse_reactions(lines)
  local p1 = fuel_cost(reactions, 1)

  local lo, hi = 1, 1000000000000
  local target = 1000000000000
  while lo < hi do
    local mid = math.floor((lo + hi + 1) / 2)
    local o = fuel_cost(reactions, mid)
    if o <= target then
      lo = mid
    else
      hi = mid - 1
    end
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', lo))
end

return function(path)
  return day14(path)
end
