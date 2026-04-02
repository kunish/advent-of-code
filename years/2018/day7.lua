local function day7(path)
  local lines = readLines(path)
  local succ = {}
  local preds = {}
  local all = {}

  local function add_node(c)
    if not succ[c] then
      succ[c] = {}
      preds[c] = {}
      all[#all + 1] = c
    end
  end

  for li = 1, #lines do
    local line = lines[li]
    local a, b = line:match('Step (.) must be finished before step (.) can begin')
    if a and b then
      add_node(a)
      add_node(b)
      succ[a][b] = true
      preds[b][a] = true
    end
  end

  table.sort(all)

  local function step_duration(c)
    return 60 + (string.byte(c) - string.byte('A') + 1)
  end

  local pred_left = {}
  for i = 1, #all do
    local c = all[i]
    local n = 0
    for _ in pairs(preds[c]) do
      n = n + 1
    end
    pred_left[c] = n
  end

  local order = {}
  local pl = {}
  for i = 1, #all do
    local c = all[i]
    pl[c] = pred_left[c]
  end

  while #order < #all do
    local ready = {}
    for i = 1, #all do
      local c = all[i]
      if pl[c] == 0 then
        local taken = false
        for j = 1, #order do
          if order[j] == c then
            taken = true
            break
          end
        end
        if not taken then
          ready[#ready + 1] = c
        end
      end
    end
    table.sort(ready)
    local c = ready[1]
    order[#order + 1] = c
    pl[c] = -1
    for d, _ in pairs(succ[c]) do
      pl[d] = pl[d] - 1
    end
  end

  local part1 = table.concat(order)

  for i = 1, #all do
    local c = all[i]
    pred_left[c] = 0
    for _ in pairs(preds[c]) do
      pred_left[c] = pred_left[c] + 1
    end
  end

  local done = {}
  local workers = {}
  for wi = 1, 5 do
    workers[wi] = { c = nil, left = 0 }
  end

  local function working_on(c)
    for wi = 1, 5 do
      if workers[wi].c == c then
        return true
      end
    end
    return false
  end

  local function pick_ready()
    local best = nil
    for i = 1, #all do
      local c = all[i]
      if not done[c] and pred_left[c] == 0 and not working_on(c) then
        if best == nil or c < best then
          best = c
        end
      end
    end
    return best
  end

  local function any_busy()
    for wi = 1, 5 do
      if workers[wi].c ~= nil then
        return true
      end
    end
    return false
  end

  local function all_done()
    for i = 1, #all do
      if not done[all[i]] then
        return false
      end
    end
    return true
  end

  local time = 0
  while true do
    for wi = 1, 5 do
      local w = workers[wi]
      if w.c ~= nil and w.left == 0 then
        local c = w.c
        done[c] = true
        w.c = nil
        for d, _ in pairs(succ[c]) do
          pred_left[d] = pred_left[d] - 1
        end
      end
    end
    for wi = 1, 5 do
      local w = workers[wi]
      if w.c == nil then
        local c = pick_ready()
        if c then
          w.c = c
          w.left = step_duration(c)
        end
      end
    end
    if all_done() and not any_busy() then break end
    for wi = 1, 5 do
      local w = workers[wi]
      if w.c ~= nil then
        w.left = w.left - 1
      end
    end
    time = time + 1
  end

  local part2 = time

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day7(path)
end
