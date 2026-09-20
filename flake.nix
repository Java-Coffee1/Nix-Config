{
  description = "NixOS configuration for javi's machines";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      treefmt-nix,
      agenix,
      ...
    }@inputs:
    let
      homeManagerModule = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.javi = import ./modules/home.nix;
          backupFileExtension = "backup";
        };
      };

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
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./modules/apps/treefmt.nix;
        in
        treefmtEval.config.build.wrapper // { inherit (treefmtEval) config; }
      );

      nixosConfigurations = {
        fw-nixos-btw = mkHost {
          name = "fw-nixos-btw";
          modules = [
            home-manager.nixosModules.home-manager
            homeManagerModule
          ];
        };

        homelab-nixos-btw = mkHost { name = "homelab-nixos-btw"; };

        pi = mkHost {
          name = "pi";
          system = "aarch64-linux";
          modules = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];
        };
      };
    };
}
