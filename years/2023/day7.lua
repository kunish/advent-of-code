local ORDER1 = { A = 14, K = 13, Q = 12, J = 11, T = 10 }
local ORDER2 = { A = 14, K = 13, Q = 12, J = 1, T = 10 }

local function card_rank(c, part2)
  local o = part2 and ORDER2 or ORDER1
  if o[c] then
    return o[c]
  end
  return tonumber(c)
end

local function hand_type(counts, jokers)
  local t = {}
  for k, v in pairs(counts) do
    if k ~= 'J' or jokers == 0 then
      t[#t + 1] = v
    end
  end
  table.sort(t, function(a, b)
    return a > b
  end)
  local j = jokers or 0
  if j > 0 then
    if #t == 0 then
      t[1] = j
    else
      t[1] = t[1] + j
    end
    table.sort(t, function(a, b)
      return a > b
    end)
  end
  local a, b, c, d, e = t[1] or 0, t[2] or 0, t[3] or 0, t[4] or 0, t[5] or 0
  if a == 5 then
    return 7
  end
  if a == 4 then
    return 6
  end
  if a == 3 and b == 2 then
    return 5
  end
  if a == 3 then
    return 4
  end
  if a == 2 and b == 2 then
    return 3
  end
  if a == 2 then
    return 2
  end
  return 1
end

local function count_cards(hand, part2)
  local c = {}
  local jokers = 0
  for i = 1, #hand do
    local ch = hand:sub(i, i)
    if part2 and ch == 'J' then
      jokers = jokers + 1
    else
      c[ch] = (c[ch] or 0) + 1
    end
  end
  return c, jokers
end

local function cmp_hand(a, b, part2)
  if a.type ~= b.type then
    return a.type < b.type
  end
  for i = 1, 5 do
    local ra = card_rank(a.hand:sub(i, i), part2)
    local rb = card_rank(b.hand:sub(i, i), part2)
    if ra ~= rb then
      return ra < rb
    end
  end
  return false
end

local function score(path, part2)
  local lines = readLines(path)
  local hands = {}
  for i = 1, #lines do
    local hand, bid = lines[i]:match('(%S+)%s+(%d+)')
    local counts, jokers = count_cards(hand, part2)
    local typ = hand_type(counts, jokers)
    hands[#hands + 1] = { hand = hand, bid = tonumber(bid), type = typ }
  end
  table.sort(hands, function(a, b)
    return cmp_hand(a, b, part2)
  end)
  local total = 0
  for i = 1, #hands do
    total = total + i * hands[i].bid
  end
  return total
end

local function day7(path)
  print(string.format('Part 1: %d', score(path, false)))
  print(string.format('Part 2: %d', score(path, true)))
end

return function(p)
  return day7(p)
end
