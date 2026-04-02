local function apply(name, regs, a, b, c)
  local r = { regs[1], regs[2], regs[3], regs[4], regs[5], regs[6] }
  local ra, rb, rc = a + 1, b + 1, c + 1
  if name == 'addr' then
    r[rc] = r[ra] + r[rb]
  elseif name == 'addi' then
    r[rc] = r[ra] + b
  elseif name == 'mulr' then
    r[rc] = r[ra] * r[rb]
  elseif name == 'muli' then
    r[rc] = r[ra] * b
  elseif name == 'banr' then
    r[rc] = r[ra] & r[rb]
  elseif name == 'bani' then
    r[rc] = r[ra] & b
  elseif name == 'borr' then
    r[rc] = r[ra] | r[rb]
  elseif name == 'bori' then
    r[rc] = r[ra] | b
  elseif name == 'setr' then
    r[rc] = r[ra]
  elseif name == 'seti' then
    r[rc] = a
  elseif name == 'gtir' then
    r[rc] = (a > r[rb]) and 1 or 0
  elseif name == 'gtri' then
    r[rc] = (r[ra] > b) and 1 or 0
  elseif name == 'gtrr' then
    r[rc] = (r[ra] > r[rb]) and 1 or 0
  elseif name == 'eqir' then
    r[rc] = (a == r[rb]) and 1 or 0
  elseif name == 'eqri' then
    r[rc] = (r[ra] == b) and 1 or 0
  elseif name == 'eqrr' then
    r[rc] = (r[ra] == r[rb]) and 1 or 0
  end
  return r
end

local function sum_divisors(n)
  local s = 0
  local i = 1
  while i * i <= n do
    if n % i == 0 then
      s = s + i
      local j = n // i
      if j ~= i then
        s = s + j
      end
    end
    i = i + 1
  end
  return s
end

local function run_vm(program, ipreg, r0_init)
  local regs = { r0_init, 0, 0, 0, 0, 0 }
  local ip = 0
  local ip_idx = ipreg + 1
  while ip >= 0 and ip < #program do
    regs[ip_idx] = ip
    local ins = program[ip + 1]
    regs = apply(ins[1], regs, ins[2], ins[3], ins[4])
    ip = regs[ip_idx] + 1
  end
  return regs
end

local function day19(path)
  local lines = readLines(path)
  local ipreg = tonumber((lines[1] or ''):match('#ip (%d+)')) or 0
  local program = {}
  for i = 2, #lines do
    local ln = lines[i]
    if ln ~= '' then
      local op, a, b, c = ln:match('(%a+)%s+(%d+)%s+(%d+)%s+(%d+)')
      if op then
        program[#program + 1] = { op, tonumber(a), tonumber(b), tonumber(c) }
      end
    end
  end

  local regs1 = run_vm(program, ipreg, 0)
  local part1 = regs1[1]

  local r2 = 0
  local ip_idx = ipreg + 1
  local regs = { 1, 0, 0, 0, 0, 0 }
  local ip = 0
  for _ = 1, 200 do
    if ip < 0 or ip >= #program then
      break
    end
    regs[ip_idx] = ip
    local ins = program[ip + 1]
    regs = apply(ins[1], regs, ins[2], ins[3], ins[4])
    ip = regs[ip_idx] + 1
  end
  r2 = regs[3]

  local part2 = sum_divisors(r2)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day19(path)
end
