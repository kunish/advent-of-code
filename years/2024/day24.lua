return function(path)
  local lines = readLines(path)
  local init = {}
  local gates = {}

  for _, line in ipairs(lines) do
    if line:match(':') and not line:match('%-') then
      local w, v = line:match('(%w+):%s*(%d)')
      if w then
        init[w] = (v == '1')
      end
    elseif line:match('%-') then
      local a, op, b, out = line:match('(%w+)%s+(%w+)%s+(%w+)%s+%-%>%s+(%w+)')
      if out then
        gates[out] = { op = op, a = a, b = b }
      end
    end
  end

  local memo = {}
  local function eval(w)
    if memo[w] ~= nil then
      return memo[w]
    end
    local v = init[w]
    if v ~= nil then
      memo[w] = v
      return v
    end
    local g = gates[w]
    local va, vb = eval(g.a), eval(g.b)
    local r
    if g.op == 'AND' then
      r = va and vb
    elseif g.op == 'OR' then
      r = va or vb
    else
      r = va ~= vb
    end
    memo[w] = r
    return r
  end

  local function z_value()
    local zs = {}
    for w, _ in pairs(gates) do
      local zi = w:match('^z(%d+)$')
      if zi then
        zs[#zs + 1] = { tonumber(zi), w }
      end
    end
    table.sort(zs, function(x, y)
      return x[1] < y[1]
    end)
    local n = 0
    for i = #zs, 1, -1 do
      n = n * 2
      if eval(zs[i][2]) then
        n = n + 1
      end
    end
    return n
  end

  memo = {}
  print(string.format('Part 1: %.0f', z_value()))

  local function find_op(op, i1, i2)
    if not i1 or not i2 then
      return nil
    end
    for out, g in pairs(gates) do
      if g.op == op and ((g.a == i1 and g.b == i2) or (g.a == i2 and g.b == i1)) then
        return out
      end
    end
    return nil
  end

  local bits = 0
  for w, _ in pairs(init) do
    if w:match('^x%d+$') then
      bits = bits + 1
    end
  end

  local swaps = {}
  local carry = nil

  for bit = 0, bits - 1 do
    local xi = string.format('x%02d', bit)
    local yi = string.format('y%02d', bit)
    local adder = find_op('XOR', xi, yi)
    local nxt = find_op('AND', xi, yi)
    local output = nil
    local next_carry = nil

    if carry then
      local result = find_op('AND', adder, carry)
      if not result then
        swaps[#swaps + 1] = { adder, nxt }
        adder, nxt = nxt, adder
        result = find_op('AND', adder, carry)
      end

      output = find_op('XOR', adder, carry)

      local function fix_z(wa, wb)
        if not wa or not wb then
          return wa, wb
        end
        if wa:sub(1, 1) == 'z' then
          swaps[#swaps + 1] = { wa, wb }
          return wb, wa
        end
        return wa, wb
      end

      if output then
        adder, output = fix_z(adder, output)
        nxt, output = fix_z(nxt, output)
        if result then
          result, output = fix_z(result, output)
        end
      end

      if nxt and result then
        next_carry = find_op('OR', nxt, result)
      end
    end

    if bit ~= bits - 1 and next_carry and next_carry:sub(1, 1) == 'z' and output then
      swaps[#swaps + 1] = { next_carry, output }
      next_carry, output = output, next_carry
    end

    if carry then
      carry = next_carry
    else
      carry = nxt
    end
  end

  local names = {}
  for _, p in ipairs(swaps) do
    names[#names + 1] = p[1]
    names[#names + 1] = p[2]
  end
  table.sort(names)
  print(string.format('Part 2: %s', table.concat(names, ',')))
end
