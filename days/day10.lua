
function day10_round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

 function day10(path) 
	local lines = readLines(path)
	
	
	local part1 = 0
	local part2 = 0
	local part2_scores = {}
	for i = 1,#lines do 
		local char_stack = {}
		local bad = false
		for j = 1,string.len(lines[i]) do 
			local chr = string.sub(lines[i],j,j)
			if chr == '(' or chr == '[' or chr == '{' or chr == '<' then 
				table.insert(char_stack, chr)
			else 
				local chr2 = table.remove(char_stack, #char_stack)
				if chr == ')' and chr2 ~= '(' then 
					part1 = part1 + 3
					bad = true
				elseif chr == ']' and chr2 ~= '[' then
					part1 = part1 + 57
					bad = true
				elseif chr == '}' and chr2 ~= '{' then
					part1 = part1 + 1197
					bad = true
				elseif chr == '>' and chr2 ~= '<' then
					part1 = part1 + 25137
					bad = true
				end
			end
			if bad then 
				break
			end
		end
		if not bad then 
			local total_score = 0
			for j = #char_stack,1,-1 do 
				total_score = total_score * 5
				local pop_char = char_stack[j]
				if pop_char == '(' then 
					total_score = total_score + 1
				elseif pop_char == '[' then 
					total_score = total_score + 2
				elseif pop_char == '{' then 
					total_score = total_score + 3
				elseif pop_char == '<' then 
					total_score = total_score + 4
				end
			end
			part2_scores[#part2_scores + 1] = total_score
		end
	end

	table.sort(part2_scores)	
	part2 = part2_scores[day10_round((#part2_scores)/2)]
	
	print(string.format("Part 1: %d", part1))
	print(string.format("Part 2: %d", part2))
 
 end
 