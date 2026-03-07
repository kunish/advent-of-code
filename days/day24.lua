
function day24_reg_get(key, reg) 
	if key == 'w' then 
		return reg.w
	elseif key == 'x' then 
		return reg.x
	elseif key == 'y' then 
		return reg.y
	elseif key == 'z' then 
		return reg.z
	end
	return nil
end

function day24_reg_set(key, val,reg) 
	if key == 'w' then 
		reg.w = val
	elseif key == 'x' then 
		reg.x = val 
	elseif key == 'y' then
		reg.y = val 
	elseif key == 'z' then 
		reg.z = val
	end
	return
end

function day24_trunc(val) 
	if val < 0 then 
		return math.ceil(val)
	elseif val > 0 then 
		return math.floor(val)
	else 
		return 0
	end
end

function day24_input_str(input) 
	local ret = ''
	for i = 1,#input do 
		ret = ret .. tostring(input[i])
	end
	return ret
end

function day24_run(prog, inp, registers, limit, start, input_index)
	
	local inp_index = input_index == nil and 1 or input_index
	
	for i = start ~= nil and start or 1,#prog do 
		if limit ~= nil and limit == i then 
			break
		end
		if prog[i].op == 'inp' then
			day24_reg_set(prog[i].a, inp[inp_index], registers)
			inp_index = inp_index + 1
		elseif prog[i].op == 'add' then 
			if not prog[i].b_int then 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) + day24_reg_get(prog[i].b, registers), registers)
			else 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) + prog[i].b_val, registers)
			end
		elseif prog[i].op == 'mul' then 
			if not prog[i].b_int then 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) * day24_reg_get(prog[i].b, registers), registers)
			else 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) * prog[i].b_val, registers)
			end
		elseif prog[i].op == 'div' then 
			if not prog[i].b_int then 
				day24_reg_set(prog[i].a,  day24_trunc(day24_reg_get(prog[i].a, registers) / day24_reg_get(prog[i].b, registers)), registers)
			else 
				day24_reg_set(prog[i].a,  day24_trunc(day24_reg_get(prog[i].a, registers) / prog[i].b_val), registers)
			end
		elseif prog[i].op == 'mod' then 
			if not prog[i].b_int then 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) % day24_reg_get(prog[i].b, registers), registers)
			else 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) % prog[i].b_val, registers)
			end
		elseif prog[i].op == 'eql' then 
			if not prog[i].b_int then 
				day24_reg_set(prog[i].a,  day24_trunc(day24_reg_get(prog[i].a, registers) == day24_reg_get(prog[i].b, registers) and 1 or 0), registers)
			else 
				day24_reg_set(prog[i].a,  day24_reg_get(prog[i].a, registers) == prog[i].b_val and 1 or 0, registers)
			end
		else 
			print("SOMETHING BAD HAS HAPPENED")
		end
	end
end


function day24_inst(line) 
	local inst = {}
	inst.op = string.sub(line, 1,3)
	inst.a = string.sub(line, 5,5) 
	inst.b_int = false
	inst.b_val = 0
	inst.b = nil
	local b = string.sub(line,7)
	if tonumber(b) ~= nil then 
		inst.b_int = true
		inst.b_val = tonumber(b) 
	else 
		inst.b_int = false
		inst.b = b
	end
	return inst
end


--[[
Okay, I think I understand how this works. The z register functions as an odd 
stack, with items added by shifting the stack down by multiplying z by 26 and 
arithmetically adding the item to z and popped by taking the z mod 26 to obtain 
the top item and then dividing z by 26 to shift the stack up. The program also 
includes terms added to the input item when it is popped and pushed.

I don't actually know if 26 is the stack shifting value in every puzzle input 
or just mine, but this function doesn't assume it.

If (popped previous input) + (current pop term) + (previous push term) isn't 
equal to the current input, the model number is invalid. This gives upper and 
lower bounds on what a valid pushed input can be and knowing a pushed input you 
can determine the valid pop input to go with it. Since the push inputs all 
appear earlier in the input string than pop inputs, this lets us determine the 
highest or lowest valid model number.
--]]

function day24_solve(instructions) 
	local params = {}
	local digits = {}
	local stack = {}
	for i = 1,#instructions,18 do
		local digit = math.floor(i/18) + 1
		local div = instructions[i + 4].b_val
		local pop_term = instructions[i + 5].b_val
		local push_term = instructions[i + 15].b_val
		local is_pushed = div == 1
		table.insert(params, {is_pushed = is_pushed, pop = pop_term, push = push_term})
		if is_pushed then 
			table.insert(stack, #params)
		else 
			local pop_index = table.remove(stack, #stack)
			if pop_term + params[pop_index].push > 0 then 
				digits[pop_index] = {is_pushed = true, lo = 1, hi = 9-(pop_term + params[pop_index].push)}
			else 
				digits[pop_index] = {is_pushed = true, hi = 9, lo = 1 - (pop_term + params[pop_index].push)}
			end
			digits[digit] = {is_pushed = false, pop_index = pop_index, term = (pop_term + params[pop_index].push)}
		end
	end
	
	local input_lo = {}
	local input_hi = {}
	
	for i = 1,#params do 
		if digits[i].is_pushed then 
			input_hi[i] = digits[i].hi
			input_lo[i] = digits[i].lo
		else 
			input_hi[i] = input_hi[digits[i].pop_index] + digits[i].term
			input_lo[i] = input_lo[digits[i].pop_index] + digits[i].term
		end
	end
	
	return day24_input_str(input_hi), day24_input_str(input_lo)
end

function day24(path) 
	local lines = readLines(path)
	
	local instructions = {}
	for i = 1, #lines do 
		instructions[#instructions + 1] = day24_inst(lines[i])
	end
	
	local part1, part2 = day24_solve(instructions)
	print(string.format("Part 1: %s", part1))
	print(string.format("Part 2: %s", part2))
	
 end
 