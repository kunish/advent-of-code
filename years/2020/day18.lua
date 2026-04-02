return function(path)
  local lines = readLines(path)

  local function eval_p1(s)
    local i = 1
    local function term()
      local ch = string.sub(s, i, i)
      if ch == '(' then
        i = i + 1
        local v = expr()
        i = i + 1
        return v
      end
      local v = tonumber(ch)
      i = i + 1
      return v
    end
    function expr()
      local v = term()
      while i <= #s do
        local op = string.sub(s, i, i)
        if op == '+' or op == '*' then
          i = i + 1
          if op == '+' then
            v = v + term()
          else
            v = v * term()
          end
        else
          break
        end
      end
      return v
    end
    return expr()
  end

  local function eval_p2(s)
    local i = 1
    local function atom()
      local ch = string.sub(s, i, i)
      if ch == '(' then
        i = i + 1
        local v = mul_expr()
        i = i + 1
        return v
      end
      local v = tonumber(ch)
      i = i + 1
      return v
    end
    function mul_expr()
      local v = add_expr()
      while i <= #s do
        local op = string.sub(s, i, i)
        if op == '*' then
          i = i + 1
          v = v * add_expr()
        else
          break
        end
      end
      return v
    end
    function add_expr()
      local v = atom()
      while i <= #s do
        local op = string.sub(s, i, i)
        if op == '+' then
          i = i + 1
          v = v + atom()
        else
          break
        end
      end
      return v
    end
    return mul_expr()
  end

  local sum1 = 0
  local sum2 = 0
  local li = 1
  while li <= #lines do
    local s = lines[li]:gsub('%s+', '')
    if s ~= '' then
      sum1 = sum1 + eval_p1(s)
      sum2 = sum2 + eval_p2(s)
    end
    li = li + 1
  end

  print(string.format('Part 1: %d', sum1))
  print(string.format('Part 2: %d', sum2))
end
