---@param lines string[]
local function build_binary_vec(lines)
  -- [
  --    [
  --      0,0,1,0,0
  --    ],
  --    [
  --      1,1,1,1,0
  --    ]
  -- ]
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
local function part1(binary_vec)
  local on_bit_count_map = {}

  for _, bit_vec in ipairs(binary_vec) do
    for i, bit in ipairs(bit_vec) do
      if bit == 1 then
        if not on_bit_count_map[i] then
          on_bit_count_map[i] = 1
        else
          on_bit_count_map[i] = on_bit_count_map[i] + 1
        end
      end
    end
  end

  local total = #binary_vec
  local gamma_rate_binary = {}
  local epsilon_rate_binary = {}

  for i, on_bit_count in ipairs(on_bit_count_map) do
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

local lines = require('utils').read_lines_from('inputs/day3.txt')
local binary_vec = build_binary_vec(lines)

print(part1(binary_vec))
