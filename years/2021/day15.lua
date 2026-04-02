local day9_coord = day9_coord or function(x, y)
  return string.format('%d,%d', x, y)
end

function day15_risk(grid, width, height, x, y)
  local x_div = math.floor((x - 1) / width)
  local x_mod = (x - 1) % width
  local y_div = math.floor((y - 1) / height)
  local y_mod = (y - 1) % height
  local inc = x_div + y_div
  return (((grid[day9_coord(x_mod + 1, y_mod + 1)] - 1) + inc) % 9) + 1
end

-- priority queue ordered by dist
function day15_queue_insert(queue, val, dist)
  local i = 1
  while i <= #queue do
    if queue[i].dist > dist then
      break
    end
    i = i + 1
  end
  local entry = {}
  entry.dist = dist
  entry.val = val
  table.insert(queue, i, entry)
end

function day15_dijkstra(grid, width, height, dest_x, dest_y)
  local seen = {}
  local queue = {}
  local dists = {}
  local start_coord = day9_coord(1, 1)
  dists[start_coord] = 0
  day15_queue_insert(queue, { 1, 1 }, 0)

  while #queue > 0 do
    local entry = table.remove(queue, 1)
    local x = entry.val[1]
    local y = entry.val[2]
    local d = entry.dist
    local xy = day9_coord(x, y)

    if seen[xy] or d > dists[xy] then
      -- already finalized, or stale queue entry
    else
      seen[xy] = true

      local neighbors = {}
      if x > 1 then
        table.insert(neighbors, { x - 1, y })
      end
      if x < dest_x then
        table.insert(neighbors, { x + 1, y })
      end
      if y > 1 then
        table.insert(neighbors, { x, y - 1 })
      end
      if y < dest_y then
        table.insert(neighbors, { x, y + 1 })
      end

      for i = 1, #neighbors do
        local nx = neighbors[i][1]
        local ny = neighbors[i][2]
        local xy2 = day9_coord(nx, ny)
        local w = day15_risk(grid, width, height, nx, ny)
        local nd = d + w
        if dists[xy2] == nil or nd < dists[xy2] then
          dists[xy2] = nd
          if not seen[xy2] then
            day15_queue_insert(queue, { nx, ny }, nd)
          end
        end
      end
    end
  end

  return dists[day9_coord(dest_x, dest_y)]
end

function day15(path)
  local lines = readLines(path)

  local width = string.len(lines[1])
  local height = #lines
  local grid = {}
  for i = 1, #lines do
    for j = 1, string.len(lines[i]) do
      grid[day9_coord(j, i)] = tonumber(string.sub(lines[i], j, j))
    end
  end

  local part1 = day15_dijkstra(grid, width, height, width, height)
  print(string.format('Part 1: %d', part1))

  local part2 = day15_dijkstra(grid, width, height, width * 5, height * 5)
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day15(path)
end
