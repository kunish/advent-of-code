local function parse_line(line)
  -- Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
  local name, speed, fly, rest = line:match('^(%w+) can fly (%d+) km/s for (%d+) seconds, but then must rest for (%d+) seconds%.')
  return name, tonumber(speed), tonumber(fly), tonumber(rest)
end

local function distance_after(speed, fly, rest, t)
  local cycle = fly + rest
  local full = math.floor(t / cycle)
  local rem = t % cycle
  local fly_time = math.min(rem, fly)
  return full * speed * fly + fly_time * speed
end

local function day14(path)
  local lines = readLines(path)
  local reindeer = {}
  for _, line in ipairs(lines) do
    if line ~= '' then
      local name, speed, fly, rest = parse_line(line)
      reindeer[#reindeer + 1] = { name = name, speed = speed, fly = fly, rest = rest }
    end
  end
  local T = 2503
  local best_dist = -1
  for _, r in ipairs(reindeer) do
    local d = distance_after(r.speed, r.fly, r.rest, T)
    if d > best_dist then
      best_dist = d
    end
  end
  local n = #reindeer
  local dist = {}
  local points = {}
  for i = 1, n do
    dist[i] = 0
    points[i] = 0
  end
  for sec = 1, T do
    for i = 1, n do
      local r = reindeer[i]
      local cycle = r.fly + r.rest
      local phase = (sec - 1) % cycle
      if phase < r.fly then
        dist[i] = dist[i] + r.speed
      end
    end
    local lead = -1
    for i = 1, n do
      if dist[i] > lead then
        lead = dist[i]
      end
    end
    for i = 1, n do
      if dist[i] == lead then
        points[i] = points[i] + 1
      end
    end
  end
  local best_pts = -1
  for i = 1, n do
    if points[i] > best_pts then
      best_pts = points[i]
    end
  end
  print(string.format('Part 1: %d', best_dist))
  print(string.format('Part 2: %d', best_pts))
end

return function(path)
  return day14(path)
end
