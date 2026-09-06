{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };
}
