{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {nixpkgs, ...}: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed
      (system: function nixpkgs.legacyPackages.${system});
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          go-task
          bun
          flyctl
          alejandra
          #sqlite
          #corepack
          #deno
          #nodejs
        ];

        shellHook = ''
          echo "Welcome to the bun development environment!"
          echo "Bun: $(bun --version)"
          echo ""
        '';
      };
    });
  };
}
