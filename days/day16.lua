function day16_bitaccess(str, pos)
	local pos_i = math.floor((pos-1)/4)
	local pos_b = (pos - 1) % 4
	local c = string.sub(str, pos_i+1, pos_i+1)
	local b = tonumber("0x" .. c)
	if (b >> (3-pos_b)) & 0x1 == 1 then 
		return true
	else 
		return false
	end
end

function day16_packet(arr, start)
	local packet = {}
	packet.version = day16_toint(arr, start, start + 2)
	packet.typeid = day16_toint(arr, start+3,start + 5)
	packet.value = 0
	packet.lengthtype = -1
	packet.operator = 0
	packet.children = {}
	local index = start + 6
	if packet.typeid == 4 then 
		local val = 0
		local chunks = {}
		while true do 
			local last = (not arr[index])
			local chunk = day16_toint(arr, index + 1, index + 4)
			table.insert(chunks, chunk)
			index = index + 5
			if last then 
				break
			end
		end
		for i = 1,#chunks do 
			val = val | (chunks[i] << 4 * (#chunks - i))
		end
		packet.value = val
	else 
		if arr[index] == false then 
			packet.lengthtype = 0
		else 
			packet.lengthtype = 1
		end
		index = index + 1
		if packet.lengthtype == 0 then 
			local length = day16_toint(arr, index, index+14)
			index = index + 15
			local subpacketstart = index
			while index < subpacketstart + length - 1 do 
				 local subpacket, position = day16_packet(arr, index)
				 index = position
				 table.insert(packet.children, subpacket)
			end
		else
			local numpackets = day16_toint(arr,index,index+10)
			index = index + 11
			local packetcount = 0
			while packetcount < numpackets do 
				local subpacket, position = day16_packet(arr, index)
				index = position
				table.insert(packet.children, subpacket)
				packetcount = packetcount + 1
			end
		end
		
	end
	return packet, index
end

function day16_bit(boolval) 
	if boolval then return 1 end 
	return 0
end

function day16_part1(packet) 
	local sum = packet.version
	for i=1,#packet.children do 
		sum = sum + day16_part1(packet.children[i])
	end
	return sum
end

function day16_part2(packet)
	if packet.typeid == 0 then 
		local sum = 0
		for i = 1,#packet.children do 
			sum = sum + day16_part2(packet.children[i])
		end
		return sum
	elseif packet.typeid == 1 then 
		local product = 1
		for i = 1,#packet.children do 
			product = product * day16_part2(packet.children[i])
		end
		return product
	elseif packet.typeid == 2 then 
		local m = nil 
		for i = 1,#packet.children do 
			local val = day16_part2(packet.children[i])
			if m == nil or val < m then 
				m = val
			end
		end
		return m
	elseif packet.typeid == 3 then 
		local m = nil 
		for i = 1,#packet.children do 
			local val = day16_part2(packet.children[i])
			if m == nil or val > m then 
				m = val
			end
		end
		return m
	elseif packet.typeid == 4 then 
		return packet.value
	elseif packet.typeid == 5 then 
		local valA = day16_part2(packet.children[1])
		local valB = day16_part2(packet.children[2])
		if valA > valB then 
			return 1
		else 
			return 0
		end
	elseif packet.typeid == 6 then 
		local valA = day16_part2(packet.children[1])
		local valB = day16_part2(packet.children[2])
		if valA < valB then 
			return 1
		else 
			return 0
		end
	elseif packet.typeid == 7 then 
		local valA = day16_part2(packet.children[1])
		local valB = day16_part2(packet.children[2])
		if valA == valB then 
			return 1
		else 
			return 0
		end
	end
	return 0
end

function day16_toint(arr, start, finish)
	local length = finish - start
	if length > 31 or length < 1 then
		print("bad")
		return -1
	end
	local r = 0
	for i = start,finish do 
		r = r | (day16_bit(arr[i]) << (finish-i))
	end
	return r
end

function day16(path) 
	local lines = readLines(path)
	
	local hex = lines[1]
	local i = 1 
	local arr = {}
	while i <= string.len(hex)*4 do 
		table.insert(arr, day16_bitaccess(hex, i))
		i = i + 1
	end
	
	local versions = {}
	
	local packet,index = day16_packet(arr, 1)
	
	local part1 = day16_part1(packet) 
	local part2 = day16_part2(packet) 
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 