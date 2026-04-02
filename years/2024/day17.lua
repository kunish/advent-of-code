return function(path)
  local lines = readLines(path)
  local A = tonumber(lines[1]:match('Register A: (%d+)'))
  local B = tonumber(lines[2]:match('Register B: (%d+)'))
  local C = tonumber(lines[3]:match('Register C: (%d+)'))
  local prog = {}
  local pline
  for _, line in ipairs(lines) do
    if line:match('^Program:') then
      pline = line
      break
    end
  end
  for n in pline:gmatch('%d+') do
    prog[#prog + 1] = tonumber(n)
  end

  local function combo(op, a, b, c)
    if op <= 3 then
      return op
    elseif op == 4 then
      return a
    elseif op == 5 then
      return b
    elseif op == 6 then
      return c
    end
    return 0
  end

  local function run(init_a)
    local a, b, c = init_a, B, C
    local ip = 1
    local out = {}
    while ip <= #prog do
      local opc = prog[ip]
      local op = prog[ip + 1]
      ip = ip + 2
      if opc == 0 then
        a = math.floor(a / (2 ^ combo(op, a, b, c)))
      elseif opc == 1 then
        b = b ~ op
      elseif opc == 2 then
        b = combo(op, a, b, c) % 8
      elseif opc == 3 then
        if a ~= 0 then
          ip = op + 1
        end
      elseif opc == 4 then
        b = b ~ c
      elseif opc == 5 then
        out[#out + 1] = combo(op, a, b, c) % 8
      elseif opc == 6 then
        b = math.floor(a / (2 ^ combo(op, a, b, c)))
      elseif opc == 7 then
        c = math.floor(a / (2 ^ combo(op, a, b, c)))
      end
    end
    return out
  end

  local p1 = run(A)
  local s1 = table.concat(p1, ',')
  print(string.format('Part 1: %s', s1))

  local function find_a()
    local candidates = { 0 }
    for t = #prog, 1, -1 do
      local nxt = {}
      for ci = 1, #candidates do
        local a = candidates[ci]
        for d = 0, 7 do
          local na = a * 8 + d
          local out = run(na)
          if #out > 0 and out[1] == prog[t] then
            nxt[#nxt + 1] = na
          end
        end
      end
      candidates = nxt
    end
    local mn = candidates[1]
    for i = 2, #candidates do
      if candidates[i] < mn then
        mn = candidates[i]
      end
    end
    return mn
  end

  local p2 = find_a()
  print(string.format('Part 2: %d', p2 or 0))
end
