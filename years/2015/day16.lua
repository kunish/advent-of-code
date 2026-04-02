local function parse_sue(line)
  local num, rest = line:match('^Sue (%d+): (.+)$')
  if not num then
    return nil
  end
  local props = {}
  for segment in rest:gmatch('([^,]+)') do
    local trimmed = segment:match('^%s*(.-)%s*$')
    local k, v = trimmed:match('^(%a+): (%d+)$')
    if k then
      props[k] = tonumber(v)
    end
  end
  return tonumber(num), props
end

local function day16(path)
  local lines = readLines(path)
  local target = {
    children = 3,
    cats = 7,
    samoyeds = 2,
    pomeranians = 3,
    akitas = 0,
    vizslas = 0,
    goldfish = 5,
    trees = 3,
    cars = 2,
    perfumes = 1,
  }

  local function matches1(props)
    for k, v in pairs(props) do
      if target[k] ~= v then
        return false
      end
    end
    return true
  end

  local function matches2(props)
    for k, v in pairs(props) do
      local t = target[k]
      if k == 'cats' or k == 'trees' then
        if not (v > t) then
          return false
        end
      elseif k == 'pomeranians' or k == 'goldfish' then
        if not (v < t) then
          return false
        end
      else
        if v ~= t then
          return false
        end
      end
    end
    return true
  end

  local part1, part2
  for _, line in ipairs(lines) do
    local n, props = parse_sue(line)
    if n and matches1(props) then
      part1 = n
    end
    if n and matches2(props) then
      part2 = n
    end
  end

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %s', part2))
end

return function(p)
  return day16(p)
end
