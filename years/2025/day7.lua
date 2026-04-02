return function(path)
  local lines = readLines(path)
  local first = lines[1]
  local start = 0
  for i = 1, #first do
    if string.sub(first, i, i) == 'S' then
      start = i
      break
    end
  end

  local function solve(use_counts)
    local beams = {}
    for i = 1, #first do
      beams[i] = use_counts and 0 or false
    end
    if use_counts then
      beams[start] = 1
    else
      beams[start] = true
    end

    local splits = 0
    for r = 2, #lines do
      local row = lines[r]
      for col = 1, #row do
        local ch = string.sub(row, col, col)
        local b = beams[col]
        local active = use_counts and (b > 0) or b
        if ch == '^' and active then
          splits = splits + 1
          if use_counts then
            beams[col - 1] = beams[col - 1] + b
            beams[col + 1] = beams[col + 1] + b
            beams[col] = 0
          else
            beams[col - 1] = b
            beams[col + 1] = b
            beams[col] = false
          end
        end
      end
    end

    if use_counts then
      local total = 0
      for i = 1, #beams do
        total = total + beams[i]
      end
      return splits, total
    end
    return splits, nil
  end

  local part1 = select(1, solve(false))
  local part2 = select(2, solve(true))

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
