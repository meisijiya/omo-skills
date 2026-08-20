#!/usr/bin/env bash
# 路径分类 lint —— §9 规则守护
# 加入 §4 rebase 后必跑
set -e
cd "$(dirname "$0")/.."
ROOT="mattpocock-skills"

err=0

# 1. SKILL.md 内禁止裸 .scratch / .out-of-scope
echo "=== 检查 SKILL.md 裸临时态路径 ==="
for f in $(find "$ROOT/skills" -name SKILL.md); do
  bad=$(grep -nE '\bscratch/|out-of-scope/' "$f" | grep -vE '\.omo/scratch/|\.omo/out-of-scope/' || true)
  if [ -n "$bad" ]; then
    echo "FAIL: $f 含裸路径"
    echo "$bad"
    err=1
  fi
done

# 2. references/*.md 仍含裸路径 → WARN，不阻塞
echo ""
echo "=== 检查 references/*.md 裸临时态路径（WARN）==="
for f in $(find "$ROOT/skills" -name '*.md' -not -name 'SKILL.md'); do
  case "$(basename "$f")" in
    AGENT-BRIEF.md) continue ;;  # 历史快照豁免
  esac
  bad=$(grep -nE '\bscratch/|out-of-scope/' "$f" | grep -vE '\.omo/scratch/|\.omo/out-of-scope/' || true)
  if [ -n "$bad" ]; then
    echo "WARN: $f 含裸路径（手动迁移见 MAINTENANCE.md §9.6）"
  fi
done

echo ""
if [ $err -eq 0 ]; then
  echo "PASS: 路径分类 lint 干净"
fi
exit $err