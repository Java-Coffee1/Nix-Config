{pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    # -- fonts -- 
    nerd-fonts.geist-mono
    # -- icons --
    tela-circle-icon-theme

  ];

}