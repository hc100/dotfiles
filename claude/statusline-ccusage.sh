#!/usr/bin/env bash
# ccusage statusline 用ラッパー。
# Bedrock の application-inference-profile ARN はそのままだと視認性が悪いため、
# 人間可読なモデル名へ置換してから ccusage statusline に渡す。
# ccusage は model.id をそのまま表示名に使うので id（と display_name）を書き換える。
#
# ARN は秘匿値のため git 管理外の ~/.config/bedrock/env.sh が export する
# HAIKU_ARN / SONNET_ARN / OPUS_ARN と完全一致比較する（ID をこのスクリプトに埋め込まない）。
# 環境変数が無い（非 Bedrock 起動など）場合や一致しない場合は入力をそのまま通す。
set -uo pipefail

input="$(cat)"

mapped="$(printf '%s' "$input" | jq -c \
  --arg haiku  "${HAIKU_ARN:-}" \
  --arg sonnet "${SONNET_ARN:-}" \
  --arg opus   "${OPUS_ARN:-}" '
  (.model.id // .model.display_name // "") as $id
  | (if   $id != "" and $id == $opus   then "Opus"
     elif $id != "" and $id == $sonnet then "Sonnet"
     elif $id != "" and $id == $haiku  then "Haiku"
     else null end) as $name
  | if $name != null then .model.id = $name | .model.display_name = $name else . end
' 2>/dev/null)"

[ -n "$mapped" ] || mapped="$input"

printf '%s' "$mapped" | ccusage statusline
