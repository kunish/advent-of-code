---@param lines string[]
local function part1(lines)
  local horizontal = 0
  local depth = 0

  for _, line in ipairs(lines) do
    local splited = require('utils').split_string(line, ' ')
    local cmd = splited[1]
    local val = tonumber(splited[2])

    if cmd == 'down' then
      depth = depth + val
    end

    if cmd == 'up' then
      depth = depth - val
    end

    if cmd == 'forward' then
      horizontal = horizontal + val
    end
  end

  return horizontal * depth
end

---@param lines string[]
local function part2(lines)
  local horizontal = 0
  local depth = 0
  local aim = 0

  for _, line in ipairs(lines) do
    local splited = require('utils').split_string(line, ' ')
    local cmd = splited[1]
    local val = tonumber(splited[2])

    if cmd == 'down' then
      aim = aim + val
    end

    if cmd == 'up' then
      aim = aim - val
    end

    if cmd == 'forward' then
      horizontal = horizontal + val
      depth = depth + aim * val
    end
  end

  return horizontal * depth
end

local lines = require('utils').read_lines_from('inputs/day2.txt')
local answer1 = part1(lines)
local answer2 = part2(lines)

print(answer1, answer2)
