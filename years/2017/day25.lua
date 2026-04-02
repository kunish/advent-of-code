local function day25(path)
  local lines = readLines(path)
  local text = table.concat(lines, '\n')
  local steps = tonumber(text:match('after (%d+) steps')) or 0
  local start = text:match('Begin in state (%w+)') or 'A'

  local states = {}
  local cur = 1
  while cur <= #lines do
    local name = lines[cur]:match('^In state (%w+):')
    if name then
      cur = cur + 1
      local body = {}
      while cur <= #lines and not lines[cur]:match('^In state') do
        body[#body + 1] = lines[cur]
        cur = cur + 1
      end
      states[name] = body
    else
      cur = cur + 1
    end
  end

  local function parse_body(body)
    local rules = {}
    local val = nil
    for _, ln in ipairs(body) do
      local v = ln:match('If the current value is (%d+)')
      if v then
        val = tonumber(v)
        rules[val] = {}
      else
        local w = ln:match('Write the value (%d+)')
        if w then
          rules[val].write = tonumber(w)
        end
        if ln:match('Move one slot to the left') then
          rules[val].move = -1
        elseif ln:match('Move one slot to the right') then
          rules[val].move = 1
        end
        local nx = ln:match('Continue with state ([%w]+)')
        if nx then
          rules[val].next = nx
        end
      end
    end
    return rules
  end

  local machine = {}
  for name, body in pairs(states) do
    machine[name] = parse_body(body)
  end

  local tape = {}
  local pos = 0
  local state = start

  for _ = 1, steps do
    local v = tape[pos] or 0
    local r = machine[state][v]
    tape[pos] = r.write
    pos = pos + r.move
    state = r.next
  end

  local ones = 0
  for _, t in pairs(tape) do
    if t == 1 then
      ones = ones + 1
    end
  end

  print(string.format('Part 1: %d', ones))
  print('Part 2: (no part 2)')
end

return function(path)
  return day25(path)
end
