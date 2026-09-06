{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kvantum
    
  ];
}