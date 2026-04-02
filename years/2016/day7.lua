local function has_abba(s)
  for i = 1, #s - 3 do
    local a, b, c, d = s:sub(i, i), s:sub(i + 1, i + 1), s:sub(i + 2, i + 2), s:sub(i + 3, i + 3)
    if a == d and b == c and a ~= b then
      return true
    end
  end
  return false
end

local function collect_aba(s, out)
  for i = 1, #s - 2 do
    local a, b, c = s:sub(i, i), s:sub(i + 1, i + 1), s:sub(i + 2, i + 2)
    if a == c and a ~= b then
      out[a .. b] = true
    end
  end
end

local function split_ip(line)
  local outs, ins = {}, {}
  local rest = line
  while true do
    local ob, oe = rest:find('%[')
    if not ob then
      outs[#outs + 1] = rest
      break
    end
    outs[#outs + 1] = rest:sub(1, ob - 1)
    rest = rest:sub(oe + 1)
    local cb, ce = rest:find('%]')
    if not cb then
      break
    end
    ins[#ins + 1] = rest:sub(1, cb - 1)
    rest = rest:sub(ce + 1)
  end
  return outs, ins
end

local function day7(path)
  local lines = readLines(path)
  local part1, part2 = 0, 0
  for _, line in ipairs(lines) do
    local outs, ins = split_ip(line)

    local outside_abba = false
    for _, s in ipairs(outs) do
      if has_abba(s) then
        outside_abba = true
        break
      end
    end
    local inside_abba = false
    for _, s in ipairs(ins) do
      if has_abba(s) then
        inside_abba = true
        break
      end
    end
    if outside_abba and not inside_abba then
      part1 = part1 + 1
    end

    local abas = {}
    for _, s in ipairs(outs) do
      collect_aba(s, abas)
    end
    local ssl = false
    for pair in pairs(abas) do
      local a, b = pair:sub(1, 1), pair:sub(2, 2)
      local bab = b .. a .. b
      for _, h in ipairs(ins) do
        if h:find(bab, 1, true) then
          ssl = true
          break
        end
      end
      if ssl then
        break
      end
    end
    if ssl then
      part2 = part2 + 1
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day7(path)
end
