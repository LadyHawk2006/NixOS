{
  description = "NixOS Flake Configuration with Home Manager and DMS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Add Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add DankMaterialShell repository
    dms.url = "github:AvengeMedia/DankMaterialShell/v1.6.2";
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, home-manager, dms, ... }@inputs: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Pass flake inputs to all modules
      specialArgs = { inherit inputs; };

      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
        })

        # Include DMS NixOS module for system-level services (like dms-greeter)
        dms.nixosModules.dank-material-shell

        ./configuration.nix

        # Set up Home Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };

          # Inline Home Manager configuration for your user
          home-manager.users.shadrack = { pkgs, inputs, ... }: {
            # Import the DMS Home Manager module
            imports = [ inputs.dms.homeModules.dank-material-shell ];

            home.stateVersion = "26.05";

            # Enable DankMaterialShell for the user
            programs.dank-material-shell = {
              enable = true;
            };
          };
        }
      ];
    };
  };
}
