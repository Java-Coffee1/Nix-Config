{ config, pkgs, lib, inputs, ... }:
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

  ############################################
  ## SSH
  ############################################

  environment.systemPackages = [
    inputs.agenix.packages."nixos-btw".default
  ];
  services.openssh.enable = true;

  # let 
  #   javi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
  #   userKeys = [ javi ];
  # in
  # {
  #   "secret1.age"
  # }
}