
function day13_print(grid, x_min, x_max, y_min, y_max)
	local result = ""
	for y = y_min,y_max do 
		for x = x_min,x_max do 
			if grid[string.format("%d,%d", x,y)] then 
				result = result .. '#'
			else 
				result = result .. ' '
			end
		end
		result = result .. '\n'
	end
	return result
end

function day13(path) 
	local lines = readLines(path)
	
	local dots = {}
	local folds = {}
	local line_i = 1
	while true do 
		if(lines[line_i]  ~= "") then 
			local coords = {}
			for str in string.gmatch(lines[line_i], "([^,]+)") do
				table.insert(coords, tonumber(str))
			end
			dots[#dots + 1] = {coords[1], coords[2]}
		else
			break
		end
		line_i = line_i + 1
	end
	line_i = line_i + 1
	while line_i <= #lines do
		if string.sub(lines[line_i], 1, string.len("fold along x=")) == "fold along x=" then 
			folds[#folds + 1] = {"x",tonumber(string.sub(lines[line_i], string.len("fold along x=")  + 1))}
		else 
			folds[#folds + 1] = {"y",tonumber(string.sub(lines[line_i], string.len("fold along y=") + 1))}
		end
			line_i = line_i + 1
	end
	
	local grid1 = {}
	local grid2 = {}
	local x_min = -1
	local y_min = -1
	local x_max = -1
	local y_max = -1
	
	for i = 1, #dots do 
		local x = dots[i][1]
		local y = dots[i][2]
		for j = 1,#folds do 
			if folds[j][1] == "x" then 
				if x >= folds[j][2] then 
					x = x + 2*(folds[j][2] - x)
				end
			else 
				if y >= folds[j][2] then 
					y = y + 2*(folds[j][2] - y)
				end
			end
			if j == 1 then 
				grid1[string.format("%d,%d",x,y)] = true
			end
		end
		if x_min == -1 or x_min > x then 
			x_min = x
		end
		if x_max == -1 or x_max < x then 
			x_max = x
		end
		if y_min == -1 or y_min > y then 
			y_min = y
		end
		if y_max == -1 or y_max < y then 
			y_max = y
		end
		grid2[string.format("%d,%d",x,y)] = true
		
	end
	
	local part1 = 0
	
	for k,v in pairs(grid1) do
		part1 = part1 + 1
	end
	
	local part2 = day13_print(grid2, x_min, x_max, y_min, y_max)
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2:\n%s", part2))
 
 end
 