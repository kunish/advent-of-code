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
  return not (tok:match('^%-?%d+$'))
end

local function get(regs, tok)
  if is_reg(tok) then
    return regs[tok] or 0
  end
  return tonumber(tok)
end

local function day18(path)
  local lines = readLines(path)
  local prog = parse_prog(lines)

  local regs = {}
  local last = nil
  local ip = 1
  while ip >= 1 and ip <= #prog do
    local ins = prog[ip]
    local op = ins[1]
    if op == 'snd' then
      last = get(regs, ins[2])
      ip = ip + 1
    elseif op == 'set' then
      regs[ins[2]] = get(regs, ins[3])
      ip = ip + 1
    elseif op == 'add' then
      local r = ins[2]
      regs[r] = (regs[r] or 0) + get(regs, ins[3])
      ip = ip + 1
    elseif op == 'mul' then
      local r = ins[2]
      regs[r] = (regs[r] or 0) * get(regs, ins[3])
      ip = ip + 1
    elseif op == 'mod' then
      local r = ins[2]
      regs[r] = (regs[r] or 0) % get(regs, ins[3])
      ip = ip + 1
    elseif op == 'rcv' then
      if get(regs, ins[2]) ~= 0 then
        break
      end
      ip = ip + 1
    elseif op == 'jgz' then
      if get(regs, ins[2]) > 0 then
        ip = ip + get(regs, ins[3])
      else
        ip = ip + 1
      end
    else
      ip = ip + 1
    end
  end

  print(string.format('Part 1: %d', last or 0))

  local function exec(vm, inq, outq, count_snd)
    if vm.ip < 1 or vm.ip > #prog then
      return false
    end
    local ins = prog[vm.ip]
    local op = ins[1]
    if op == 'snd' then
      local v = get(vm.regs, ins[2])
      outq[#outq + 1] = v
      if count_snd then
        count_snd[1] = count_snd[1] + 1
      end
      vm.ip = vm.ip + 1
      return true
    elseif op == 'rcv' then
      if #inq == 0 then
        return false
      end
      local v = table.remove(inq, 1)
      vm.regs[ins[2]] = v
      vm.ip = vm.ip + 1
      return true
    elseif op == 'set' then
      vm.regs[ins[2]] = get(vm.regs, ins[3])
      vm.ip = vm.ip + 1
      return true
    elseif op == 'add' then
      local r = ins[2]
      vm.regs[r] = (vm.regs[r] or 0) + get(vm.regs, ins[3])
      vm.ip = vm.ip + 1
      return true
    elseif op == 'mul' then
      local r = ins[2]
      vm.regs[r] = (vm.regs[r] or 0) * get(vm.regs, ins[3])
      vm.ip = vm.ip + 1
      return true
    elseif op == 'mod' then
      local r = ins[2]
      vm.regs[r] = (vm.regs[r] or 0) % get(vm.regs, ins[3])
      vm.ip = vm.ip + 1
      return true
    elseif op == 'jgz' then
      if get(vm.regs, ins[2]) > 0 then
        vm.ip = vm.ip + get(vm.regs, ins[3])
      else
        vm.ip = vm.ip + 1
      end
      return true
    end
    vm.ip = vm.ip + 1
    return true
  end

  local vm0 = { ip = 1, regs = { p = 0 } }
  local vm1 = { ip = 1, regs = { p = 1 } }
  local q0 = {}
  local q1 = {}
  local sends1 = { 0 }

  while true do
    local progressed = false
    while exec(vm0, q0, q1, nil) do
      progressed = true
    end
    while exec(vm1, q1, q0, sends1) do
      progressed = true
    end
    if not progressed then
      break
    end
  end

  print(string.format('Part 2: %d', sends1[1]))
end

return function(path)
  return day18(path)
end
