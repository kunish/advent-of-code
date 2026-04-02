local function hash_str(s)
  local cur = 0
  local i = 1
  local n = #s
  while i <= n do
    cur = ((cur + s:byte(i)) * 17) % 256
    i = i + 1
  end
  return cur
end

return function(path)
  local lines = readLines(path)
  local line = lines[1]
  local p1 = 0
  local start = 1
  local i = 1
  local n = #line
  while i <= n do
    if line:sub(i, i) == ',' or i == n then
      local seg_end = i
      if line:sub(i, i) == ',' then
        seg_end = i - 1
      end
      if seg_end >= start then
        local seg = line:sub(start, seg_end)
        p1 = p1 + hash_str(seg)
      end
      start = i + 1
    end
    i = i + 1
  end

  local boxes = {}
  local b = 0
  while b <= 255 do
    boxes[b] = {}
    b = b + 1
  end

  start = 1
  i = 1
  while i <= n do
    if line:sub(i, i) == ',' or i == n then
      local seg_end = i
      if line:sub(i, i) == ',' then
        seg_end = i - 1
      end
      if seg_end >= start then
        local seg = line:sub(start, seg_end)
        if seg:find('=') then
          local eq = seg:find('=')
          local label = seg:sub(1, eq - 1)
          local fl = tonumber(seg:sub(eq + 1))
          local h = hash_str(label)
          local box = boxes[h]
          local found
          local j = 1
          while j <= #box do
            if box[j][1] == label then
              box[j][2] = fl
              found = true
              break
            end
            j = j + 1
          end
          if not found then
            box[#box + 1] = { label, fl }
          end
        else
          local dash = seg:find('-')
          local label = seg:sub(1, dash - 1)
          local h = hash_str(label)
          local box = boxes[h]
          local newb = {}
          local j = 1
          while j <= #box do
            if box[j][1] ~= label then
              newb[#newb + 1] = box[j]
            end
            j = j + 1
          end
          boxes[h] = newb
        end
      end
      start = i + 1
    end
    i = i + 1
  end

  local p2 = 0
  local bi = 0
  while bi <= 255 do
    local box = boxes[bi]
    local j = 1
    while j <= #box do
      p2 = p2 + (bi + 1) * j * box[j][2]
      j = j + 1
    end
    bi = bi + 1
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
