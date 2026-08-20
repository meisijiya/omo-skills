#!/usr/bin/env node
// 幂等地把 config/oh-my-openagent.prompt-append.jsonc 的 prompt_append 合并进
// ~/.config/opencode/oh-my-openagent.jsonc（只更新三个 agent 的 prompt_append，
// 不碰用户的 model / variant / categories / team_mode 等其它字段）。
//
// 用法：node scripts/install-prompt-append.mjs

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FRAGMENT = path.join(__dirname, "..", "config", "oh-my-openagent.prompt-append.jsonc");
const TARGET = path.join(os.homedir(), ".config", "opencode", "oh-my-openagent.jsonc");

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

const fragment = parseJsonc(fs.readFileSync(FRAGMENT, "utf8"));
const targetExists = fs.existsSync(TARGET);
const target = targetExists ? parseJsonc(fs.readFileSync(TARGET, "utf8")) : {};

target.agents ??= {};

let changed = 0;
for (const [name, cfg] of Object.entries(fragment.agents)) {
  if (target.agents[name]?.prompt_append !== cfg.prompt_append) {
    target.agents[name] = { ...target.agents[name], prompt_append: cfg.prompt_append };
    changed++;
  }
}

if (changed === 0) {
  console.log("✓ prompt_append 已是最新，无需改动（幂等）。");
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
  console.log(`✓ 已合并 ${changed} 个 agent 的 prompt_append → ${TARGET}`);
  console.log("  提示：写回为标准 JSON；首行注释保留，其余行内注释会移除。");
}
