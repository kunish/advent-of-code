return function(path)
  local lines = readLines(path)
  local map = lines[1] or ''

  local files = {}
  local free_list = {}
  local fid = 0
  local pos = 0
  for i = 1, #map do
    local len = tonumber(map:sub(i, i))
    local is_file = (i % 2) == 1
    if is_file then
      files[#files + 1] = { id = fid, start = pos, len = len }
      fid = fid + 1
    else
      free_list[#free_list + 1] = { start = pos, len = len }
    end
    pos = pos + len
  end

  -- Part 1
  local blocks = {}
  local bp = 0
  for i = 1, #map do
    local len = tonumber(map:sub(i, i))
    local is_file = (i % 2) == 1
    if is_file then
      local id = (i - 1) / 2
      for _ = 1, len do
        bp = bp + 1
        blocks[bp] = id
      end
    else
      for _ = 1, len do
        bp = bp + 1
        blocks[bp] = -1
      end
    end
  end

  local right = bp
  local left = 1
  while left < right do
    if blocks[left] ~= -1 then
      left = left + 1
    elseif blocks[right] == -1 then
      right = right - 1
    else
      blocks[left] = blocks[right]
      blocks[right] = -1
      left = left + 1
      right = right - 1
    end
  end

  local part1 = 0
  for i = 1, bp do
    if blocks[i] ~= -1 then
      part1 = part1 + (i - 1) * blocks[i]
    end
  end

  -- Part 2
  local free2 = {}
  for _, f in ipairs(free_list) do
    free2[#free2 + 1] = { start = f.start, len = f.len }
  end

  local function merge_free()
    table.sort(free2, function(a, b)
      return a.start < b.start
    end)
    local k = 1
    while k < #free2 do
      local a, b = free2[k], free2[k + 1]
      if a.start + a.len == b.start then
        a.len = a.len + b.len
        table.remove(free2, k + 1)
      else
        k = k + 1
      end
    end
  end

  merge_free()

  for fi = #files, 1, -1 do
    local f = files[fi]
    local best_j, best_start
    for j = 1, #free2 do
      local sp = free2[j]
      if sp.len >= f.len and sp.start < f.start then
        if not best_start or sp.start < best_start then
          best_start = sp.start
          best_j = j
        end
      end
    end
    if best_j then
      local sp = free2[best_j]
      local ns = sp.start
      if sp.len == f.len then
        table.remove(free2, best_j)
      else
        sp.start = sp.start + f.len
        sp.len = sp.len - f.len
      end
      free2[#free2 + 1] = { start = f.start, len = f.len }
      f.start = ns
      merge_free()
    end
  end

  local part2 = 0
  for _, f in ipairs(files) do
    for k = 0, f.len - 1 do
      part2 = part2 + (f.start + k) * f.id
    end
  end

  print('Part 1: ' .. string.format('%.0f', part1))
  print('Part 2: ' .. string.format('%.0f', part2))
end
