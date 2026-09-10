{ ... }:

{
  # Cursor Agent CLI の statusLine 用スクリプト。
  # ccusage statusline は Claude Code 専用のため、Cursor CLI が渡す JSON payload から
  # ccusage 風の表示を自前で組み立てる。
  # ~/.cursor/cli-config.json 側で
  #   "statusLine": { "type": "command", "command": "~/.cursor/statusline.sh", "padding": 2 }
  # を指定する（先頭トークンだけ ~ 展開されるため bash 経由は使わない）。
  home.file.".cursor/statusline.sh" = {
    source = ../cursor/statusline.sh;
    executable = true;
  };
}
