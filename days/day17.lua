
function day17_xmax(x_vel) 
	local x_v = x_vel
	local x = 0
	local step = 0
	while x_v ~= 0 do 
		x = x + x_v
		if x_v > 0 then 
			x_v = x_v - 1
		elseif x < 0 then 
			x_v = x_v + 1
		end
		step = step + 1
	end
	return x 
end

-- return min and max x velocity that can reach target
function day17_x_range(min_x, max_x) 
	local x_v = 1
	while day17_xmax(x_v) < min_x do
		x_v = x_v + 1
	end
	local lo = x_v
	return lo,max_x -- if x_vel exceeds max_x, impossible to not overshoot
end

-- Shoot something up and it will return to y=0 some number of steps later
-- with the inverse velocity. If that velocity exceeds min_y, it will 
-- overshoot the target on the next step. So -min_y is an upper bound for 
-- y_vel
function day17_part1(min_x, max_x, min_y, max_y)
	local y_v0 = -min_y
	while y_v0 > 0 do
		local y = 0
		local prev_y = 0
		local prev_y_v = 0
		local y_v = y_v0 
		local step = 0
		local y_max = 0
		while y > min_y do
			prev_y = y
			prev_y_v = y_v
			step = step + 1
			y = y + y_v
			if y > y_max then 
				y_max = y
			end
			y_v = y_v - 1
			if y >= min_y and y <= max_y then 
				return y_max, y_v0
			end
		end
		y_v0 = y_v0 - 1
	end
	return -1,0
end

function day17_part2(min_x, max_x, min_y, max_y, part1_y_v)
	local min_x_v, max_x_v = day17_x_range(min_x, max_x)
	local success = {}
	for x_v0 = min_x_v,max_x_v do 
		for y_v0 = part1_y_v,min_y,-1 do 
			local x = 0
			local y = 0
			local x_v = x_v0
			local y_v = y_v0 
			while y > min_y do 
				x = x + x_v
				y = y + y_v
				if x_v > 0 then 
					x_v = x_v - 1
				elseif x < 0 then 
					x_v = x_v + 1
				end
				y_v = y_v - 1
				if x >= min_x and x <= max_x and y >= min_y and y <= max_y then 
					table.insert(success, {x_v0, y_v0})
					break
				end
			end
		end
	end
	
	return #success
end

function day17(path) 
	local lines = readLines(path)
	
	local lineA = string.sub(lines[1], string.len("target area: x=") + 1)
	local lineB = string.sub(lineA, 0, string.find(lineA, ", y=") - 1)
	local lineC = string.sub(lineA, string.find(lineA, ", y=") + string.len(", y="))
	local indexA,indexB = string.find(lineB, "%.%.")
	local min_x = tonumber(string.sub(lineB, 0, indexA - 1))
	local max_x = tonumber(string.sub(lineB, indexB + 1))
	indexA, indexB = string.find(lineC, "%.%.")
	local min_y = tonumber(string.sub(lineC, 0, indexA - 1))
	local max_y = tonumber(string.sub(lineC, indexB + 1))
		
	local part1, part1_y_v = day17_part1(min_x, max_x, min_y, max_y)
	if part1 == -1 then 
		print("Part 1: Could not solve")
		return
	end
	local part2 = day17_part2(min_x, max_x, min_y, max_y, part1_y_v)
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 