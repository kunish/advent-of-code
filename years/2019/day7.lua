local intcode = require('years.2019.intcode')

local function perm5_used(from, to_, used, depth, phases, cb)
  if depth == 6 then
    cb(phases)
    return
  end
  local i = from
  while i <= to_ do
    if not used[i] then
      used[i] = true
      phases[depth] = i
      perm5_used(from, to_, used, depth + 1, phases, cb)
      used[i] = false
    end
    i = i + 1
  end
end

local function day7(path)
  local lines = readLines(path)
  local base = intcode.parse(lines[1] or '')

  local best1 = 0
  local used = {}
  local phases = {}
  perm5_used(0, 4, used, 1, phases, function(p)
    local sig = 0
    local k = 1
    while k <= 5 do
      local outs = intcode.run(intcode.copy(base), { p[k], sig })
      sig = outs[#outs]
      k = k + 1
    end
    if sig > best1 then
      best1 = sig
    end
  end)

  local best2 = 0
  used = {}
  perm5_used(5, 9, used, 1, phases, function(p)
    local sig = intcode.run_feedback(base, p)
    if sig > best2 then
      best2 = sig
    end
  end)

  print(string.format('Part 1: %d', best1))
  print(string.format('Part 2: %d', best2))
end

return function(path)
  return day7(path)
end
