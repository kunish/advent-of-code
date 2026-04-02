local intcode = require('years.2019.intcode')

local function run_until_halt(mem)
  local vm = { mem = mem, ip = 0, rb = 0 }
  local out = {}
  while true do
    local ev = intcode.step(vm)
    if ev == 'in' then
      error('unexpected input in camera mode')
    elseif type(ev) == 'table' and ev[1] == 'out' then
      out[#out + 1] = ev[2]
    elseif ev == 'halt' then
      break
    end
  end
  return out
end

local function to_string(codes)
  local t = {}
  for i = 1, #codes do
    t[i] = string.char(codes[i] % 256)
  end
  return table.concat(t)
end

local function parse_grid(s)
  local rows = {}
  local y = 1
  for line in s:gmatch('[^\n]+') do
    rows[y] = line
    y = y + 1
  end
  local h = #rows
  local w = 0
  for i = 1, h do
    if #rows[i] > w then
      w = #rows[i]
    end
  end
  return rows, w, h
end

local function at(rows, x, y)
  local row = rows[y]
  if not row then
    return nil
  end
  return row:sub(x, x)
end

local function is_scaffold(ch)
  return ch == '#' or ch == '^' or ch == 'v' or ch == '<' or ch == '>'
end

local function dir_from_char(ch)
  if ch == '^' then
    return 0, -1
  elseif ch == 'v' then
    return 0, 1
  elseif ch == '<' then
    return -1, 0
  elseif ch == '>' then
    return 1, 0
  end
  return nil
end

local function trim_comma(rest)
  if rest:sub(1, 1) == ',' then
    return rest:sub(2)
  end
  return rest
end

local function trace_path(rows, w, h)
  local sx, sy, sc
  for y = 1, h do
    for x = 1, w do
      local ch = at(rows, x, y)
      local dx, dy = dir_from_char(ch)
      if dx then
        sx, sy, sc = x, y, ch
        break
      end
    end
    if sx then
      break
    end
  end
  local dx, dy = dir_from_char(sc)
  local steps = {}
  local x, y = sx, sy

  local function can_step(tx, ty)
    return is_scaffold(at(rows, tx, ty))
  end

  -- CW / CCW on direction (dx,dy): N(0,-1) E(1,0) S(0,1) W(-1,0)
  local function succ_w(px, py)
    return -py, px
  end
  local function pred_w(px, py)
    return py, -px
  end

  while true do
    local fx, fy = x + dx, y + dy
    local swx, swy = succ_w(dx, dy)
    local cwx, cwy = x + swx, y + swy
    local pwx, pwy = pred_w(dx, dy)
    local ax, ay = x + pwx, y + pwy

    if can_step(fx, fy) then
      steps[#steps + 1] = 'F'
      x, y = fx, fy
    elseif can_step(cwx, cwy) then
      steps[#steps + 1] = 'R'
      dx, dy = swx, swy
    elseif can_step(ax, ay) then
      steps[#steps + 1] = 'L'
      dx, dy = pwx, pwy
    else
      break
    end
  end

  local tokens = {}
  local i = 1
  while i <= #steps do
    if steps[i] == 'F' then
      local n = 0
      while i <= #steps and steps[i] == 'F' do
        n, i = n + 1, i + 1
      end
      tokens[#tokens + 1] = tostring(n)
    else
      tokens[#tokens + 1] = steps[i]
      i = i + 1
    end
  end
  return tokens
end

local function copy_main(m)
  local t = {}
  for i = 1, #m do
    t[i] = m[i]
  end
  return t
end

local function find_routines(full)
  local function rec(remain, S, main)
    if remain == '' then
      if S.A and S.B and S.C then
        local mstr = table.concat(main, ',')
        if #mstr <= 20 then
          return mstr, S.A, S.B, S.C
        end
      end
      return nil
    end
    local cand = {}
    for _, name in ipairs({ 'A', 'B', 'C' }) do
      local body = S[name]
      if body and #remain >= #body and remain:sub(1, #body) == body then
        cand[#cand + 1] = { name, body }
      end
    end
    table.sort(cand, function(a, b)
      return #a[2] > #b[2]
    end)
    for i = 1, #cand do
      local name, body = cand[i][1], cand[i][2]
      local rest = trim_comma(remain:sub(#body + 1))
      local nm = copy_main(main)
      nm[#nm + 1] = name
      local r1, r2, r3, r4 = rec(rest, S, nm)
      if r1 then
        return r1, r2, r3, r4
      end
    end
    for _, name in ipairs({ 'A', 'B', 'C' }) do
      if not S[name] then
        for l = 1, math.min(20, #remain) do
          if l < #remain and remain:sub(l + 1, l + 1) ~= ',' then
            goto cont_def
          end
          local body = remain:sub(1, l)
          local NS = { A = S.A, B = S.B, C = S.C }
          NS[name] = body
          local rest = trim_comma(remain:sub(l + 1))
          local nm = copy_main(main)
          nm[#nm + 1] = name
          local r1, r2, r3, r4 = rec(rest, NS, nm)
          if r1 then
            return r1, r2, r3, r4
          end
          ::cont_def::
        end
      end
    end
    return nil
  end
  return rec(full, { A = nil, B = nil, C = nil }, {})
end

local function run_with_ascii(program_mem, ascii_str)
  local mem = intcode.copy(program_mem)
  mem[0] = 2
  local vm = { mem = mem, ip = 0, rb = 0 }
  local inputs = {}
  for i = 1, #ascii_str do
    inputs[#inputs + 1] = ascii_str:byte(i, i)
  end
  local in_i = 1
  local outs = {}
  while true do
    local ev = intcode.step(vm)
    if ev == 'in' then
      if in_i > #inputs then
        error('out of ASCII input')
      end
      intcode.apply_input(vm, inputs[in_i])
      in_i = in_i + 1
    elseif type(ev) == 'table' and ev[1] == 'out' then
      outs[#outs + 1] = ev[2]
    elseif ev == 'halt' then
      break
    end
  end
  return outs
end

local function day17(path)
  local lines = readLines(path)
  local program = intcode.parse(lines[1] or '')
  local codes = run_until_halt(intcode.copy(program))
  local s = to_string(codes)
  local rows, w, h = parse_grid(s)

  local sum = 0
  for y = 2, h - 1 do
    for x = 2, w - 1 do
      if at(rows, x, y) == '#' then
        if is_scaffold(at(rows, x - 1, y)) and is_scaffold(at(rows, x + 1, y)) and is_scaffold(at(rows, x, y - 1)) and is_scaffold(at(rows, x, y + 1)) then
          sum = sum + (x - 1) * (y - 1)
        end
      end
    end
  end

  local tokens = trace_path(rows, w, h)
  local full = table.concat(tokens, ',')
  local main, A, B, C = find_routines(full)
  if not main then
    error('could not compress path')
  end
  local function expand_main(mstr, a, b, c)
    local map = { A = a, B = b, C = c }
    local parts = {}
    for tok in mstr:gmatch('[^,]+') do
      local body = map[tok]
      if not body then
        return nil
      end
      parts[#parts + 1] = body
    end
    return table.concat(parts, ',')
  end
  if expand_main(main, A, B, C) ~= full then
    error('compress mismatch')
  end

  local ascii_str = table.concat({ main, A, B, C, 'n' }, '\n') .. '\n'
  local outs2 = run_with_ascii(program, ascii_str)
  local ans2 = 0
  for i = 1, #outs2 do
    local v = outs2[i]
    if v > 127 then
      ans2 = v
    end
  end

  print(string.format('Part 1: %d', sum))
  print(string.format('Part 2: %d', ans2))
end

return function(p)
  return day17(p)
end
