
function day21_key(p1,p1_score,p2,p2_score, won) 
	return(string.format("%d,%d,%d,%d,%d", p1, p1_score, p2, p2_score, won))
end

function day21_mod(val, modulo) 
	return(((val - 1) % modulo) + 1)
end

function day21(path) 
	local lines = readLines(path)
	
	local p1_start = tonumber(string.sub(lines[1], string.len(lines[1])))
	local p2_start = tonumber(string.sub(lines[2], string.len(lines[2])))
	
	local p1 = p1_start
	local p2 = p2_start
	
	local dice = 1
	local dice_rolls = 0
	
	local p1_score = 0
	local p2_score = 0
	
	while p1_score < 1000 and p2_score < 1000 do
		local p1_roll = 0
		for i = 1,3 do 
			p1_roll = p1_roll + dice
			dice = day21_mod(dice + 1, 100)
		end
		dice_rolls = dice_rolls + 3
		p1 = day21_mod(p1 + p1_roll, 10)
		p1_score = p1_score + p1
		if p1_score < 1000 then 
			local p2_roll = 0
			for i = 1,3 do 
				p2_roll = p2_roll + dice
				dice = day21_mod(dice + 1, 100)
			end
			dice_rolls = dice_rolls + 3
			p2 = day21_mod(p2 + p2_roll, 10)
			p2_score = p2_score + p2
		end
	end
	
	local part1 = p1_score < p2_score and p1_score * dice_rolls or p2_score * dice_rolls
	print(string.format("Part 1: %d", part1))
	
	p1 = p1_start
	p2 = p2_start
	
	-- for each state in a previous round, play it forward for
	-- all possible outcomes of both turns (3 dice 1-3 produces 
	-- outcomes 3-9, with the number of possible distinct rolls 
	-- producing the outcome having the distribution given 
	-- below). Add any win states to the total for the 
	-- appropriate player. If neither player's turn results in 
	-- a win, propagate the state to the next turn in the 
	-- positions table, together with a sum of all possible 
	-- states leading to that position (the number of previous 
	-- states producing that outcome multiplied by the number of 
	-- possible rolls on the turn producing the outcome. Continue
	-- until no more non-win states occur.
	local dirac = {0,0,1,3,6,7,6,3,1}
	local positions = {}
	local p1_win_count = 0
	local p2_win_count = 0
	positions[1] = {}
	positions[1][day21_key(p1,0,p2,0,0)] = {p1,0,p2,0,1} 
	local new_position_count = 1
	local round = 1
	while true do 
		if new_position_count < 1 then 
			break
		end
		round = round + 1
		positions[round] = {}
		new_position_count = 0
		for k,v in pairs(positions[round-1]) do 
			local p1_t = v[1]
			local p1_score_t = v[2]
			local p2_t = v[3]
			local p2_score_t = v[4]
			local count_t = v[5]
			local win = tonumber(string.sub(k, string.len(k), string.len(k)))
			if win == 0 then 
				for j = 3,9 do 
					local p1_t2 = day21_mod(p1_t + j, 10)
					local p1_score_t2 = p1_score_t + p1_t2
					if p1_score_t2 >= 21 then 
						p1_win_count = p1_win_count + (count_t * dirac[j]);
					else 
						for l = 3,9 do 
							local p2_t2 = day21_mod(p2_t + l, 10)
							local p2_score_t2 = p2_score_t + p2_t2
							if p2_score_t2 >= 21 then 
								p2_win_count = p2_win_count + count_t * dirac[j] * dirac[l]
							else 
								-- not a win result, propagate outcome
								local positionkey = day21_key(p1_t2,p1_score_t2,p2_t2,p2_score_t2,0) 
								if positions[round][positionkey] == nil then 
									positions[round][positionkey] = {p1_t2, p1_score_t2, p2_t2, p2_score_t2, count_t * dirac[j] * dirac[l]}
									new_position_count = new_position_count + 1
								else 
									positions[round][positionkey][5] = positions[round][positionkey][5] + (count_t * dirac[j] * dirac[l])
								end
							end
						end
					end 
				end 
			end 
		end
	end
	
	local part2 =  p1_win_count > p2_win_count and p1_win_count or p2_win_count
	
	print(string.format("Part 2: %d", part2))
 
 end
 