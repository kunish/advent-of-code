local function parse(lines)
  local ins = {}
  for _, line in ipairs(lines) do
    local op = line:match('^(%a+)')
    if op == 'cpy' then
      local a, b = line:match('^cpy (%S+) (%S+)$')
      ins[#ins + 1] = { 'cpy', a, b }
    elseif op == 'inc' then
      local r = line:match('^inc (%S+)$')
      ins[#ins + 1] = { 'inc', r }
    elseif op == 'dec' then
      local r = line:match('^dec (%S+)$')
      ins[#ins + 1] = { 'dec', r }
    elseif op == 'jnz' then
      local a, b = line:match('^jnz (%S+) (%S+)$')
      ins[#ins + 1] = { 'jnz', a, b }
    end
  end
  return ins
end

local function run(ins, c0)
  local regs = { a = 0, b = 0, c = c0, d = 0 }
  local function val(x)
    local n = tonumber(x)
    if n then
      return n
    end
    return regs[x] or 0
  end
  local ip = 1
  while ip >= 1 and ip <= #ins do
    local cur = ins[ip]
    local op = cur[1]
    if op == 'cpy' then
      regs[cur[3]] = val(cur[2])
      ip = ip + 1
    elseif op == 'inc' then
      local r = cur[2]
      regs[r] = (regs[r] or 0) + 1
      ip = ip + 1
    elseif op == 'dec' then
      local r = cur[2]
      regs[r] = (regs[r] or 0) - 1
      ip = ip + 1
    elseif op == 'jnz' then
      if val(cur[2]) ~= 0 then
        ip = ip + val(cur[3])
      else
        ip = ip + 1
      end
    end
  end
  return regs.a
end

local function day12(path)
  local lines = readLines(path)
  local ins = parse(lines)
  local p1 = run(ins, 0)
  local p2 = run(ins, 1)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day12(path)
end
