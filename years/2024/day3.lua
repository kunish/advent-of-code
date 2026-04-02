return function(path)
  local lines = readLines(path)
  local s = table.concat(lines, '')

  local function sum_muls(str, filter)
    local sum = 0
    local i = 1
    local enabled = true
    while i <= #str do
      if str:sub(i, i + 6) == "don't()" then
        enabled = false
        i = i + 7
      elseif str:sub(i, i + 3) == 'do()' then
        enabled = true
        i = i + 4
      elseif str:sub(i, i + 3) == 'mul(' then
        local j = i + 4
        local a, b
        a, j = str:match('^(%d+)()', j)
        if a then
          if str:sub(j, j) == ',' then
            j = j + 1
            b, j = str:match('^(%d+)()', j)
            if b and str:sub(j, j) == ')' then
              if not filter or enabled then
                sum = sum + tonumber(a) * tonumber(b)
              end
              i = j + 1
            else
              i = i + 1
            end
          else
            i = i + 1
          end
        else
          i = i + 1
        end
      else
        i = i + 1
      end
    end
    return sum
  end

  local part1 = 0
  for a, b in s:gmatch('mul%((%d+),(%d+)%)') do
    part1 = part1 + tonumber(a) * tonumber(b)
  end

  local part2 = sum_muls(s, true)
  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
