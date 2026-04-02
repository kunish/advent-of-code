return function(path)
  local lines = readLines(path)
  local card_pub = tonumber(lines[1])
  local door_pub = tonumber(lines[2])
  local mod = 20201227

  local function loop_size(pub)
    local v = 1
    local loops = 0
    while v ~= pub do
      v = (v * 7) % mod
      loops = loops + 1
    end
    return loops
  end

  local function transform(subject, loops)
    local v = 1
    local i = 1
    while i <= loops do
      v = (v * subject) % mod
      i = i + 1
    end
    return v
  end

  local card_loop = loop_size(card_pub)
  local encryption = transform(door_pub, card_loop)

  print(string.format('Part 1: %d', encryption))
  print('Part 2:')
end
