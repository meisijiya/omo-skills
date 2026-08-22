#!/usr/bin/env node
// 幂等地把 config/oh-my-openagent.prompt-append.jsonc 的 agent overrides 合并进
// ~/.omo/omo.jsonc 的 target["[opencode]"].agents.*：
//   - 主代理（sisyphus / prometheus / atlas）的 prompt_append
//   - 子代理（oracle / metis / momus 等）的 skills[]
// 只更新 fragment 列出的字段；model / variant / categories / team_mode 等用户字段不动。
//
// 用法：node scripts/install-prompt-append.mjs

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FRAGMENT = path.join(__dirname, "..", "config", "oh-my-openagent.prompt-append.jsonc");
const TARGET = path.join(os.homedir(), ".omo", "omo.jsonc");

// jsonc → object：剥离 // 注释（含行内；保留字符串内的 //，如 URL）与尾逗号
function parseJsonc(text) {
  let inStr = false;
  let out = "";
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === '"' && text[i - 1] !== "\\") inStr = !inStr;
    if (!inStr && c === "/" && text[i + 1] === "/") {
      while (i < text.length && text[i] !== "\n") i++;
      out += "\n";
    } else {
      out += c;
    }
  }
  return JSON.parse(out.replace(/,\s*([}\]])/g, "$1"));
}

// 浅比较两个值（JSON.stringify 足够：处理 string / number / array of string 等原子类型）
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

const fragment = parseJsonc(fs.readFileSync(FRAGMENT, "utf8"));
const targetExists = fs.existsSync(TARGET);
const target = targetExists ? parseJsonc(fs.readFileSync(TARGET, "utf8")) : {};

target["[opencode]"] ??= {};
target["[opencode]"].agents ??= {};

let changed = 0;
const diffs = [];
for (const [name, cfg] of Object.entries(fragment.agents)) {
  const existing = target["[opencode]"].agents[name] ?? {};
  // 浅比对 fragment 里的每个字段；任一字段不一致即触发该 agent 的合并
  const fieldDiffs = Object.keys(cfg).filter((k) => !same(existing[k], cfg[k]));
  if (fieldDiffs.length === 0) continue;
  target["[opencode]"].agents[name] = { ...existing, ...cfg };
  diffs.push(`${name}: ${fieldDiffs.join(", ")}`);
  changed++;
}

if (changed === 0) {
  console.log("✓ agent overrides 已是最新，无需改动（幂等）。");
} else {
  // 保留目标文件的首行 // 注释（如有），其余按标准 JSON 写回
  let header = "";
  if (targetExists) {
    const raw = fs.readFileSync(TARGET, "utf8");
    const m = raw.match(/^(\s*\/\/[^\n]*\n)/);
    if (m) header = m[1];
  }
  fs.mkdirSync(path.dirname(TARGET), { recursive: true });
  fs.writeFileSync(TARGET, header + JSON.stringify(target, null, 2) + "\n");
  console.log(`✓ 已合并 ${changed} 个 agent 的 override → ${TARGET}`);
  for (const d of diffs) console.log(`    · ${d}`);
  console.log("  提示：写回为标准 JSON；首行注释保留，其余行内注释会移除。");
}
