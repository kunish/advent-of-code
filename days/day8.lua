
-- replace each character with its mapping,
-- alphabetically sort the result and return
-- as a string
function day8_mapandsort(str, map) 
	local t = {}
	for i = 1,string.len(str) do 
		t[#t+1] = map[string.sub(str, i,i)]
	end
	table.sort(t)
	local ret = ''
	for i = 1,#t do
		ret = ret .. t[i]
	end
	return ret
end

 function day8(path) 
	local lines = readLines(path)
	
	local chars = {'a','b','c','d','e','f','g'}
	local digits = {}
	digits[0] = 'abcefg'
	digits[1] = 'cf'
	digits[2] = 'acdeg'
	digits[3] = 'acdfg'
	digits[4] = 'bcdf'
	digits[5] = 'abdfg'
	digits[6] = 'abdefg'
	digits[7] = 'acf'
	digits[8] = 'abcdefg'
	digits[9] = 'abcdfg'
	local part1 = 0
	local part2 = 0
	
	for i = 1,#lines do
		local index = string.find(lines[i], " | ")
		local partA = string.sub(lines[i], 1, string.find(lines[i], " | "))
		local partB = string.sub(lines[i], string.find(lines[i], " | ") + string.len(" | "))
		local patterns = {}
		local outputs = {}
		local deduced = {}
		
		for str in string.gmatch(partA, "([^ ]+)") do
			patterns[#patterns + 1] = str
			local strlen = string.len(str)
			if strlen == 2 then
				deduced[1] = str
			elseif strlen == 4 then 
				deduced[4] = str
			elseif strlen == 3 then 
				deduced[7] = str
			elseif strlen == 7 then
				deduced[8] = str
			end
		end
		
		for str in string.gmatch(partB, "([^ ]+)") do
			outputs[#outputs + 1] = str
			local strlen = string.len(str)
			if(strlen == 2 or strlen == 4 or strlen == 3 or strlen == 7) then
				part1 = part1 + 1
			end
		end
		
		local map = {}
		
		-- a appears in 7 and not in 1
		local a_test = {}
		for j = 1,string.len(deduced[1]) do
			
			if a_test[string.sub(deduced[1],j,j)] == nil then
				a_test[string.sub(deduced[1],j,j)] = 1
			else 
				a_test[string.sub(deduced[1],j,j)] = a_test[string.sub(deduced[1],j,j)] + 1
			end 
		end
		for j = 1,string.len(deduced[7]) do
			if a_test[string.sub(deduced[7],j,j)] == nil then
				a_test[string.sub(deduced[7],j,j)] = 1
			else 
				a_test[string.sub(deduced[7],j,j)] = a_test[string.sub(deduced[7],j,j)] + 1
			end 
		end
		for j = 1, #chars do 
			if a_test[chars[j]] == 1 then
				map[chars[j]] = 'a'
				break
			end
		end
		
		-- count frequency of each segment in patterns
		local counts = {}
		for j = 1,#patterns do 
			for k = 1,#chars do 
				if(string.find(patterns[j], chars[k])) then
					if(counts[chars[k]] == nil) then
						counts[chars[k]] = 1
					else 
						counts[chars[k]] = counts[chars[k]] + 1
					end
				end
			end
		end
		
		-- segment b=6, e=4,f=9
		for j = 1, #chars do 
			if counts[chars[j]] == 6 then
				map[chars[j]] = 'b'
			elseif counts[chars[j]] == 4 then
				map[chars[j]] = 'e'
			elseif counts[chars[j]] == 9 then
				map[chars[j]] = 'f'
			end
		end
		
		-- a, c each appears 8 times, but a is already known
		-- leaving d and g at 7 appearances each
		local d_g = {}
		for j = 1, #chars do 
			if map[chars[j]] == nil and counts[chars[j]] == 8 then
				map[chars[j]] = 'c'
			elseif counts[chars[j]] == 7 then
				d_g[#d_g + 1] = chars[j]
			end
		end
		
		-- d appears in 4, g does not. the mapping is finished.
		for j=1,#d_g do
			if string.find(deduced[4], d_g[j]) then 
				map[d_g[j]] = 'd'
			else 
				map[d_g[j]] = 'g'
			end
		end
		
		local d1 = day8_mapandsort(outputs[1], map)
		local d2 = day8_mapandsort(outputs[2], map)
		local d3 = day8_mapandsort(outputs[3], map)
		local d4 = day8_mapandsort(outputs[4], map)
		
		local result = 0
		for j = 0,#digits do 
			if d1 == digits[j] then 
				result = result + j * 1000
			end
			if d2 == digits[j] then 
				result = result + j * 100
			end
			if d3 == digits[j] then 
				result = result + j * 10
			end
			if d4 == digits[j] then 
				result = result + j
			end
		end
		part2 = part2 + result
		
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 