{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];
  nixpkgs.config.qt5 = {
    enable = true;
    platformTheme = "qt5ct"; 
      style = {
        package = pkgs.utterly-nord-plasma;
        name = "Utterly Nord Plasma";
      };
  };

}