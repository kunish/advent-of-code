return function(path)
  local lines = readLines(path)
  local nodes = {}

  for i = 1, #lines do
    local line = lines[i]
    local name, rest = line:match('^(%a+): (.+)$')
    local num = tonumber(rest)
    if num then
      nodes[name] = { kind = 'num', val = num }
    else
      local a, op, b = rest:match('^(%a+) ([%+%-%*/]) (%a+)$')
      nodes[name] = { kind = 'op', op = op, a = a, b = b }
    end
  end

  local function idiv(a, b)
    local q = a // b
    if a % b ~= 0 and (a ~ b) < 0 then
      q = q + 1
    end
    return q
  end

  local function eval(name, humn)
    if name == 'humn' and humn ~= nil then
      return humn
    end
    local n = nodes[name]
    if n.kind == 'num' then
      return n.val
    end
    local va = eval(n.a, humn)
    local vb = eval(n.b, humn)
    if n.op == '+' then
      return va + vb
    elseif n.op == '-' then
      return va - vb
    elseif n.op == '*' then
      return va * vb
    else
      return idiv(va, vb)
    end
  end

  print(string.format('Part 1: %d', eval('root', nil)))

  local function has_humn(name)
    if name == 'humn' then return true end
    local n = nodes[name]
    if n.kind == 'num' then return false end
    return has_humn(n.a) or has_humn(n.b)
  end

  local rn = nodes['root']
  local target, humn_side
  if has_humn(rn.a) then
    target = eval(rn.b, nil)
    humn_side = rn.a
  else
    target = eval(rn.a, nil)
    humn_side = rn.b
  end

  local function solve(name, t)
    if name == 'humn' then return t end
    local n = nodes[name]
    if has_humn(n.a) then
      local bv = eval(n.b, nil)
      if n.op == '+' then return solve(n.a, t - bv)
      elseif n.op == '-' then return solve(n.a, t + bv)
      elseif n.op == '*' then return solve(n.a, t // bv)
      else return solve(n.a, t * bv) end
    else
      local av = eval(n.a, nil)
      if n.op == '+' then return solve(n.b, t - av)
      elseif n.op == '-' then return solve(n.b, av - t)
      elseif n.op == '*' then return solve(n.b, t // av)
      else return solve(n.b, av // t) end
    end
  end

  print(string.format('Part 2: %d', solve(humn_side, target)))
end
