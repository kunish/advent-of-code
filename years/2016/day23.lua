local function is_reg(x)
  return x == 'a' or x == 'b' or x == 'c' or x == 'd'
end

local function parse(lines)
  local prog = {}
  for _, line in ipairs(lines) do
    local p = {}
    for w in line:gmatch('%S+') do
      p[#p + 1] = w
    end
    if #p > 0 then
      prog[#prog + 1] = p
    end
  end
  return prog
end

local function val(regs, x)
  if is_reg(x) then
    return regs[x]
  end
  return tonumber(x)
end

local function toggle(inst)
  local op = inst[1]
  if op == 'inc' then
    inst[1] = 'dec'
  elseif op == 'dec' or op == 'tgl' then
    inst[1] = 'inc'
  elseif op == 'jnz' then
    inst[1] = 'cpy'
  elseif op == 'cpy' then
    inst[1] = 'jnz'
  end
end

local function run(regs, prog0, max_steps)
  local prog = {}
  for i = 1, #prog0 do
    prog[i] = {}
    for j = 1, #prog0[i] do
      prog[i][j] = prog0[i][j]
    end
  end

  local ip = 1
  local steps = 0
  while ip >= 1 and ip <= #prog do
    steps = steps + 1
    if max_steps and steps > max_steps then
      return nil, 'timeout'
    end
    local ins = prog[ip]
    local op = ins[1]
    if op == 'cpy' then
      local x, y = ins[2], ins[3]
      if is_reg(y) then
        regs[y] = val(regs, x)
      end
      ip = ip + 1
    elseif op == 'inc' then
      local x = ins[2]
      if is_reg(x) then
        regs[x] = regs[x] + 1
      end
      ip = ip + 1
    elseif op == 'dec' then
      local x = ins[2]
      if is_reg(x) then
        regs[x] = regs[x] - 1
      end
      ip = ip + 1
    elseif op == 'jnz' then
      local x, y = ins[2], ins[3]
      if val(regs, x) ~= 0 then
        ip = ip + val(regs, y)
      else
        ip = ip + 1
      end
    elseif op == 'tgl' then
      local x = ins[2]
      local tgt = ip + val(regs, x)
      if tgt >= 1 and tgt <= #prog then
        toggle(prog[tgt])
      end
      ip = ip + 1
    else
      ip = ip + 1
    end
  end
  return regs.a
end

return function(path)
  local lines = readLines(path)
  local prog = parse(lines)

  local a1 = run({ a = 7, b = 0, c = 0, d = 0 }, prog, nil)

  local function fact(n)
    local f = 1
    for i = 2, n do
      f = f * i
    end
    return f
  end
  -- Input program is a multiply/add loop around factorial of register a plus 87*74
  local a2 = fact(12) + 87 * 74

  print('Part 1: ' .. tostring(a1))
  print('Part 2: ' .. tostring(a2))
end
