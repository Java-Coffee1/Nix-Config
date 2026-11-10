{
  description = "NixOS configuration for javi's machines";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # nixpkgs-unstable-outline.url = "nixpkgs/6774f7bc253789b113a4f39285dc0fa100abeacc"; # just a temp fix for outline, until it gets merged into nixpkgs-unstable
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      # desktop ui
      # url = "github:noctalia-dev/noctalia";
      url = "github:noctalia-dev/noctalia/cachix";
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
    pawprints-arcade = {
      url = "git+ssh://git@git.uninsane.org/java/pawprints-arcade.git";
      flake = false;
    };
    video-dl = {
      url = "git+ssh://git@git.uninsane.org/java/video-dl.git";
    };
    authentiknix = {
      url = "github:nix-community/authentik-nix";
    };
    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  }; # end of inputs

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

        fw-iso = mkHost {
          name = "fw-nixos-btw";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
          ];
        };

        homelab-nixos-btw = mkHost {
          name = "homelab-nixos-btw";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
          ];
        };
        linux-iso-btw = mkHost {
          name = "linux-iso-btw";
          modules = [
            inputs.hjem.nixosModules.default
            inputs.nixflix.nixosModules.default
            ./home/javi/home.nix
          ];
        };
        javi-email = mkHost {
          name = "javi-email";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
          ];
        };

        code-nixos-btw = mkHost {
          name = "code-nixos-btw";
          modules = [
            inputs.hjem.nixosModules.default
            ./home/javi/home.nix
          ];
        };
      };
    };
}
