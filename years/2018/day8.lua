local function parse_nums(s)
  local t = {}
  for n in s:gmatch('%d+') do
    t[#t + 1] = tonumber(n)
  end
  return t
end

local function read_node(nums, idx)
  local child_count = nums[idx]
  local meta_count = nums[idx + 1]
  local pos = idx + 2
  local children = {}
  for _ = 1, child_count do
    local child
    child, pos = read_node(nums, pos)
    children[#children + 1] = child
  end
  local metadata = {}
  for m = 1, meta_count do
    metadata[m] = nums[pos + m - 1]
  end
  pos = pos + meta_count
  return { children = children, metadata = metadata }, pos
end

local function sum_meta(node)
  local s = 0
  local md = node.metadata
  for i = 1, #md do
    s = s + md[i]
  end
  local ch = node.children
  for i = 1, #ch do
    s = s + sum_meta(ch[i])
  end
  return s
end

local function value(node)
  local ch = node.children
  if #ch == 0 then
    local s = 0
    local md = node.metadata
    for i = 1, #md do
      s = s + md[i]
    end
    return s
  end
  local s = 0
  local md = node.metadata
  for i = 1, #md do
    local idx = md[i]
    if idx >= 1 and idx <= #ch then
      s = s + value(ch[idx])
    end
  end
  return s
end

local function day8(path)
  local lines = readLines(path)
  local nums = parse_nums(lines[1] or '')
  local root = select(1, read_node(nums, 1))
  local part1 = sum_meta(root)
  local part2 = value(root)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day8(path)
end
