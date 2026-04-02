return function(path)
  local lines = readLines(path)

  local function parse_line(line)
    local tok = {}
    for t in line:gmatch('%S+') do
      tok[#tok + 1] = t
    end
    local raw_ind = string.sub(tok[1], 2, -2)
    local raw_jolt = string.sub(tok[#tok], 2, -2)
    local ind = {}
    for i = 1, #raw_ind do
      if string.sub(raw_ind, i, i) == '#' then
        ind[#ind + 1] = i - 1
      end
    end
    local buttons = {}
    for ti = 2, #tok - 1 do
      local inner = string.sub(tok[ti], 2, -2)
      local btn = {}
      if inner ~= '' then
        for n in inner:gmatch('%d+') do
          btn[#btn + 1] = tonumber(n)
        end
      end
      buttons[#buttons + 1] = btn
    end
    local jolt = {}
    for n in raw_jolt:gmatch('%d+') do
      jolt[#jolt + 1] = tonumber(n)
    end
    return ind, buttons, jolt
  end

  local function xor_mask(mask, btn)
    for i = 1, #btn do
      local idx = btn[i]
      mask = mask ~ (1 << idx)
    end
    return mask
  end

  local function mask_from_set(ind_list)
    local m = 0
    for i = 1, #ind_list do
      m = m | (1 << ind_list[i])
    end
    return m
  end

  local function combinations(n, k)
    if k == 0 then
      return {{}}
    end
    if k > n then
      return {}
    end
    local out = {}
    local chosen = {}
    local function rec(start)
      if #chosen == k then
        local c = {}
        for i = 1, #chosen do
          c[i] = chosen[i]
        end
        out[#out + 1] = c
        return
      end
      for i = start, n do
        chosen[#chosen + 1] = i
        rec(i + 1)
        chosen[#chosen] = nil
      end
    end
    rec(1)
    return out
  end

  local function valid_patterns(buttons)
    local patterns = {}
    for np = 0, #buttons do
      local combs = combinations(#buttons, np)
      for ci = 1, #combs do
        local comb = combs[ci]
        local mask = 0
        for j = 1, #comb do
          mask = xor_mask(mask, buttons[comb[j]])
        end
        if not patterns[mask] then
          patterns[mask] = {}
        end
        local seq = {}
        for j = 1, #comb do
          seq[j] = buttons[comb[j]]
        end
        table.insert(patterns[mask], seq)
      end
    end
    return patterns
  end

  local function min_indicator_presses(ind_list, patterns)
    local target = mask_from_set(ind_list)
    local plist = patterns[target]
    if not plist then
      return nil
    end
    local best = nil
    for i = 1, #plist do
      local ln = #plist[i]
      if best == nil or ln < best then
        best = ln
      end
    end
    return best
  end

  local function tuple_key(t)
    local s = {}
    for i = 1, #t do
      s[i] = tostring(t[i])
    end
    return table.concat(s, ',')
  end

  local function configure_joltages(joltages, patterns)
    local memo = {}

    local function min_presses(target)
      local key = tuple_key(target)
      if memo[key] ~= nil then
        return memo[key]
      end
      local any = false
      for i = 1, #target do
        if target[i] ~= 0 then
          any = true
          break
        end
      end
      if not any then
        memo[key] = 0
        return 0
      end
      local odd_mask = 0
      for i = 1, #target do
        if target[i] % 2 == 1 then
          odd_mask = odd_mask | (1 << (i - 1))
        end
      end
      local plist = patterns[odd_mask]
      if not plist then
        memo[key] = false
        return false
      end
      local best = false
      for pi = 1, #plist do
        local presses = plist[pi]
        local after = {}
        for i = 1, #target do
          after[i] = target[i]
        end
        for _, btn in ipairs(presses) do
          for _, ji in ipairs(btn) do
            after[ji + 1] = after[ji + 1] - 1
          end
        end
        local neg = false
        for i = 1, #after do
          if after[i] < 0 then
            neg = true
            break
          end
        end
        if not neg then
          local half = {}
          for i = 1, #after do
            half[i] = after[i] // 2
          end
          local sub = min_presses(half)
          if sub ~= false then
            local total = #presses + 2 * sub
            if best == false or total < best then
              best = total
            end
          end
        end
      end
      memo[key] = best
      return best
    end

    return min_presses(joltages)
  end

  local part1, part2 = 0, 0
  for li = 1, #lines do
    local ind, buttons, jolt = parse_line(lines[li])
    local patterns = valid_patterns(buttons)
    part1 = part1 + min_indicator_presses(ind, patterns)
    local j2 = configure_joltages(jolt, patterns)
    part2 = part2 + j2
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
