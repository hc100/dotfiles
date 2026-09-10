#!/usr/bin/env bash
# Cursor Agent CLI 用のカスタム statusline スクリプト。
# ccusage statusline は Claude Code 専用のため、Cursor CLI が stdin 経由で渡す
# JSON payload から ccusage 風の表示（モデル / ディレクトリ / コンテキスト使用率）を組み立てる。
#
# 有効化方法: ~/.cursor/cli-config.json に以下を設定する。
#   {
#     "statusLine": {
#       "type": "command",
#       "command": "~/.cursor/statusline.sh",
#       "padding": 2
#     }
#   }
# 注意: Cursor は shell:false で spawn し、先頭トークンだけ ~ 展開する。
# 「bash ~/.cursor/statusline.sh」だと引数側の ~ が展開されず失敗する。
set -uo pipefail

payload="$(cat)"

jq_value() {
  printf '%s' "$payload" | jq -r "$1" 2>/dev/null || true
}

is_number() {
  [[ "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

format_tokens() {
  local tokens="${1:-}"
  is_number "$tokens" || { printf 'N/A'; return; }
  awk -v n="$tokens" 'BEGIN {
    if (n >= 1000000) { printf "%.1fM", n / 1000000 }
    else if (n >= 1000) { printf "%.1fk", n / 1000 }
    else { printf "%.0f", n }
  }'
}

context_bar() {
  local pct="${1:-0}"
  local width="${2:-10}"
  local filled empty bar

  is_number "$pct" || pct=0
  # 整数化（小数切り捨て）
  pct="$(awk -v n="$pct" 'BEGIN { printf "%d", n }')"
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100

  filled=$((pct * width / 100))
  empty=$((width - filled))
  bar=""
  if (( filled > 0 )); then
    printf -v fill "%${filled}s"
    bar="${fill// /▓}"
  fi
  if (( empty > 0 )); then
    printf -v pad "%${empty}s"
    bar="${bar}${pad// /░}"
  fi
  printf '%s' "$bar"
}

# モデル名 + パラメータ要約（Thinking など）+ max mode
model="$(jq_value '.model.display_name // .model.id // "N/A"')"
param_summary="$(jq_value '.model.param_summary // empty')"
max_mode="$(jq_value '.model.max_mode // false')"

model_label="$model"
if [[ -n "$param_summary" && "$param_summary" != "null" ]]; then
  model_label="${model_label} ${param_summary}"
fi
if [[ "$max_mode" == "true" ]]; then
  model_label="${model_label} MAX"
fi

# 作業ディレクトリ（末尾のディレクトリ名だけ）
cwd="$(jq_value '.workspace.current_dir // .cwd // empty')"
dir_name="?"
if [[ -n "$cwd" && "$cwd" != "null" ]]; then
  dir_name="${cwd##*/}"
fi

# worktree 名があれば併記
worktree="$(jq_value '.worktree.name // empty')"
if [[ -n "$worktree" && "$worktree" != "null" ]]; then
  dir_name="${dir_name} (${worktree})"
fi

# コンテキスト使用率
used_pct="$(jq_value '.context_window.used_percentage // empty')"
total_input="$(jq_value '.context_window.total_input_tokens // empty')"
window_size="$(jq_value '.context_window.context_window_size // empty')"

parts=()
parts+=("🤖 ${model_label}")
parts+=("📁 ${dir_name}")

if is_number "$used_pct"; then
  pct_int="$(awk -v n="$used_pct" 'BEGIN { printf "%d", n }')"
  bar="$(context_bar "$pct_int" 10)"
  if is_number "$total_input" && is_number "$window_size"; then
    parts+=("🧠 ${bar} ${pct_int}% ($(format_tokens "$total_input")/$(format_tokens "$window_size"))")
  else
    parts+=("🧠 ${bar} ${pct_int}%")
  fi
elif is_number "$total_input" && is_number "$window_size" && (( ${window_size%.*} > 0 )); then
  pct_int="$(awk -v u="$total_input" -v t="$window_size" 'BEGIN { printf "%d", (u / t) * 100 }')"
  bar="$(context_bar "$pct_int" 10)"
  parts+=("🧠 ${bar} ${pct_int}% ($(format_tokens "$total_input")/$(format_tokens "$window_size"))")
fi

# vim mode / autorun は有効時のみ
vim_mode="$(jq_value '.vim.mode // empty')"
if [[ -n "$vim_mode" && "$vim_mode" != "null" ]]; then
  parts+=("⌨ ${vim_mode}")
fi

autorun="$(jq_value '.autorun // false')"
if [[ "$autorun" == "true" ]]; then
  parts+=("⚡ autorun")
fi

join_by() {
  local sep="$1"
  shift
  local out="$1"
  shift
  for p in "$@"; do
    out+="${sep}${p}"
  done
  printf '%s\n' "$out"
}

join_by ' | ' "${parts[@]}"
