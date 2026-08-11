{ self, inputs, ... }:
{

  flake.nixosModules.virtualisation =
    { ... }:
    {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
    };
}
