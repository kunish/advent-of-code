
function table.day12_clone(org)
  return {table.unpack(org)}
end

function day12_statekey(statekey, append)
	if string.len(statekey) > 0 then 
		return statekey .. ',' .. append
	else 
		return append
	end
end

function day12_instate(state, node) 
	for i = 1, #state do
		if state[i] == node then 
			return true
		end
	end
	return false
end

-- very crude check but works for the solution
function day12_islower(str)
	if string.byte(string.sub(str,1,1)) >= 97 then
		return true
	end
	return false
end

function day12_explore(state, statekey, nodes, graph, seen)
	if seen[statekey] then 
		return false
	end
	seen[statekey] = true
	if state[#state] == "end" then 
		return true
	end
	local branches = 0
	for i = 1,#nodes do 
		if nodes[i] ~= state[#state] then
			if graph[day12_key(state[#state],nodes[i])] then
				if (not day12_islower(nodes[i]) and not seen[day12_statekey(statekey, nodes[i])]) 
					or (day12_islower(nodes[i]) and not day12_instate(state, nodes[i])) then 
					local newstate = table.day12_clone(state)
					table.insert(newstate, nodes[i])
					day12_explore(newstate, day12_statekey(statekey, nodes[i]), nodes, graph, seen)
				
				end 
			end
		end
	end
	return true
end 

function day12_explore2(state, statekey, nodes, graph, seen, revisited)
	if seen[statekey] then 
		return false
	end
	seen[statekey] = true
	if state[#state] == "end" then 
		return true
	end
	local branches = 0
	for i = 1,#nodes do 
		if nodes[i] ~= state[#state] then
			if graph[day12_key(state[#state],nodes[i])] then
				if (not day12_islower(nodes[i]) ) then 
					local newstate = table.day12_clone(state)
					table.insert(newstate, nodes[i])
					day12_explore2(newstate, day12_statekey(statekey, nodes[i]), nodes, graph, seen, revisited)
				elseif day12_islower(nodes[i]) then 
					if not day12_instate(state, nodes[i]) then 
						local newstate = table.day12_clone(state)
						table.insert(newstate, nodes[i])
						day12_explore2(newstate, day12_statekey(statekey, nodes[i]), nodes, graph, seen, revisited)
					else 
						if revisited == nil and nodes[i] ~= "start" and nodes[i] ~= "end" then 
							local newstate = table.day12_clone(state)
							table.insert(newstate, nodes[i])
							day12_explore2(newstate, day12_statekey(statekey, nodes[i]), nodes, graph, seen, nodes[i])
						end
					end
				end
			end
		end
	end
	return true
end 

function day12_key(a,b) 
	return string.format("%s-%s",a,b)
end

 function day12(path) 
	local lines = readLines(path)
	
	local graph = {}
	local nodes = {}
	for i = 1,#lines do 
		local st,ed = string.find(lines[i], "-")
		local a = string.sub(lines[i], 1, st-1)
		local b = string.sub(lines[i], ed+1)
		graph[day12_key(a,b)] = true
		graph[day12_key(b,a)] = true
		local found = false
		for j = 1, #nodes do 
			if nodes[j] == a then
				found = true
				break
			end
		end
		if not found then 
			nodes[#nodes + 1] = a
		end
		found = false
		for j = 1, #nodes do 
			if nodes[j] == b then
				found = true
				break
			end
		end
		if not found then 
			nodes[#nodes + 1] = b
		end
	end
	
	local seen = {}
	local state = {"start"}
	day12_explore(state, "start", nodes, graph, seen)
	
	local successes = {}
	for k,v in pairs(seen) do 
		if(string.sub(k, 0, string.len("start")) == "start" and string.sub(k, string.len(k) - string.len("end") + 1) == "end") then 
			successes[#successes + 1] = k
		end
	end
	local part1 = #successes
	
	print(string.format("Part 1: %d", part1))
	
	local state2 = {"start"}
	local seen2 = {}
	day12_explore2(state2, "start", nodes, graph, seen2, nil)
	
	local successes2 = {}
	for k,v in pairs(seen2) do
		if(string.sub(k, 0, string.len("start")) == "start" and string.sub(k, string.len(k) - string.len("end") + 1) == "end") then 
			successes2[#successes2 + 1] = k
		end
	end
	local part2 = #successes2
	
	print(string.format("Part 2: %d", part2))
 
 end
 