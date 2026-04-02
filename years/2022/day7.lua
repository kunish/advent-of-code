local function day7(path)
  local lines = readLines(path)

  local sizes = {}
  local path_stack = {}

  local function cwd_key()
    return table.concat(path_stack, '/')
  end

  local function ensure_dir(k)
    if sizes[k] == nil then
      sizes[k] = 0
    end
  end

  for i = 1, #lines do
    local line = lines[i]
    if line:sub(1, 1) == '$' then
      local cmd, arg = line:match('%$ (%w+)%s*(.*)')
      if cmd == 'cd' then
        if arg == '/' then
          path_stack = {}
        elseif arg == '..' then
          path_stack[#path_stack] = nil
        else
          path_stack[#path_stack + 1] = arg
        end
      end
    else
      local sz, name = line:match('(%S+)%s+(%S+)')
      if sz ~= 'dir' then
        local file_size = tonumber(sz)
        local k = ''
        ensure_dir('')
        sizes[''] = sizes[''] + file_size
        for j = 1, #path_stack do
          k = k .. '/' .. path_stack[j]
          ensure_dir(k)
          sizes[k] = sizes[k] + file_size
        end
      end
    end
  end

  local part1 = 0
  for k, v in pairs(sizes) do
    if v <= 100000 then
      part1 = part1 + v
    end
  end

  local total = 70000000
  local need_free = 30000000
  local used = sizes[''] or 0
  local free = total - used
  local must_delete = need_free - free

  local part2 = nil
  for _, v in pairs(sizes) do
    if v >= must_delete then
      if part2 == nil or v < part2 then
        part2 = v
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2 or 0))
end

return function(p)
  return day7(p)
end
