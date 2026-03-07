
function day18_string(node) 
	local ret = "["
	if node.left.value == nil then 
		ret = ret .. day18_string(node.left)
	else 
		ret = ret .. string.format("%d", node.left.value)
	end
	ret = ret .. ","
	if node.right.value == nil  then 
		ret = ret .. day18_string(node.right)
	else 
		ret = ret .. string.format("%d", node.right.value)
	end
	ret = ret .. "]"
	return ret
end

function day18_magnitude(node) 
	if node.value ~= nil then 
		return node.value
	end
	return 3*day18_magnitude(node.left) + 2*day18_magnitude(node.right)
end

function day18_add(a,b) 
	local node = {}
	node.left = a
	node.right = b 
	node.left.parent = node
	node.right.parent = node
	node.value = nil
	return node
end

function day18_explode(node, depth) 
	if node.value ~= nil then 
		return false 
	end
	if depth > 4 then 
		-- if at leaves
		if node.left.value ~= nil and node.right.value ~= nil then 
			local leftval = node.left.value
			local rightval = node.right.value
			node.value = 0
			node.left = nil
			node.right = nil
			-- move left
			local upnode = node.parent 
			local thisnode = node
			while upnode ~= nil and thisnode == upnode.left do 
				thisnode = upnode
				upnode = thisnode.parent
			end
			if upnode ~= nil then 
				local downnode = upnode.left
				while downnode.value == nil do 
					downnode = downnode.right
				end 
				downnode.value = downnode.value + leftval
			end
			-- move right
			upnode = node.parent
			thisnode = node 
			while upnode ~= nil and thisnode == upnode.right do 
				thisnode = upnode
				upnode = thisnode.parent
			end
			if upnode ~= nil then 
				local downnode = upnode.right
				while downnode.value == nil do 
					downnode = downnode.left
				end 
				downnode.value = downnode.value + rightval
			end
			return true
		end
	end
	
	local left = false
	local right = false
	if node.left.value == nil then 
		left = day18_explode(node.left, depth + 1)
	end
	if left then 
		return true 
	end
	if node.right.value == nil then 
		right = day18_explode(node.right, depth + 1)
	end 
	return right
	
	--return false
end

function day18_split(node) 
	local split = false
	if node.left.value ~= nil then
		if  node.left.value > 9 then 
			local leftval = node.left.value
			node.left.value = nil
			node.left.left = {}
			node.left.right = {}
			node.left.left.value = math.floor(leftval/2)
			node.left.left.parent = node.left
			node.left.right.value = math.ceil(leftval/2)
			node.left.right.parent = node.left
			return true
		end
	else 
		local left = day18_split(node.left)
		if left then 
			return true 
		end
	end
	
	if node.right.value ~= nil then  
		if node.right.value > 9 then 
			local rightval = node.right.value
			node.right.value = nil
			node.right.left = {}
			node.right.right = {}
			node.right.left.value = math.floor(rightval/2)
			node.right.left.parent = node.right
			node.right.right.value = math.ceil(rightval/2)
			node.right.right.parent = node.right
			return true
		end
	else 
		return day18_split(node.right)
	end
	
	
end

function day18_reduce(a)
	local explode = day18_explode(a,1)
	if explode then 
		return true 
	end
	local split = day18_split(a)
	return split
end

function day18_line(line)
	local _,count = line:gsub(",","")
	if( count == 0) then
		local node = {}
		node.left = nil
		node.right = nil
		node.value = tonumber(line)
		node.parent = nil
		return node
	end
	
	local node = {}
	local start = 1
	local finish = 1
	local mid = 1
	local depth = 0
	while finish < string.len(line) and depth >= 0  do
		if string.sub(line, finish, finish) == '[' then 
			depth = depth + 1
		elseif string.sub(line, finish, finish) == ']' then 
			depth = depth - 1
		elseif string.sub(line, finish,finish) == ',' and depth == 1 then 
			mid = finish
		elseif string.sub(line, finish,finish) == ',' then 
		end
		finish = finish + 1
	end
	local node = {}
	node.left = day18_line(string.sub(line, start+1, mid-1))
	node.left.parent = node
	node.right = day18_line(string.sub(line, mid+1, finish-1))
	node.right.parent = node 
	node.value = nil
	node.parent = nil
	return node
end

function day18(path) 
	local lines = readLines(path)
	
	local fishsum = day18_line(lines[1])
	for i=2,#lines do 
		fishsum = day18_add(fishsum, day18_line(lines[i]))
		while true do 
			if not day18_reduce(fishsum) then 
				break
			end
		end
	end
	
	local part1 = day18_magnitude(fishsum)
	print(string.format("Part 1: %d", part1))
	
	local part2 = nil
	for i = 1,#lines do 	
		for j = 1,#lines do 
			if j ~= i then 
				local fishpair = day18_line(lines[i])
				fishpair = day18_add(fishpair, day18_line(lines[j]))
				while true do 
					if not day18_reduce(fishpair) then 
						break
					end
				end
				local magnitude = day18_magnitude(fishpair)
				if part2 == nil or magnitude > part2 then 
					part2 = magnitude
				end
			end
		end
	end
	
	print(string.format("Part 2: %d", part2))
	
	
	
 end
 