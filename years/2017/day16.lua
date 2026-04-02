local function parse_moves(s)
  local moves = {}
  for seg in s:gmatch('[^,]+') do
    local token = seg:match('^%s*(.-)%s*$')
    local n = token:match('^s(%d+)$')
    if n then
      moves[#moves + 1] = { 's', tonumber(n) }
    else
      local i, j = token:match('^x(%d+)/(%d+)$')
      if i then
        moves[#moves + 1] = { 'x', tonumber(i), tonumber(j) }
      else
        local p, q = token:match('^p(%w)/(%w)$')
        if p then
          moves[#moves + 1] = { 'p', p, q }
        end
      end
    end
  end
  return moves
end

local function apply_moves(state, moves)
  local s = state
  for _, m in ipairs(moves) do
    if m[1] == 's' then
      local x = m[2] % #s
      s = s:sub(#s - x + 1) .. s:sub(1, #s - x)
    elseif m[1] == 'x' then
      local i, j = m[2] + 1, m[3] + 1
      if i > j then
        i, j = j, i
      end
      local a, b = s:sub(i, i), s:sub(j, j)
      s = s:sub(1, i - 1) .. b .. s:sub(i + 1, j - 1) .. a .. s:sub(j + 1)
    else
      local p, q = m[2], m[3]
      local i = s:find(p, 1, true)
      local j = s:find(q, 1, true)
      if i > j then
        i, j = j, i
      end
      local a, b = s:sub(i, i), s:sub(j, j)
      s = s:sub(1, i - 1) .. b .. s:sub(i + 1, j - 1) .. a .. s:sub(j + 1)
    end
  end
  return s
end

local function day16(path)
  local lines = readLines(path)
  local moves = parse_moves(lines[1] or '')

  local initial = 'abcdefghijklmnop'
  local p1 = apply_moves(initial, moves)

  local seen = {}
  local states = {}
  local s = initial
  local step = 0
  while not seen[s] do
    seen[s] = step
    states[step] = s
    s = apply_moves(s, moves)
    step = step + 1
  end
  local cycle_start = seen[s]
  local cycle_len = step - cycle_start
  local target = 1000000000
  local idx
  if target < cycle_start then
    idx = target
  else
    idx = cycle_start + (target - cycle_start) % cycle_len
  end
  local p2 = states[idx]

  print(string.format('Part 1: %s', p1))
  print(string.format('Part 2: %s', p2))
end

return function(path)
  return day16(path)
end
