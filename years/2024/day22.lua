return function(path)
  local lines = readLines(path)

  local function step(s)
    s = ((s * 64) ~ s) % 16777216
    s = (math.floor(s / 32) ~ s) % 16777216
    s = ((s * 2048) ~ s) % 16777216
    return s
  end

  local p1 = 0
  for _, line in ipairs(lines) do
    local n = tonumber(line)
    if n then
      local s = n
      for _ = 1, 2000 do
        s = step(s)
      end
      p1 = p1 + s
    end
  end

  local total = {}
  for _, line in ipairs(lines) do
    local n = tonumber(line)
    if n then
      local s = n
      local digits = { [0] = n % 10 }
      local chg = {}
      for i = 1, 2000 do
        s = step(s)
        digits[i] = s % 10
        chg[i] = digits[i] - digits[i - 1]
      end
      local seen = {}
      for i = 4, 2000 do
        local key =
          string.format('%d,%d,%d,%d', chg[i - 3] + 9, chg[i - 2] + 9, chg[i - 1] + 9, chg[i] + 9)
        if not seen[key] then
          seen[key] = true
          total[key] = (total[key] or 0) + digits[i]
        end
      end
    end
  end

  local p2 = 0
  for _, v in pairs(total) do
    if v > p2 then
      p2 = v
    end
  end

  print(string.format('Part 1: %.0f', p1))
  print(string.format('Part 2: %.0f', p2))
end
