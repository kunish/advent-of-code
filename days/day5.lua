 
 
 function day5_coord(x,y)
	return string.format("%d,%d",x,y)
 end
 
 function day5_contains(set,key) 
	return set[key] ~= nil
 end
 
 function day5(path)
	local lines = readLines(path)
	
	
	local min_x, max_x, min_y, max_y = -1
	local vents = {}
	for i = 1,#lines do 
		local st,ed = string.find(lines[i], " %-> ")
		local strA = string.sub(lines[i],0,st)
		local strB = string.sub(lines[i], ed, string.len(lines[i]))
		local commaA = string.find(strA, ",")
		local commaB = string.find(strB, ",")
		vents[#vents+1] = {}
		vents[#vents]['a'] = {}
		vents[#vents]['a']['x'] = tonumber(string.sub(strA, 0, commaA-1))
		vents[#vents]['a']['y'] = tonumber(string.sub(strA, commaA+1, string.len(strA)))
		vents[#vents]['b'] = {}
		vents[#vents]['b']['x'] = tonumber(string.sub(strB, 0, commaB-1))
		vents[#vents]['b']['y'] = tonumber(string.sub(strB, commaB+1, string.len(strB)))
	end
	
	
	local grid1 = {}
	local grid2 = {}
	for i = 1,#vents do 
		-- vertical
		if vents[i].a.x == vents[i].b.x then
			local x = vents[i].a.x
			for y = vents[i].a.y,vents[i].b.y,(vents[i].a.y < vents[i].b.y and 1 or -1) do
				local coord = day5_coord(x,y)
				if day5_contains(grid1, coord) then
					grid1[coord] = grid1[coord] + 1
				else 
					grid1[coord] = 1
				end
				if day5_contains(grid2, coord) then
					grid2[coord] = grid2[coord] + 1
				else 
					grid2[coord] = 1
				end
			end
		-- horizontal
		elseif vents[i].a.y == vents[i].b.y then
			local y = vents[i].a.y
			for x = vents[i].a.x,vents[i].b.x,(vents[i].a.x < vents[i].b.x and 1 or -1) do
				local coord = day5_coord(x,y)
				if day5_contains(grid1, coord) then
					grid1[coord] = grid1[coord] + 1
				else 
					grid1[coord] = 1
				end
				if day5_contains(grid2, coord) then
					grid2[coord] = grid2[coord] + 1
				else 
					grid2[coord] = 1
				end
			end
		-- diagonal
		else 
			local x_inc = (vents[i].a.x < vents[i].b.x and 1 or -1)
			local y_inc = (vents[i].a.y < vents[i].b.y and 1 or -1)
			local x = vents[i].a.x
			local y = vents[i].a.y
			while x ~= vents[i].b.x and y ~= vents[i].b.y do
				local coord = day5_coord(x,y)
				if day5_contains(grid2, coord) then
					grid2[coord] = grid2[coord] + 1
				else 
					grid2[coord] = 1
				end
				x = x + x_inc
				y = y + y_inc
			end
			-- last position
			local coord = day5_coord(x,y)
			if day5_contains(grid2, coord) then
				grid2[coord] = grid2[coord] + 1
			else 
				grid2[coord] = 1
			end
		end
	end
	
	local part1 = 0
	local part2 = 0
	
	for key,value in pairs(grid1) do 
		if value > 1 then
			part1 = part1 + 1
		end
	end
	for key,value in pairs(grid2) do 
		if value > 1 then
			part2 = part2 + 1
		end
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 