{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user.email = "kyoichi@gmail.com";
      push.default = "current";
      credential."https://github.com".helper = "!/opt/homebrew/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!/opt/homebrew/bin/gh auth git-credential";
    };
  };
}
