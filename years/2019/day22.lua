local M = 119315717514047
local ROUNDS = 101741582076661

local function modmul(a, b)
  a = a % M
  b = b % M
  if a < 0 then a = a + M end
  if b < 0 then b = b + M end
  local result = 0
  while b > 0 do
    if b % 2 == 1 then
      result = (result + a) % M
    end
    a = (a + a) % M
    b = math.floor(b / 2)
  end
  return result
end

local function modpow(base, exp)
  local result = 1
  base = base % M
  if base < 0 then base = base + M end
  while exp > 0 do
    if exp % 2 == 1 then
      result = modmul(result, base)
    end
    base = modmul(base, base)
    exp = math.floor(exp / 2)
  end
  return result
end

local function modinv(a)
  return modpow(a, M - 2)
end

--- Compose: apply g then f to position: f(g(x))
local function compose(fa, fb, ga, gb)
  local na = modmul(fa, ga)
  local nb = (modmul(fa, gb) + fb) % M
  return na, nb
end

local function inv_new_stack(a, b)
  -- pos' = -pos + (M-1); inverse is the same map
  return compose(M - 1, M - 1, a, b)
end

local function inv_cut(n, a, b)
  return compose(1, (n % M + M) % M, a, b)
end

local function inv_deal_inc(k, a, b)
  local ik = modinv(k)
  return compose(ik, 0, a, b)
end

local function pow_compose(a, b, e)
  local ca, cb = 1 % M, 0
  local pa, pb = a % M, b % M
  local n = e
  while n > 0 do
    if n % 2 == 1 then
      ca, cb = compose(pa, pb, ca, cb)
    end
    pa, pb = compose(pa, pb, pa, pb)
    n = math.floor(n / 2)
  end
  return ca, cb
end

local function day22(path)
  local lines = readLines(path)
  local ops = {}
  for i = 1, #lines do
    local line = lines[i]
    local inc = line:match('deal with increment (%-?%d+)')
    local cut = line:match('cut (%-?%d+)')
    if line:match('deal into new stack') then
      ops[#ops + 1] = { 'stack' }
    elseif inc then
      ops[#ops + 1] = { 'inc', tonumber(inc) }
    elseif cut then
      ops[#ops + 1] = { 'cut', tonumber(cut) }
    end
  end

  -- Part 1: small deck 10007, forward
  local m1 = 10007
  local p1 = 2019
  for i = 1, #ops do
    local op = ops[i]
    if op[1] == 'stack' then
      p1 = (m1 - 1 - p1) % m1
    elseif op[1] == 'cut' then
      p1 = (p1 - op[2]) % m1
    else
      p1 = (op[2] * p1) % m1
    end
  end

  -- Part 2: inverse shuffle on position 2020
  local a, b = 1, 0
  for i = #ops, 1, -1 do
    local op = ops[i]
    if op[1] == 'stack' then
      a, b = inv_new_stack(a, b)
    elseif op[1] == 'cut' then
      a, b = inv_cut(op[2], a, b)
    else
      a, b = inv_deal_inc(op[2], a, b)
    end
  end
  local aK, bK = pow_compose(a, b, ROUNDS)
  local p2 = (modmul(aK, 2020) + bK) % M

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day22(p)
end
