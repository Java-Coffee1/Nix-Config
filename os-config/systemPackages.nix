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
      ];
  };
in
{
  environment.systemPackages = with pkgs; [
    # -- Core CLI tools --
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop
    fwupd
    ripgrep #find packages
    fastfetch

    # -- KDE / Plasma integration --
    # kdePackages.kdbusaddons
    # kdePackages.qtstyleplugin-kvantum

    # -- Hyperland intergration --
    awww 
    zsh
    rofi #look things up 
    waybar
    swaynotificationcenter # Notification Daemom
    pipewire #audio Driver
    wireplumber #audio Driver

    kdePackages.qtwayland
    kdePackages.qtwayland
        
    kdePackages.dolphin #file manager
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum # home.nix is where its conf
    kitty
    playerctl
    swayosd
    cliphist
    wl-clipboard
    grim 
    slurp  

    # -- fonts -- 
    nerd-fonts.geist-mono

    # -- Communication --
    element-desktop
    (pkgs.discord.override {
      withOpenASAR = true;
    })
    slack

    # -- Media / Audio --
    ytmdesktop
    easyeffects
    orca-slicer

    # -- Development --
    vscode-configured
    docker
 ];
}
