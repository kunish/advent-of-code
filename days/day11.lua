
function day11_step( grid,width, height)
	-- step 1
	local flashed = {}
	for x = 1,width do 
		for y = 1,height do
			local xy = day9_coord(x,y)
			flashed[xy] = false
			grid[xy] = grid[xy] + 1
		end
	end
	
	-- step2
	local flashtotal = 0
	local done = false
	while not done do
		local flashcount = 0
		for x = 1,width do 
			for y = 1,height do 
				local xy = day9_coord(x,y)
				if grid[xy] > 9 and not flashed[xy] then 
					flashed[xy] = true
					flashcount = flashcount + 1
					-- nw
					if x > 1 and y > 1 then 
						grid[day9_coord(x-1,y-1)] = grid[day9_coord(x-1,y-1)] + 1
					end
					-- w
					if x > 1 then 
						grid[day9_coord(x-1,y)] = grid[day9_coord(x-1,y)] + 1
					end
					-- sw
					if x > 1 and y < height then 
						grid[day9_coord(x-1,y+1)] = grid[day9_coord(x-1,y+1)] + 1
					end
					-- s
					if y < height then 
						grid[day9_coord(x,y+1)] = grid[day9_coord(x,y+1)] + 1
					end
					-- se
					if x < width and y < height then 
						grid[day9_coord(x+1,y+1)] = grid[day9_coord(x+1,y+1)] + 1
					end
					-- e
					if x < width then 
						grid[day9_coord(x+1,y)] = grid[day9_coord(x+1,y)] + 1
					end
					-- ne
					if x < width and y > 1 then 
						grid[day9_coord(x+1,y-1)] = grid[day9_coord(x+1,y-1)] + 1
					end
					-- n
					if y > 1 then 
						grid[day9_coord(x,y-1)] = grid[day9_coord(x,y-1)] + 1
					end
				end
			end
		end
		flashtotal = flashtotal + flashcount
		if flashcount == 0 then 
			done = true
		end	
	end
	for x = 1,width do 
		for y = 1,height do
			local xy = day9_coord(x,y)
			if flashed[xy] then 
				grid[xy] = 0
			end
		end
	end 
	return flashtotal
end

 function day11(path) 
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
	local part2 = 0
	
	local flashtotal = 0
	local i = 1
	while true do
		local flashcount = day11_step(grid, width, height)
		flashtotal = flashtotal + flashcount
		if i == 100 then 
			part1 = flashtotal
		end 
		if flashcount == width * height then 
			part2 = i
		end
		if part1 > 0 and part2 > 0 then 
			break
		end
		i = i + 1
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 