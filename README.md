# 生于一九五〇 · 鞋盒里的美国

原生 macOS / iOS 文字冒险游戏（SwiftUI，无第三方依赖）。1950.3.17—2026.3.3，宾夕法尼亚州一个钢铁小镇，
玩家是汤米·诺瓦克——钢厂平炉工人的二儿子，从出生一直活到七十六岁；
框架是 2026 年他的孙女在地下室热水器后面找到一只鞋盒，盒盖上写着 NOT MINE。

> 这是 `ios` 分支：Mac 版 + iPhone / iPad 版，两者共用同一份引擎和剧本。只要 Mac 版请看 [`macos` 分支](https://github.com/Leo-learner/born-1950/tree/macos)。

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

## iOS 版

`iOS/` 是原生 iPhone / iPad 版（SwiftUI，iOS 17+）。引擎、衰老、存档、配色、氛围特效直接引用 `Sources/` 里的
`Expr / Story / Engine / Aging / Store / Checker / GameModel / Theme / Effects`，剧本直接打包 `story/`——**改剧本两边同时生效**；
界面层是 iOS 自己的一套（`iOS/Born1950/`）。Xcode 工程由 [xcodegen](https://github.com/yonaskolb/XcodeGen)（`brew install xcodegen`）
按 `iOS/project.yml` 生成，不进仓库，也不要手改 `.xcodeproj`。

```bash
iOS/build-ios.sh            # 检查剧本 → 生成工程 → 编译 → 装进模拟器启动（默认 iPhone 17 Pro）
iOS/build-ios.sh device     # 编译 Release 装到数据线连着的 iPhone
iOS/build-ios.sh open       # 生成工程并用 Xcode 打开
SIM="iPad Pro 13-inch (M5)" iOS/build-ios.sh
```

装真机要用你自己的苹果开发者团队 ID：写进 `iOS/.team`（一行，已在 `.gitignore` 里），或者 `DEVELOPMENT_TEAM=… iOS/build-ios.sh device`。
免费的个人团队签出来的 App 7 天后失效，重跑一次 `device` 即可（覆盖安装不丢存档）。

和 Mac 版不同的地方：

- **字体**：宋体（Songti SC）和仿宋（STFangsong）在 iOS 上是系统"按需下载"字体。第一次启动要联网下载（约 55 MB，走 Apple），
  期间先用苹方；以后每次启动都要重新"激活"（一秒内，不用联网）。`Fonts.serifReady` 在激活前把宋体/仿宋换成苹方——
  不能先用 "Songti SC" 去要字，SwiftUI 会把退回苹方的结果按字体描述缓存住，字体到位后也换不回来。
  打字机体、记号笔、手写体（盒盖上的 NOT MINE、相册里的 "Tommy '69"）是 iOS 自带的。
- **下载只走 Wi-Fi**：蜂窝网络下（包括开了"5G 下允许更多数据"的 5G）系统接了请求却一直卡住。
  `FontLoader` 按网卡类型判断：卡在蜂窝网络时在标题页和"更多"菜单里提示，连上 Wi-Fi 自动重发请求。
  下载过程记在 App 的 `Library/Caches/fonts.log`，真机上用 `xcrun devicectl device copy from … --domain-type appDataContainer` 取回。
- **相册**：手机上收进底部面板，Mac 版的悬停说明改成点一下展开；每次抉择后正文开头挂一排数值变化标签
  （`Changes.swift`，挑哪几项由 `pickHeadlineChanges` 决定）。iPad 横屏、竖屏都保留右侧栏。
- **标题页**：手机竖屏放不下"左边文字、右下盒盖"，盒盖挪到最上面；iPad 和 Mac 一样放右下角。
- **切到后台**时写一次自动存档并停表，后台时间不算游戏时长（`GameModel.suspend()/resume()`，Mac 版不调用）。
- 存档在设备自己的沙盒里，和 Mac 版不互通。

模拟器自检用启动参数跳界面（只在 Debug 构建里有效），配合 `xcrun simctl io <UDID> screenshot a.png`：

```bash
xcrun simctl launch <UDID> local.leo.born1950 -screen game -node b4_ws2 -unlockAll YES -textMode 2
xcrun simctl launch <UDID> local.leo.born1950 -screen archive -tab 1 -doc d05 -theme 1
xcrun simctl launch <UDID> local.leo.born1950 -screen game -node b1_start -album YES
```

## 目录

- `Sources/` Swift 源码：`Expr`（表达式）、`Story`（剧本解析）、`Engine`（运行时）、`Aging`（衰老）、`Checker`（检查器）、各界面
- `iOS/` iOS 版：`project.yml`（工程描述）、`Born1950/`（iOS 界面层）、`tools/render-icon.swift`（铺满式 iOS 图标）
- `story/` 剧本：`00_defs` 声明，`01_frame` 鞋盒框架与间章，`1x` 第一部，`2x` 第二部，`3x` 第三部，`4x` 那几年与第四部（`48` `49` 是几条支线），
  `5x` 第五、六部与终章，`9x` 结局登记与旧物
- `docs/BIBLE.md` 剧本圣经：真实历史、人物、数值与旗标、结局与旧物对照表、剧本语法
- `tests/true_ending.walk` 真结局攻略
- `tools/autowalk.py` 续写攻略的小工具

本作人物、蒙韦尔镇与拱心石钢铁公司均为虚构；历史事件、制度与时间线参照真实历史。
