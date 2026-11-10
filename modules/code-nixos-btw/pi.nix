{
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  environment.systemPackages = [ unstable.pi-coding-agent ];

  # where pi finds the llama.cpp server, put your llama VM's IP here
  environment.sessionVariables.LLAMA_BASE_URL = "http://127.0.0.1:8080";
}