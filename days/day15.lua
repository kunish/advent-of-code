function day15_risk(grid, width, height, x, y)
	local x_div = math.floor((x-1)/(width))
	local x_mod = (x-1) % width
	local y_div = math.floor((y-1)/(height))
	local y_mod = (y-1) % height
	local inc = x_div + y_div
	return (((grid[day9_coord(x_mod + 1, y_mod + 1)] - 1) + inc) % 9) + 1
	
end

-- priority queue ordered by dist
function day15_queue_insert(queue, val, dist)
	local i = 1
	while i < #queue do 
		if queue[i].dist > dist then 
			break
		end
		i = i + 1
	end
	local entry = {}
	entry.dist = dist
	entry.val = val 
	table.insert(queue, i, entry)
end

function day15_dijkstra(grid, width, height, dest_x, dest_y)
	local seen = {}
	local queue = {}
	local dists = {}
	local start_coord = day9_coord(1,1)
	local dest_coord = day9_coord(dest_x, dest_y)
	dists[start_coord] = 0
	day15_queue_insert(queue, {1,1}, 0)
	
	local seen_count = 0
	
	while #queue > 0 do
		local min_i = -1
		local min_dist = -1
		
		-- lowest dist node should be at front of queue 
		local coord = table.remove(queue, 1)
		
		local x = coord.val[1]
		local y = coord.val[2]
		local xy = day9_coord(x, y)
		if not seen[xy] then 
			seen[xy] = true
			seen_count = seen_count + 1
			
			local dist = dists[xy]
			local node_dist = day15_risk(grid, width, height, x, y)
			local best_dist = dist
			
			local neighbors = {}
			if x > 1 then 
				table.insert(neighbors, {x-1, y})
			end 
			if x < dest_x then 
				table.insert(neighbors, {x+1,y})
			end
			if y > 1 then 
				table.insert(neighbors, {x, y-1})
			end 
			if y < dest_y then 
				table.insert(neighbors, {x,y+1})
			end
			
			for i = 1, #neighbors do 
				local xy2 = day9_coord(neighbors[i][1],neighbors[i][2])
				if dists[xy2] ~= nil and dists[xy2] + day15_risk(grid, width, height, neighbors[i][1],neighbors[i][2]) < best_dist then 
					best_dist = dists[xy2] + day15_risk(grid, width, height, neighbors[i][1],neighbors[i][2]) 
				end
			end
			
			if best_dist < dists[xy] then 
				dists[xy] = best_dist
			end
			
			-- update neighbors and add unseen ones to queue
			-- if dist is changed, a new queue entry is added
			-- even if a previous queue entry exists.
			-- multiple queue entries will be ignored after the
			-- first time the node is seen.
			
			for i = 1, #neighbors do 
				local xy2 = day9_coord(neighbors[i][1],neighbors[i][2])
				local dist_changed = false
				if dists[xy2] == nil then 
					dists[xy2] = best_dist + node_dist
					dist_changed = true
				elseif dists[xy2] > best_dist + node_dist then 
					dists[xy2] = best_dist + node_dist
					dist_changed = true
				end
				if not seen[xy2] and dist_changed then 
					day15_queue_insert(queue, {neighbors[i][1],neighbors[i][2]}, dists[xy2])
				end
			end
			
		end
	end
	
	return dists[day9_coord(dest_x, dest_y)] + day15_risk(grid, width, height, dest_x, dest_y) - day15_risk(grid, width, height, 1, 1)
end


function day15(path) 
	local lines = readLines(path)
	
	local width = string.len(lines[1])
	local height = #lines
	local grid = {}
	for i = 1,#lines do 
		for j = 1, string.len(lines[i]) do 
			grid[day9_coord(j,i)] = tonumber(string.sub(lines[i],j,j))
		end
	end
	
	
	local part1 = day15_dijkstra(grid, width, height, width, height)
	print(string.format("Part 1: %d", part1))
	
	local part2 = day15_dijkstra(grid, width, height, width*5, height*5)
	print(string.format("Part 2: %d", part2))
 
 end
 
