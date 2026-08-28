{pkgs, ...}:

{
  imports = [
    ./hyprland.nix
    ./apps.nix
  ];
  environment.systemPackages = with pkgs; [
    # -- Core CLI tools --
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop
    fwupd
    ripgrep #find packages
    fastfetch
    unzip 
  ];
}