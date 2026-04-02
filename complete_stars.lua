--[[
  Fetch your AoC calendar (AOC_SESSION), find days with < 2 stars, run
  `lua run.lua <year> <day>`, parse "Part 1:" / "Part 2:" lines, POST answers.

  Run from repository root:
    export AOC_SESSION='…'
    lua complete_stars.lua [from_year] [to_year]

  Defaults: 2015 2025. Sleeps 1s between HTTP calls. Do not commit your cookie.
]]

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function cookie_header(session)
  return 'Cookie: session=' .. session
end

local function enc_url(s)
  return (tostring(s):gsub('[^%w%-_%.]', function(c)
    return string.format('%%%02X', string.byte(c))
  end))
end

local function http_get(url, session)
  local tmp = os.tmpname()
  local cmd = string.format(
    'curl -fsSL --max-time 60 -H %s -o %s %s',
    shell_quote(cookie_header(session)),
    shell_quote(tmp),
    shell_quote(url)
  )
  local ok = os.execute(cmd)
  if not ok then
    os.remove(tmp)
    return nil
  end
  local f = io.open(tmp, 'r')
  local body = f:read('*a')
  f:close()
  os.remove(tmp)
  return body
end

local function http_post_answer(url, session, level, answer)
  local body = string.format('level=%s&answer=%s', enc_url(level), enc_url(answer))
  local tmp_in = os.tmpname()
  local f = io.open(tmp_in, 'w')
  f:write(body)
  f:close()
  local tmp_out = os.tmpname()
  local cmd = string.format(
    'curl -fsSL --max-time 60 -X POST -H %s -H %s --data-binary @%s -o %s %s',
    shell_quote(cookie_header(session)),
    shell_quote('Content-Type: application/x-www-form-urlencoded'),
    shell_quote(tmp_in),
    shell_quote(tmp_out),
    shell_quote(url)
  )
  local ok = os.execute(cmd)
  os.remove(tmp_in)
  if not ok then
    os.remove(tmp_out)
    return nil
  end
  f = io.open(tmp_out, 'r')
  local resp = f:read('*a')
  f:close()
  os.remove(tmp_out)
  return resp
end

local function stars_for_day(html, day)
  local tail = html:match('aria%-label="Day ' .. day .. '([^%d]-)"')
  if tail == nil then
    return nil
  end
  if tail:find('two stars', 1, true) then
    return 2
  end
  if tail:find('one star', 1, true) then
    return 1
  end
  return 0
end

local function parse_parts(output)
  local p1 = output:match('Part 1:%s*(.-)[\r\n]')
  local p2 = output:match('Part 2:%s*(.-)[\r\n]')
  if p1 then
    p1 = p1:match('^%s*(.-)%s*$')
  end
  if p2 then
    p2 = p2:match('^%s*(.-)%s*$')
  end
  return p1, p2
end

local function sleep(n)
  os.execute(string.format('sleep %d', n))
end

--- Classify the AoC response.
--- Returns one of:
---   "correct"      – star awarded
---   "already_done" – previously completed
---   "rate_limited"  – throttled; wait_seconds is set
---   "wrong"        – incorrect answer
---   "error"        – network / unknown
local function classify_response(html)
  if not html then
    return 'error', 0
  end
  if html:find("That's the right answer", 1, true) then
    return 'correct', 0
  end
  if html:find('Did you already complete it', 1, true) then
    return 'already_done', 0
  end
  if html:find('You gave an answer too recently', 1, true) then
    local mins = tonumber(html:match('(%d+)m')) or 0
    local secs = tonumber(html:match('(%d+)s')) or 0
    return 'rate_limited', mins * 60 + secs + 2
  end
  return 'wrong', 0
end

local function submit_answer(post_url, session, level, answer, year, day)
  local max_retries = 3
  for attempt = 1, max_retries do
    local resp = http_post_answer(post_url, session, level, answer)
    sleep(1)
    local kind, wait = classify_response(resp)
    if kind == 'correct' then
      return 'correct'
    elseif kind == 'already_done' then
      return 'already_done'
    elseif kind == 'rate_limited' then
      if attempt < max_retries and wait > 0 and wait <= 600 then
        io.stderr:write(string.format('  RATE-LIMITED %d/%d part %s – waiting %ds…\n', year, day, level, wait))
        sleep(wait)
      else
        io.stderr:write(string.format('  RATE-LIMITED %d/%d part %s – skip (wait %ds too long)\n', year, day, level, wait))
        return 'rate_limited'
      end
    else
      return 'wrong'
    end
  end
  return 'rate_limited'
end

local session = os.getenv('AOC_SESSION')
if not session or session == '' then
  io.stderr:write('Set AOC_SESSION (see https://adventofcode.com/settings).\n')
  os.exit(1)
end

local from_year = tonumber(arg[1]) or 2015
local to_year = tonumber(arg[2]) or 2025

local submitted = 0
local failed = 0

for year = from_year, to_year do
  local cal_url = string.format('https://adventofcode.com/%d', year)
  local html = http_get(cal_url, session)
  sleep(1)
  if not html or html:find('<title>404', 1, true) then
    io.stderr:write(string.format('Skip year %d (no calendar)\n', year))
  else
    for day = 1, 25 do
      local stars = stars_for_day(html, day)
      if stars == nil then
        -- Day not on calendar (future / not started)
      elseif stars >= 2 then
        -- Already complete
      else
        local lua_cmd = 'lua'
        if year == 2016 and day == 5 then lua_cmd = 'luajit' end
        local p = io.popen(string.format('timeout 120 %s run.lua %d %d 2>&1', lua_cmd, year, day), 'r')
        local out = p:read('*a')
        p:close()

        if out:find('not implemented yet', 1, true) then
          io.stderr:write(string.format('SKIP %d/%d: solver not implemented\n', year, day))
        elseif out:find('input file missing', 1, true) then
          io.stderr:write(string.format('SKIP %d/%d: missing input (download or unlock on site)\n', year, day))
        else
          local p1, p2 = parse_parts(out)

          if stars == 0 then
            if not p1 then
              io.stderr:write(string.format('WARN %d/%d: no Part 1 in output\n', year, day))
            else
              local post_url = string.format('https://adventofcode.com/%d/day/%d/answer', year, day)
              local result = submit_answer(post_url, session, '1', p1, year, day)
              if result == 'correct' or result == 'already_done' then
                submitted = submitted + 1
                print(string.format('OK %d/%d part 1 -> %s', year, day, p1))
                html = http_get(cal_url, session) or html
                sleep(1)
                stars = stars_for_day(html, day) or 1
              elseif result == 'rate_limited' then
                print(string.format('RATELIMIT %d/%d part 1 (answer: %s)', year, day, p1))
              else
                io.stderr:write(string.format('FAIL %d/%d part 1 (answer: %s)\n', year, day, p1))
                failed = failed + 1
              end
            end
          end

          if stars == 1 then
            if p2 then
              local post_url = string.format('https://adventofcode.com/%d/day/%d/answer', year, day)
              local result = submit_answer(post_url, session, '2', p2, year, day)
              if result == 'correct' or result == 'already_done' then
                submitted = submitted + 1
                print(string.format('OK %d/%d part 2 -> %s', year, day, p2))
              elseif result == 'rate_limited' then
                print(string.format('RATELIMIT %d/%d part 2 (answer: %s)', year, day, p2))
              else
                io.stderr:write(string.format('FAIL %d/%d part 2 (answer: %s)\n', year, day, p2))
                failed = failed + 1
              end
            elseif day ~= 25 and not (year == 2025 and day == 12) then
              io.stderr:write(string.format('WARN %d/%d: no Part 2 line (stars still 1)\n', year, day))
            end
          end
        end
        sleep(1)
      end
    end
  end
end

print(string.format('Done. Accepted: %d; wrong answers: %d', submitted, failed))
