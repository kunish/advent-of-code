local WORDS = {
  one = 1,
  two = 2,
  three = 3,
  four = 4,
  five = 5,
  six = 6,
  seven = 7,
  eight = 8,
  nine = 9,
}

local WORD_LIST = { 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine' }

local function first_value(s, use_words)
  local len = #s
  for pos = 1, len do
    local c = s:sub(pos, pos)
    if c >= '0' and c <= '9' then
      return tonumber(c)
    end
    if use_words then
      for w = 1, #WORD_LIST do
        local word = WORD_LIST[w]
        local wl = #word
        if pos + wl - 1 <= len and s:sub(pos, pos + wl - 1) == word then
          return WORDS[word]
        end
      end
    end
  end
  return nil
end

local function last_value(s, use_words)
  local len = #s
  for pos = len, 1, -1 do
    local c = s:sub(pos, pos)
    if c >= '0' and c <= '9' then
      return tonumber(c)
    end
    if use_words then
      for w = 1, #WORD_LIST do
        local word = WORD_LIST[w]
        local wl = #word
        if pos - wl + 1 >= 1 and s:sub(pos - wl + 1, pos) == word then
          return WORDS[word]
        end
      end
    end
  end
  return nil
end

local function day1(path)
  local lines = readLines(path)
  local sum1 = 0
  local sum2 = 0
  for i = 1, #lines do
    local line = lines[i]
    local a = first_value(line, false)
    local b = last_value(line, false)
    sum1 = sum1 + a * 10 + b
    local c = first_value(line, true)
    local d = last_value(line, true)
    sum2 = sum2 + c * 10 + d
  end
  print(string.format('Part 1: %d', sum1))
  print(string.format('Part 2: %d', sum2))
end

return function(p)
  return day1(p)
end
