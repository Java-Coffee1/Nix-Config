{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.mixxx
  ];
}