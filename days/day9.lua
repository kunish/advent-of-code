
function day9_coord(x,y)
	return string.format("%d,%d",x,y);
end

 function day9(path) 
	local lines = readLines(path)
	
	local width = string.len(lines[1])
	local height = #lines
	local grid = {}
	for i = 1,#lines do 
		for j = 1, string.len(lines[i]) do 
			grid[day9_coord(j,i)] = tonumber(string.sub(lines[i],j,j))
		end
	end

	local part1 = 0
	local part2 = 1
	
	local basin_counts = {}
	
	for x = 1,width do
		for y = 1,height do 
			local neighbors = 0
			local higher = 0
			local xy = day9_coord(x,y)
			if x > 1 then 
				neighbors = neighbors + 1
				if (grid[day9_coord(x-1,y)] > grid[xy]) then 
					higher = higher + 1
				end
			end
			if x < width then 
				neighbors = neighbors + 1
				if (grid[day9_coord(x+1,y)] > grid[xy]) then 
					higher = higher + 1
				end
			end
			if y > 1 then 
				neighbors = neighbors + 1
				if (grid[day9_coord(x,y-1)] > grid[xy]) then 
					higher = higher + 1
				end
			end
			if y < height then 
				neighbors = neighbors + 1
				if (grid[day9_coord(x,y+1)] > grid[xy]) then 
					higher = higher + 1
				end
			end
			if higher == neighbors then
				part1 = part1 + grid[xy] + 1
				
				local basin_stack = {}
				local basin_found = {}
				local basin_count = 0
				
				table.insert(basin_stack, {x,y})
				
				while #basin_stack > 0 do
					local coord = table.remove(basin_stack, 1)
					local x1 = coord[1]
					local y1 = coord[2]
					
					local x1y1 = day9_coord(x1,y1)
					if not basin_found[x1y1] then 
						basin_found[x1y1] = true
						basin_count = basin_count + 1
					end
					
					if x1 > 1 then 
						local next_coord = day9_coord(x1-1, y1)
						if grid[next_coord] < 9 and not basin_found[next_coord] then 
							table.insert(basin_stack, {x1-1,y1})
						end
					end
					if x1 < width then 
						local next_coord = day9_coord(x1+1, y1)
						if  grid[next_coord] < 9 then 
							if grid[next_coord] < 9 and not basin_found[next_coord] then 
								table.insert(basin_stack, {x1+1,y1})
							end
						end
					end
					if y1 > 1 then 
						local next_coord = day9_coord(x1, y1-1)
						if  grid[next_coord] < 9 then 
							if grid[next_coord] < 9 and not basin_found[next_coord] then 
								table.insert(basin_stack, {x1,y1-1})
							end
						end
					end
					if y1 < height then 
						local next_coord = day9_coord(x1, y1+1)
						if  grid[next_coord] < 9 then 
							if grid[next_coord] < 9 and not basin_found[next_coord] then 
								table.insert(basin_stack, {x1,y1+1})
							end
						end
					end
				end
				
				basin_counts[#basin_counts + 1] = basin_count
			end
		end
	end
	
	table.sort(basin_counts, function(x,y) return x > y end)
	for i = 1,3 do 
		part2 = part2 * basin_counts[i]
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 