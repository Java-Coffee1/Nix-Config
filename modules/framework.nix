{ config, pkgs, inputs, ... }:
{
   ############################################
   ## Framework 16 hardware
   ############################################

  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
  ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
  hardware.enableAllFirmware = true;

  ############################################
  ## Time & Locale
  ############################################

  time.timeZone = "America/Vancouver";

  services.displayManager.ly.enable = true;

  services.fprintd.enable = false;


}