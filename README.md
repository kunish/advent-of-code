# advent-of-code (Lua)

## 运行方式

- 运行 2021 某天（兼容入口）：
  - `lua day1.lua` ... `lua day25.lua`
- 运行任意年份/天（统一入口）：
  - `lua run.lua <year> <day> [input_path]`

默认输入路径：`inputs/<year>/day<day>.txt`。
如果输入不存在且设置了 `AOC_SESSION`，会自动从 Advent of Code 下载对应输入。

## 年份覆盖

- 2021：day1-day25 已实现（`years/2021` 通过复用 `days/` 解法）。
- 其他年份（2015-2026）：已补齐 day1-day25 文件结构与执行入口，当前为待实现占位，运行会报明确错误。

