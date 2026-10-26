{ lib, ... }:
let
  box = "u693820";
  hostname = "${box}.your-storagebox.de";
  port = 23;
in
{

  flake.nixosModules.storageBox = {
    services.gvfs.enable = true;

    programs.ssh.knownHosts.storageBox = {
      hostNames = [ "[${hostname}]:${toString port}" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };
  };

  flake.homeModules.storageBox = {
    programs.ssh.settings.storagebox = {
      inherit hostname port;
      user = box;
      identityFile = "~/.ssh/box_storage";
      identitiesOnly = true;
    };

    gtk.gtk3.bookmarks = lib.mkAfter [ "sftp://storagebox/home Storage Box" ];
  };
}
