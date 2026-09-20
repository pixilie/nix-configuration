{ self, inputs, ... }:
{

  flake.homeModules.secrets =
    {
      config,
      lib,
      ...
    }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      options.secrets.identityFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.ssh/secret";
        description = ''
          Dedicated passphrase-less ed25519 ssh private key used as an age
          identity to decrypt the sops files of this profile
        '';
      };

      config.sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        age.sshKeyPaths = [ config.secrets.identityFile ];
      };
    };
}
