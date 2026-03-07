
function day23_charval(chr) 
	if chr == 'A' then 
		return 1
	elseif chr == 'B' then 
		return 2 
	elseif chr == 'C' then 
		return 3
	elseif chr == 'D' then 
		return 4
	end
	return 0
end

function day23_init_state(positions, part1) 
	local state = {}
	state.part1 = part1
	state.cost = 0
	state.positions = {}
	for i = 1,7 do 
		table.insert(state.positions, 0)
	end
	if state.part1 then 
		table.insert(state.positions, day23_charval(positions[1])) -- 8
		table.insert(state.positions, day23_charval(positions[2])) -- 9
		table.insert(state.positions, day23_charval(positions[3])) -- 10
		table.insert(state.positions, day23_charval(positions[4])) -- 11
		
		table.insert(state.positions, day23_charval(positions[5])) -- 12
		table.insert(state.positions, day23_charval(positions[6])) -- 13
		table.insert(state.positions, day23_charval(positions[7])) -- 14
		table.insert(state.positions, day23_charval(positions[8])) -- 15
	else 
		table.insert(state.positions, day23_charval(positions[1])) -- 8
		table.insert(state.positions, day23_charval(positions[2])) -- 9
		table.insert(state.positions, day23_charval(positions[3])) -- 10
		table.insert(state.positions, day23_charval(positions[4])) -- 11
		
		table.insert(state.positions, day23_charval('D'))
		table.insert(state.positions, day23_charval('C'))
		table.insert(state.positions, day23_charval('B'))
		table.insert(state.positions, day23_charval('A'))
		table.insert(state.positions, day23_charval('D'))
		table.insert(state.positions, day23_charval('B'))
		table.insert(state.positions, day23_charval('A'))
		table.insert(state.positions, day23_charval('C'))
		
		table.insert(state.positions, day23_charval(positions[5])) -- 20
		table.insert(state.positions, day23_charval(positions[6])) -- 21
		table.insert(state.positions, day23_charval(positions[7])) -- 22
		table.insert(state.positions, day23_charval(positions[8])) -- 23
	end
	
	return state
end

function day23_copy_state(state) 
	local state2 = {}
	state2.cost = state.cost
	state2.part1 = state.part1
	state2.positions = {}
	for i = 1,#state.positions do 
		table.insert(state2.positions, state.positions[i])
	end
	return state2
end

function day23_str_from_key(key)
	local ret = ''
	for i = 1,15 do 
		local val = (key >> ((i-1) * 3)) & 0x7
		if val == 0 then 
			ret = ret .. '.'
		elseif val == 1 then 
			ret = ret .. 'A'
		elseif val == 2 then 
			ret = ret .. 'B'
		elseif val == 3 then 
			ret = ret .. 'C'
		elseif val == 4 then 
			ret = ret .. 'D'
		else 
			ret = ret .. 'X'
		end
	end
	return ret
end

function day23_state_key(state) 
	local result = 0
	for i = 1,#state.positions do
		local val = state.positions[i]
		result = result | ((val & 0x7) << ((i-1) * 3))
	end
	return result
end

function day23_gen_key(str)
	local result = 0
	for i = 1,string.len(str) do
		local val = 0
		if string.sub(str,i,i) == 'A' then 
			val = 1
		elseif string.sub(str,i,i) == 'B' then 
			val = 2
		elseif string.sub(str,i,i) == 'C' then 
			val = 3
		elseif string.sub(str,i,i) == 'D' then 
			val = 4
		end
		result = result | (val << ((i-1) * 3))
	end
	return result
end

function day23_coord_from_pos(pos) 
	local row1x = {1,2,4,6,8,10,11}
	if pos < 8 then 
		return row1x[pos],1
	else 
		return 3+(((pos-8) % 4)*2), 2+math.floor((pos - 8)/4)
	end
end

function day23_pos_from_coord(x,y) 
	local row1 = {1,2,-1,3,-1,4,-1,5,-1,6,7}
	if y == 1 then 
		return row1[x]
	else 
		return math.floor((x-3)/2) + ((y) * 4)
	end
end

function day23_move(startpos, endpos, state) 
	if state.positions[endpos] ~= 0 or state.positions[startpos] == 0 then 
		return false
	end
	state.positions[endpos] = state.positions[startpos]
	state.positions[startpos] = 0
	return true 
end

function day23_occupied(x,y,state)
	if y == 1 and (x == 3 or x == 5 or x == 7 or x == 9) then 
		return false
	end
	return state.positions[day23_pos_from_coord(x,y)] ~= 0 
end

-- build a cache of all moves from all positions to all other positions
-- for faster evaluation day23_can_reach
function day23_movecache()
	local movecache = {}
	for i = 1,23 do 
		movecache[i] = {}
		for j = 1,23 do 
			movecache[i][j] = {}
			if i ~= j then 
				local x1,y1 = day23_coord_from_pos(i)
				local x2,y2 = day23_coord_from_pos(j)
				local x = x1
				local y = y1
				movecache[i][j] = {}
				if x ~= x2 then 
					while y > 1 do 
						y = y - 1 
						table.insert(movecache[i][j], {x,y})
					end
					while x ~= x2 do 
						if x < x2 then 
							x = x + 1
						else 
							x = x - 1
						end
						table.insert(movecache[i][j], {x,y})
					end
					while y < y2 do 
						y = y + 1
						table.insert(movecache[i][j], {x,y})
					end
				else 
					while y ~= y2 do 
						if y < y2 then 
							y = y + 1
						else 
							y = y - 1
						end 
						table.insert(movecache[i][j], {x,y})
					end 
				end
			end
		end
	end
	return movecache
end

-- returns nil if unreachable, distance otherwise
function day23_can_reach(i,j,state, movecache) 
	local steps = 0
	if i == j then 
		return nil
	end 
	
	for k = 1,#movecache[i][j] do 
		local x = movecache[i][j][k][1]
		local y = movecache[i][j][k][2]
		if day23_occupied(x,y,state) then 
			return nil
		end
	end
	
	return #movecache[i][j]
end

function day23_moves(index, state, movecache) 
	local moves = {}
	local x,y = day23_coord_from_pos(index)
	local me = state.positions[index]
	local room_x = 0
	if me == 1 then 
		room_x = 3
	elseif me == 2 then 
		room_x = 5
	elseif me == 3 then 
		room_x = 7
	elseif me == 4 then 
		room_x = 9
	end

	local inroom_x = (room_x == x)
	local okroom_x = true 
	for y1 = 2,(state.part1 and 3 or 5) do 
		if state.positions[day23_pos_from_coord(room_x,y1)] ~= 0 and  state.positions[day23_pos_from_coord(room_x,y1)] ~= me then 
			okroom_x = false
			break
		end
	end
	
	-- amphipod done, should not move
	if inroom_x and okroom_x then 
		return {}
	end
	
	-- find first available slot in destination room if okay to enter
	local dest_room_i = day23_pos_from_coord(room_x, state.part1 and 3 or 5)
	if not okroom_x then 
		dest_room_i = nil 
	else 
		while dest_room_i > 7 do 
			if state.positions[dest_room_i] ~= 0 then 
				dest_room_i = dest_room_i - 4
			else 
				break
			end
		end
		if dest_room_i < 8 then 
			dest_room_i = nil
		end
	end
	
	-- try to move to destination room
	if not inroom_x and okroom_x and dest_room_i ~= nil then 
		local dist = day23_can_reach(index, dest_room_i, state, movecache)
		if dist ~= nil then 
			table.insert(moves, {dest_room_i, dist})
			return moves
		end
	-- destination room not available, try hallway
	elseif y > 1 then
		for i = 1,7 do 
			local dist = day23_can_reach(index, i, state, movecache)
			if dist ~= nil then 
				table.insert(moves, {i, dist})
			end
		end
	end
	return moves
end

function day23_solve(state, movecache, part1)
	
	local finalkey = day23_gen_key('.......ABCDABCD')
	if not part1 then 
		finalkey = day23_gen_key('.......ABCDABCDABCDABCD')
	end
	
	local states = {}
	local queue = {}
	table.insert(queue, state)
	
	while #queue > 0 do
		-- dfs instead of bfs lets us hit an end state more quickly and provides
		-- an upper bound to discard queued states
		local curr_state = table.remove(queue,#queue) 
		local curr_state_key = day23_state_key(curr_state) 
		local finalcost = states[finalkey]
		
		-- don't bother evaluating further positions from this state if we've already 
		-- found a path to completion with a lower cost or if this state has already 
		-- been reached with a lower cost
		if (finalcost == nil or finalcost > curr_state.cost) and (states[curr_state_key] == nil or (states[curr_state_key] > curr_state.cost)) then 
			states[curr_state_key] = curr_state.cost
			for i = 1,#curr_state.positions do 
				if curr_state.positions[i] ~= 0 then 
					local x,y = day23_coord_from_pos(i)
					local moves = day23_moves(i,curr_state, movecache)
					for j = 1,#moves do 
						local movepos = moves[j][1]
						local movedist = moves[j][2]
						local newstate = day23_copy_state(curr_state)
						
						local cost = movedist
						local amphipod = newstate.positions[i]
						if amphipod == 2 then 
							cost = cost * 10 
						elseif amphipod == 3 then 
							cost = cost * 100
						elseif amphipod == 4 then 
							cost = cost * 1000
						end
						day23_move(i, movepos, newstate)
						newstate.cost = newstate.cost + cost
						
						local newstate_key = day23_state_key(newstate)
						if states[newstate_key] == nil or states[newstate_key] > newstate.cost then 
							table.insert(queue, newstate)
						end
						-- don't need to evaluate any other moves from this position
						if newstate_key == finalkey then 
							break 
						end
					end
				
				end
				
			end
		end
	end
	
	return states[finalkey]
end

function day23(path) 
	local lines = readLines(path)
	
	local positions = {string.sub(lines[3], 4, 4), string.sub(lines[3], 6, 6), string.sub(lines[3], 8, 8), string.sub(lines[3], 10, 10),
						string.sub(lines[4], 4, 4), string.sub(lines[4], 6, 6), string.sub(lines[4], 8, 8), string.sub(lines[4], 10, 10)}
	
	local movecache = day23_movecache()
	local state1 = day23_init_state(positions, true)
	local state2 = day23_init_state(positions, false)
	
	local part1 = day23_solve(state1, movecache, true)
	print(string.format("Part 1: %d", part1))
	
	local part2 = day23_solve(state2, movecache, false)
	print(string.format("Part 2: %d", part2))
	
 end
 