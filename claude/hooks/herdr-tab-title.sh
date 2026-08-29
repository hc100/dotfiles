#!/bin/sh
# UserPromptSubmit フック: プロンプト先頭を herdr のタブ名に反映する
set -u

# フック入力(JSON)は stdin で来る。ヒアドキュメントと競合するので先にファイルへ退避
hook_input_file="$(mktemp)" || exit 0
trap 'rm -f "$hook_input_file"' EXIT
cat >"$hook_input_file" 2>/dev/null || true

[ "${HERDR_ENV:-}" = "1" ] || exit 0   # herdr のペイン内でだけ動かす
command -v herdr >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HOOK_INPUT_FILE="$hook_input_file" python3 - <<'PY' >/dev/null 2>&1
import json, os, subprocess, sys

with open(os.environ["HOOK_INPUT_FILE"], encoding="utf-8") as fh:
    d = json.load(fh)
if d.get("agent_id"):  # サブエージェントのイベントは無視
    sys.exit(0)

prompt = " ".join(str(d.get("prompt") or "").split())
session_id = str(d.get("session_id") or "")

# transcript から2種類のタイトルを取得する。いずれも同一セッションの最新行を後勝ちで採用
#  - custom-title: /rename で設定した Session name(/status の「Session name」項目)
#  - ai-title:     Claude が会話ごとに自動生成する要約タイトル
custom_title = ""
ai_title = ""
transcript_path = str(d.get("transcript_path") or "")
if transcript_path and os.path.exists(transcript_path):
    try:
        with open(transcript_path, encoding="utf-8") as tf:
            for line in tf:
                line = line.strip()
                if not line:
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                if session_id and e.get("sessionId") != session_id:
                    continue
                t = e.get("type")
                if t == "custom-title" and e.get("customTitle"):
                    custom_title = str(e["customTitle"]).strip()
                elif t == "ai-title" and e.get("aiTitle"):
                    ai_title = str(e["aiTitle"]).strip()
    except Exception:
        pass

# タブ名: /rename の Session name を最優先。無ければ要約、最後にプロンプト先頭でフォールバック
if custom_title:
    title = custom_title
elif ai_title:
    title = ai_title
elif prompt:
    title = prompt[:19] + "…" if len(prompt) > 20 else prompt
else:
    sys.exit(0)

# 対象タブは herdr が各ペインに渡す環境変数 HERDR_TAB_ID から確実に特定する。
# フォーカス状態や別 space に依存せず、必ず自分のペインが属するタブを対象にできる
target = os.environ.get("HERDR_TAB_ID") or ""
if target:
    subprocess.run(["herdr", "tab", "rename", target, title],
                   capture_output=True, timeout=3)
PY
exit 0
