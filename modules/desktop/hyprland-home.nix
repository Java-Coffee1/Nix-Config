{
  ## Hyprland configuration files
  home.file.".config/hypr/hyprland.lua".source = ./hyprland/hyprland.lua;
  home.file.".config/hypr/keybindings.lua".source = ./hyprland/keybindings.lua;
  home.file.".config/hypr/var.lua".source = ./hyprland/var.lua;

  home.file.".config/hypr/windows_and_workspaces.lua".source = ./hyprland/windows_and_workspaces.lua;
  home.file.".config/hypr/wallpaper1.png".source = ./wallpaper/wallpaper1.png;

  home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
  wayland.windowManager.hyprland.systemd.enable = false;

  home.file.".config/Kvantum".source = ./kvantum;

  # swayosd needs its own service for volume/brightness OSD popups
  services.swayosd.enable = true;

  ## widget config files
  # home.file.".config/ags/config.js".source = ./hyprland/ags/config.js;

  #noctalia
  # home.file. ".config/noctalia".source = ./hyprland/noctalia;
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";

    qt5ctSettings = {
      Appearance = {
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        custom_palette = false;
        standard_dialogs = "default";
      };
      Fonts = {
        general = ''"Noto Sans,12"'';
        fixed = ''"GeistMono Nerd Font Mono,12"'';
      };
    };

    qt6ctSettings = {
      Appearance = {
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        custom_palette = false;
        standard_dialogs = "default";
      };
      Fonts = {
        general = ''"Noto Sans,12"'';
        fixed = ''"GeistMono Nerd Font Mono,12"'';
      };
    };
  };
}
