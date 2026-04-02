return function(path)
  local lines = readLines(path)

  local function parse_mask(s)
    local mask_and = 0
    local mask_or = 0
    local j = 1
    while j <= #s do
      local ch = string.sub(s, j, j)
      mask_and = mask_and << 1
      mask_or = mask_or << 1
      if ch == '0' then
        -- and 0, or 0
      elseif ch == '1' then
        mask_and = mask_and | 1
        mask_or = mask_or | 1
      else
        mask_and = mask_and | 1
      end
      j = j + 1
    end
    return mask_and, mask_or
  end

  local function parse_mask_addr(s)
    local bits = {}
    local j = 1
    while j <= #s do
      bits[j] = string.sub(s, j, j)
      j = j + 1
    end
    return bits
  end

  local part1_mem = {}
  local mask_and = 0
  local mask_or = 0
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if string.sub(line, 1, 4) == 'mask' then
      local m = string.sub(line, 8)
      mask_and, mask_or = parse_mask(m)
    else
      local addr_s, val_s = string.match(line, 'mem%[(%d+)%] = (%d+)')
      local val = tonumber(val_s)
      val = (val & mask_and) | mask_or
      part1_mem[tonumber(addr_s)] = val
    end
    i = i + 1
  end

  local sum1 = 0
  for _, v in pairs(part1_mem) do
    sum1 = sum1 + v
  end

  local mem = {}
  local mask_bits = nil
  i = 1
  while i <= #lines do
    local line = lines[i]
    if string.sub(line, 1, 4) == 'mask' then
      mask_bits = parse_mask_addr(string.sub(line, 8))
    else
      local addr_s, val_s = string.match(line, 'mem%[(%d+)%] = (%d+)')
      local addr = tonumber(addr_s)
      local val = tonumber(val_s)
      local bits = {}
      local b = 1
      while b <= 36 do
        local bi = 36 - b
        bits[b] = (addr >> bi) & 1
        b = b + 1
      end

      local float = {}
      local j = 1
      while j <= 36 do
        local c = mask_bits[j]
        if c == '1' then
          bits[j] = 1
        elseif c == 'X' then
          float[#float + 1] = j
        end
        j = j + 1
      end

      local function emit(idx)
        if idx > #float then
          local a = 0
          local k = 1
          while k <= 36 do
            if bits[k] == 1 then
              local bi = 36 - k
              a = a | (1 << bi)
            end
            k = k + 1
          end
          mem[a] = val
          return
        end
        local pos = float[idx]
        bits[pos] = 0
        emit(idx + 1)
        bits[pos] = 1
        emit(idx + 1)
      end

      emit(1)
    end
    i = i + 1
  end

  local sum2 = 0
  for _, v in pairs(mem) do
    sum2 = sum2 + v
  end

  print(string.format('Part 1: %d', sum1))
  print(string.format('Part 2: %d', sum2))
end
