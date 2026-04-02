local function parse_prog(lines)
  local prog = {}
  for _, line in ipairs(lines) do
    line = line:match('^%s*(.-)%s*$')
    if line ~= '' then
      local parts = {}
      for p in line:gmatch('%S+') do
        parts[#parts + 1] = p
      end
      prog[#prog + 1] = parts
    end
  end
  return prog
end

local function is_reg(tok)
  return tok:match('^%-?%d+$') == nil
end

local function get(regs, tok)
  if is_reg(tok) then
    return regs[tok] or 0
  end
  return tonumber(tok)
end

local function exec_step(regs, prog, ip)
  local ins = prog[ip]
  local op = ins[1]
  if op == 'set' then
    regs[ins[2]] = get(regs, ins[3])
    return ip + 1
  elseif op == 'sub' then
    local r = ins[2]
    regs[r] = (regs[r] or 0) - get(regs, ins[3])
    return ip + 1
  elseif op == 'mul' then
    local r = ins[2]
    regs[r] = (regs[r] or 0) * get(regs, ins[3])
    return ip + 1
  elseif op == 'jnz' then
    if get(regs, ins[2]) ~= 0 then
      return ip + get(regs, ins[3])
    end
    return ip + 1
  end
  return ip + 1
end

local function run_count_mul(regs, prog)
  local ip = 1
  local muls = 0
  while ip >= 1 and ip <= #prog do
    local ins = prog[ip]
    if ins[1] == 'mul' then
      muls = muls + 1
    end
    ip = exec_step(regs, prog, ip)
  end
  return muls
end

local function is_prime(n)
  if n < 2 then
    return false
  end
  if n % 2 == 0 then
    return n == 2
  end
  local lim = math.floor(math.sqrt(n))
  local d = 3
  while d <= lim do
    if n % d == 0 then
      return false
    end
    d = d + 2
  end
  return true
end

local function day23(path)
  local lines = readLines(path)
  local prog = parse_prog(lines)

  local regs = { a = 0 }
  local muls = run_count_mul(regs, prog)
  print(string.format('Part 1: %d', muls))

  regs = { a = 1 }
  local ip = 1
  while ip < 9 do
    ip = exec_step(regs, prog, ip)
  end

  local b0 = regs.b
  local c0 = regs.c
  local h = 0
  local x = b0
  while x <= c0 do
    if not is_prime(x) then
      h = h + 1
    end
    x = x + 17
  end

  print(string.format('Part 2: %d', h))
end

return function(path)
  return day23(path)
end
