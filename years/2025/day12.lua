return function(path)
  local f = assert(io.open(path, 'r'))
  local s = f:read('*a')
  f:close()

  local shape_tiles = {}
  for id = 0, 5 do
    local pat = id .. ':\n'
    local a = s:find(pat, 1, true)
    if not a then
      error('shape ' .. id)
    end
    local start = a + #pat
    local grid = s:sub(start, start + 500)
    local lines_block = {}
    for line in grid:gmatch('[^\n]+') do
      lines_block[#lines_block + 1] = line
      if #lines_block == 3 then
        break
      end
    end
    local h = 0
    for li = 1, #lines_block do
      for j = 1, #lines_block[li] do
        if string.sub(lines_block[li], j, j) == '#' then
          h = h + 1
        end
      end
    end
    shape_tiles[id + 1] = h
  end

  local part1 = 0
  for wa, hb, rest in s:gmatch('(%d+)x(%d+):%s*([^\n]+)') do
    local w, h = tonumber(wa), tonumber(hb)
    local q = {}
    for n in rest:gmatch('%d+') do
      q[#q + 1] = tonumber(n)
    end
    local sumq = 0
    for i = 1, #q do
      sumq = sumq + q[i]
    end
    local slots = (w // 3) * (h // 3)
    local tiles = 0
    for i = 1, #q do
      tiles = tiles + q[i] * shape_tiles[i]
    end
    local area = w * h
    if sumq <= slots then
      part1 = part1 + 1
    elseif tiles > area then
      -- cannot fit
    else
      part1 = part1 + 1
    end
  end

  print(string.format('Part 1: %d', part1))
end
