 
 function day3_process(lines, numbits, is_o2)
	for i = 1, numbits do
		local one_count = 0
		for j = 1,#lines do
			if string.sub(lines[j], i, i) == '1' then
				one_count = one_count + 1
			end
		end
		
		local target = '0'
		if is_o2 then
			if one_count >= (#lines) - one_count then
				target = '1'
			end
		else 
			if one_count < (#lines) - one_count then
				target = '1'
			end
		end
		
		local remove = {}
		for j = 1, #lines do 
			if string.sub(lines[j], i, i) ~= target then
				remove[lines[j]] = true
			else 
				remove[lines[j]] = false
			end
		end
		
		local k = 1
		while k <= #lines do
			if remove[lines[k]] then
				table.remove(lines, k)
			else
				k = k + 1
			end	
			if #lines == 1 then
				break
			end
		end
		
		if #lines == 1 then
			break
		end
	end
	return lines
 end
 
 function day3(path) 
	local lines = readLines(path)
	
	local numbits = string.len(lines[1])
	
	local bits = {}
	for i = 1,numbits do
		bits[i] = 0
	end
	
	local o2 = {}
	local co2 = {}
	for i = 1,#lines do 
		--print(i, #lines)
		o2[i] = lines[i]
		co2[i] = lines[i]
		for j = 1,numbits do
			if string.sub(lines[i], j,j) == '1' then
				bits[j] = bits[j] + 1
			end
		end
	end
	
	local gamma = 0
	local epsilon = 0
	
	for i = 1,numbits do
		if bits[i] > #lines/2 then
			gamma = gamma | (1 << (numbits - i))
		else 
			epsilon = epsilon | (1 << (numbits - i))
			
		end
	end

	local part1 = gamma * epsilon
	print(string.format("Part 1: %d", part1))
	
	while #o2 > 1 do
		o2 = day3_process(o2, numbits, true)
	end
	
	while #co2 > 1 do
		co2 = day3_process(co2, numbits, false)
	end
	
	local part2 = tonumber(o2[1], 2) * tonumber(co2[1], 2)
	print(string.format("Part 2: %d", part2))
 end
 