local function day1(path)
  local lines = readLines(path)
  local s = lines[1] or ''
  local floor = 0
  local basement_pos = nil
  for i = 1, #s do
    local c = s:sub(i, i)
    if c == '(' then
      floor = floor + 1
    elseif c == ')' then
      floor = floor - 1
    end
    if basement_pos == nil and floor == -1 then
      basement_pos = i
    end
  end
  print(string.format('Part 1: %d', floor))
  print(string.format('Part 2: %d', basement_pos or 0))
end

return function(path)
  return day1(path)
end
