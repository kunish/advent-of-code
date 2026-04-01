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
  local needle = 'aria-label="Day ' .. day .. '"'
  local start = html:find(needle, 1, true)
  if not start then
    return nil
  end
  local next_a = html:find('aria-label="Day ', start + 1, true)
  local block = next_a and html:sub(start, next_a - 1) or html:sub(start, #html)
  if block:find('calendar%-mark%-verycomplete', 1, true) then
    return 2
  end
  if block:find('calendar%-mark%-complete', 1, true) then
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

local function response_ok(html)
  if not html then
    return false
  end
  if html:find("That's the right answer", 1, true) then
    return true
  end
  if html:find('You gave an answer too recently', 1, true) then
    return true
  end
  if html:find('Did you already complete it', 1, true) then
    return true
  end
  return false
end

local session = os.getenv('AOC_SESSION')
if not session or session == '' then
  io.stderr:write('Set AOC_SESSION (see https://adventofcode.com/settings).\n')
  os.exit(1)
end

local from_year = tonumber(arg[1]) or 2015
local to_year = tonumber(arg[2]) or 2025

local function sleep(n)
  os.execute(string.format('sleep %d', n))
end

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
        local p = io.popen(string.format('lua run.lua %d %d 2>&1', year, day), 'r')
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
              local resp = http_post_answer(post_url, session, '1', p1)
              sleep(1)
              if response_ok(resp) then
                submitted = submitted + 1
                print(string.format('OK %d/%d part 1 -> %s', year, day, p1))
                html = http_get(cal_url, session) or html
                sleep(1)
                stars = stars_for_day(html, day) or 1
              else
                io.stderr:write(string.format('FAIL %d/%d part 1\n', year, day))
                failed = failed + 1
              end
            end
          end

          if stars == 1 then
            if p2 then
              local post_url = string.format('https://adventofcode.com/%d/day/%d/answer', year, day)
              local resp = http_post_answer(post_url, session, '2', p2)
              sleep(1)
              if response_ok(resp) then
                submitted = submitted + 1
                print(string.format('OK %d/%d part 2 -> %s', year, day, p2))
              else
                io.stderr:write(string.format('FAIL %d/%d part 2\n', year, day))
                failed = failed + 1
              end
            elseif day ~= 25 then
              io.stderr:write(string.format('WARN %d/%d: no Part 2 line (stars still 1)\n', year, day))
            end
          end
        end
        sleep(1)
      end
    end
  end
end

print(string.format('Done. Answer posts accepted (or rate-limited): %d; hard failures: %d', submitted, failed))
