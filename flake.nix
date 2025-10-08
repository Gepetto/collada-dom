{
  description = "COLLADA Document Object Model (DOM) C++ Library";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          packages = {
            default = self'.packages.collada-dom;
            collada-dom = pkgs.collada-dom.overrideAttrs {
              src = lib.fileset.toSource {
                root = ./.;
                fileset = lib.fileset.unions [
                  ./cmake-modules
                  ./CMakeLists.txt
                  ./collada-dom-141.pc.in
                  ./collada-dom-150.pc.in
                  ./collada-dom.pc.in
                  ./collada_dom-config-version.cmake.in
                  ./collada_dom-config.cmake.in
                  ./description
                  ./dom
                  ./licenses
                  ./release
                ];
              };
            };
          };
        };
    };
}
