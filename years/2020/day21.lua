return function(path)
  local lines = readLines(path)
  local foods = {}
  local fi = 1
  while fi <= #lines do
    local line = lines[fi]
    if line ~= '' then
      local ing = {}
      local al = {}
      local in_paren = string.match(line, '%((.-)%)')
      local before = string.match(line, '^(.-)%s*%(')
      if before then
        for w in string.gmatch(before, '(%S+)') do
          ing[#ing + 1] = w
        end
      end
      if in_paren then
        for w in string.gmatch(in_paren, '(%w+)') do
          al[#al + 1] = w
        end
      end
      foods[#foods + 1] = { ing = ing, al = al }
    end
    fi = fi + 1
  end

  local allergen_candidates = {}
  local ai = 1
  while ai <= #foods do
    local f = foods[ai]
    local j = 1
    while j <= #f.al do
      local a = f.al[j]
      if not allergen_candidates[a] then
        local copy = {}
        local k = 1
        while k <= #f.ing do
          copy[f.ing[k]] = true
          k = k + 1
        end
        allergen_candidates[a] = copy
      else
        local prev = allergen_candidates[a]
        local new = {}
        for ing, _ in pairs(prev) do
          local found = false
          local k = 1
          while k <= #f.ing and not found do
            if f.ing[k] == ing then
              found = true
            end
            k = k + 1
          end
          if found then
            new[ing] = true
          end
        end
        allergen_candidates[a] = new
      end
      j = j + 1
    end
    ai = ai + 1
  end

  local assigned = {}
  local changed = true
  while changed do
    changed = false
    for a, cand in pairs(allergen_candidates) do
      if not assigned[a] then
        local cnt = 0
        local only = nil
        for ing, _ in pairs(cand) do
          cnt = cnt + 1
          only = ing
        end
        if cnt == 1 then
          assigned[a] = only
          changed = true
          for a2, c2 in pairs(allergen_candidates) do
            if a2 ~= a then
              c2[only] = nil
            end
          end
        end
      end
    end
  end

  local dangerous = {}
  for a, ing in pairs(assigned) do
    dangerous[#dangerous + 1] = { a = a, ing = ing }
  end
  table.sort(dangerous, function(x, y)
    return x.a < y.a
  end)

  local dangerous_set = {}
  local di = 1
  while di <= #dangerous do
    dangerous_set[dangerous[di].ing] = true
    di = di + 1
  end

  local part1 = 0
  local i = 1
  while i <= #foods do
    local f = foods[i]
    local j = 1
    while j <= #f.ing do
      local ing = f.ing[j]
      if not dangerous_set[ing] then
        part1 = part1 + 1
      end
      j = j + 1
    end
    i = i + 1
  end

  local parts = {}
  local pi = 1
  while pi <= #dangerous do
    parts[pi] = dangerous[pi].ing
    pi = pi + 1
  end
  local part2 = table.concat(parts, ',')

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %s', part2))
end
