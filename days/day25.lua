
function day25_state(r,d,width,height,grid) 
	local ret = ''
	for y = 1,height do 
		ret = ret .. table.concat(grid[y], '')
		ret = ret .. '\n'
	end
	return ret
end

function day25_step(r,d,width,height, grid ) 
	local r1 = {}
	local d1 = {}
	
	local r_moves = {}
	local l_moves = {}
	
	for i = 1,#d do 
		d1[i] = {}
		d1[i][1] = d[i][1]
		d1[i][2] = d[i][2]
	end
	for i = 1,#r do 
		local x = r[i][1]
		local y = r[i][2]
		r1[i] = {}
		if grid[y][x+1 > width and 1 or x+1] ~= '.' then 
			r1[i] = {x,y}
		else 
			r_moves[#r_moves + 1] = {x,y}
			if x + 1 > width then 
				r1[i] = {1,y}
				
			else 
				r1[i] = {x+1,y}
				
			end
		end
	end
	
	for i = 1,#r_moves do 
		local x = r_moves[i][1]
		local y = r_moves[i][2]
		grid[y][x] = '.'
		if x+1 > width then 
			grid[y][1] = '>'
		else 
			grid[y][x+1] = '>'
		end
	end
	
	for i = 1,#d do 
		local x = d[i][1]
		local y = d[i][2]
		d1[i] = {}
		if grid[y+1 > height and 1 or y+1][x] ~= '.' then 
			d1[i] = {x,y}
		else 
			l_moves[#l_moves + 1] = {x,y}
			if y + 1 > height then 
				d1[i] = {x,1}
				
			else 
				d1[i] = {x,y+1}
			end
		end
	end
	
	for i = 1,#l_moves do 
		local x = l_moves[i][1]
		local y = l_moves[i][2]
		grid[y][x] = '.'
		if y+1 > height then 
			grid[1][x] = 'v'
		else 
			grid[y+1][x] = 'v'
		end
	end
	
	return r1, d1
end

function day25(path) 
	local lines = readLines(path)
	
	local r = {}
	local d = {}
	local width = string.len(lines[1]) 
	local height = #lines 
	
	for y = 1,#lines do 
		for x = 1,string.len(lines[y]) do 
			if string.sub(lines[y], x, x) == '>' then 
				r[#r+1] = {x,y}
			elseif string.sub(lines[y],x,x) == 'v' then 
				d[#d+1] = {x,y}
			end
		end
	end
	
	local grid = {}
	for y = 1,height do 
		grid[y] = {}
		for x = 1,width do 
			grid[y][x] = '.'
		end
	end
	for i = 1,#r do
		grid[r[i][2]][r[i][1]] = '>'
	end
	for i = 1,#d do
		grid[d[i][2]][d[i][1]] = 'v'
	end
	
	local last_state = day25_state(r,d,width,height, grid)
	local steps = 0
	while true do 
		r,d = day25_step(r,d,width,height,grid)
		local state = day25_state(r,d,width,height,grid)
		if state == last_state then 
			break
		end
		last_state = state
		steps = steps + 1
	end
	
	local part1 = steps + 1
	print(string.format("Part 1: %d", part1))
	
 end
 