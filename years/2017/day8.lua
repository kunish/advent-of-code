local function eval_cond(regs, a, op, b)
  local av = regs[a] or 0
  local bv = tonumber(b)
  if op == '>' then
    return av > bv
  elseif op == '<' then
    return av < bv
  elseif op == '>=' then
    return av >= bv
  elseif op == '<=' then
    return av <= bv
  elseif op == '==' then
    return av == bv
  elseif op == '!=' then
    return av ~= bv
  end
  error('unknown op ' .. tostring(op))
end

local function day8(path)
  local lines = readLines(path)
  local regs = {}
  local max_ever = 0

  for _, line in ipairs(lines) do
    if line ~= '' then
      local left, right = line:match('^(.+)%s+if%s+(.+)$')
      if not left then
        error('bad line: ' .. line)
      end
      local r1, dir, n1 = left:match('^(%w+)%s+(%w+)%s+(%-?%d+)$')
      local condr, condop, condv = right:match('^(%w+)%s+([%!=<>]+)%s+(%-?%d+)$')
      if not r1 or not condr then
        error('bad line: ' .. line)
      end
      n1 = tonumber(n1)
      condv = tonumber(condv)
      if eval_cond(regs, condr, condop, condv) then
        local cur = regs[r1] or 0
        if dir == 'inc' then
          regs[r1] = cur + n1
        else
          regs[r1] = cur - n1
        end
      end
      for _, v in pairs(regs) do
        if v > max_ever then
          max_ever = v
        end
      end
    end
  end

  local max_end = 0
  for _, v in pairs(regs) do
    if v > max_end then
      max_end = v
    end
  end

  print(string.format('Part 1: %d', max_end))
  print(string.format('Part 2: %d', max_ever))
end

return function(path)
  return day8(path)
end
