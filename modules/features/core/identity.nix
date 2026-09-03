{ self, inputs, ... }:
{

  flake.homeModules.identity =
    { lib, config, ... }:
    {
      options.identity = {
        name = lib.mkOption {
          type = lib.types.str;
          example = "Kristen Couty";
          description = ''
            Full name recorded as the author of git commits.
          '';
        };

        email = lib.mkOption {
          type = lib.types.str;
          example = "kristen.couty@gmail.com";
          description = ''
            Email recorded as the author of git commits. Commit signatures are
            verified against this address, so it must match the entry generated
            in the allowed signers file.
          '';
        };

        signingKey = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/.ssh/github.pub";
          defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/.ssh/github.pub"'';
          example = lib.literalExpression ''"''${config.home.homeDirectory}/.ssh/epita.pub"'';
          description = ''
            SSH public key used to sign git commits. The matching private key
            must sit next to it, and the public key must be registered as a
            signing key on the forge the profile pushes to.
          '';
        };
      };
    };
}
