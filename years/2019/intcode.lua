--- Intcode VM (AoC 2019). Memory uses 0-based indices; unset cells read as 0.
local M = {}

function M.parse(line)
  local mem = {}
  local i = 0
  for x in string.gmatch(line, '%-?%d+') do
    mem[i] = tonumber(x)
    i = i + 1
  end
  return mem
end

function M.copy(mem)
  local m = {}
  for k, v in pairs(mem) do
    m[k] = v
  end
  return m
end

local function mem_get(state)
  return state.memory or state.mem
end

local function rb_get(state)
  local rb = state.relative_base
  if rb == nil then
    rb = state.rb
  end
  if rb == nil then
    return 0
  end
  return rb
end

local function rb_set(state, v)
  state.relative_base = v
  state.rb = v
end

local function loadv(mem, mode, raw, rb)
  if mode == 1 then
    return raw
  end
  local addr = raw
  if mode == 2 then
    addr = rb + raw
  end
  local v = mem[addr]
  if v == nil then
    return 0
  end
  return v
end

local function storev(mem, mode, raw, rb, val)
  local addr = raw
  if mode == 2 then
    addr = rb + raw
  end
  mem[addr] = val
end

--- Create a VM from parsed program memory (copied).
--- Fields: memory, ip, relative_base, input_queue, output_queue, halted, waiting_for_input
--- Methods: :run() until halt or needs input; :push_input(n) when waiting; :pop_output / :has_output
function M.new(program_mem)
  local vm = {
    memory = M.copy(program_mem),
    ip = 0,
    relative_base = 0,
    rb = 0,
    input_queue = {},
    output_queue = {},
    halted = false,
    waiting_for_input = false,
  }

  function vm:run()
    self.waiting_for_input = false
    self.waiting = false
    while not self.halted do
      local ev = M.step(self)
      if ev == 'in' then
        self.waiting_for_input = true
        self.waiting = true
        return
      elseif ev == 'halt' then
        return
      end
    end
  end

  function vm:push_input(val)
    if not self.waiting_for_input then
      error('intcode: push_input while not waiting')
    end
    M.apply_input(self, val)
    self.waiting_for_input = false
    self.waiting = false
    self:run()
  end

  function vm:pop_output()
    return table.remove(self.output_queue, 1)
  end

  function vm:has_output()
    return #self.output_queue > 0
  end

  return vm
end

--- Run until halt; consumes `inputs` in order (copied into input_queue). Returns list of outputs (same as before).
function M.run(mem, inputs)
  local vm = M.new(mem)
  local iq = vm.input_queue
  local ii = 1
  while inputs and ii <= #inputs do
    iq[#iq + 1] = inputs[ii]
    ii = ii + 1
  end
  while not vm.halted do
    local ev = M.step(vm)
    if ev == 'in' then
      error('intcode.run: missing input at ip ' .. tostring(vm.ip))
    end
  end
  return vm.output_queue
end

--- One step. State must have memory (or mem), ip, relative_base (or rb).
--- Returns: nil (continue) | 'in' (need apply_input) | { 'out', n } | 'halt'
function M.step(state)
  local mem = mem_get(state)
  local ip = state.ip
  local rb = rb_get(state)
  state.waiting_for_input = false

  if state.halted then
    return 'halt'
  end

  local inst = mem[ip] or 0
  local op = inst % 100
  local m1 = math.floor(inst / 100) % 10
  local m2 = math.floor(inst / 1000) % 10
  local m3 = math.floor(inst / 10000) % 10

  if op == 1 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    storev(mem, m3, mem[ip + 3] or 0, rb, a + b)
    state.ip = ip + 4
    rb_set(state, rb)
    return nil
  elseif op == 2 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    storev(mem, m3, mem[ip + 3] or 0, rb, a * b)
    state.ip = ip + 4
    rb_set(state, rb)
    return nil
  elseif op == 3 then
    local v = nil
    local iq = state.input_queue
    if iq and #iq > 0 then
      v = table.remove(iq, 1)
    end
    if v == nil then
      state.waiting_for_input = true
      state.ip = ip
      rb_set(state, rb)
      return 'in'
    end
    storev(mem, m1, mem[ip + 1] or 0, rb, v)
    state.ip = ip + 2
    rb_set(state, rb)
    return nil
  elseif op == 4 then
    local v = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local oq = state.output_queue
    if not oq then
      oq = {}
      state.output_queue = oq
    end
    oq[#oq + 1] = v
    state.ip = ip + 2
    rb_set(state, rb)
    return { 'out', v }
  elseif op == 5 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    if a ~= 0 then
      state.ip = b
    else
      state.ip = ip + 3
    end
    rb_set(state, rb)
    return nil
  elseif op == 6 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    if a == 0 then
      state.ip = b
    else
      state.ip = ip + 3
    end
    rb_set(state, rb)
    return nil
  elseif op == 7 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    storev(mem, m3, mem[ip + 3] or 0, rb, (a < b) and 1 or 0)
    state.ip = ip + 4
    rb_set(state, rb)
    return nil
  elseif op == 8 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    local b = loadv(mem, m2, mem[ip + 2] or 0, rb)
    storev(mem, m3, mem[ip + 3] or 0, rb, (a == b) and 1 or 0)
    state.ip = ip + 4
    rb_set(state, rb)
    return nil
  elseif op == 9 then
    local a = loadv(mem, m1, mem[ip + 1] or 0, rb)
    rb_set(state, rb + a)
    state.ip = ip + 2
    return nil
  elseif op == 99 then
    state.halted = true
    state.ip = ip
    rb_set(state, rb)
    return 'halt'
  else
    error('unknown opcode ' .. tostring(op) .. ' at ip ' .. tostring(ip))
  end
end

--- After step returned 'in', supply one input value.
function M.apply_input(state, val)
  local mem = mem_get(state)
  local ip = state.ip
  local rb = rb_get(state)
  local inst = mem[ip] or 0
  local m1 = math.floor(inst / 100) % 10
  storev(mem, m1, mem[ip + 1] or 0, rb, val)
  state.ip = ip + 2
  state.waiting_for_input = false
  rb_set(state, rb)
end

--- Day 7 part 2: five amplifiers with feedback; phases 5–9 each used once.
function M.run_feedback(program, phases)
  local queues = {}
  local vms = {}
  local idx = 1
  local last_out = 0
  local halted = { false, false, false, false, false }

  local n = 1
  while n <= 5 do
    if n == 1 then
      queues[n] = { phases[n], 0 }
    else
      queues[n] = { phases[n] }
    end
    vms[n] = {
      memory = M.copy(program),
      mem = nil,
      ip = 0,
      relative_base = 0,
      rb = 0,
      input_queue = {},
      output_queue = {},
      halted = false,
      waiting_for_input = false,
    }
    n = n + 1
  end

  local function advance(vm, q)
    while true do
      local ev = M.step(vm)
      if ev == 'in' then
        if #q == 0 then
          return 'blocked'
        end
        M.apply_input(vm, table.remove(q, 1))
      elseif type(ev) == 'table' and ev[1] == 'out' then
        return 'out', ev[2]
      elseif ev == 'halt' then
        return 'halt'
      end
    end
  end

  while not halted[5] do
    if halted[idx] then
      idx = (idx % 5) + 1
    else
      local st, v = advance(vms[idx], queues[idx])
      if st == 'blocked' then
        idx = (idx % 5) + 1
      elseif st == 'out' then
        last_out = v
        local nxt = (idx % 5) + 1
        table.insert(queues[nxt], v)
        idx = nxt
      elseif st == 'halt' then
        halted[idx] = true
        idx = (idx % 5) + 1
      end
    end
  end

  return last_out
end

return M
