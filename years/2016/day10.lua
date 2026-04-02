local function parse_target(w1, id)
  id = tonumber(id)
  if w1 == 'bot' then
    return 'bot', id
  end
  return 'output', id
end

local function day10(path)
  local lines = readLines(path)
  local bots = {}
  local outputs = {}
  local rules = {}

  local function ensure_bot(id)
    if not bots[id] then
      bots[id] = {}
    end
    return bots[id]
  end

  local values = {}

  for _, line in ipairs(lines) do
    local v, bid = line:match('^value (%d+) goes to bot (%d+)$')
    if v then
      values[#values + 1] = { tonumber(v), tonumber(bid) }
    else
      local from, loww, lowid, highw, highid =
        line:match('^bot (%d+) gives low to (%w+) (%d+) and high to (%w+) (%d+)$')
      if from then
        local lt, li = parse_target(loww, lowid)
        local ht, hi = parse_target(highw, highid)
        rules[tonumber(from)] = { low = { lt, li }, high = { ht, hi } }
      end
    end
  end

  local compare_bot = nil

  local function give_chip(target_type, target_id, val)
    if target_type == 'output' then
      outputs[target_id] = val
      return
    end
    local chips = ensure_bot(target_id)
    chips[#chips + 1] = val
    if #chips < 2 then
      return
    end
    table.sort(chips)
    local low, high = chips[1], chips[2]
    for i = 1, #chips do
      chips[i] = nil
    end
    if low == 17 and high == 61 then
      compare_bot = target_id
    end
    local r = rules[target_id]
    give_chip(r.low[1], r.low[2], low)
    give_chip(r.high[1], r.high[2], high)
  end

  for _, pair in ipairs(values) do
    give_chip('bot', pair[2], pair[1])
  end

  local p2 = (outputs[0] or 0) * (outputs[1] or 0) * (outputs[2] or 0)
  print(string.format('Part 1: %d', compare_bot or -1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day10(path)
end
