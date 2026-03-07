
function day22_coord(x,y,z) 
	return string.format("%d,%d,%d", x,y,z)
end

-- if vol2 entirely within vol1
function day22_contained(volume1, volume2) 
	return 	volume2.x1 >= volume1.x1 and volume2.x1 <= volume1.x2 and 
			volume2.x2 >= volume1.x1 and volume2.x2 <= volume1.x2 and 
			volume2.y1 >= volume1.y1 and volume2.y1 <= volume1.y2 and 
			volume2.y2 >= volume1.y1 and volume2.y2 <= volume1.y2 and
			volume2.z1 >= volume1.z1 and volume2.z1 <= volume1.z2 and 
			volume2.z2 >= volume1.z1 and volume2.z2 <= volume1.z2 
end

function day22_overlap(volume1, volume2) 
	return (( 
				(volume2.x1 >= volume1.x1 and volume2.x1 <= volume1.x2) or 
				(volume2.x2 >= volume1.x1 and volume2.x2 <= volume1.x2) or
				(volume1.x1 >= volume2.x1 and volume1.x1 <= volume2.x2) or
				(volume1.x2 >= volume2.x1 and volume1.x2 <= volume2.x2)
			) 
				and 
			( 
				(volume2.y1 >= volume1.y1 and volume2.y1 <= volume1.y2) or 
				(volume2.y2 >= volume1.y1 and volume2.y2 <= volume1.y2) or
				(volume1.y1 >= volume2.y1 and volume1.y1 <= volume2.y2) or
				(volume1.y2 >= volume2.y1 and volume1.y2 <= volume2.y2)
			) 
				and 
			( 
				(volume2.z1 >= volume1.z1 and volume2.z1 <= volume1.z2) or 
				(volume2.z2 >= volume1.z1 and volume2.z2 <= volume1.z2) or
				(volume1.z1 >= volume2.z1 and volume1.z1 <= volume2.z2) or
				(volume1.z2 >= volume2.z1 and volume1.z2 <= volume2.z2)
			))
end

-- returns nil if no intersection in x, otherwise gives coord of dividing plane for adding vol2 to vol1
function day22_intersection_plane_x(volume1, volume2) 
	-- can't split, too small
	if volume2.x2 - volume2.x1 < 1 then 
		return nil
	end
	-- no intersection
	if volume1.x2 < volume2.x1 then 
		return nil
	elseif volume1.x1 > volume2.x2 then
		return nil
	-- vol1 contains vol2 
	elseif volume1.x1 <= volume2.x1 and volume1.x2 >= volume2.x2 then 
		return nil
	-- vol2 contains vol1 - more than one split, pick vol1.x1
	elseif volume2.x1 <= volume1.x1 and volume2.x2 >= volume1.x2 then 
		return volume1.x1
	-- vol2 higher, split at vol1.x2
	elseif volume1.x1 < volume2.x1 and volume1.x2 < volume2.x2 then 
		return volume1.x2
	else
		return (volume1.x1 - 1)
	end
end

-- returns nil if no intersection in y, otherwise gives coord of dividing plane for adding vol2 to vol1
function day22_intersection_plane_y(volume1, volume2) 
	-- can't split, too small
	if volume2.y2 - volume2.y1 < 1 then 
		return nil
	end
	-- no intersection
	if volume1.y2 < volume2.y1 then 
		return nil
	elseif volume1.y1 > volume2.y2 then
		return nil
	-- vol1 contains vol2 
	elseif volume1.y1 <= volume2.y1 and volume1.y2 >= volume2.y2 then 
		return nil
	-- vol2 contains vol1
	elseif volume2.y1 <= volume1.y1 and volume2.y2 >= volume1.y2 then 
		return volume1.y1
	-- vol2 higher, split at vol1.y2
	elseif volume1.y1 < volume2.y1 and volume1.y2 < volume2.y2 then 
		return volume1.y2
	-- intersecting plane at volume2 y1
	else
		return (volume1.y1 - 1)
	end
end

-- returns nil if no intersection in z, otherwise gives coord of dividing plane for adding vol2 to vol1
function day22_intersection_plane_z(volume1, volume2) 
	-- can't split, too small
	if volume2.z2 - volume2.z1 < 1 then 
		return nil
	end
	-- no intersection
	if volume1.z2 < volume2.z1 then 
		return nil
	elseif volume1.z1 > volume2.z2 then
		return nil
	-- vol1 contains vol2 
	elseif volume1.z1 <= volume2.z1 and volume1.z2 >= volume2.z2 then 
		return nil
	-- vol2 contains vol1
	elseif volume2.z1 <= volume1.z1 and volume2.z2 >= volume1.z2 then 
		return volume1.z1
	-- vol2 higher, split at vol1.z2
	elseif volume1.z1 < volume2.z1 and volume1.z2 < volume2.z2 then 
		return volume1.z2
	-- intersecting plane at volume2 z1
	else
		return (volume1.z1 - 1)
	end
end

-- note, only one of x,y or z should be set for expected behavior
function day22_split(vol, x, y, z) 
	if x ~= nil then 
		if x < vol.x1 or x > vol.x2 then 
			return vol, nil
		else 
			local vol1 = day22_volume_init(vol.x1, x, vol.y1,vol.y2,vol.z1,vol.z2, vol.val)
			local vol2 = day22_volume_init(x+1, vol.x2, vol.y1,vol.y2,vol.z1,vol.z2, vol.val)
			return vol1, vol2
		end
	end
	if y ~= nil then 
		if y < vol.y1 or y > vol.y2 then 
			return vol, nil
		else 
			local vol1 = day22_volume_init(vol.x1, vol.x2, vol.y1,y,vol.z1,vol.z2, vol.val)
			local vol2 = day22_volume_init(vol.x1, vol.x2, y+1,vol.y2,vol.z1,vol.z2, vol.val)
			return vol1, vol2
		end
	end
	if z ~= nil then 
		if z < vol.z1 or z > vol.z2 then 
			return vol, nil
		else 
			local vol1 = day22_volume_init(vol.x1, vol.x2, vol.y1, vol.y2, vol.z1, z, vol.val)
			local vol2 = day22_volume_init(vol.x1, vol.x2, vol.y1, vol.y2, z+1, vol.z2, vol.val)
			return vol1, vol2
		end
	end
	
	return vol, nil
end

function day22_volume_init(x1,x2,y1,y2,z1,z2,val)
	return {x1 = x1, x2 = x2, y1 = y1, y2 = y2, z1 = z1, z2 = z2, val = val, children = {}}
end

-- add vol2 as a sub-volume of vol1
function day22_add_child(vol1, vol2, depth, split_depth) 
	local contained = day22_contained(vol1, vol2)
	if not contained then 
		print(string.format("%s does not contain %s"), day22_str(vol2), day22_str(vol1))
		return false
	end
	
	-- if the new volume fully contains any child volume, remove the child
	while true do
		local del = false
		for i = 1, #vol1.children do 
			if day22_contained(vol2, vol1.children[i]) then 
				del = true
				table.remove(vol1.children, i)
				break
			end
		end
		if not del then 
			break
		end
	end
	
	if #vol1.children == 0 then
		-- if no children, don't add the new volume if it has the same value 
		if vol1.val ~= vol2.val then 
			vol1.children[#vol1.children + 1] = vol2
		end
		return true 
	end 
	
	-- if the new volume intersects no children
	local intersections = 0
	for i = 1, #vol1.children do 
		if day22_overlap(vol1.children[i], vol2) then 
			intersections = intersections + 1
		end
	end
	if intersections == 0 then 
		-- if the same val, don't bother adding
		if vol1.val ~= vol2.val then 
			vol1.children[#vol1.children + 1] = vol2
		end
		return true
	end
	
	-- if a child fully contains the new volume, add to the child
	for i = 1, #vol1.children do 
		if day22_contained(vol1.children[i],vol2) then 
			return day22_add_child(vol1.children[i], vol2, depth + 1, split_depth)
		end
	end
	
	-- easy options exhausted, now the hard stuff
	-- across all current children find the first overlapping volume where 
	-- vol2 can be split into two subvolumes, one entirely outside of the 
	-- overlapping volume, one at least partly contained within it.
	-- each subdivided volume is recursively added to the volume tree and 
	-- split as necessary until everything is an easy case that can be 
	-- evaluated.
	for i = 1,#vol1.children do 
		if day22_overlap(vol1.children[i], vol2) then 
			local x_plane = day22_intersection_plane_x(vol1.children[i], vol2)
			if x_plane ~= nil then 
				local splitvolA, splitvolB = day22_split(vol2, x_plane, nil, nil)
				if(splitvolA == nil or splitvolB == nil) then 
					-- something went wrong here 
					return false
				end
				day22_add_child(vol1, splitvolA,depth, split_depth + 1)
				day22_add_child(vol1, splitvolB,depth, split_depth + 1)
				return true
			end
			local y_plane = day22_intersection_plane_y(vol1.children[i], vol2)
			if y_plane ~= nil then 
				local splitvolA, splitvolB = day22_split(vol2, nil, y_plane, nil)
				if(splitvolA == nil or splitvolB == nil) then 
					-- something went wrong here 
					return false
				end
				day22_add_child(vol1, splitvolA,depth, split_depth + 1)
				day22_add_child(vol1, splitvolB,depth, split_depth + 1)
				return true
			end
			local z_plane = day22_intersection_plane_z(vol1.children[i], vol2)
			if z_plane ~= nil then 
				local splitvolA, splitvolB = day22_split(vol2, nil, nil, z_plane)
				if(splitvolA == nil or splitvolB == nil) then 
					-- something went wrong here 
					return false
				end
				day22_add_child(vol1, splitvolA,depth, split_depth + 1)
				day22_add_child(vol1, splitvolB,depth, split_depth + 1)
				return true 
			end
		end
	end
		
	return false
end

function day22_vol(vol) 
	return (vol.x2-vol.x1 + 1) * (vol.y2-vol.y1 + 1) * (vol.z2-vol.z1 + 1)
end

function day22_recursive_volume(vol, depth)
	local volume = day22_vol(vol)
	local vol_temp = volume
	for i = 1,#vol.children do 
		volume = volume - day22_recursive_volume(vol.children[i], depth + 1)
	end
	return volume
end

function day22(path) 
	local lines = readLines(path)
	
	local steps = {}
	for i = 1,#lines do --#lines do 
		local substr = string.sub(lines[i], string.find(lines[i],"x=") +2)
		local x_ed, y_st = string.find(substr, ",y=");
		local y_ed, z_st = string.find(substr, ",z=");
		local x_sub = string.sub(substr, 0, x_ed-1)
		local y_sub = string.sub(substr, y_st + 1, y_ed - 1)
		local z_sub = string.sub(substr, z_st+1)
		local index = 1
		while string.sub(x_sub, index, index) ~= '.' do
			index = index + 1
		end
		local x1 = tonumber(string.sub(x_sub, 0,index-1))
		local x2 = tonumber(string.sub(x_sub, index+2))
		index = 1
		while string.sub(y_sub, index, index) ~= '.' do
			index = index + 1
		end
		local y1 = tonumber(string.sub(y_sub, 0,index-1))
		local y2 = tonumber(string.sub(y_sub, index+2))
		index = 1
		while string.sub(z_sub, index, index) ~= '.' do
			index = index + 1
		end
		local z1 = tonumber(string.sub(z_sub, 0,index-1))
		local z2 = tonumber(string.sub(z_sub, index+2))
		
		if string.sub(lines[i],2,2) == 'f' then 
			steps[#steps + 1] = {0, x1, x2, y1, y2, z1, z2}
		else
			steps[#steps + 1] = {1, x1, x2, y1, y2, z1, z2}
		end
	end
	
	local grid = {}
	local min_x = nil
	local max_x = nil
	local min_y = nil
	local max_y = nil
	local min_z = nil
	local max_z = nil
	for i = 1, #steps do 
		if min_x == nil or steps[i][2] < min_x then 
			min_x = steps[i][2] 
		end
		if max_x == nil or steps[i][3] > max_x then 
			max_x = steps[i][3] 
		end
		if min_y == nil or steps[i][4] < min_y then 
			min_y = steps[i][4] 
		end
		if max_y == nil or steps[i][5] > max_y then 
			max_y = steps[i][5] 
		end
		if min_z == nil or steps[i][6] < min_z then 
			min_z = steps[i][6] 
		end
		if max_z == nil or steps[i][7] > max_z then 
			max_z = steps[i][7] 
		end
		
		local x1 = steps[i][2] < -50 and -50 or steps[i][2]
		local x2 = steps[i][3] > 50 and 50 or steps[i][3]
		local y1 = steps[i][4] < -50 and -50 or steps[i][4]
		local y2 = steps[i][5] > 50 and 50 or steps[i][5]
		local z1 = steps[i][6] < -50 and -50 or steps[i][6]
		local z2 = steps[i][7] > 50 and 50 or steps[i][7]
		for x = x1, x2 do 
			for y = y1,y2 do 
				for z = z1,z2 do 
					grid[day22_coord(x,y,z)] = steps[i][1]
				end
			end
		end
	end
	
	local part1 = 0
	local part2 =  0
	
	for k,v in pairs(grid) do 
		if v == 1 then 
			part1 = part1 + 1
		end
	end
	print(string.format("Part 1: %d", part1))
	
	local voltree = day22_volume_init(min_x, max_x, min_y, max_y, min_z, max_z, 0)
	for i = 1, #steps do 
		-- if the next volume is entirely within an existing volume
		-- move down tree to find largest child volume entirely
		-- containing new volume.
		-- within that parent, if no intersection with children -> new child volume
		-- for every child intersection, generate sub-volumes
		-- if a volume is entirely contained within another volume with no children and the same state, it doesn't 
		-- need to be added to the tree
		local vol = day22_volume_init(steps[i][2],steps[i][3],steps[i][4],steps[i][5],steps[i][6],steps[i][7],steps[i][1])
		day22_add_child(voltree, vol, 1, 1)
	end
	
	part2 = 0
	for i=1,#voltree.children do 
		part2 = part2 + day22_recursive_volume(voltree.children[i],2)
	end
	
	print(string.format("Part 2: %d", part2))
 
 end
 