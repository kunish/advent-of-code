local required = { byr = true, iyr = true, eyr = true, hgt = true, hcl = true, ecl = true, pid = true }

local function split_fields(block)
  local t = {}
  for token in block:gmatch('%S+') do
    local k, v = token:match('^([^:]+):(.+)$')
    if k then
      t[k] = v
    end
  end
  return t
end

local function has_required(f)
  for k in pairs(required) do
    if f[k] == nil then
      return false
    end
  end
  return true
end

local eye_colors = { amb = true, blu = true, brn = true, gry = true, grn = true, hzl = true, oth = true }

local function valid_field(k, v)
  if k == 'byr' then
    local y = tonumber(v)
    return y and y >= 1920 and y <= 2002
  elseif k == 'iyr' then
    local y = tonumber(v)
    return y and y >= 2010 and y <= 2020
  elseif k == 'eyr' then
    local y = tonumber(v)
    return y and y >= 2020 and y <= 2030
  elseif k == 'hgt' then
    local cms = v:match('^(%d+)cm$')
    if cms then
      local n = tonumber(cms)
      return n and n >= 150 and n <= 193
    end
    local ins = v:match('^(%d+)in$')
    if ins then
      local n = tonumber(ins)
      return n and n >= 59 and n <= 76
    end
    return false
  elseif k == 'hcl' then
    return v:match('^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$') ~= nil
  elseif k == 'ecl' then
    return eye_colors[v] == true
  elseif k == 'pid' then
    return #v == 9 and v:match('^%d%d%d%d%d%d%d%d%d$') ~= nil
  end
  return true
end

local function all_valid(f)
  if not has_required(f) then
    return false
  end
  for k in pairs(required) do
    if not valid_field(k, f[k]) then
      return false
    end
  end
  return true
end

return function(path)
  local raw = readLines(path)
  local blocks = {}
  local cur = {}
  local i = 1
  while i <= #raw do
    local line = raw[i]
    if line == '' then
      if #cur > 0 then
        blocks[#blocks + 1] = table.concat(cur, ' ')
        cur = {}
      end
    else
      cur[#cur + 1] = line
    end
    i = i + 1
  end
  if #cur > 0 then
    blocks[#blocks + 1] = table.concat(cur, ' ')
  end

  local part1, part2 = 0, 0
  local b = 1
  while b <= #blocks do
    local f = split_fields(blocks[b])
    if has_required(f) then
      part1 = part1 + 1
    end
    if all_valid(f) then
      part2 = part2 + 1
    end
    b = b + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
