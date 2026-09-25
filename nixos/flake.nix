{
  description = "NixOS Flake Configuration with Home Manager and DMS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Strictly tracks the release branch for Hydra CI binary cache hits
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms.url = "github:AvengeMedia/DankMaterialShell/v1.6.2";
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, home-manager, dms, ... }@inputs: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ({ pkgs, ... }: {
          # Uses the exact nixpkgs revision to guarantee binary cache hits
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
        })

        dms.nixosModules.dank-material-shell

        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit inputs; };

          home-manager.users.shadrack = import ./home.nix;
        }
      ];
    };
  };
}
