{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, ... }@inputs: {
    # The hostname in your configuration is "nixos"
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Pass all flake inputs to your modules
      specialArgs = { inherit inputs; };

      modules = [
        ({ pkgs, ... }: {
          # Use the pinned overlay matching the exact nixpkgs revision to ensure binary cache hits
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
        })
        ./configuration.nix
      ];
    };
  };
}
