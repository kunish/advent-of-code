  
 function day6_part1(fish)
	local fishnum = #fish
	for i=1,fishnum do
		fish[i] = fish[i] - 1
		if fish[i] < 0 then
			fish[i] = 6
			fish[#fish+1] = 8
		end
	end
 end
 
 function day6_part2(bins)
	local new = bins[0]
	for i = 0,7 do
		bins[i] = bins[i+1]
	end
	bins[6] = bins[6] + new
	bins[8] = new
 end
 
 function day6(path) 
	local lines = readLines(path)
	
	local fish1 = {}
	local fish2 = {}
	for str in string.gmatch(lines[1], "([^,]+)") do
		fish1[#fish1+1] = tonumber(str)
		fish2[#fish2+1] = tonumber(str)
	end
	
	local day = 1
	while day <= 80 do
		day6_part1(fish1)
		day = day + 1
	end
	local part1 = #fish1
	
	local bins = {}
	for i = 0,8 do
		bins[i] = 0
	end
	for i = 1,#fish2 do
		bins[fish2[i]] = bins[fish2[i]] + 1
	end
	
	day = 1
	while day <= 256 do
		day6_part2(bins)
		day = day + 1
	end
	
	local part2 = 0
	for i = 0,8 do
		part2 = part2 + bins[i]
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 