{ ... }:
{

  flake.nixosModules.fingerprint =
    { pkgs, ... }:
    let
      libfprint = pkgs.libfprint.overrideAttrs (old: {
        version = "1.94.9-elanmoc2";
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "Depau";
          repo = "libfprint";
          rev = "11f0316d069cc90c154c8cb0e46478388c5e2a74";
          hash = "sha256-dxMls9Z5J9agesuNC46OoXAiYW/GcqWEEiAF7Y7DfwQ=";
        };
        patches = [ ./elanmoc2-wait-for-finger.patch ];
        nativeBuildInputs = old.nativeBuildInputs ++ old.nativeInstallCheckInputs;
        doInstallCheck = false;
      });
    in
    {
      services.fprintd = {
        enable = true;
        package = pkgs.fprintd.override { inherit libfprint; };
      };

      security.pam.services = {
        login.fprintAuth = false;
        sddm.fprintAuth = false;
        veila.fprintAuth = false;
        sshd.fprintAuth = false;
      };
    };
}
