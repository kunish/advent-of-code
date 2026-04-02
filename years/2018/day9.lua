local function day9(path)
  local lines = readLines(path)
  local line = lines[1] or ''
  local nplayers, last = line:match('(%d+) players; last marble is worth (%d+) points')
  nplayers = tonumber(nplayers)
  last = tonumber(last)

  local function high_score(nlast)
    local scores = {}
    for p = 1, nplayers do
      scores[p] = 0
    end

    local function new_node(v)
      return { v = v, prev = nil, next = nil }
    end

    local zero = new_node(0)
    zero.prev = zero
    zero.next = zero
    local current = zero

    for marble = 1, nlast do
      local player = (marble - 1) % nplayers + 1
      if marble % 23 ~= 0 then
        current = current.next
        local a = current.next
        local node = new_node(marble)
        node.prev = current
        node.next = a
        current.next = node
        a.prev = node
        current = node
      else
        scores[player] = scores[player] + marble
        local rm = current
        for _ = 1, 7 do
          rm = rm.prev
        end
        scores[player] = scores[player] + rm.v
        local nxt = rm.next
        rm.prev.next = rm.next
        rm.next.prev = rm.prev
        current = nxt
      end
    end

    local best = 0
    for p = 1, nplayers do
      if scores[p] > best then
        best = scores[p]
      end
    end
    return best
  end

  local part1 = high_score(last)
  local part2 = high_score(last * 100)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day9(path)
end
