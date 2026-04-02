local function day11(path)
  local lines = readLines(path)
  local monkeys = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    local mid = line:match('Monkey (%d+):')
    if mid then
      local m = { items = {}, count = 0 }
      i = i + 1
      local items_line = lines[i]
      for num in items_line:gmatch('(%d+)') do
        m.items[#m.items + 1] = tonumber(num)
      end
      i = i + 1
      local op_line = lines[i]
      if op_line:find('old %* old') then
        m.op = function(old)
          return old * old
        end
      else
        local mul = op_line:match('old %* (%d+)')
        local add = op_line:match('old %+ (%d+)')
        if mul then
          local k = tonumber(mul)
          m.op = function(old)
            return old * k
          end
        else
          local k = tonumber(add)
          m.op = function(old)
            return old + k
          end
        end
      end
      i = i + 1
      local test_line = lines[i]
      m.div = tonumber(test_line:match('divisible by (%d+)'))
      i = i + 1
      m.iftrue = tonumber(lines[i]:match('monkey (%d+)'))
      i = i + 1
      m.iffalse = tonumber(lines[i]:match('monkey (%d+)'))
      monkeys[#monkeys + 1] = m
    end
    i = i + 1
  end

  local function lcm_mod()
    local p = 1
    for j = 1, #monkeys do
      local d = monkeys[j].div
      p = p * d
    end
    return p
  end

  local mod = lcm_mod()

  local function run_rounds(rounds, relief)
    local ms = {}
    for j = 1, #monkeys do
      local src = monkeys[j]
      local copy = { items = {}, op = src.op, div = src.div, iftrue = src.iftrue, iffalse = src.iffalse, count = 0 }
      for k = 1, #src.items do
        copy.items[k] = src.items[k]
      end
      ms[j] = copy
    end

    for _ = 1, rounds do
      for j = 1, #monkeys do
        local m = ms[j]
        while #m.items > 0 do
          local old = table.remove(m.items, 1)
          m.count = m.count + 1
          local w = m.op(old)
          if relief then
            w = w // 3
          else
            w = w % mod
          end
          local tgt
          if w % m.div == 0 then
            tgt = m.iftrue
          else
            tgt = m.iffalse
          end
          local dest = ms[tgt + 1]
          dest.items[#dest.items + 1] = w
        end
      end
    end

    local counts = {}
    for j = 1, #ms do
      counts[j] = ms[j].count
    end
    table.sort(counts)
    return counts[#counts] * counts[#counts - 1]
  end

  print(string.format('Part 1: %d', run_rounds(20, true)))
  print(string.format('Part 2: %d', run_rounds(10000, false)))
end

return function(p)
  return day11(p)
end
