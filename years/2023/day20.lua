local function parse(lines)
  local modules = {}
  local li = 1
  while li <= #lines do
    local line = lines[li]
    if line ~= '' then
      local left, rights = line:match('^(.+)%s*%-%>%s*(.+)$')
      left = left:match('^%s*(.-)%s*$')
      local dests = {}
      for d in rights:gmatch('%w+') do
        dests[#dests + 1] = d
      end
      if left == 'broadcaster' then
        modules.broadcaster = { kind = 'broadcaster', dests = dests }
      elseif left:sub(1, 1) == '%' then
        local name = left:sub(2)
        modules[name] = { kind = 'ff', on = false, dests = dests }
      elseif left:sub(1, 1) == '&' then
        local name = left:sub(2)
        modules[name] = { kind = 'conj', inputs = {}, dests = dests }
      end
    end
    li = li + 1
  end

  for name, m in pairs(modules) do
    if m.dests then
      local di = 1
      while di <= #m.dests do
        local d = m.dests[di]
        local t = modules[d]
        if t and t.kind == 'conj' then
          t.inputs[name] = false
        end
        di = di + 1
      end
    end
  end

  return modules
end

local function press_button(modules, on_pulse)
  local q = {}
  local qh = 1
  local qt = 1
  q[1] = { 'button', 'broadcaster', false }
  qt = 2
  local lo = 0
  local hi = 0

  while qh < qt do
    local ev = q[qh]
    qh = qh + 1
    local from, to, is_high = ev[1], ev[2], ev[3]
    if is_high then
      hi = hi + 1
    else
      lo = lo + 1
    end
    if on_pulse then
      on_pulse(from, to, is_high)
    end

    local m = modules[to]
    if not m then
      -- sink (e.g. rx)
    elseif m.kind == 'broadcaster' then
      local di = 1
      while di <= #m.dests do
        q[qt] = { to, m.dests[di], is_high }
        qt = qt + 1
        di = di + 1
      end
    elseif m.kind == 'ff' then
      if not is_high then
        m.on = not m.on
        local out_high = m.on
        local di = 1
        while di <= #m.dests do
          q[qt] = { to, m.dests[di], out_high }
          qt = qt + 1
          di = di + 1
        end
      end
    elseif m.kind == 'conj' then
      m.inputs[from] = is_high
      local all_high = true
      for _, v in pairs(m.inputs) do
        if not v then
          all_high = false
          break
        end
      end
      local out_high = not all_high
      local di = 1
      while di <= #m.dests do
        q[qt] = { to, m.dests[di], out_high }
        qt = qt + 1
        di = di + 1
      end
    end
  end

  return lo, hi
end

local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

local function lcm(a, b)
  return (a / gcd(a, b)) * b
end

return function(path)
  local lines = readLines(path)
  local modules_p1 = parse(lines)

  local p1_lo = 0
  local p1_hi = 0
  local press = 1
  while press <= 1000 do
    local lo, hi = press_button(modules_p1, nil)
    p1_lo = p1_lo + lo
    p1_hi = p1_hi + hi
    press = press + 1
  end
  local p1 = p1_lo * p1_hi

  local modules = parse(lines)

  local feed_rx
  for name, m in pairs(modules) do
    if m.dests then
      local di = 1
      while di <= #m.dests do
        if m.dests[di] == 'rx' then
          feed_rx = name
          break
        end
        di = di + 1
      end
    end
  end

  local p2 = 0
  if feed_rx then
    local conj = modules[feed_rx]
    local periods = {}
    local watch = {}
    for inp in pairs(conj.inputs) do
      watch[inp] = true
    end

    local press_count = 0
    local done = false
    while not done do
      press_count = press_count + 1
      local function on_pulse(from, to, is_high)
        if to == feed_rx and is_high and watch[from] then
          if not periods[from] then
            periods[from] = press_count
          end
        end
      end
      press_button(modules, on_pulse)
      local all_found = true
      for inp in pairs(watch) do
        if not periods[inp] then
          all_found = false
          break
        end
      end
      if all_found then
        done = true
      end
      if press_count > 100000000 then
        error('part2 timeout')
      end
    end

    p2 = 1
    for _, v in pairs(periods) do
      p2 = lcm(p2, v)
    end
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
