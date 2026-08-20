#!/usr/bin/env bash
# scripts/lint-path-conventions.sh
#
# Lint skill SKILL.md files against path conventions documented in
# MAINTENANCE.md §9. Exit 0 if clean, 1 if any violation found.
#
# Conventions enforced:
#   1. 临时态路径（issue tracker 工作目录）应使用工作区根直接子目录 `.scratch/` 与
#      `.out-of-scope/`（无 `.omo/` 前缀；与 omo / Mavis / 上游三方一致）。
#      旧 omo 专属前缀 `.omo/scratch/` 与 `.omo/out-of-scope/` 已废弃。
#   2. 工程内绝对路径不应硬编码（如 `/home/<user>/...`）；使用相对路径或
#      `~/.config/<...>` 风格。
#   3. Skill 互相引用时**应**使用裸名（与 omo / Mavis 共存），而不是
#      `/skill-name` 的 Claude Code 风格 slash command —— 仅在
#      `ask-matt/SKILL.md` 内有专门的"调用约定"声明处除外。
#
# Usage:
#   bash scripts/lint-path-conventions.sh           # 检查当前仓库
#   bash scripts/lint-path-conventions.sh --fix     # 自动修复 .omo/ 前缀问题

set -uo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$REPO_ROOT"

VIOLATIONS=0

scan() {
  local pattern="$1"
  local label="$2"
  local exclude_paths="${3:-}"
  local hits
  if [[ -n "$exclude_paths" ]]; then
    hits=$(grep -rn "$pattern" skills/ 2>/dev/null | grep -v "$exclude_paths" || true)
  else
    hits=$(grep -rn "$pattern" skills/ 2>/dev/null || true)
  fi
  if [[ -n "$hits" ]]; then
    echo "✗ $label"
    echo "$hits" | sed 's/^/    /'
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
}

scan '\.omo/scratch/' '禁止 .omo/scratch/ 前缀（应改为 .scratch/）' \
  'ask-matt/SKILL.md'  # ask-matt 头部 "调用约定" 段落如无该模式则排除
scan '\.omo/out-of-scope/' '禁止 .omo/out-of-scope/ 前缀（应改为 .out-of-scope/）'
scan '/home/[^/]\+/' '禁止硬编码用户目录（如 /home/xxx/）'

if [[ $VIOLATIONS -eq 0 ]]; then
  echo "✓ path conventions OK"
  exit 0
else
  echo ""
  echo "FAIL: $VIOLATIONS violation(s) — 见 MAINTENANCE.md §9"
  exit 1
fi