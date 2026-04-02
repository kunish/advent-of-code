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

local function run_until_out(regs, prog0, max_out, max_steps)
  local prog = {}
  for i = 1, #prog0 do
    prog[i] = {}
    for j = 1, #prog0[i] do
      prog[i][j] = prog0[i][j]
    end
  end

  local ip = 1
  local steps = 0
  local out = {}
  while ip >= 1 and ip <= #prog and #out < max_out do
    steps = steps + 1
    if steps > max_steps then
      return nil
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
    elseif op == 'out' then
      local x = ins[2]
      out[#out + 1] = val(regs, x)
      ip = ip + 1
    else
      ip = ip + 1
    end
  end
  return out
end

local function good_alt(seq)
  for i = 1, #seq do
    local want = (i - 1) % 2
    if seq[i] ~= want then
      return false
    end
  end
  return true
end

return function(path)
  local lines = readLines(path)
  local prog0 = parse(lines)

  local answer
  for a0 = 1, 10000000 do
    local regs = { a = a0, b = 0, c = 0, d = 0 }
    local out = run_until_out(regs, prog0, 32, 100000000)
    if out and good_alt(out) then
      answer = a0
      break
    end
  end

  print('Part 1: ' .. tostring(answer))
  print('Part 2: ')
end
