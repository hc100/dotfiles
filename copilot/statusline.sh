#!/usr/bin/env bash
# GitHub Copilot CLI 用のカスタム statusline スクリプト。
# ccusage (Claude Code 用) はセッション形式が異なるためそのまま流用できないので、
# ccusage 風の見た目（モデル名 / セッションコスト / コンテキスト使用率）を
# Copilot CLI が stdin 経由で渡す JSON payload から自前で組み立てる。
#
# 有効化方法: ~/.copilot/settings.json に以下を設定する。
#   {
#     "experimental": true,
#     "statusLine": { "type": "command", "command": "bash ~/.copilot/statusline.sh" }
#   }
set -uo pipefail

payload="$(cat)"

jq_value() {
  printf '%s' "$payload" | jq -r "$1" 2>/dev/null || true
}

is_number() {
  [[ "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

format_usd() {
  local amount="${1:-}"
  is_number "$amount" || { printf 'N/A'; return; }
  awk -v n="$amount" 'BEGIN {
    if (n > 0 && n < 0.01) { printf "$%.4f", n } else { printf "$%.2f", n }
  }'
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

# モデル名: 複数のフィールド候補を優先順に探す
model="$(jq_value '
  def text:
    if type == "object" then (.display_name // .displayName // .name // .id // empty)
    else tostring end;
  [
    .currentModel?, .cost.model?, .model?,
    .model.display_name?, .model.displayName?, .model.name?, .model.id?,
    .selectedModel?, .session.selectedModel?
  ]
  | map(select(. != null and . != ""))
  | first // "N/A"
  | text
')"

# セッションコスト(USD): 提供されていればそれを使用
session_cost_usd="$(jq_value '
  def as_num:
    if type == "number" then .
    elif type == "string" and test("^[0-9]+([.][0-9]+)?$") then tonumber
    else empty end;
  [
    .cost.total_cost_usd?, .cost.totalCostUsd?, .cost.total_usd?, .cost.totalUsd?,
    .cost.usd?, .cost.amount_usd?, .cost.amountUsd?,
    .usage.cost_usd?, .usage.costUsd?,
    .total_cost_usd?, .totalCostUsd?
  ]
  | map(as_num) | first // empty
')"

# コンテキストウィンドウ使用状況
current_context_tokens="$(jq_value '.context_window.current_context_tokens // .currentTokens // empty')"
displayed_context_limit="$(jq_value '.context_window.displayed_context_limit // .context_window.limit // .contextWindow.displayedContextLimit // empty')"
used_percentage="$(jq_value '.context_window.used_percentage // .contextWindow.usedPercentage // empty')"

parts=()
parts+=("🤖 ${model}")

if is_number "$session_cost_usd"; then
  parts+=("💰 $(format_usd "$session_cost_usd") session")
fi

if is_number "$current_context_tokens" && is_number "$displayed_context_limit"; then
  parts+=("🧠 $(format_tokens "$current_context_tokens")/$(format_tokens "$displayed_context_limit")")
elif is_number "$used_percentage"; then
  parts+=("🧠 ${used_percentage}%")
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
