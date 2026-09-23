{
  description = "NixOS configuration for javi's machines";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      # desktop ui
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wallpapers = {
      url = "git+ssh://git@github.com/Java-Coffee1/wallpaper.git";
      flake = false;
    };
    javamurraywebsite = {
      url = "git+ssh://git@github.com/Java-Coffee1/javamurraywebsite.git";
      flake = false;
    };
    government_crow_website = {
      url = "git+ssh://git@github.com/Java-Coffee1/government_crow_website.git";
      flake = false;
    };
    authentiknix = {
      url = "github:nix-community/authentik-nix";
    };
  };# end of inputs 

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      agenix,
      ...
    }@inputs:
    let
      mkHost =
        {
          name,
          system ? "x86_64-linux",
          modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${name}
            agenix.nixosModules.default
            { networking.hostName = name; }
          ]
          ++ modules;
        };
    in
    {
      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        treefmtEval.config.build.wrapper // { inherit (treefmtEval) config; }
      );

      nixosConfigurations = {
        fw-nixos-btw = mkHost {
          name = "fw-nixos-btw";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
          ];
        };

        homelab-nixos-btw = mkHost {
          name = "homelab-nixos-btw";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
          ];
        };
      };
    };
}
