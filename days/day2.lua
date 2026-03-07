 
 
 function day2(path) 
	local lines = readLines(path)
	
	local x = 0
	local y = 0
	local x2 = 0
    local y2 = 0
    local aim = 0
	for i = 1,#lines do
		local line = lines[i]
		if string.sub(line, 0, string.len("forward")) == "forward" then
			local num = tonumber(string.sub(line, string.len("forward") + 1))
			x = x + num
			x2 = x2 + num
			y2 = y2 + (aim * num)
		elseif string.sub(line, 0, string.len("down")) == "down" then 
			local num = tonumber(string.sub(line, string.len("down") + 1))
			y = y + num
			aim = aim + num
		elseif string.sub(line, 0, string.len("up")) == "up" then 
			local num = tonumber(string.sub(line, string.len("up") + 1))
			y = y - num
			aim = aim - num
		end
	end
	local part1 = x * y
	local part2 = x2 * y2
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 end
 