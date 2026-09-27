# 生于一九五〇 · 鞋盒里的美国

原生 macOS 文字冒险游戏（SwiftUI，无第三方依赖）。1950.3.17—2026.3.3，宾夕法尼亚州一个钢铁小镇，
玩家是汤米·诺瓦克——钢厂平炉工人的二儿子，从出生一直活到七十六岁；
框架是 2026 年他的孙女在地下室热水器后面找到一只鞋盒，盒盖上写着 NOT MINE。

- 六部正文，中间穿插四段"那几年"：河谷（1950—1962）→ 收音机（1963—1968）→ 号码（1969—1975，征兵抽签）→ 关厂（1976—1989）→ 千禧（1990—2007）→ 窗外（2008—2026）
- 559 个节点、约 16.8 万字正文、36 个结局（BE/NE/GE/SE/TE）、48 件旧物
- 每个结局拆开鞋盒里的一个信封，揭示"这个结局真正属于谁"；三件关键旧物会在后面的重来里解锁【旧物】选项，真结局要靠它们拼出来
- 本事（头脑/手艺/体格/胆量/心肠）、境况（健康/积蓄/心气/心结/烟/酒）、十几个人的亲疏与生死，一路带到老年；
  年份往前走时按烟、酒、体格一年一年扣健康（`Sources/Aging.swift`）
- "那几年"里是随机生活事件；随机数种子随存档保存，读档刷不出运气；另有"一次"模式（只有自动存档、不能回头）

## 构建

需要 Apple 芯片的 Mac、macOS 15 以上和 Xcode（或命令行工具里的 `swiftc`）。

```bash
./build.sh                # 编译 → 检查剧本（2000 局模拟）→ 渲染图标 → 打包 → 覆盖安装到 ~/Desktop/生于一九五〇.app
NO_INSTALL=1 ./build.sh   # 只打包到 build/，不动桌面
RUNS=6000 ./build.sh      # 模拟更多局
```

## 剧本工具

```bash
build/Born1950 -check story -runs 3000                     # 静态检查 + 带跨周目进度的蒙特卡洛模拟
build/Born1950 -check story -probe "b6_2020:health"        # 顺带统计：走到某个节点那一刻某个变量的分布
build/Born1950 -walk tests/true_ending.walk -story story   # 按攻略走到真结局
tools/autowalk.py tests/true_ending.walk choices.txt       # 续写攻略：只有"继续"的节点自动补，抉择按表里选
```

真结局要三件关键旧物加一长串特定的选择，随机模拟走不到，靠 `tests/true_ending.walk` 验证。
改了剧本（尤其是插入新的抉择节点）要重跑一遍攻略，步数错位时按提示补步骤。

自检截图（本机没有屏幕录制权限时用）：

```bash
"build/生于一九五〇.app/Contents/MacOS/Born1950" -snapshot /tmp/a.png -screen game -node b1_start -datadir /tmp/b1950 -textMode 2
```

`-screen` 可选 title / game / archive / log / settings / load / newgame；`-node` 跳到某个节点（`end_e34` 这类结局节点直接进结局页），`-vars "year=1969,health=40"` 顺便改变量；
`-unlockAll YES` 解锁全部结局和旧物；`-datadir` 把存档写到别处，不碰真存档（真存档在 `~/Library/Application Support/Born1950/`）。

## 目录

- `Sources/` Swift 源码：`Expr`（表达式）、`Story`（剧本解析）、`Engine`（运行时）、`Aging`（衰老）、`Checker`（检查器）、各界面
- `story/` 剧本：`00_defs` 声明，`01_frame` 鞋盒框架与间章，`1x` 第一部，`2x` 第二部，`3x` 第三部，`4x` 那几年与第四部（`48` `49` 是几条支线），
  `5x` 第五、六部与终章，`9x` 结局登记与旧物
- `docs/BIBLE.md` 剧本圣经：真实历史、人物、数值与旗标、结局与旧物对照表、剧本语法
- `tests/true_ending.walk` 真结局攻略
- `tools/autowalk.py` 续写攻略的小工具

本作人物、蒙韦尔镇与拱心石钢铁公司均为虚构；历史事件、制度与时间线参照真实历史。
