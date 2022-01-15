local inputs = require('utils').read_lines_from('test.txt')

---@param lines string[]
---@param start_from number
local function build_boards(lines, start_from)
  local boards = {}
  local step = 5

  for i = start_from, #lines, step do
    local board = {}
    for j = 1, step do
      board[#board + 1] = lines[i + j - 1]
    end
    boards[#boards + 1] = board
  end

  return boards
end

local chosen = inputs[1]
local boards = build_boards(inputs, 2)

print(chosen, boards)
