local M = {}

local FONT = {}

local letters = {
  A = {".##.", "#..#", "#..#", "####", "#..#", "#..#"},
  B = {"###.", "#..#", "###.", "#..#", "#..#", "###."},
  C = {".##.", "#..#", "#...", "#...", "#..#", ".##."},
  E = {"####", "#...", "###.", "#...", "#...", "####"},
  F = {"####", "#...", "###.", "#...", "#...", "#..."},
  G = {".##.", "#..#", "#...", "#.##", "#..#", ".###"},
  H = {"#..#", "#..#", "####", "#..#", "#..#", "#..#"},
  J = {"..##", "...#", "...#", "...#", "#..#", ".##."},
  K = {"#..#", "#.#.", "##..", "#.#.", "#.#.", "#..#"},
  L = {"#...", "#...", "#...", "#...", "#...", "####"},
  O = {".##.", "#..#", "#..#", "#..#", "#..#", ".##."},
  P = {"###.", "#..#", "#..#", "###.", "#...", "#..."},
  R = {"###.", "#..#", "#..#", "###.", "#.#.", "#..#"},
  U = {"#..#", "#..#", "#..#", "#..#", "#..#", ".##."},
  Y = {"#..#", "#..#", ".##.", "..#.", "..#.", "..#."},
  Z = {"####", "...#", "..#.", ".#..", "#...", "####"},
}

for letter, rows in pairs(letters) do
  FONT[table.concat(rows)] = letter
end

FONT[table.concat({"#...#", "#...#", ".#.#.", "..#..", "..#..", "..#.."})] = "Y"

local function normalize(rows)
  local norm = {}
  local maxw = 0
  for i = 1, 6 do
    norm[i] = (rows[i] or ''):gsub(' ', '.')
    if #norm[i] > maxw then maxw = #norm[i] end
  end
  for i = 1, 6 do
    norm[i] = norm[i] .. string.rep('.', maxw - #norm[i])
  end
  return norm, maxw
end

function M.decode(rows)
  local norm, maxw = normalize(rows)
  local result = {}
  local cs = nil

  for col = 1, maxw + 1 do
    local is_gap = true
    if col <= maxw then
      for r = 1, 6 do
        if norm[r]:sub(col, col) == '#' then
          is_gap = false
          break
        end
      end
    end

    if is_gap then
      if cs then
        local pattern = ''
        for r = 1, 6 do
          pattern = pattern .. norm[r]:sub(cs, col - 1)
        end
        result[#result + 1] = FONT[pattern] or '?'
        cs = nil
      end
    else
      if not cs then cs = col end
    end
  end

  return table.concat(result)
end

function M.decode_fixed(rows, pitch)
  pitch = pitch or 5
  local norm, maxw = normalize(rows)
  local result = {}
  local col = 1
  while col + 3 <= maxw do
    local p4 = ''
    for r = 1, 6 do
      p4 = p4 .. norm[r]:sub(col, col + 3)
    end
    if FONT[p4] then
      result[#result + 1] = FONT[p4]
    elseif col + pitch - 1 <= maxw then
      local pw = ''
      for r = 1, 6 do
        pw = pw .. norm[r]:sub(col, col + pitch - 1)
      end
      result[#result + 1] = FONT[pw] or '?'
    else
      result[#result + 1] = '?'
    end
    col = col + pitch
  end
  return table.concat(result)
end

return M
