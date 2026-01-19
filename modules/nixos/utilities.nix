{ ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Riga";

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "monthly";
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
}
