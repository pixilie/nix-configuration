{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = { addKeysToAgent = "yes"; };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github";
        identitiesOnly = true;
      };

      "*.epita.fr" = {
        identityFile = "~/.ssh/epita";
        identitiesOnly = true;
      };

    };
  };
}
