{
  description = "COLLADA Document Object Model (DOM) C++ Library";

  inputs.gepetto.url = "github:gepetto/nix";

  outputs =
    inputs:
    inputs.gepetto.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        overrideAttrs.collada-dom = {
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
      }
    );
}
