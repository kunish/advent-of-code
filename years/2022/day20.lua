return function(path)
  local lines = readLines(path)
  local nums = {}
  for i = 1, #lines do
    nums[i] = tonumber(lines[i])
  end
  local n = #nums

  local function mod_ring(a, m)
    local r = a % m
    if r < 0 then
      r = r + m
    end
    return r
  end

  local function mix_once(arr, key)
    local order = {}
    for i = 1, n do
      order[i] = i
    end
    for oi = 1, n do
      local id = order[oi]
      local v = key[id]
      local idx = 1
      for j = 1, #arr do
        if arr[j] == id then
          idx = j
          break
        end
      end
      table.remove(arr, idx)
      local m = n - 1
      if m == 0 then
        return
      end
      local new0 = mod_ring((idx - 1) + v, m)
      table.insert(arr, new0 + 1, id)
    end
  end

  local function grove_sum(arr, key)
    local zidx = 1
    for j = 1, #arr do
      if key[arr[j]] == 0 then
        zidx = j
        break
      end
    end
    local function at(off)
      local j = mod_ring(zidx - 1 + off, n) + 1
      return key[arr[j]]
    end
    return at(1000) + at(2000) + at(3000)
  end

  local arr1 = {}
  for i = 1, n do
    arr1[i] = i
  end
  mix_once(arr1, nums)
  print(string.format('Part 1: %d', grove_sum(arr1, nums)))

  local key = {}
  local dec = 811589153
  for i = 1, n do
    key[i] = nums[i] * dec
  end
  local arr2 = {}
  for i = 1, n do
    arr2[i] = i
  end
  for _ = 1, 10 do
    mix_once(arr2, key)
  end
  print(string.format('Part 2: %d', grove_sum(arr2, key)))
end
