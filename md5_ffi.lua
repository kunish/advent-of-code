local ffi = require('ffi')

ffi.cdef[[
unsigned char *MD5(const unsigned char *d, unsigned long n, unsigned char *md);
]]

local crypto = ffi.load('crypto')
local buf = ffi.new('unsigned char[16]')
local hex = ffi.new('char[33]')

local function sumhexa(str)
  crypto.MD5(str, #str, buf)
  for i = 0, 15 do
    ffi.copy(hex + i * 2, string.format('%02x', buf[i]), 2)
  end
  return ffi.string(hex, 32)
end

return { sumhexa = sumhexa }
