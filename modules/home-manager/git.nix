{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gh-dash
    lazygit
    onefetch
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "Kristen Couty";
    userEmail = "kristen.couty@gmail.com";

    aliases = {
      ui = "!lazygit";

      lla = "log --graph --oneline --all";

      pu = "push";
      put = "push --follow-tags";
      puf = "push --force-with-lease";
      pl = "pull";
      st = "status";

      a = "add";
      aa = "add -A";

      cm = "commit --message";
      ca = "commit --amend";
    };

    ignores = [ ".direnv/" "result" ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;

      pull.rebase = true;
    };
    difftastic.enable = true;
  };

  programs.gh.enable = true;
}
