return function(path)
  local lines = readLines(path)
  local ranges_line = lines[1]

  local function iter_ids()
    local pos = 1
    return function()
      local a, b = ranges_line:find('[^,]+', pos)
      if not a then
        return nil
      end
      pos = b + 2
      local seg = ranges_line:sub(a, b)
      local dash = seg:find('-', 1, true)
      local lo = tonumber(seg:sub(1, dash - 1))
      local hi = tonumber(seg:sub(dash + 1))
      return lo, hi
    end
  end

  local function is_concat_twice(s)
    local n = #s
    if n % 2 ~= 0 then
      return false
    end
    local h = n // 2
    return s:sub(1, h) == s:sub(h + 1, n)
  end

  local function is_concat_k_times(s)
    local n = #s
    for p = 1, n - 1 do
      if n % p == 0 then
        local k = n // p
        if k >= 2 then
          local pat = s:sub(1, p)
          local ok = true
          for j = 1, k - 1 do
            if s:sub(j * p + 1, (j + 1) * p) ~= pat then
              ok = false
              break
            end
          end
          if ok then
            return true
          end
        end
      end
    end
    return false
  end

  local part1, part2 = 0, 0
  for lo, hi in iter_ids() do
    for n = lo, hi do
      local s = tostring(n)
      if is_concat_twice(s) then
        part1 = part1 + n
      end
      if is_concat_k_times(s) then
        part2 = part2 + n
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
