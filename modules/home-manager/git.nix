{ pkgs, config, lib, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

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
}
