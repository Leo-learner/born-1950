#!/usr/bin/env python3
"""把攻略文件往前推：遇到只有"继续"的节点自动补"继续"，遇到抉择节点查 choices 表；表里没有就停下来列出选项。
用法：tools/autowalk.py tests/true_ending.walk choices.txt
choices.txt 每行：节点id = 选项文字片段
"""
import subprocess, sys, re
walk, table = sys.argv[1], sys.argv[2]
picks = {}
for line in open(table, encoding='utf-8'):
    line = line.strip()
    if not line or line.startswith('//'): continue
    k, v = line.split('=', 1)
    picks[k.strip()] = v.strip()
for _ in range(600):
    out = subprocess.run(['build/Born1950', '-walk', walk, '-story', 'story'], capture_output=True, text=True).stdout
    lines = out.strip().split('\n')
    stop = [l for l in lines if l.startswith('停在：')]
    fail = [l for l in lines if l.startswith('✘')]
    if fail:
        print('\n'.join(lines[-12:])); sys.exit(1)
    if not stop: print(out); sys.exit(1)
    node = stop[0].split('：')[1].split()[0]
    if '· 结局' in stop[0]:
        print('\n'.join(lines[-3:])); sys.exit(0)
    opts = [l.strip()[2:] for l in lines if l.strip().startswith('· ') or l.strip().startswith('🔒')]
    enabled = [l.strip()[2:] for l in lines if l.strip().startswith('· ')]
    if node in picks:
        step = picks.pop(node)
    elif enabled == ['继续']:
        step = '继续'
    else:
        print(f'需要抉择：[{node}]'); print('\n'.join(lines[-8:])); sys.exit(2)
    with open(walk, 'a', encoding='utf-8') as f: f.write(step + '\n')
print('步数太多'); sys.exit(1)
