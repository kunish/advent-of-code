local function parse_op(line)
  local op, arg = line:match('^(%a+) ([+-]%d+)$')
  return op, tonumber(arg)
end

return function(path)
  local lines = readLines(path)
  local prog = {}
  local i = 1
  while i <= #lines do
    if lines[i] ~= '' then
      local op, arg = parse_op(lines[i])
      prog[#prog + 1] = { op = op, arg = arg or 0 }
    end
    i = i + 1
  end

  local function run_program(flipped)
    local acc, pc = 0, 1
    local seen = {}
    while pc >= 1 and pc <= #prog do
      if seen[pc] then
        return nil, acc
      end
      seen[pc] = true
      local ins = prog[pc]
      local op = ins.op
      if flipped == pc then
        if op == 'jmp' then
          op = 'nop'
        elseif op == 'nop' then
          op = 'jmp'
        end
      end
      if op == 'acc' then
        acc = acc + ins.arg
        pc = pc + 1
      elseif op == 'jmp' then
        pc = pc + ins.arg
      else
        pc = pc + 1
      end
    end
    return acc
  end

  local _, acc_before = run_program(nil)
  local part1 = acc_before

  local part2 = 0
  local fix = 1
  while fix <= #prog do
    local ins = prog[fix]
    if ins.op == 'jmp' or ins.op == 'nop' then
      local r = run_program(fix)
      if r ~= nil then
        part2 = r
        break
      end
    end
    fix = fix + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
