 
 function day4_print(grid, used)
	for row = 0,4 do
		print(grid[5*row + 1], grid[5*row + 2], grid[5*row + 3], grid[5*row + 4], grid[5*row + 5])
	end
	for row = 0,4 do
		print(used[5*row + 1], used[5*row + 2], used[5*row + 3], used[5*row + 4], used[5*row + 5])
	end
 end
 
 function day4_winner(grid, used)
	for row = 0,4 do
		local count = 0
		for col=1,5 do
			if used[col + (5*row)] then count = count + 1 end
		end
		if count == 5 then
			return true
		end
	end
	for col = 1,5 do
		local count = 0
		for row=0,4 do
			if used[col + (5*row)] then count = count + 1 end
		end
		if count == 5 then
			return true
		end
	end
	return false
 end
 
 function day4_mark(grid, used, number)
	for i=1,25 do
		if grid[i] == number then
			used[i] = true
		end
	end
 end
 
 function day4_score(grid, used, number)
	local sum = 0
	for i =1,25 do
		if used[i] == false then
			sum = sum + grid[i]
		end
	end
	return sum * number
 end
 
 function day4(path) 
	local lines = readLines(path)
	
	local numbers = {}
	for str in string.gmatch(lines[1], "([^,]+)") do
		table.insert(numbers, tonumber(str))
	end
	
	local boards = {}
	for i=3,#lines,6 do
		boards[#boards+1] = {}
		boards[#boards]['grid'] = {}
		boards[#boards]['used'] = {}
		boards[#boards]['won'] = false
		for j = 1,5 do 
			for str in string.gmatch(lines[i+j-1], "([^%s]+)") do
				table.insert(boards[#boards]['grid'], tonumber(str))
				table.insert(boards[#boards]['used'], false)
			end
		end
	end
	
	local number_index = 1
	local part1 = 0
	local part2 = 0
	local winners = 0
	while true do
		local number = numbers[number_index]
		for i = 1,#boards do
			day4_mark(boards[i]['grid'], boards[i]['used'], number)
		end
		for i = 1,#boards do
			if boards[i]['won'] == false and day4_winner(boards[i]['grid'], boards[i]['used']) then 
				boards[i]['won'] = true
				winners = winners + 1
				if winners == 1 then 
					part1 = day4_score(boards[i]['grid'], boards[i]['used'], number)
				end
				if winners == #boards then 
					part2 = day4_score(boards[i]['grid'], boards[i]['used'], number)
					break
				end
			end
		end
		if part1 ~= 0 and part2 ~= 0 then
			break
		end
		number_index = number_index + 1
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 