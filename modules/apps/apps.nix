############################################
## System Packages
############################################

# List packages installed in system profile.
# You can use https://search.nixos.org/ to find more packages (and options).
{ pkgs, ... }:

let
  vscode-configured = pkgs.vscode-with-extensions.override {
    vscodeExtensions =
      with pkgs.vscode-extensions;
      [
        jnoortheen.nix-ide
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
        {
          name = "hackatime-time-tracker";
          publisher = "hackatime";
          version = "30.2.2004";
          sha256 = "sha256-bX8egMLHdyUq6yWF+ta7jGMBu4NO3KFJtvaA9jfZc/0=";
        }
        {
          name = "remote-explorer";
          publisher = "ms-vscode";
          version = "0.6.2026031809";
          # sha256 = pkgs.lib.fakeSha256;
          sha256 = "sha256-WRg8ObPVQMluuCW/dBM2ibBDW/zc8cQQS5QQMfcpw2c=";
        }
      ];
  };
in
{
  environment.systemPackages = with pkgs; [
    # -- Communication --
    element-desktop
    (pkgs.discord.override { withOpenASAR = true; })
    slack

    # -- Media / Audio --
    ytmdesktop
    easyeffects
    orca-slicer

    # -- Development --
    vscode-configured
    # docker
  ];
  home-manager.users.javi.xdg.configFile."Code/User/settings.json".text = builtins.toJSON {
    "editor.fontSize" = 18;
    "editor.fontFamily" = "'GeistMono Nerd Font Mono', monospace";
    "terminal.integrated.fontSize" = 14;
    "window.zoomLevel" = 1;
  };
}
