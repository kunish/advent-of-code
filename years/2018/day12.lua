local function trim_state(state, offset)
  local first = state:find('#')
  if not first then
    return '', offset
  end
  local last = first
  for i = #state, first, -1 do
    if state:sub(i, i) == '#' then
      last = i
      break
    end
  end
  state = state:sub(first, last)
  offset = offset + first - 1
  return state, offset
end

local function evolve(state, offset, rules)
  local pad = 4
  state = string.rep('.', pad) .. state .. string.rep('.', pad)
  offset = offset - pad
  local n = #state
  local next_state = {}
  for i = 1, n do
    next_state[i] = '.'
  end
  for i = 3, n - 2 do
    local pat = state:sub(i - 2, i + 2)
    next_state[i] = rules[pat] or '.'
  end
  state = table.concat(next_state)
  return trim_state(state, offset)
end

local function pot_sum(state, offset)
  local s = 0
  for i = 1, #state do
    if state:sub(i, i) == '#' then
      s = s + (offset + i - 1)
    end
  end
  return s
end

local function day12(path)
  local lines = readLines(path)
  local initial = (lines[1] or ''):match('initial state: ([.#]+)')
  local rules = {}
  for li = 2, #lines do
    local pat, res = lines[li]:match('([.#]+) => ([.#])')
    if pat then
      rules[pat] = res
    end
  end

  local state = initial or ''
  local offset = 0
  for _ = 1, 20 do
    state, offset = evolve(state, offset, rules)
  end
  local part1 = pot_sum(state, offset)

  state = initial or ''
  offset = 0
  local prev_s = nil
  local prev_d = nil
  local part2 = nil
  for g = 1, 10000 do
    state, offset = evolve(state, offset, rules)
    local s = pot_sum(state, offset)
    if prev_s ~= nil then
      local d = s - prev_s
      if prev_d ~= nil and d == prev_d and g > 50 then
        local target = 50000000000
        part2 = s + d * (target - g)
        break
      end
      prev_d = d
    end
    prev_s = s
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2 or 0))
end

return function(path)
  return day12(path)
end
