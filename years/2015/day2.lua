local function day2(path)
  local lines = readLines(path)
  local paper = 0
  local ribbon = 0
  for _, line in ipairs(lines) do
    local l, w, h = line:match('^(%d+)x(%d+)x(%d+)')
    if l then
      l, w, h = tonumber(l), tonumber(w), tonumber(h)
      local a1, a2, a3 = l * w, w * h, h * l
      paper = paper + 2 * a1 + 2 * a2 + 2 * a3 + math.min(a1, a2, a3)
      local p1, p2, p3 = 2 * (l + w), 2 * (w + h), 2 * (h + l)
      ribbon = ribbon + math.min(p1, p2, p3) + l * w * h
    end
  end
  print(string.format('Part 1: %d', paper))
  print(string.format('Part 2: %d', ribbon))
end

return function(path)
  return day2(path)
end
