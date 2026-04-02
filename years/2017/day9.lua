local function day9(path)
  local lines = readLines(path)
  local s = lines[1] or ''
  local i = 1
  local score = 0
  local depth = 0
  local garbage = 0

  while i <= #s do
    local c = s:sub(i, i)
    if c == '{' then
      depth = depth + 1
      score = score + depth
      i = i + 1
    elseif c == '}' then
      depth = depth - 1
      i = i + 1
    elseif c == '<' then
      i = i + 1
      while i <= #s do
        local g = s:sub(i, i)
        if g == '!' then
          i = i + 2
        elseif g == '>' then
          i = i + 1
          break
        else
          garbage = garbage + 1
          i = i + 1
        end
      end
    else
      i = i + 1
    end
  end

  print(string.format('Part 1: %d', score))
  print(string.format('Part 2: %d', garbage))
end

return function(path)
  return day9(path)
end
