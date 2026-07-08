{
  description = "Blake West personal home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL must NOT follow our nixpkgs: its Nvidia driver derivation is built
    # against nixGL's own pinned nixpkgs. Forcing a current nixpkgs breaks with
    # "unexpected argument 'kernel'" because nvidia-x11/generic.nix was
    # refactored (libsOnly). nixGL injects host GL drivers, so its wrapper's
    # nixpkgs need not match ghostty's.
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      # Reusable, self-contained modules. The work flake consumes this via
      # personal.homeModules.default and layers its own work modules on top.
      homeModules.default = import ./modules/default.nix;

      homeConfigurations."bwest" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./hosts/bwest/home.nix
          ./modules/default.nix
        ];
      };
    };
}
