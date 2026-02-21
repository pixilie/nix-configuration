{ pkgs, config, lib, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      key = "F89FAB6CA27348D0";
      signByDefault = true;
    };

    settings = {
      user.name = "Kristen Couty";
      user.email = "kristen.couty@gmail.com";

      alias = {
        ui = "!lazygit";
        ll = "log --graph --oneline";
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

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      gpg.format = "ssh";
      user.signingkey = "~/.ssh/github.pub";
      commit.gpgsign = true;
    };

    ignores = [ ".direnv/" "result" ];
  };

  programs.gh = {
    enable = true;
    extensions = lib.optionals (!config.isSchoolProfile) [ pkgs.gh-dash ];
  };

  programs.lazygit.enable = !config.isSchoolProfile;
  programs.difftastic.enable = !config.isSchoolProfile;

  home.packages =
    lib.optionals (!config.isSchoolProfile) (with pkgs; [ onefetch ]);

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };
}
