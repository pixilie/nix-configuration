{ self, inputs, ... }:
{

  flake.nixosModules.gns3 =
    { lib, pkgs, ... }:
    {
      users.groups.ubridge = { };

      security.wrappers.ubridge = {
        source = lib.getExe pkgs.ubridge;
        capabilities = "cap_net_raw,cap_net_admin=eip";
        owner = "root";
        group = "ubridge";
        permissions = "u=rwx,g=rx,o=r";
      };
    };

  flake.homeModules.gns3 =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        gns3-gui
        gns3-server
        dynamips
        inetutils
      ];

      home.activation.gns3DockerResources = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        dir="${config.xdg.dataHome}/GNS3/docker"
        if [ -d "$dir" ]; then
          run chmod -R u+w "$dir"
        fi
      '';
    };
}
