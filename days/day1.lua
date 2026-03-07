 
 
 function day1(path) 
	local lines = readLines(path)
	
	local values = {}
	local part1 = 0
	local part2 = 0
	for i = 1,#lines do
		values[i] = tonumber(lines[i])
		if i > 1 and values[i-1] < values[i] then
			part1 = part1 + 1
		end
		if i > 3 and values[i-3] + values[i-2] + values[i-1] < values[i-2] + values[i-1] + values[i] then
			part2 = part2 + 1
		end
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
	
 end