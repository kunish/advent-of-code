return function(path)
  local lines = readLines(path)
  local h = #lines
  local w = #lines[1]
  local rolls = {}
  for r = 1, h do
    local row = lines[r]
    for c = 1, w do
      if string.sub(row, c, c) == '@' then
        rolls[r .. ',' .. c] = true
      end
    end
  end

  local function is_accessible(rc)
    local r, c = rc:match('^(%d+),(%d+)$')
    r, c = tonumber(r), tonumber(c)
    local n = 0
    for dr = -1, 1 do
      for dc = -1, 1 do
        if dr ~= 0 or dc ~= 0 then
          local k = (r + dr) .. ',' .. (c + dc)
          if rolls[k] then
            n = n + 1
          end
        end
      end
    end
    return n < 4
  end

  local part1 = 0
  for k in pairs(rolls) do
    if is_accessible(k) then
      part1 = part1 + 1
    end
  end

  local part2 = 0
  while true do
    local rem = {}
    for k in pairs(rolls) do
      if is_accessible(k) then
        rem[#rem + 1] = k
      end
    end
    if #rem == 0 then
      break
    end
    part2 = part2 + #rem
    for i = 1, #rem do
      rolls[rem[i]] = nil
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
