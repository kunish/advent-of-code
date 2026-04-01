-- Bulk-fetch puzzle inputs. Requires AOC_SESSION (see https://adventofcode.com/settings).
-- As of 2026-04, completed AoC seasons are 2015–2025 (December puzzles per year).
-- Usage (from repo root): lua prefetch_inputs.lua [from_year] [to_year]
-- Defaults: 2015 2025

local runner = require('runner')

local from_year = tonumber(arg[1]) or 2015
local to_year = tonumber(arg[2]) or 2025

if from_year > to_year then
  print('Error: from_year must be <= to_year')
  os.exit(1)
end

local session = os.getenv('AOC_SESSION')
if not session or session == '' then
  print('Missing AOC_SESSION. Export your session cookie from adventofcode.com/settings')
  os.exit(1)
end

print(string.format('Prefetching inputs for years %d–%d (days 1–25 each)...', from_year, to_year))
local downloaded, skipped, failed = runner.prefetch_inputs(from_year, to_year)
print(string.format('Downloaded: %d, already present: %d, failed: %d', downloaded, skipped, #failed))
if #failed > 0 then
  print('Failed (first 20):')
  for i = 1, math.min(20, #failed) do
    print('  ', failed[i])
  end
  if #failed > 20 then
    print(string.format('  ... and %d more', #failed - 20))
  end
end
