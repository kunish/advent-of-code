local MASK = 0xFFFF

local function trim(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function eval_operand(s, eval_wire)
  s = trim(s)
  local n = tonumber(s)
  if n then
    return n & MASK
  end
  return eval_wire(s)
end

local function make_eval(circuit, override_b)
  local memo = {}

  local function eval_wire(w)
    if override_b and w == 'b' then
      return override_b & MASK
    end
    if memo[w] then
      return memo[w]
    end

    local instr = circuit[w]
    if not instr then
      error('unknown wire: ' .. tostring(w))
    end

    local v

    if instr:match('^%d+$') then
      v = tonumber(instr) & MASK
    elseif instr:match('^NOT ') then
      local a = instr:match('^NOT (.+)$')
      v = (~eval_wire(trim(a))) & MASK
    else
      local left, sh = instr:match('^(.+) LSHIFT (%d+)$')
      if left then
        v = (eval_wire(trim(left)) << tonumber(sh)) & MASK
      else
        left, sh = instr:match('^(.+) RSHIFT (%d+)$')
        if left then
          v = (eval_wire(trim(left)) >> tonumber(sh)) & MASK
        else
          local apos = instr:find(' AND ', 1, true)
          if apos then
            local left = trim(instr:sub(1, apos - 1))
            local right = trim(instr:sub(apos + 5))
            v = eval_operand(left, eval_wire) & eval_operand(right, eval_wire)
          else
            local opos = instr:find(' OR ', 1, true)
            if opos then
              local left = trim(instr:sub(1, opos - 1))
              local right = trim(instr:sub(opos + 4))
              v = eval_operand(left, eval_wire) | eval_operand(right, eval_wire)
            else
              v = eval_wire(trim(instr))
            end
          end
        end
      end
    end

    memo[w] = v
    return v
  end

  return eval_wire
end

local function day7(path)
  local lines = readLines(path)
  local circuit = {}

  for _, line in ipairs(lines) do
    local arrow = line:find(' -> ', 1, true)
    if arrow then
      local instr = trim(line:sub(1, arrow - 1))
      local wire = trim(line:sub(arrow + 4))
      circuit[wire] = instr
    end
  end

  local eval1 = make_eval(circuit, nil)
  local part1 = eval1('a')

  local eval2 = make_eval(circuit, part1)
  local part2 = eval2('a')

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day7(path)
end
