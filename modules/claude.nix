{ ... }:

{
  home.file.".claude/hooks/herdr-tab-title.sh" = {
    source = ../claude/hooks/herdr-tab-title.sh;
    executable = true;
  };

  # herdr の Claude セッション復元(claude --resume)に必要な integration hook。
  # SessionStart で session_id を herdr に報告し、再起動時の resume 参照を記録する。
  # 更新時は `herdr integration install claude` で再生成し本ファイルへ取り込む。
  home.file.".claude/hooks/herdr-agent-state.sh" = {
    source = ../claude/hooks/herdr-agent-state.sh;
    executable = true;
  };
}
