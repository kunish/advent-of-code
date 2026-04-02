local op_names = {
  'addr',
  'addi',
  'mulr',
  'muli',
  'banr',
  'bani',
  'borr',
  'bori',
  'setr',
  'seti',
  'gtir',
  'gtri',
  'gtrr',
  'eqir',
  'eqri',
  'eqrr',
}

local function apply_op(name, regs, a, b, c)
  local r = { regs[1] or 0, regs[2] or 0, regs[3] or 0, regs[4] or 0 }
  if name == 'addr' then
    r[c + 1] = r[a + 1] + r[b + 1]
  elseif name == 'addi' then
    r[c + 1] = r[a + 1] + b
  elseif name == 'mulr' then
    r[c + 1] = r[a + 1] * r[b + 1]
  elseif name == 'muli' then
    r[c + 1] = r[a + 1] * b
  elseif name == 'banr' then
    r[c + 1] = r[a + 1] & r[b + 1]
  elseif name == 'bani' then
    r[c + 1] = r[a + 1] & b
  elseif name == 'borr' then
    r[c + 1] = r[a + 1] | r[b + 1]
  elseif name == 'bori' then
    r[c + 1] = r[a + 1] | b
  elseif name == 'setr' then
    r[c + 1] = r[a + 1]
  elseif name == 'seti' then
    r[c + 1] = a
  elseif name == 'gtir' then
    r[c + 1] = (a > r[b + 1]) and 1 or 0
  elseif name == 'gtri' then
    r[c + 1] = (r[a + 1] > b) and 1 or 0
  elseif name == 'gtrr' then
    r[c + 1] = (r[a + 1] > r[b + 1]) and 1 or 0
  elseif name == 'eqir' then
    r[c + 1] = (a == r[b + 1]) and 1 or 0
  elseif name == 'eqri' then
    r[c + 1] = (r[a + 1] == b) and 1 or 0
  elseif name == 'eqrr' then
    r[c + 1] = (r[a + 1] == r[b + 1]) and 1 or 0
  end
  return r
end

local function regs_equal(a, b)
  for i = 1, 4 do
    if (a[i] or 0) ~= (b[i] or 0) then
      return false
    end
  end
  return true
end

local function parse_regs(s)
  local t = {}
  for x in s:gmatch('%-?%d+') do
    t[#t + 1] = tonumber(x)
  end
  return t
end

local function day16(path)
  local lines = readLines(path)
  local samples = {}
  local program = {}
  local i = 1
  while i <= #lines do
    local ln = lines[i]
    if ln == '' then
      i = i + 1
    elseif ln:match('^Before') then
      local before = parse_regs(ln)
      i = i + 1
      local op_line = lines[i] or ''
      i = i + 1
      local op = {}
      for x in op_line:gmatch('%S+') do
        op[#op + 1] = tonumber(x)
      end
      local after_ln = lines[i] or ''
      i = i + 1
      local after = parse_regs(after_ln)
      samples[#samples + 1] = { before = before, op = op, after = after }
    else
      local op = {}
      for x in ln:gmatch('%S+') do
        op[#op + 1] = tonumber(x)
      end
      if #op == 4 then
        program[#program + 1] = op
      end
      i = i + 1
    end
  end

  local part1 = 0
  for si = 1, #samples do
    local s = samples[si]
    local a, b, c = s.op[2], s.op[3], s.op[4]
    local before = { s.before[1], s.before[2], s.before[3], s.before[4] }
    local match = 0
    for oi = 1, 16 do
      local out = apply_op(op_names[oi], before, a, b, c)
      local after = { s.after[1], s.after[2], s.after[3], s.after[4] }
      if regs_equal(out, after) then
        match = match + 1
      end
    end
    if match >= 3 then
      part1 = part1 + 1
    end
  end

  local candidates = {}
  for code = 0, 15 do
    candidates[code] = {}
    for oi = 1, 16 do
      candidates[code][oi] = true
    end
  end

  for si = 1, #samples do
    local s = samples[si]
    local code = s.op[1]
    local a, b, c = s.op[2], s.op[3], s.op[4]
    local before = { s.before[1], s.before[2], s.before[3], s.before[4] }
    local after = { s.after[1], s.after[2], s.after[3], s.after[4] }
    for oi = 1, 16 do
      local out = apply_op(op_names[oi], before, a, b, c)
      if not regs_equal(out, after) then
        candidates[code][oi] = false
      end
    end
  end

  local opcode_to_op = {}
  local function propagate()
    local changed = false
    for code = 0, 15 do
      if opcode_to_op[code] == nil then
        local opts = {}
        for oi = 1, 16 do
          if candidates[code][oi] then
            local taken = false
            for oc = 0, 15 do
              if opcode_to_op[oc] == oi then
                taken = true
                break
              end
            end
            if not taken then
              opts[#opts + 1] = oi
            end
          end
        end
        if #opts == 1 then
          opcode_to_op[code] = opts[1]
          changed = true
        end
      end
    end
    return changed
  end
  for _ = 1, 100 do
    if not propagate() then
      break
    end
  end

  local regs = { 0, 0, 0, 0 }
  for pi = 1, #program do
    local ins = program[pi]
    local code = ins[1]
    local oi = opcode_to_op[code]
    local name = op_names[oi]
    regs = apply_op(name, regs, ins[2], ins[3], ins[4])
  end

  local part2 = regs[1]

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day16(path)
end
