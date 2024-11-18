{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "Kristen Couty";
    userEmail = "kristen.couty@gmail.com";

    aliases = {
      ui = "lazygit";

      pu = "push";
      puf = "push --force-with-lease";
      pl = "pull";

      cm = "commit --message";
      ca = "commit --amend";
    };

    ignores = [
      # Nix build result
      "result"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;

      pull.rebase = true;
    };
  };

  programs.gh.enable = true;
}
