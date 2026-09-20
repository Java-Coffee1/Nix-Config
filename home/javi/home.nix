{
  inputs,
  config,
  pkgs,
  ...
}:

{
  programs.bash.shellAliases = {
    btw = "echo I use nixos, btw";
  };
  programs.zsh.shellAliases = {
    s = "kitten ssh";
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  hjem.users.javi = {
    user = "javi";
    directory = "/home/javi";

    packages = [ pkgs.bibata-cursors ];

    files = {
      ## Hyprland configuration files
      ".config/hypr/hyprland.lua".source = ./dotfiles/hyprland/hyprland.lua;
      ".config/hypr/keybindings.lua".source = ./dotfiles/hyprland/keybindings.lua;
      ".config/hypr/var.lua".source = ./dotfiles/hyprland/var.lua;
      ".config/hypr/windows_and_workspaces.lua".source = ./dotfiles/hyprland/windows_and_workspaces.lua;

      ## Wallaper
      ".config/hypr/wallpaper1.png".source = inputs.wallpapers;
      "wallpapers".source = inputs.wallpapers;
      ## Kitty
      ".config/kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;

      ## Kvantum
      ".config/Kvantum".source = ./dotfiles/kvantum;

      ## cursor theme
      ".icons/default/index.theme".text = ''
        [Icon Theme]
        Name=Default
        Inherits=Bibata-Modern-Classic
      '';

      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name=Bibata-Modern-Classic
        gtk-cursor-theme-size=24
      '';

      ## qt theming
      ".config/qt5ct/qt5ct.conf" = {
        generator = (pkgs.formats.ini { }).generate "qt5ct.conf";
        value = {
          Appearance = {
            style = "kvantum";
            icon_theme = "Papirus-Dark";
            custom_palette = false;
            standard_dialogs = "default";
          };
        };
      };

      ".config/qt6ct/qt6ct.conf" = {
        generator = (pkgs.formats.ini { }).generate "qt6ct.conf";
        value = {
          Appearance = {
            style = "kvantum";
            icon_theme = "Papirus-Dark";
            custom_palette = false;
            standard_dialogs = "default";
          };
        };
      };

      ## hypridle
      ".config/hypr/hypridle.conf".text = ''
        general {
            lock_cmd = noctalia msg session lock
            before_sleep_cmd = noctalia msg session lock
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        listener {
            timeout = 600
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on
        }

        listener {
            timeout = 900
            on-timeout = systemctl suspend
        }
      '';
    };

    systemd.services.hypridle = {
      description = "Hypridle idle daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
      };
    };

    systemd.services.swayosd = {
      description = "Volume/backlight OSD indicator";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
        Restart = "on-failure";
      };
    };
  };
}
