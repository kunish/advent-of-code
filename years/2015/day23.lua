local function parse_offset(s)
  local sign = 1
  if s:sub(1, 1) == '+' then
    sign = 1
  elseif s:sub(1, 1) == '-' then
    sign = -1
  end
  return sign * tonumber(s:match('%d+'))
end

local function run_program(lines, a_start)
  local regs = { a = a_start, b = 0 }
  local ip = 1

  while ip >= 1 and ip <= #lines do
    local line = lines[ip]
    local op, rest = line:match('^(%a+)%s+(.*)$')
    if op == 'hlf' then
      local r = rest:match('^(%a)$')
      regs[r] = regs[r] // 2
      ip = ip + 1
    elseif op == 'tpl' then
      local r = rest:match('^(%a)$')
      regs[r] = regs[r] * 3
      ip = ip + 1
    elseif op == 'inc' then
      local r = rest:match('^(%a)$')
      regs[r] = regs[r] + 1
      ip = ip + 1
    elseif op == 'jmp' then
      ip = ip + parse_offset(rest)
    elseif op == 'jie' then
      local r, off = rest:match('^(%a),%s*(.+)$')
      if regs[r] % 2 == 0 then
        ip = ip + parse_offset(off)
      else
        ip = ip + 1
      end
    elseif op == 'jio' then
      local r, off = rest:match('^(%a),%s*(.+)$')
      if regs[r] == 1 then
        ip = ip + parse_offset(off)
      else
        ip = ip + 1
      end
    else
      error('unknown op: ' .. line)
    end
  end

  return regs.b
end

local function day23(path)
  local lines = readLines(path)
  print(string.format('Part 1: %d', run_program(lines, 0)))
  print(string.format('Part 2: %d', run_program(lines, 1)))
end

return function(path)
  return day23(path)
end
