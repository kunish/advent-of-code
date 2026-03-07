  
function day7_gauss(n)
	if n == 0 then 
		return 0
	elseif n == 1 then 
		return 1
	end
	return (n * (n+1))/2
end

 function day7(path) 
	local lines = readLines(path)
	
	local crabs = {}
	for str in string.gmatch(lines[1], "([^,]+)") do
		crabs[#crabs+1] = tonumber(str)
	end
	
	local min_crab = -1
	local max_crab = -1
	for i=1,#crabs do 
		if min_crab == -1 or crabs[i] < min_crab then
			min_crab = crabs[i]
		end
		if max_crab == -1 or crabs[i] > max_crab then 
			max_crab = crabs[i]
		end
	end
	
	local min_i = -1
	local min_i2 = -1
	local part1 = -1
	local part2 = -1
	
	for i = min_crab,max_crab do
		local fuel1 = 0
		local fuel2 = 0;
		for j = 1,#crabs do 
			local diff = crabs[j] - i
			if diff < 0 then
				fuel1 = fuel1 - diff
				fuel2 = fuel2 + day7_gauss(-diff)
			else
				fuel1 = fuel1 + diff
				fuel2 = fuel2 + day7_gauss(diff)
			end
		end
		if min_i == -1 or fuel1 < part1 then
			min_i = i
			part1 = fuel1
		end
		if min_i2 == -1 or fuel2 < part2 then
			min_i2 = i
			part2 = fuel2
		end
	end
	
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 