function day19_matrix_mult(m1, m2) 
	local result = {}
	for i = 1, #m1 do 
		result[i] = {}
		for j = 1, #m2[1] do
			result[i][j] = 0
			for k = 1, #m2 do 
				result[i][j] = result[i][j] +  math.floor(m1[i][k] * m2[k][j])
			end
		end
	end
	
	return result
end

function day19_matrix_vector_mult(m1, v2) 
	local v = {}
	for i = 1, #m1 do 
		v[i] = 0
		for j = 1, #m1[1] do
			v[i] = v[i] + math.floor(v2[j] * m1[i][j])
		end
	end
	return v
end

-- possibly quicker than actual trig
function day19_cos(rot90) 
	if rot90 % 4 == 0 then 
		return 1
	elseif rot90 % 4 == 2 then 
		return -1
	end
	return 0
end

function day19_sin(rot90) 
	if rot90 % 4 == 1 then 
		return 1
	elseif rot90 % 4 == 3 then 
		return -1
	end
	return 0
end

function day19_rot_mat(x,y,z)
	local sin_x = day19_sin(x)
	local cos_x = day19_cos(x)
	local x_rot = { {1,0,0}, {0, cos_x, -sin_x}, {0, sin_x, cos_x} }
	local sin_y = day19_sin(y)
	local cos_y = day19_cos(y)
	local y_rot = { {cos_y,0,sin_y}, {0, 1, 0}, {-sin_y, 0, cos_y} }
	local sin_z = day19_sin(z)
	local cos_z = day19_cos(z)
	local z_rot = { {cos_z,-sin_z,0}, {sin_z, cos_z, 0}, {0, 0, 1} }
	local rotation = day19_matrix_mult(x_rot,y_rot)
	rotation = day19_matrix_mult(rotation, z_rot)
	return rotation
end

-- x,y,z between 0 and 3 representing 90-degree rotations about each axis
-- v a 3-term vector
function day19_rot(v,x,y,z)
	local rotation = day19_rot_mat(x,y,z)
	return day19_matrix_vector_mult(rotation, v)
end

function day19_vector_key(v,xr,yr,zr) 
	return string.format("%d,%d,%d|%d,%d,%d", v[1], v[2], v[3],xr,yr,zr)
end

-- given an undetermined scanner, try all rotations and attempt to match to beacons of known position
function day19_scanner(scanners, beacons, index)
	local vectors = {}
	local cutoff = 3 -- at 3 matches to known beacon positions, consider the beacon determined
	local beaconslist = {}
	for k,v in pairs(beacons) do
		table.insert(beaconslist, v)
	end
	
	local found = false
	for xr = 0, 3 do 
		if found then 
			break
		end
		for yr = 0, 3 do 
			if found then 
				break
			end
			for zr = 0,3 do 
				if found then 
					break
				end
				for i = 1,#scanners[index] do 
					local coord = scanners[index][i]
					local rotated = day19_rot(coord, xr, yr, zr)
					local match_hi = 0
					for k,v in pairs(beacons) do 
						local delta = {v[1] - rotated[1],v[2] - rotated[2], v[3] - rotated[3]}
						local key = day19_vector_key(delta,xr,yr,zr)
						if vectors[key] == nil then 
							vectors[key] = {delta[1], delta[2], delta[3], xr, yr, zr, 1}
						else 
							vectors[key][7] = vectors[key][7] + 1
						end
						if vectors[key][7] > match_hi then 
							match_hi = vectors[key][7]
						end
						if match_hi >= cutoff then 
							found = true
							break
						end
					end
					
				end
			end
		end
	end
	
	local max_match = 0
	local max_key = ""
	for k,v in pairs(vectors) do 
		if v[7] > max_match then 
			max_match = vectors[k][7]
			max_key = k
		end 
	end
	
	if max_match < cutoff then 
		return false
	end
	
	return vectors[max_key]
end

function day19(path) 
	local lines = readLines(path)
	
	local scanners = {}
	local beacons = {}
	local scanner_pos = {}
	local scanner_last = 1
	local scanners_set = 1
	
	local index = 1
	while index <= #lines do 
		if string.sub(lines[index], 1, string.len('--- scanner')) == '--- scanner' then 
			scanners[#scanners + 1] = {}
		elseif string.len(lines[index]) > 0 then 
			local coords = {}
			for str in string.gmatch(lines[index], "([^,]+)") do
				table.insert(coords, tonumber(str))
			end
			
			table.insert(scanners[#scanners], coords)
		end
		index = index + 1
	end
	
	scanner_pos[1] = {x = 0, y = 0, z = 0, xr = 0, yr = 0, zr = 0}
	for i = 1,#scanners[1] do 
		local key = string.format("%d,%d,%d", scanners[1][i][1], scanners[1][i][2], scanners[1][i][3])
		if beacons[key] == nil then 
			beacons[key] = {scanners[1][i][1], scanners[1][i][2], scanners[1][i][3]}
		end
	end
	scanner_last = 1
	
	while scanners_set < #scanners do 
		local found = false
		for i = 1, #scanners do 
			if scanner_pos[i] == nil then 
				local result = day19_scanner(scanners, beacons, i)
				if result ~= false then
					found = true 
					
					local pos = {result[1], result[2], result[3]}
					local rot = {result[4],result[5], result[6]}
					local rot_mat = day19_rot_mat(rot[1],rot[2],rot[3])
					
					for j = 1,#scanners[i] do 
						local beacon_pos = day19_matrix_vector_mult(rot_mat, scanners[i][j])
						local bx = beacon_pos[1] + pos[1]
						local by = beacon_pos[2] + pos[2]
						local bz = beacon_pos[3] + pos[3]
						local key = string.format("%d,%d,%d", bx, by, bz)
						if beacons[key] == nil then 
							beacons[key] = { bx, by, bz }
						end
					end
					
					scanner_pos[i] = {x = pos[1], y = pos[2], z = pos[3], xr = rot[1], yr = rot[2], zr = rot[3]}
					scanners_set = scanners_set + 1
				end
			end
		end
		if not found then 
			break
		end
	end
	
	if scanners_set < #scanners then 
		print("Unable to determine solution")
		return
	end	
	
	local part1 = 0
	local part2 = 0
	
	for k,v in pairs(beacons) do 
		part1 = part1 + 1
	end
	for i = 1,#scanner_pos do 
		for j = i+1,#scanner_pos do 
			local dist = math.abs(scanner_pos[i].x - scanner_pos[j].x) + math.abs(scanner_pos[i].y - scanner_pos[j].y) + math.abs(scanner_pos[i].z - scanner_pos[j].z)
			if dist > part2 then 
				part2 = dist
			end
		end
	end
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
	
	
	
 end
 