local function day4(path)
  local lines = readLines(path)

  local function real_room(name, checksum)
    local counts = {}
    for i = 1, #name do
      local c = name:sub(i, i)
      if c >= 'a' and c <= 'z' then
        counts[c] = (counts[c] or 0) + 1
      end
    end
    local letters = {}
    for c, n in pairs(counts) do
      letters[#letters + 1] = { c = c, n = n }
    end
    table.sort(letters, function(u, v)
      if u.n ~= v.n then
        return u.n > v.n
      end
      return u.c < v.c
    end)
    local top = {}
    for i = 1, math.min(5, #letters) do
      top[i] = letters[i].c
    end
    return table.concat(top) == checksum
  end

  local function decrypt(name, sector)
    local out = {}
    for i = 1, #name do
      local c = name:sub(i, i)
      if c == '-' then
        out[#out + 1] = ' '
      elseif c >= 'a' and c <= 'z' then
        local rot = sector % 26
        local o = ((c:byte() - string.byte('a') + rot) % 26) + string.byte('a')
        out[#out + 1] = string.char(o)
      end
    end
    return table.concat(out)
  end

  local part1 = 0
  local part2 = 0
  for _, line in ipairs(lines) do
    local enc, sector_s, chk = line:match('^(.+)-(%d+)%[(%a+)%]$')
    if enc and sector_s and chk then
      local sector = tonumber(sector_s)
      local name_for_count = enc:gsub('%-', '')
      if real_room(name_for_count, chk) then
        part1 = part1 + sector
        local plain = decrypt(enc, sector)
        if plain:find('northpole', 1, true) then
          part2 = sector
        end
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day4(path)
end
