local function day6(path)
  local lines = readLines(path)
  if #lines == 0 then
    print('Part 1: ')
    print('Part 2: ')
    return
  end
  local w = #lines[1]
  local cols = {}
  for c = 1, w do
    cols[c] = {}
  end
  for _, line in ipairs(lines) do
    for c = 1, w do
      local ch = line:sub(c, c)
      cols[c][ch] = (cols[c][ch] or 0) + 1
    end
  end

  local function best(col, most)
    local bestch, bestn = nil, most and -1 or math.huge
    for ch, n in pairs(col) do
      if most then
        if n > bestn or (n == bestn and (bestch == nil or ch < bestch)) then
          bestch, bestn = ch, n
        end
      else
        if n < bestn or (n == bestn and (bestch == nil or ch < bestch)) then
          bestch, bestn = ch, n
        end
      end
    end
    return bestch
  end

  local p1, p2 = {}, {}
  for c = 1, w do
    p1[c] = best(cols[c], true)
    p2[c] = best(cols[c], false)
  end

  print(string.format('Part 1: %s', table.concat(p1)))
  print(string.format('Part 2: %s', table.concat(p2)))
end

return function(path)
  return day6(path)
end
