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

  # Bedrock 用ラッパー。~/bin は home.sessionPath に含まれるため従来どおり claude-bedrock で起動できる。
  # ARN 等の秘匿値は git 管理外の ~/.config/bedrock/env.sh から読み込む(bedrock/env.sh.example 参照)。
  home.file."bin/claude-bedrock" = {
    source = ../bin/claude-bedrock;
    executable = true;
  };
}
