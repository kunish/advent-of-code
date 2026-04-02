-- MD5: prefer native CC_MD5 via LuaJIT FFI on macOS (fast); else pure Lua.
local sumhexa
do
  local jit_on = type(rawget(_G, 'jit')) == 'table'
  local ffi_ok, ffi_or_err = pcall(require, 'ffi')
  local ffi = ffi_ok and ffi_or_err or nil
  local lib
  if jit_on and ffi then
    ffi.cdef [[
      typedef unsigned long CC_LONG;
      unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md);
    ]]
    for _, p in ipairs({
      '/usr/lib/system/libcommonCrypto.dylib',
    }) do
      local ok, l = pcall(ffi.load, p)
      if ok then
        lib = l
        break
      end
    end
  end
  if lib then
    local out = ffi.new('unsigned char[16]')
    local b2h = {}
    for i = 0, 255 do
      b2h[i] = string.format('%02x', i)
    end
    sumhexa = function(s)
      lib.CC_MD5(s, #s, out)
      local t = {}
      for i = 0, 15 do
        t[#t + 1] = b2h[out[i]]
      end
      return table.concat(t)
    end
  else
    local md5 = jit_on and dofile('years/2015/md5_luajit.lua') or dofile('years/2015/md5.lua')
    sumhexa = md5.sumhexa
  end
end

local function stretched_hash(salt, idx, times)
  local h = sumhexa(salt .. tostring(idx))
  for _ = 2, times do
    h = sumhexa(h)
  end
  return h
end

local function first_triple(hex)
  for i = 1, #hex - 2 do
    local c = hex:sub(i, i)
    if hex:sub(i + 1, i + 1) == c and hex:sub(i + 2, i + 2) == c then
      return c
    end
  end
  return nil
end

local function has_quint(h, ch)
  local p = string.rep(ch, 5)
  return h:find(p, 1, true) ~= nil
end

local function find_keys(salt, stretch_times)
  local cache = {}
  local function get_hash(i)
    if cache[i] then
      return cache[i]
    end
    local h
    if stretch_times == 1 then
      h = sumhexa(salt .. tostring(i))
    else
      h = stretched_hash(salt, i, stretch_times)
    end
    cache[i] = h
    return h
  end

  local keys = {}
  local i = 0
  while #keys < 64 do
    local h = get_hash(i)
    local t = first_triple(h)
    if t then
      local ok = false
      for j = i + 1, i + 1000 do
        local hj = get_hash(j)
        if has_quint(hj, t) then
          ok = true
          break
        end
      end
      if ok then
        keys[#keys + 1] = i
      end
    end
    i = i + 1
  end
  return keys[64]
end

local function day14(path)
  local lines = readLines(path)
  local salt = (lines[1] or ''):gsub('%s+', '')
  local p1 = find_keys(salt, 1)
  print(string.format('Part 1: %d', p1))
  io.stdout:flush()
  local p2 = find_keys(salt, 2017)
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day14(path)
end
