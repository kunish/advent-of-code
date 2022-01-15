---@param lines string[]
local function build_binary_vec(lines)
  ---@type number[][]
  local binary_vec_map = {}

  for i, line in ipairs(lines) do
    local binary = {}

    for b in line:gmatch('.') do
      binary[#binary + 1] = tonumber(b)
    end

    binary_vec_map[i] = binary
  end

  return binary_vec_map
end

---@param binary number[]
local function reverse_binary(binary)
  local reversed = {}

  for i = #binary, 1, -1 do
    reversed[#reversed + 1] = binary[i]
  end

  return reversed
end

---@param binary number[]
local function binary_to_decimal(binary)
  local decimal = 0
  local binary_reversed = reverse_binary(binary)

  for i, bit in ipairs(binary_reversed) do
    if bit == 1 then
      decimal = decimal + math.floor(math.pow(2, i - 1))
    end
  end

  return decimal
end

---@param binary_vec number[][]
local function build_one_bit_count_map(binary_vec)
  local one_bit_count_map = {}

  for _, bit_vec in ipairs(binary_vec) do
    for i, bit in ipairs(bit_vec) do
      if bit == 1 then
        if not one_bit_count_map[i] then
          one_bit_count_map[i] = 1
        else
          one_bit_count_map[i] = one_bit_count_map[i] + 1
        end
      end
    end
  end

  return one_bit_count_map
end

---@param binary_vec number[][]
local function part1(binary_vec)
  local one_bit_count_map = build_one_bit_count_map(binary_vec)

  local total = #binary_vec
  local gamma_rate_binary = {}
  local epsilon_rate_binary = {}

  for i, on_bit_count in ipairs(one_bit_count_map) do
    if on_bit_count > total / 2 then
      gamma_rate_binary[i] = 1
      epsilon_rate_binary[i] = 0
    else
      gamma_rate_binary[i] = 0
      epsilon_rate_binary[i] = 1
    end
  end

  local gamma_rate = binary_to_decimal(gamma_rate_binary)
  local epsilon_rate = binary_to_decimal(epsilon_rate_binary)

  return gamma_rate * epsilon_rate
end

---@param binary_vec number[][]
---@param cb fun(i: number, v: number[]): boolean
local function filter(binary_vec, cb)
  local res = {}

  for i, binary in ipairs(binary_vec) do
    if cb(i, binary) then
      res[#res + 1] = binary
    end
  end

  return res
end

---@param binary_vec number[][]
---@param keep_common boolean
---@param position number
local function find_rating(binary_vec, keep_common, position)
  if #binary_vec == 1 then
    return binary_vec[1]
  end

  local one_bit_count_map = build_one_bit_count_map(binary_vec)
  local new_binary_vec = filter(binary_vec, function(_, v)
    if one_bit_count_map[position] >= #binary_vec / 2 then
      if keep_common then
        return v[position] == 1
      else
        return v[position] == 0
      end
    else
      if keep_common then
        return v[position] == 0
      else
        return v[position] == 1
      end
    end
  end)

  return find_rating(new_binary_vec, keep_common, position + 1)
end

---@param binary_vec number[][]
local function part2(binary_vec)
  local oxygen_generator_rating_binary = find_rating(binary_vec, true, 1)
  local co2_scrubber_rating_binary = find_rating(binary_vec, false, 1)

  local oxygen_generator_rating = binary_to_decimal(oxygen_generator_rating_binary)
  local co2_scrubber_rating = binary_to_decimal(co2_scrubber_rating_binary)
  return oxygen_generator_rating * co2_scrubber_rating
end

local lines = require('utils').read_lines_from('inputs/day3.txt')
local binary_vec = build_binary_vec(lines)

local answer1 = part1(binary_vec)
local answer2 = part2(binary_vec)

print(answer1, answer2)
