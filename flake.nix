{
  description = "A tmux-sessionizer inspired script using kitty and sway.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          kitty-swayssionizer =
            pkgs.writeShellApplication {
              name = "kitty-swayssionizer";
              runtimeInputs = with pkgs; [
                kitty
                tofi
                libnotify
              ];
              text = (builtins.readFile ./kitty-swayssionizer.sh);
            };
          default = kitty-swayssionizer;
        };
      }
    );
}
