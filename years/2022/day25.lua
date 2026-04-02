return function(path)
  local lines = readLines(path)

  local digit_val = { ['2'] = 2, ['1'] = 1, ['0'] = 0, ['-'] = -1, ['='] = -2 }

  local function from_snafu(s)
    local v = 0
    for i = 1, #s do
      v = v * 5 + digit_val[s:sub(i, i)]
    end
    return v
  end

  local map = { [-2] = '=', [-1] = '-', [0] = '0', [1] = '1', [2] = '2' }

  local function to_snafu(n)
    if n == 0 then
      return '0'
    end
    local out = {}
    local x = n
    while x ~= 0 do
      local r = x % 5
      x = x // 5
      if r > 2 then
        x = x + 1
        r = r - 5
      end
      out[#out + 1] = map[r]
    end
    local s = ''
    for i = #out, 1, -1 do
      s = s .. out[i]
    end
    return s
  end

  local sum = 0
  for i = 1, #lines do
    if lines[i] ~= '' then
      sum = sum + from_snafu(lines[i])
    end
  end

  print(string.format('Part 1: %s', to_snafu(sum)))
  print('Part 2: 0')
end
