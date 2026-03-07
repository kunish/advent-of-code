-- using a string-indexed table to store raster data is convenient for an 
-- "infinite" grid, but it's not very fast for lookups and updates

function day20_9x9(image, x,y)
	local str = ''
	for i = y-1,y+1 do 
		for j=x-1,x+1 do 
			str = str .. ((day20_imageval(image, j, i) == 1) and '1' or '0')
		end
	end
	local result = tonumber(str, 2)
	return result
end

function day20_enhancexy(image, alg, x, y) 
	local index = day20_9x9(image,x,y)
	return alg[index + 1]
end

function day20_imageval(image, x,y)
	local coord = day9_coord(x,y)
	if image[coord] == nil then
		return 0
	else 
		return image[coord]
	end
end

function day20_coordsplit(coord) 
	local comma = string.find(coord, ',')
	return tonumber(string.sub(coord, 0, comma-1)), tonumber(string.sub(coord, comma+1))
end

function day20_enhance(image, alg, padding)
	local image2 = {}
	local min_x = nil 
	local max_x = nil 
	local min_y = nil 
	local max_y = nil 
	for k,v in pairs(image) do 
		local x,y = day20_coordsplit(k)
		if min_x == nil or min_x > x then 
			min_x = x
		end
		if max_x == nil or max_x < x then 
			max_x = x
		end
		if min_y == nil or min_y > y then 
			min_y = y
		end
		if max_y == nil or max_y < y then 
			max_y = y
		end
	end
	
	for y = min_y-padding,max_y+padding do 
		for x = min_x-padding, max_x+padding do 
			image2[day9_coord(x,y)] = day20_enhancexy(image, alg, x,y)
		end
	end
	return image2
end

function day20_print(image ) 
	local min_x = nil 
	local max_x = nil 
	local min_y = nil 
	local max_y = nil 
	for k,v in pairs(image) do 
		--print(k,v)
		local x,y = day20_coordsplit(k)
		if min_x == nil or min_x > x then 
			min_x = x
		end
		if max_x == nil or max_x < x then 
			max_x = x
		end
		if min_y == nil or min_y > y then 
			min_y = y
		end
		if max_y == nil or max_y < y then 
			max_y = y
		end
	end
	local litcount = 0
	for y = min_y-2,max_y+2 do 
		for x = min_x-2, max_x + 2 do 
			io.write(image[day9_coord(x,y)] == 1 and '#' or '.')
			if image[day9_coord(x,y)] == 1 then 
				litcount = litcount + 1
			end
		end
		print("")
	end
end

function day20(path) 
	local lines = readLines(path)
	
	local alg = {}
	for i = 1, string.len(lines[1]) do 
		if string.sub(lines[1], i, i) == '#' then 
			table.insert(alg, 1)
		else 
			table.insert(alg, 0)
		end
	end
	local image = {}
	local height = #lines - 2
	local width = string.len(lines[3])
	for i = 3,#lines do
		for j = 1,string.len(lines[i]) do 
			image[day9_coord(j,i-2)] = string.sub(lines[i], j, j) == '#' and 1 or 0
		end
	end
		
	local part1 = 0
	local part2 = 0
			
	-- enhance up to 10 pixels around the image area
	local imageA = day20_enhance(image, alg,10)
	-- the void flips bits each enhancement step, so is off on enhancement 2
	imageA = day20_enhance(imageA, alg,10)
	for i = -4,height+4 do 
		for j = -4,width+4 do
			if imageA[day9_coord(j,i)] == 1 then 
				part1 = part1 + 1
			end
		end
	end
	print(string.format("Part 1: %d", part1))
		
	-- padding for propagation waves moving in from the edge
	local imageB = day20_enhance(image, alg, 102)
	for i = 2,50 do
		imageB = day20_enhance(imageB, alg, 2)
	end
	
	for i = -55,height+55 do 
		for j = -55,width+55 do
			if imageB[day9_coord(j,i)] == 1 then 
				part2 = part2 + 1
			end
		end
	end
	
	print(string.format("Part 2: %d", part2))
 
 end
 