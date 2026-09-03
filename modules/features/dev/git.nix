{ self, inputs, ... }:
{

  flake.homeModules.git =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.identity) name email signingKey;
      allowedSigners = "${config.home.homeDirectory}/.ssh/allowed_signers";
    in
    {
      programs.git = {
        enable = true;
        lfs.enable = true;
        package = if config.isLightProfile then pkgs.gitMinimal else pkgs.git;

        settings = {
          user.name = name;
          user.email = email;

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
          gpg.ssh.allowedSignersFile = allowedSigners;
          user.signingkey = signingKey;
          commit.gpgsign = true;
        };

        ignores = [
          ".direnv/"
          "result"
        ];
      };

      programs.gh = {
        enable = true;
        extensions = lib.optionals (!config.isSchoolProfile) [ pkgs.gh-dash ];
      };

      programs.lazygit.enable = !config.isSchoolProfile;
      programs.difftastic.enable = !config.isSchoolProfile;

      home.packages =
        [ config.programs.gpg.package ]
        ++ lib.optionals (!config.isSchoolProfile) (with pkgs; [ onefetch ]);

      home.activation.gitAllowedSigners = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [ -r "${signingKey}" ]; then
          run ${pkgs.writeShellScript "git-allowed-signers" ''
            umask 077
            printf '%s %s\n' "${email}" "$(cat "${signingKey}")" > "${allowedSigners}"
          ''}
        fi
      '';

      services.gpg-agent = {
        enable = true;
        pinentry.package = if config.isSchoolProfile then pkgs.pinentry-curses else pkgs.pinentry-qt;
        defaultCacheTtl = 31536000;
        maxCacheTtl = 31536000;
      };
    };
}
