# advent-of-code (Lua)

## 运行方式

- 运行任意年份/天（统一入口，在项目根目录执行）：
  - `lua run.lua <year> <day> [input_path]`
- 运行 2021 某天（快捷脚本，等价于 `run.lua 2021 <day>`）：
  - `lua years/2021/entry/day1.lua` … `lua years/2021/entry/day25.lua`

默认输入路径：`inputs/<year>/day<day>.txt`。
如果输入不存在且设置了 `AOC_SESSION`，会自动从 Advent of Code 下载对应输入。

### 批量拉取输入（历史赛季）

在网站 [Settings](https://adventofcode.com/settings) 复制 session cookie，在终端执行：

```bash
export AOC_SESSION='…'
lua prefetch_inputs.lua          # 默认 2015–2025
lua prefetch_inputs.lua 2023 2025
```

说明：截至 2026 年 4 月，Advent of Code 已完结的赛季是 **2015–2025**（每年 12 月 1–25 日）。`2026` 赛季在当年 12 月之前通常尚无题目与输入。

### 批量运行（检查哪些题能跑通）

```bash
lua run_all.lua                  # 默认 2015–2025
lua run_all.lua 2021 2021
```

会统计：有输入且脚本无报错的天数、缺输入、`not implemented` 占位、其它运行时错误。不会校验答案是否与官网一致。

### 补星（登录态 + 本地解法）

在官网 [Settings](https://adventofcode.com/settings) 取得 session 后：

```bash
export AOC_SESSION='…'
lua complete_stars.lua           # 默认 2015–2025
lua complete_stars.lua 2021 2021 # 仅某一年
```

脚本会拉取你账号下的日历 HTML，解析每天 0/1/2 星；对未满 2 星的题目运行 `lua run.lua`，把输出里的 `Part 1` / `Part 2` 提交到官网。**仅当本地解法正确且已有输入** 时才会成功；仓库里除 2021 外多为占位，无法自动补满历史所有星。请求之间会间隔约 1 秒，请避免短时间反复运行。

## 目录说明

- `years/<year>/day<N>.lua`：各年解题脚本。
- `years/<year>/entry/`：可选的按天快捷入口（当前仅 2021 提供）。
- `inputs/<year>/`：各年输入数据（本地生成，已 `.gitignore`，勿提交）。

## 年份覆盖

- 2021：day1–day25 已实现（源码在 `years/2021`）。
- 其他年份（2015–2026）：已补齐 `day*.lua` 占位；除 2021 外需自行实现算法。全部历史题（约 11×25 道）需要逐题编写，无法在一次提交中自动「解完」。

