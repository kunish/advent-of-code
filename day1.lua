---@param lines string[]
local function part1(lines)
	local ret = 0

	for i = 1, #lines - 1, 1 do
		local cur = tonumber(lines[i])
		local next = tonumber(lines[i + 1])

		if next > cur then
			ret = ret + 1
		end
	end

	return ret
end

---@param lines string[]
local function part2(lines)
	local ret = 0

	for i = 2, #lines - 1, 1 do
		if not lines[i + 1] or not lines[i + 2] then
			break
		end

		local cur = tonumber(lines[i - 1]) + tonumber(lines[i]) + tonumber(lines[i + 1])
		local next = tonumber(lines[i]) + tonumber(lines[i + 1]) + tonumber(lines[i + 2])

		if next > cur then
			ret = ret + 1
		end
	end

	return ret
end

local lines = require("utils").read_lines_from("inputs/day1.txt")
local answer1 = part1(lines)
local answer2 = part2(lines)

print(answer1, answer2)
