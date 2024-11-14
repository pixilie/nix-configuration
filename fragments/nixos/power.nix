{pkgs, ...}:

{
  services.poweralertd = {
    enable = true;
    extraArgs = [ "-s" "-S" ];
  };
}
