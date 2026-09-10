{ ... }:

{
  # GitHub Copilot CLI の statusLine 用スクリプト。
  # ccusage (Claude Code 用) は Copilot CLI のセッション形式に対応していないため、
  # Copilot CLI が渡す JSON payload から ccusage 風の表示を自前で組み立てる。
  # ~/.copilot/settings.json 側で
  #   "statusLine": { "type": "command", "command": "bash ~/.copilot/statusline.sh" }
  # を指定する（experimental: true も必要）。
  home.file.".copilot/statusline.sh" = {
    source = ../copilot/statusline.sh;
    executable = true;
  };
}
