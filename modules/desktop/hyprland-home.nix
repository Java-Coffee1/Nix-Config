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
    platformTheme.name = "qt6ct";
    style.name = "kvantum";

    qt5ctSettings = {
      Appearance = {
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        custom_palette = false;
        standard_dialogs = "default";
      };
    };

    qt6ctSettings = {
      Appearance = {
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        custom_palette = false;
        standard_dialogs = "default";
      };
    };
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia msg session lock";
        before_sleep_cmd = "noctalia msg session lock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
