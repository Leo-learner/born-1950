# 生于一九五〇 · 鞋盒里的美国（网页版）

文字冒险游戏，纯 HTML / CSS / JavaScript，无第三方依赖、无构建框架。1950.3.17—2026.3.3，宾夕法尼亚州一个钢铁小镇，
玩家是汤米·诺瓦克——钢厂平炉工人的二儿子，从出生一直活到七十六岁；
框架是 2026 年他的孙女在地下室热水器后面找到一只鞋盒，盒盖上写着 NOT MINE。

> 这是 `web` 分支：只有网页版。Mac 版在 [`macos` 分支](https://github.com/Leo-learner/born-1950/tree/macos)，
> iPhone / iPad 版在 [`ios` 分支](https://github.com/Leo-learner/born-1950/tree/ios)。三个版本共用同一份剧本（`story/`），
> 网页版的引擎是 Mac 版 Swift 引擎的逐行移植：同一个随机数种子、同样的选择，得到完全一样的结果
> （真结局攻略和 2000 局模拟的完整输出都和 Swift 版逐字节比对过）。

在线玩：<https://games.dkz12345.com/#/play/born-1950>

- 六部正文，中间穿插四段"那几年"：河谷（1950—1962）→ 收音机（1963—1968）→ 号码（1969—1975，征兵抽签）→ 关厂（1976—1989）→ 千禧（1990—2007）→ 窗外（2008—2026）
- 559 个节点、约 16.8 万字正文、36 个结局（BE/NE/GE/SE/TE）、48 件旧物
- 每个结局拆开鞋盒里的一个信封，揭示"这个结局真正属于谁"；三件关键旧物会在后面的重来里解锁【旧物】选项，真结局要靠它们拼出来
- 本事、境况、十几个人的亲疏与生死，一路带到老年；年份往前走时按烟、酒、体格一年一年扣健康（`web/src/aging.js`，和 Mac 版 `Aging.swift` 同一个公式）
- 随机数种子随存档保存，读档刷不出运气；另有"一次"模式（只有自动存档、不能回头）

## 网页版有什么

- 和 Mac 版一样的界面：标题、正文（逐段浮现 / 打字机 / 立即显示）、右侧"相册"、结局与拆信封、鞋盒（结局图鉴 + 旧物）、8 个存档位 + 自动存档、年表、回到上一个抉择
- 夜 / 相纸两套配色，钢厂火星、雪、雨、萤火虫、电视光等场景氛围（可关）
- 手机宽度可玩：相册收进右侧抽屉（每一项点一下看说明），每一屏正文开头用小标签提示上一个抉择改变了什么，点标签就拉出相册
- 键盘：空格/回车 继续 · 1–9 选择 · Z 回到上一个抉择 · L 年表 · D 鞋盒 · S 存档 · O 读档 · M 相册 · Esc 返回
- 存档：
  - 单独打开网页时存在浏览器 localStorage 里
  - 放在 [Game Hub](https://games.dkz12345.com/)（`/play/<slug>/<版本>/`）里时自动接入网站的云存档：登录后自动存档、8 个存档位和跨周目进度都存到云端（共 10 个云槽）；游客按网站约定不落盘，进度只留在当前页面
  - 走完真结局的一整局存档 JSON 约 690 KB（300 步回溯快照 + 年表），统一 gzip 后再存，约 110 KB，远低于 Game Hub 单槽 1 MiB 的上限

## 试玩与打包

需要 Node.js 20 以上。

```bash
npm run serve          # http://localhost:1950/  直接用 web/ 源码，改完剧本刷新即可
npm run build          # → build/web/（静态网站）和 build/born-1950-web.zip（Game Hub 上传包）
```

`build/web/` 可以放到任何静态托管上。`?seed=7` 让新的一生使用固定的随机数种子（和攻略文件里的 `@seed` 对应），调试用。

## 发布到 games.dkz12345.com

`build/born-1950-web.zip` 的根目录就是 Game Hub 要求的格式：`index.html` + `game.json`（10 个存档槽）+ `cover.svg`（16:9 封面）。
在装好 game-hub MCP 的机器上：

```bash
# game_site 仓库里，已 source 过含 GAME_HUB_MCP_TOKEN 的私有 env
node scripts/mcp-upload.mjs born-1950 /绝对路径/born-1950/build/born-1950-web.zip
```

或者直接让 Codex / Claude Code 通过 game-hub MCP：`create_game`（slug `born-1950`，标题"生于一九五〇"）→
`prepare_game_upload` → PUT 上传 ZIP → `get_game` 检查版本 → `publish_game`。

## 剧本工具

```bash
npm test                                                   # 回归测试：解析、表达式、随机数、衰老与分档词、真结局攻略、300 局模拟
npm run check                                              # 静态检查 + 2000 局带跨周目进度的蒙特卡洛模拟
node tools/check.mjs story -runs 6000 -probe "b6_2020:health"   # 模拟更多局，顺带统计走到某节点时某变量的分布
node tools/walk.mjs tests/true_ending.walk -expect e34     # 按攻略走到真结局
tools/autowalk.py tests/true_ending.walk choices.txt       # 续写攻略：只有"继续"的节点自动补，抉择按表里选
```

真结局要三件关键旧物加一长串特定的选择，随机模拟走不到，靠 `tests/true_ending.walk` 验证。

## 目录

- `web/` 网页版：`index.html`、`style.css`、`src/`（`expr` 表达式、`story` 剧本解析、`engine` 运行时、`aging` 衰老、`store` 存档后端、`atmosphere` 场景氛围、`app` 界面）、`game.json` / `cover.svg`（Game Hub 清单与封面）
- `story/` 剧本：`00_defs` 声明，`01_frame` 鞋盒框架与间章，`1x` 第一部，`2x` 第二部，`3x` 第三部，`4x` 那几年与第四部（`48` `49` 是几条支线），
  `5x` 第五、六部与终章，`9x` 结局登记与旧物
- `tools/` 打包、本地服务器、剧本检查器与按攻略走查的工具（Swift 版 Checker 的移植）
- `docs/BIBLE.md` 剧本圣经：真实历史、人物、数值与旗标、结局与旧物对照表、剧本语法
- `tests/` 回归测试和 `true_ending.walk` 攻略

本作人物、蒙韦尔镇与拱心石钢铁公司均为虚构；历史事件、制度与时间线参照真实历史。
