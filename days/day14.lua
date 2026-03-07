-- with a hint from reddit, improved day 14 that just tracks letter pair frequency counts rather than attempting to represent the expanded string on intermediate steps

function day14_increment(tbl,key, amt)
	if tbl[key] == nil then 
		tbl[key] = amt
	else
		tbl[key] = tbl[key] + amt
	end
end

function day14_expand(pair_counts, inserts)
	local new_counts = {}
	for k,v in pairs(pair_counts) do 
		if inserts[k] ~= nil then 
			local key1 = string.sub(k,1,1) .. inserts[k]
			local key2 = inserts[k] .. string.sub(k,2,2)
			day14_increment(new_counts, key1, v)
			day14_increment(new_counts, key2, v)
		else
			day14_increment(new_counts, k, v)
		end
	end
	return new_counts
end

function day14(path) 
	local lines = readLines(path)
	
	local template = lines[1]
	local inserts = {}
	for i = 3,#lines do 
		inserts[string.sub(lines[i],1,2)] = string.sub(lines[i],7,7)
	end
	
	local part1 = 0
	local part2 = 1
	
	local lo = -1
	local hi = -1 
	
	local pair_counts = {}
	for i = 1,string.len(template)-1 do 
		day14_increment(pair_counts, string.sub(template, i, i+1), 1)
	end
	
	local start = string.sub(template, 1, 1)
	
	-- part 1
	for i = 1,10 do 
		pair_counts = day14_expand(pair_counts, inserts)
	end
	
	local counts = {}
	for k,v in pairs(pair_counts) do 
		-- only increment the second part of the pair in the frequency count  
		-- to avoid double-counting. 
		local k2 = string.sub(k,2,2)
		day14_increment(counts, k2, v)
	end
	day14_increment(counts, start, 1) -- add first character in template 
	
	for k,v in pairs(counts) do 
		if(lo == -1 or counts[k] < lo) then 
			lo = counts[k]
		end
		if(hi == -1 or counts[k] > hi) then 
			hi = counts[k]
		end
	end
	
	part1 = hi - lo
	
	-- part 2 
	for i = 1,30 do 
		pair_counts = day14_expand(pair_counts, inserts)
	end
	
	counts = {}
	lo = -1
	hi = -1
	for k,v in pairs(pair_counts) do 
		local k2 = string.sub(k,2,2)
		day14_increment(counts, k2, v)
	end
	day14_increment(counts, start, 1) -- add first character in template 
	
	for k,v in pairs(counts) do 
		if(lo == -1 or counts[k] < lo) then 
			lo = counts[k]
		end
		if(hi == -1 or counts[k] > hi) then 
			hi = counts[k]
		end
	end
	part2 = hi - lo
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 
